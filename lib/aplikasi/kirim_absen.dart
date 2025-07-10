import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:projectabsen/model/absen_model.dart';
import 'package:projectabsen/api/api_absen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class KirimAbsenScreen extends StatefulWidget {
  const KirimAbsenScreen({super.key});

  @override
  State<KirimAbsenScreen> createState() => _KirimAbsenScreenState();
}

class _KirimAbsenScreenState extends State<KirimAbsenScreen> {
  GoogleMapController? _mapController;
  LatLng? _currentPosition;
  String _currentAddress = "Memuat alamat...";
  AbsenModel? _todayAbsenData;
  List<AbsenModel> _attendanceHistory = [];
  bool _isLoading = true;
  bool _takePhoto = false;
  File? _pickedImage;
  String _userToken = '';

  @override
  void initState() {
    super.initState();
    _loadTokenAndInit();
  }

  Future<void> _loadTokenAndInit() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _userToken = prefs.getString('token') ?? '';

    if (_userToken.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Token tidak ditemukan. Harap login ulang.')),
        );
      }
      setState(() => _isLoading = false);
      return;
    }

    await _initializeData();
  }

  Future<void> _initializeData() async {
    setState(() => _isLoading = true);
    await _getCurrentLocation();
    await _fetchTodayAttendanceStatus();
    await _fetchAttendanceHistory();
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) throw 'Layanan lokasi dimatikan.';

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) throw 'Izin lokasi ditolak.';
      }

      if (permission == LocationPermission.deniedForever) {
        throw 'Izin lokasi ditolak permanen.';
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (mounted) {
        setState(() {
          _currentPosition = LatLng(position.latitude, position.longitude);
          _currentAddress = "Lat: ${position.latitude}, Lng: ${position.longitude}";
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal dapat lokasi: $e')),
        );
      }
    }
  }

  Future<void> _fetchTodayAttendanceStatus() async {
    try {
      final absen = await AbsenService.getAbsenToday(_userToken);
      if (mounted) setState(() => _todayAbsenData = absen);
    } catch (e) {
      if (mounted) {
        setState(() => _todayAbsenData = null);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal ambil status kehadiran: $e')),
        );
      }
    }
  }

  Future<void> _fetchAttendanceHistory() async {
    try {
      final history = await AbsenService.getRiwayatAbsen(_userToken);
      if (mounted) setState(() => _attendanceHistory = history);
    } catch (e) {
      if (mounted) {
        setState(() => _attendanceHistory = []);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal ambil riwayat kehadiran: $e')),
        );
      }
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.camera);
    if (picked != null) {
      if (mounted) {
        setState(() => _pickedImage = File(picked.path));
      }
    }
  }

  Future<void> _handleCheckIn() async {
    if (_currentPosition == null) return;
    if (_takePhoto && _pickedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mohon ambil foto terlebih dahulu.')),
      );
      return;
    }

    try {
      setState(() => _isLoading = true);

      final absen = AbsenModel(
        id: 0,
        userId: 0,
        status: 'hadir',
        checkInLat: _currentPosition!.latitude,
        checkInLng: _currentPosition!.longitude,
        checkInAddress: _currentAddress,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await AbsenService.checkIn(absen, _userToken, imageFile: _pickedImage);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Check-in berhasil')),
        );
        _pickedImage = null;
        await _initializeData();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Check-in gagal: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleCheckOut() async {
    if (_currentPosition == null || _todayAbsenData == null) return;

    try {
      setState(() => _isLoading = true);
      final absen = AbsenModel(
        id: _todayAbsenData!.id,
        userId: _todayAbsenData!.userId,
        status: 'hadir',
        checkOutLat: _currentPosition!.latitude,
        checkOutLng: _currentPosition!.longitude,
        checkOutAddress: _currentAddress,
        createdAt: _todayAbsenData!.createdAt,
        updatedAt: DateTime.now(),
      );
      await AbsenService.checkOut(absen, _userToken);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Check-out berhasil')),
        );
        await _initializeData();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Check-out gagal: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _showIzinDialog() async {
    String alasan = '';
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Ajukan Izin/Sakit'),
        content: TextField(
          onChanged: (val) => alasan = val,
          decoration: const InputDecoration(hintText: 'Tulis alasan izin/sakit'),
          maxLines: 3,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              if (alasan.isNotEmpty) {
                await _handleAjukanIzin(alasan);
              }
            },
            child: const Text('Kirim'),
          )
        ],
      ),
    );
  }

  Future<void> _handleAjukanIzin(String alasan) async {
    try {
      setState(() => _isLoading = true);
      final absen = AbsenModel(
        id: 0,
        userId: 0,
        status: 'izin',
        alasanIzin: alasan,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await AbsenService.ajukanIzin(absen, _userToken);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Izin berhasil diajukan')),
        );
        await _initializeData();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal ajukan izin: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isHadir = _todayAbsenData?.status == 'hadir';
    final isSudahCheckIn = isHadir && _todayAbsenData?.checkIn != null;
    final isBelumCheckOut = _todayAbsenData?.checkOut == null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kirim Absen'),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMap(),
                  const SizedBox(height: 16),
                  _buildStatus(),
                  const SizedBox(height: 16),
                  if (_takePhoto) _buildPhotoPreview(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Switch(
                        value: _takePhoto,
                        onChanged: (val) => setState(() {
                          _takePhoto = val;
                          if (!val) _pickedImage = null;
                        }),
                      ),
                      const Text('Ambil Foto'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_todayAbsenData == null || _todayAbsenData?.status == null)
                    _buildActionButton('Check In', _handleCheckIn, isPrimary: true),
                  if (isSudahCheckIn && isBelumCheckOut)
                    _buildActionButton('Check Out', _handleCheckOut),
                  if (_todayAbsenData == null || (_todayAbsenData!.status != 'hadir' && _todayAbsenData!.status != 'izin'))
                    _buildActionButton('Ajukan Izin/Sakit', _showIzinDialog, color: Colors.orange),
                ],
              ),
            ),
    );
  }

  Widget _buildMap() {
    return Container(
      height: 300,
      width: double.infinity,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), border: Border.all()),
      child: _currentPosition == null
          ? const Center(child: Text('Lokasi tidak tersedia'))
          : GoogleMap(
              initialCameraPosition: CameraPosition(target: _currentPosition!, zoom: 15),
              onMapCreated: (controller) {
                _mapController = controller;
                _mapController?.animateCamera(
                  CameraUpdate.newLatLngZoom(_currentPosition!, 15),
                );
              },
              markers: {
                Marker(markerId: const MarkerId('posisi'), position: _currentPosition!),
              },
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
            ),
    );
  }

  Widget _buildStatus() {
    final checkInTime = _todayAbsenData?.checkIn != null
        ? DateFormat('HH:mm').format(_todayAbsenData!.checkIn!)
        : '-';
    final checkOutTime = _todayAbsenData?.checkOut != null
        ? DateFormat('HH:mm').format(_todayAbsenData!.checkOut!)
        : '-';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Status: ${_todayAbsenData?.status ?? 'Belum Absen'}', style: const TextStyle(fontWeight: FontWeight.bold)),
        Text('Alamat: $_currentAddress'),
        if (_todayAbsenData != null && _todayAbsenData!.status == 'hadir') ...[
          Text('Check-in: $checkInTime'),
          Text('Check-out: $checkOutTime'),
        ]
      ],
    );
  }

  Widget _buildPhotoPreview() {
    return _pickedImage == null
        ? ElevatedButton.icon(
            onPressed: _pickImage,
            icon: const Icon(Icons.camera),
            label: const Text('Ambil Foto'),
          )
        : Stack(
            children: [
              Container(
                height: 150,
                width: 150,
                decoration: BoxDecoration(
                  border: Border.all(),
                  image: DecorationImage(
                    image: FileImage(_pickedImage!),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                right: 0,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.red),
                  onPressed: () => setState(() => _pickedImage = null),
                ),
              )
            ],
          );
  }

  Widget _buildActionButton(String label, VoidCallback onPressed,
      {bool isPrimary = false, Color? color}) {
    return SizedBox(
      width: double.infinity,
      child: isPrimary
          ? ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: color ?? const Color(0xFF213F85),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: Text(label),
            )
          : OutlinedButton(
              onPressed: onPressed,
              style: OutlinedButton.styleFrom(
                foregroundColor: color ?? const Color(0xFF213F85),
                side: BorderSide(color: color ?? const Color(0xFF213F85)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: Text(label),
            ),
    );
  }
}
