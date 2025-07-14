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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const KirimAbsenScreen()),
          );
        },
        backgroundColor: const Color(0xFFDDEB9D),
        child: const Icon(Icons.add, size: 28),
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

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  final UserService userService = UserService();
  Map<String, dynamic>? _userData;
  List<HistoryData> _riwayat = [];
  bool _isLoading = true;
  double? distanceFromPlace;
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

  Future<void> _fetchRiwayatAbsen() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      final result = await AbsenService.getRiwayatAbsen(token);
      setState(() {
        _riwayat = result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint('Gagal ambil riwayat: $e');
    }
  }

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

    final user = _userData!;
    final name = user['name']?.toString() ?? 'Pengguna';
    final trainingName = user['training_title'] ?? 'Tidak ada pelatihan';
    final imageUrl = user['profile_photo'];
    final imageUrlWithTimestamp = imageUrl != null && imageUrl.isNotEmpty
        ? "$imageUrl?ts=${DateTime.now().millisecondsSinceEpoch}"
        : null;

    return Container(
      color: const Color(0xff08325b),
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
            const SizedBox(height: 24),
            const Text("Riwayat Kehadiran", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 8),
            if (_riwayat.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade200),
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.white,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _riwayat.first.attendanceDate != null
                          ? _formatDate(_riwayat.first.attendanceDate!)
                          : '-',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    _row('Check In', _riwayat.first.checkInTime ?? '-'),
                    const SizedBox(height: 8),
                    _row('Check Out', _riwayat.first.checkOutTime ?? '-'),
                  ],
                ),
              )
            else
              const Text("Belum ada riwayat absen", style: TextStyle(color: Colors.white)),
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
