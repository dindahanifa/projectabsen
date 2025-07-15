import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:projectabsen/api/api_absen.dart';
import 'package:projectabsen/model/ajukanIzin_request.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AjukanIzinScreen extends StatefulWidget {
  const AjukanIzinScreen({super.key});

  @override
  State<AjukanIzinScreen> createState() => _AjukanIzinScreenState();
}

class _AjukanIzinScreenState extends State<AjukanIzinScreen> {
  final TextEditingController _alasanController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;
  String _token = '';

  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _token = prefs.getString('token') ?? '';
    });
  }

  Future<void> _submitIzin() async {
    if (_alasanController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Alasan tidak boleh kosong')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final izinRequest = AjukanIzinRequest(
        date: DateFormat('yyyy-MM-dd').format(_selectedDate),
        alasanIzin: _alasanController.text,
      );
      await AbsenService.ajukanIzin(izinRequest, _token);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Izin berhasil diajukan')),
        );
        Navigator.pop(context); // Kembali ke halaman sebelumnya
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengajukan izin: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ajukan Izin')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Tanggal Izin'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(_selectedDate)),
                      ),
                      IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: _selectDate,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text('Alasan Izin'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _alasanController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Tulis alasan izin...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.send),
                      label: const Text('Kirim Izin'),
                      onPressed: _submitIzin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  )
                ],
              ),
      ),
    );
  }
}
