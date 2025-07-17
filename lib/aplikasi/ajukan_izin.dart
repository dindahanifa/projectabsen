// Copyright (c) 2025 Dinda Hanifa. All rights reserved.

import 'package:flutter/material.dart';
import 'package:projectabsen/widgets/base_scaffold.dart';

class AjukanIzinScreen extends StatefulWidget {
  const AjukanIzinScreen({super.key});

  @override
  State<AjukanIzinScreen> createState() => _AjukanIzinScreenState();
}

class _AjukanIzinScreenState extends State<AjukanIzinScreen> {
  final TextEditingController _alasanController = TextEditingController();

  void _kirimIzin() {
    final alasan = _alasanController.text.trim();
    if (alasan.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Alasan tidak boleh kosong")),
      );
      return;
    }

    // Kirim ke API di sini (simulasi)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Izin berhasil diajukan")),
    );

    _alasanController.clear();
  }

  @override
  void dispose() {
    _alasanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: const Text('Ajukan Izin'),
      appBarColor: Color(0xFF0C1D40),
      titleColor: Colors.white,
      backgroundColor: const Color(0xFF0C1D40),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Alasan Izin",
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _alasanController,
              maxLines: 4,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Masukkan alasan izin...",
                hintStyle:TextStyle(color: Colors.white),
                border: OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _kirimIzin,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                child: const Text("Kirim Izin"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
