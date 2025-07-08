import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:projectabsen/api/api_absen.dart';
import 'package:projectabsen/model/absen_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  KehadiranModel? kehadiranToday;
  String username = "Nama Pengguna";
  String trainingId = "ID123456";
  String? profileImageUrl;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    try {
      final data = await absenService.getAbsenToday(token);
      setState(() {
        kehadiranToday = data;
        username = prefs.getString('username') ?? 'Nama Pengguna';
        trainingId = prefs.getString('training_id') ?? 'ID123456';
        profileImageUrl = prefs.getString('profile_image');
      });
    } catch (e) {
      print('Gagal ambil data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFEFEF),
      appBar: AppBar(
        title: const Text("Beranda"),
        backgroundColor: const Color(0xFF558B2F),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GestureDetector(
              onTap: () {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(builder: (_) => const EditProfilScreen()),
                // ).then((_) => loadData()); // Refresh setelah edit profil
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFDDEB9D),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundImage: profileImageUrl != null && profileImageUrl!.isNotEmpty
                          ? NetworkImage(profileImageUrl!)
                          : null,
                      child: profileImageUrl == null || profileImageUrl!.isEmpty
                          ? const Icon(Icons.person, size: 32)
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(username, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Text("Training ID: $trainingId", style: const TextStyle(fontSize: 14)),
                      ],
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
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [BoxShadow(blurRadius: 4, color: Colors.black12)],
              ),
              child: kehadiranToday == null
                  ? const Text("Belum ada data kehadiran hari ini.")
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Status: ${kehadiranToday!.checkIn.status.toUpperCase()}",
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 4),
                        Text("Lokasi: ${kehadiranToday!.checkIn.address}"),
                        if (kehadiranToday!.checkOut != null) ...[
                          const Divider(),
                          Text("Check Out: ${kehadiranToday!.checkOut!.address}"),
                        ],
                        if (kehadiranToday!.checkIn.status == 'izin' &&
                            kehadiranToday!.checkIn.alasanIzin != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text("Alasan: ${kehadiranToday!.checkIn.alasanIzin!}",
                                style: const TextStyle(color: Colors.red)),
                          ),
                      ],
                    ),
            ),

            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [BoxShadow(blurRadius: 4, color: Colors.black12)],
              ),
              child: TableCalendar(
                focusedDay: DateTime.now(),
                firstDay: DateTime.utc(2024, 1, 1),
                lastDay: DateTime.utc(2026, 12, 31),
                headerStyle: const HeaderStyle(formatButtonVisible: false, titleCentered: true),
                calendarStyle: const CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: Color(0xFF558B2F),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
