import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:projectabsen/api/api_user.dart';
import 'package:projectabsen/api/api_absen.dart';
import 'package:projectabsen/aplikasi/edit_profil_absen.dart';
import 'package:projectabsen/aplikasi/kirim_absen.dart';
import 'package:projectabsen/aplikasi/riwayat_absen.dart';
import 'package:projectabsen/model/absen_model.dart';

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
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const KirimAbsenScreen()));
        },
        backgroundColor: const Color(0xFF0C1D40),
        child: const Icon(Icons.add, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 6,
        height: 56,
        color: const Color(0xFFFFF1F2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: const Icon(Icons.home, size: 24),
              color: _selectedIndex == 0 ? Colors.blue : Colors.grey,
              onPressed: () => _onTabTapped(0),
            ),
            const SizedBox(width: 48),
            IconButton(
              icon: const Icon(Icons.history, size: 24),
              color: _selectedIndex == 1 ? Colors.blue : Colors.grey,
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
  AbsenModel? kehadiranToday;
  double? distanceFromPlace;
  final targetLat = -0.933094;
  final targetLng = 100.361142;

  Map<String, dynamic>? _userData;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    _loadAbsenToday();
    _calculateDistance();
  }

  Future<void> _loadUserProfile() async {
    try {
      final data = await userService.getProfile();
      final user = data['data'] ?? data;
      final prefs = await SharedPreferences.getInstance();
      final overridePhoto = prefs.getString('photo_override');
      print("👉 OVERRIDE PHOTO: $overridePhoto");

      print("➡️ FROM API: ${user['photo']}");
      print("➡️ OVERRIDE: $overridePhoto");


      if (!mounted) return;
      setState(() {
        _userData = user;
      });
    } catch (e) {
      debugPrint('Gagal load profil: $e');
    }
  }

  Future<void> _loadAbsenToday() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token != null) {
      try {
        final response = await AbsenService.getAbsenToday(token);
        if (!mounted) return;
        setState(() {
          kehadiranToday = response;
        });
      } catch (e) {
        debugPrint('Gagal load absen hari ini: $e');
      }
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
      if (!mounted) return;
      setState(() {
        distanceFromPlace = distanceInMeters;
      });
    } catch (e) {
      debugPrint('Gagal mendapatkan lokasi: $e');
    }
  }

  String _formatTime(DateTime time) {
    return "${time.hour.toString().padLeft(2, '0')} : ${time.minute.toString().padLeft(2, '0')} : ${time.second.toString().padLeft(2, '0')}";
  }

  String _formatDate(DateTime time) {
    return "${["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"][time.weekday % 7]}\n${time.day.toString().padLeft(2, '0')}-${time.month.toString().padLeft(2, '0')}-${time.year.toString().substring(2)}";
  }

  Future<void> _refreshAfterEdit() async {
    await _loadUserProfile();
    await _loadAbsenToday();
  }

  @override
  Widget build(BuildContext context) {
    if (_userData == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final user = _userData!;
    final name = user['name']?.toString() ?? 'Pengguna';
    final trainingName = user['training_title'] ?? 'Tidak ada pelatihan';
    final imageUrl = user['photo'];
    final imageUrlWithTimestamp = imageUrl != null && imageUrl.isNotEmpty
    ? "$imageUrl?ts=${DateTime.now().millisecondsSinceEpoch}"
    : null;

    return SingleChildScrollView(
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
                await _refreshAfterEdit();
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
                        Text(
                          name,
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        Text(
                          "Pelatihan: $trainingName",
                          style: const TextStyle(
                              fontSize: 14, color: Colors.white),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF80D0FF),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 8,
                      backgroundColor: Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        kehadiranToday?.checkInAddress ?? "Alamat tidak tersedia",
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF68BDFE),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            const Text("Check In",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500)),
                            const SizedBox(height: 4),
                            Text(
                              kehadiranToday?.checkIn != null
                                  ? _formatTime(kehadiranToday!.checkIn!)
                                  : "-",
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: 40,
                        width: 1,
                        color: Colors.white54,
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            const Text("Check Out",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500)),
                            const SizedBox(height: 4),
                            Text(
                              kehadiranToday?.checkOut != null
                                  ? _formatTime(kehadiranToday!.checkOut!)
                                  : "-",
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                if (distanceFromPlace != null)
                  Text(
                    "Jarak ke lokasi: ${distanceFromPlace!.toStringAsFixed(0)} meter",
                    style: const TextStyle(color: Colors.white),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text("Riwayat Kehadiran",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (kehadiranToday?.createdAt != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade200),
                borderRadius: BorderRadius.circular(16),
                color: Colors.white,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _formatDate(kehadiranToday!.createdAt!),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      const Text("Check In"),
                      Text(kehadiranToday?.checkIn != null
                          ? _formatTime(kehadiranToday!.checkIn!)
                          : "-")
                    ],
                  ),
                  Column(
                    children: [
                      const Text("Check Out"),
                      Text(kehadiranToday?.checkOut != null
                          ? _formatTime(kehadiranToday!.checkOut!)
                          : "-")
                    ],
                  )
                ],
              ),
            ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300)),
            child: TableCalendar(
              focusedDay: DateTime.now(),
              firstDay: DateTime.utc(2022, 01, 01),
              lastDay: DateTime.utc(2030, 12, 31),
              calendarFormat: CalendarFormat.month,
              headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }
}
