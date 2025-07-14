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

class _RiwayatAbsenScreenState extends State<RiwayatAbsenScreen> {
  List<HistoryData> _riwayat = [];
  bool _isLoading = true;
  String? selectedMonth;

  @override
  void initState() {
    super.initState();
    _fetchRiwayatAbsen();
  }

  Future<void> _fetchRiwayatAbsen() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      final result = await AbsenService.getRiwayatAbsen(token);

      setState(() {
        _riwayat = result;
        if (_riwayat.isNotEmpty) {
          selectedMonth = DateFormat('MMMM yyyy')
              .format(DateTime.parse(_riwayat.first.attendanceDate));
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal ambil riwayat: $e')),
      );
    }
  }

  List<String> getAvailableMonths() {
    final monthSet = <String>{};
    for (final h in _riwayat) {
      monthSet.add(DateFormat('MMMM yyyy')
          .format(DateTime.parse(h.attendanceDate)));
    }
    final sorted = monthSet.toList()
      ..sort((a, b) =>
          DateFormat('MMMM yyyy').parse(a).compareTo(DateFormat('MMMM yyyy').parse(b)));
    return sorted;
  }

  Widget _buildStats(List<HistoryData> list) {
    final hari = {
      for (var h in list)
        DateFormat('yyyy-MM-dd').format(DateTime.parse(h.attendanceDate))
    }.length;

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
          _statItem(Icons.calendar_today, '$hari Hari', 'Masuk'),
          _statItem(Icons.login, avgIn, 'Rata‑rata In'),
          _statItem(Icons.logout, avgOut, 'Rata‑rata Out'),
        ],
      ),
    );
  }

  Widget _statItem(IconData icon, String value, String label) => Column(
        children: [
          Icon(icon, size: 18, color: Colors.white),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      );

  Duration _stringToDuration(String hhmmss) {
    try {
      final parts = hhmmss.split(':').map(int.parse).toList();
      final h = parts.length > 0 ? parts[0] : 0;
      final m = parts.length > 1 ? parts[1] : 0;
      final s = parts.length > 2 ? parts[2] : 0;
      return Duration(hours: h, minutes: m, seconds: s);
    } catch (e) {
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
        title: const Text('Riwayat Kehadiran', style: TextStyle(color: Colors.white, fontFamily: 'Intern'),),
        centerTitle: true,
        backgroundColor: const Color(0xff08325b),
      ),
      backgroundColor: Color(0xff08325b),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchRiwayatAbsen,
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  const SizedBox(height: 12),
                  if (months.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: months.map((month) {
                          final isSelected = selectedMonth == month;
                          return ChoiceChip(
                            label: Text(month),
                            selected: isSelected,
                            selectedColor: Colors.white,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.black : const Color(0xff3d39c2),
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                            side: const BorderSide(color: Color(0xff3d39c2)),
                            onSelected: (_) =>
                                setState(() => selectedMonth = month),
                          );
                        }).toList(),
                      ),
                    ),
                  const SizedBox(height: 16),
                  if (filtered.isNotEmpty) _buildStats(filtered),
                  if (filtered.isNotEmpty) const SizedBox(height: 12),
                  ...filtered.map((absen) => _AttendanceCard(data: absen)),
                  if (filtered.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 40),
                      child: Center(
                          child: Text('Tidak ada data di bulan ini',
                              style: Theme.of(context).textTheme.bodyLarge)),
                    ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }
}

class _AttendanceCard extends StatelessWidget {
  final HistoryData data;
  const _AttendanceCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tanggal = DateTime.tryParse(data.attendanceDate) ?? DateTime.now();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6),
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
                      style: theme.textTheme.headlineSmall!
                          .copyWith(color: Colors.black)),
                  Text(DateFormat.EEEE().format(tanggal),
                      style: const TextStyle(fontSize: 12)),
                ],
              ),
            ),
            Container(width: 1, height: 80, color: Colors.white30),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _row('Check In', data.checkInTime),
                    const SizedBox(height: 8),
                    _row('Check Out', data.checkOutTime),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

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
