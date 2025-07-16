import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:projectabsen/api/api_absen.dart';
import 'package:projectabsen/api/api_user.dart';
import 'package:projectabsen/aplikasi/edit_profil_absen.dart';
import 'package:projectabsen/aplikasi/kirim_absen.dart';
import 'package:projectabsen/aplikasi/riwayat_absen.dart';
import 'package:projectabsen/model/history_response.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  
  // untuk tombol buttom navigator

  int _selectedIndex = 0;

  void _onTabTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  static const List<Widget> _widgetOptions = <Widget>[
    HomeContent(),
    RiwayatAbsenScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _widgetOptions[_selectedIndex],
      floatingActionButton: SizedBox(
        width: 60,
        height: 60,
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const KirimAbsenScreen()),
            );
          },
          backgroundColor: const Color(0xFFDDEB9D),
          shape: const CircleBorder(),
          child: const Icon(Icons.add, size: 28),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 6,
        height: 56,
        color: const Color(0xFFFFCF50),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: const Icon(Icons.home),
              color: _selectedIndex == 0 ? Colors.black : Colors.grey,
              onPressed: () => _onTabTapped(0),
            ),
            const SizedBox(width: 48),
            IconButton(
              icon: const Icon(Icons.history),
              color: _selectedIndex == 1 ? Colors.black : Colors.grey,
              onPressed: () => _onTabTapped(1),
            ),
          ],
        ),
      ),
    );
  }
}

// Isi dalam halaman pertama

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  final UserService userService = UserService();
  Map<String, dynamic>? _userData; // mengambil data user
  List<HistoryData> _riwayat = []; // mengambil data absen
  bool _isLoading = true;
  double? distanceFromPlace; //untuk lokasi
  String? currentAddress;

  final targetLat = -0.933094;
  final targetLng = 100.361142;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    _fetchRiwayatAbsen();
    _calculateDistance();
  }

  // mengambil data user untuk profil

  Future<void> _loadUserProfile() async {
    try {
      final data = await userService.getProfile();
      final user = data['data'] ?? data;
      setState(() {
        _userData = user;
      });
    } catch (e) {
      debugPrint('Gagal load profil: $e');
    }
  }

  // mengambil data absen

  Future<void> _fetchRiwayatAbsen() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      final result = await AbsenService.getRiwayatAbsen(token);
      result.sort((a, b) => b.attendanceDate!.compareTo(a.attendanceDate!));
      setState(() {
        _riwayat = result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint('Gagal ambil riwayat: $e');
    }
  }

  // menghitung jarak lokasi

  Future<void> _calculateDistance() async {
    try {
      Position position = await Geolocator.getCurrentPosition();
      double distanceInMeters = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        targetLat,
        targetLng,
      );
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);
      Placemark place = placemarks.first;
      setState(() {
        distanceFromPlace = distanceInMeters;
        currentAddress =
            "${place.street}, ${place.subLocality}, ${place.locality}, ${place.subAdministrativeArea}, ${place.postalCode}";
      });
    } catch (e) {
      debugPrint('Gagal mendapatkan lokasi: $e');
    }
  }

  // Data waktu 

  String _formatDate(String dateString) {
    final date = DateTime.tryParse(dateString);
    if (date == null) return '-';
    final weekdays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return "${weekdays[date.weekday % 7]}, ${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year.toString().substring(2)}";
  }

  Widget _row(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        Text(value),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_userData == null || _isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // data profil

    final user = _userData!;
    final name = user['name']?.toString() ?? 'Pengguna';
    final trainingName = user['training_title'] ?? 'Tidak ada pelatihan';
    final imageUrl = user['profile_photo_url'] ?? '';
    final imageUrlWithTimestamp = imageUrl.isNotEmpty
        ? "$imageUrl?ts=${DateTime.now().millisecondsSinceEpoch}"
        : null;

    return Container(
      color: const Color(0xFF0C1D40),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 32),
            GestureDetector(
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const EditProfilScreen()),
                );
                if (result == true) {
                  await _loadUserProfile();
                }
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  image: const DecorationImage(
                    image: AssetImage('assets/image/card.png'),
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: Colors.grey.shade200,
                      backgroundImage: imageUrlWithTimestamp != null
                          ? NetworkImage(imageUrlWithTimestamp)
                          : null,
                      child: imageUrlWithTimestamp == null
                          ? const Icon(Icons.person, color: Colors.grey)
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
                          Text("Pelatihan: $trainingName", style: const TextStyle(fontSize: 14, color: Colors.black)),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),

            // jarak lokasi
            const SizedBox(height: 24),
            if (distanceFromPlace != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFCF50),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Lokasi Anda: $currentAddress", style: const TextStyle(color: Colors.black)),
                    const SizedBox(height: 8),
                    Text("Jarak ke lokasi: ${distanceFromPlace!.toStringAsFixed(0)} meter", style: const TextStyle(color: Colors.black)),
                  ],
                ),
              ),

              // riwayat kehadiran
            const SizedBox(height: 24),
            const Text("Riwayat Kehadiran", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 8),
            Builder(
              builder: (_) {
                final today = DateTime.now();
                final todayStr = "${today.year.toString().padLeft(4, '0')}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";

                final hariIni = _riwayat.firstWhere(
                  (e) => e.attendanceDate == todayStr,
                  orElse:() => HistoryData(
                    id: 0, 
                    attendanceDate: todayStr, 
                    status: 'Belum Absen'),
                );
                return SizedBox(
                  width: double.infinity,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey.shade200),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _formatDate(hariIni.attendanceDate ?? todayStr),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        if (hariIni.alasanIzin != null && hariIni.alasanIzin!.isNotEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Status: Izin", style: TextStyle(color: Colors.red)),
                              const SizedBox(height: 4),
                              Text("Alasan: ${hariIni.alasanIzin!}"),
                            ],
                          )
                        else if ((hariIni.checkInTime != null && hariIni.checkInTime != '-') ||
                                 (hariIni.checkOutTime != null && hariIni.checkOutTime != '-'))
                          Column(
                            children: [
                              _row('Check In', hariIni.checkInTime ?? '-'),
                              const SizedBox(height: 4),
                              _row('Check Out', hariIni.checkOutTime ?? '-'),
                            ],
                          )
                        else
                          const Text("Status: Belum Absen", style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                );
              },
            ),

            // Kalender
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: TableCalendar(
                focusedDay: DateTime.now(),
                firstDay: DateTime.utc(2022, 01, 01),
                lastDay: DateTime.utc(2030, 12, 31),
                calendarFormat: CalendarFormat.month,
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                  leftChevronIcon: Icon(Icons.chevron_left, color: Colors.white),
                  rightChevronIcon: Icon(Icons.chevron_right, color: Colors.white),
                ),
                daysOfWeekStyle: const DaysOfWeekStyle(
                  weekdayStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                  weekendStyle: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w500),
                ),
                calendarStyle: const CalendarStyle(
                  defaultTextStyle: TextStyle(color: Colors.white),
                  weekendTextStyle: TextStyle(color: Colors.redAccent),
                  todayDecoration: BoxDecoration(
                    color: Color(0xFFDDEB9D),
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: Color(0xFF0C1D40),
                    shape: BoxShape.circle,
                  ),
                  outsideTextStyle: TextStyle(color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }
}
