import 'package:flutter/material.dart';

class RiwayatAbsenScreen extends StatelessWidget {
  const RiwayatAbsenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Riwayat Absen")),
      body: const Center(
        child: Text("Ini halaman riwayat absen."),
      ),
    );
  }
}
