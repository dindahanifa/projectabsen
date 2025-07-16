import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:projectabsen/api/api_absen.dart';
import 'package:projectabsen/model/history_response.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RiwayatAbsenScreen extends StatefulWidget {
  const RiwayatAbsenScreen({super.key});

  @override
  State<RiwayatAbsenScreen> createState() => _RiwayatAbsenScreenState();
}

// menampilkan riwayat absen

class _RiwayatAbsenScreenState extends State<RiwayatAbsenScreen> {
  // untuk menyimpan riwayat absen
  List<HistoryData> _riwayat = [];
  bool _isLoading = true;
  String? selectedMonth;

  // untuk menginalisasi data awal

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    selectedMonth = DateFormat('MMMM yyyy').format(now);
    _fetchRiwayatAbsen();
  }

  // untuk mengambil riwayat absen dari API

  Future<void> _fetchRiwayatAbsen() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      final result = await AbsenService.getRiwayatAbsen(token);
      if (!mounted) return;
      setState(() {
        _riwayat = result;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal ambil riwayat: $e')),
      );
    }
  }

  // untuk memndapatkan daftar bulan yang tersedia

  List<String> getAvailableMonths() {
    final now = DateTime.now();
    final year = now.year;
    return List.generate(12, (index) {
      final date = DateTime(year, index + 1, 1);
      return DateFormat('MMMM yyyy').format(date);
    });
  }

  // untuk memangun wiudget statistik

  Widget _buildStats(List<HistoryData> list) {

    // menghitung jumlah masuk dan izin
    final masukCount = list.where((e) => e.status == 'hadir').length;
    final izinCount = list.where((e) => e.status == 'izin').length;

    Duration _avg(List<String> times) {
      if (times.isEmpty) return Duration.zero;
      final totalSeconds = times
          .map(_stringToDuration)
          .fold(0, (sum, d) => sum + d.inSeconds);
      return Duration(seconds: totalSeconds ~/ times.length);
    }

    final avgIn = _formatDuration(
        _avg(list.where((e) => e.checkInTime != null).map((e) => e.checkInTime!).toList()));
    final avgOut = _formatDuration(
        _avg(list.where((e) => e.checkOutTime != null).map((e) => e.checkOutTime!).toList()));

        // untuk menampilkan statistik kehadiran

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xffFFCF50),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _statItem(Icons.check_circle, '$masukCount Hari', 'Hadir'),
          _statItem(Icons.event_busy, '$izinCount Hari', 'Izin'),
          _statItem(Icons.login, avgIn, 'Rata‑rata In'),
          _statItem(Icons.logout, avgOut, 'Rata‑rata Out'),
        ],
      ),
    );
  }

  // untuk menampilkan item statistik

  Widget _statItem(IconData icon, String value, String label) => Column(
        children: [
          Icon(icon, size: 18, color: Colors.white),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      );

  // untuk mengonversi string ke duration

  Duration _stringToDuration(String hhmmss) {
    try {
      final parts = hhmmss.split(':').map(int.parse).toList();
      return Duration(
        hours: parts[0],
        minutes: parts[1],
        seconds: parts[2],
      );
    } catch (_) {
      return Duration.zero;
    }
  }

  String _formatDuration(Duration d) =>
      d == Duration.zero ? '-' : d.toString().substring(0, 8);

  @override
  Widget build(BuildContext context) {
    final months = getAvailableMonths();

    final filtered = _riwayat.where((h) {
      return selectedMonth == null
          ? true
          : DateFormat('MMMM yyyy')
              .format(DateTime.parse(h.attendanceDate)) == selectedMonth;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Riwayat Kehadiran',
            style: TextStyle(color: Colors.white, fontFamily: 'Intern')),
        centerTitle: true,
        backgroundColor: const Color(0xFF0C1D40),
      ),
      backgroundColor: const Color(0xFF0C1D40),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchRiwayatAbsen,
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  const SizedBox(height: 12),
                  Container(
                    height: 48,
                    margin: const EdgeInsets.only(left: 16),
                    // untuk memilih bulan
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: months.map((month) {
                          final isSelected = selectedMonth == month;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: ChoiceChip(
                              label: Text(month),
                              selected: isSelected,
                              selectedColor: Colors.white,
                              labelStyle: TextStyle(
                                color: isSelected
                                    ? Colors.black
                                    : const Color(0XFFFFCF50),
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                              side: const BorderSide(color: Color(0XFFFFCF50)),
                              onSelected: (_) =>
                                  setState(() => selectedMonth = month),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  // untuk menampilkan statistik
                  const SizedBox(height: 16),
                  if (filtered.isNotEmpty) _buildStats(filtered),
                  if (filtered.isNotEmpty) const SizedBox(height: 12),
                  ...filtered.map(
                    (absen) => _AttendanceCard(
                      data: absen,
                      onDelete: _fetchRiwayatAbsen,
                    ),
                  ),
                  if (filtered.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 40),
                      child: Center(
                          child: Text('Tidak ada data di bulan ini',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(color: Colors.white))),
                    ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }
}
class _AttendanceCard extends StatefulWidget {
  final HistoryData data;
  final VoidCallback onDelete;

  const _AttendanceCard({required this.data, required this.onDelete});

  @override
  State<_AttendanceCard> createState() => _AttendanceCardState();
}
// delete absen
class _AttendanceCardState extends State<_AttendanceCard> {
  bool _deleting = false;

  Future<void> _confirmDelete(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Absen'),
        content: const Text('Yakin ingin menghapus data absen ini?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Hapus')),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _deleting = true);
      try {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('token') ?? '';
        await AbsenService.deleteAbsen(widget.data.id, token);
        if (!mounted) return;
        setState(() => _deleting = false);
        widget.onDelete();
      } catch (e) {
        if (!mounted) return;
        setState(() => _deleting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menghapus data absen: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tanggal = DateTime.tryParse(widget.data.attendanceDate) ?? DateTime.now();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6),
      // untuk menampilkan data absen
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xffDDEB9D),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              width: 70,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(DateFormat.d().format(tanggal),
                      style: Theme.of(context).textTheme.headlineSmall!.copyWith(color: Colors.black)),
                  Text(DateFormat.EEEE().format(tanggal),
                      style: const TextStyle(fontSize: 12)),
                ],
              ),
            ),
            Container(width: 1, height: 100, color: Colors.white30),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _row('Check In', widget.data.checkInTime),
                    const SizedBox(height: 8),
                    _row('Check Out', widget.data.checkOutTime),
                    const SizedBox(height: 8),
                    Text('Status: ${widget.data.status ?? '-'}',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    if (widget.data.status == 'izin' && widget.data.alasanIzin != null)
                      Text('Alasan: ${widget.data.alasanIzin}',
                          style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
                    Align(
                      alignment: Alignment.centerRight,
                      child: _deleting
                          ? const CircularProgressIndicator(strokeWidth: 2)
                          : IconButton(
                              icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                              onPressed: () => _confirmDelete(context),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  // untuk menampilkan baris data
  Widget _row(String label, String? value) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13)),
          Row(
            children: [
              const Icon(Icons.access_time, size: 14),
              const SizedBox(width: 4),
              Text(value ?? '-', style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      );
}
