import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:projectabsen/api/api_absen.dart';
import 'package:projectabsen/model/absen_co_request.dart';
import 'package:projectabsen/model/absen_model.dart';
import 'package:projectabsen/model/absen_request.dart';
import 'package:projectabsen/model/absen_today.dart';
import 'package:projectabsen/model/ajukanIzin_request.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:geocoding/geocoding.dart';

class KirimAbsenScreen extends StatefulWidget {
  const KirimAbsenScreen({super.key});

  @override
  State<KirimAbsenScreen> createState() => _KirimAbsenScreenState();
}

class _KirimAbsenScreenState extends State<KirimAbsenScreen> {
  GoogleMapController? _mapController;
  LatLng? _currentPosition;
  String _currentAddress = "Memuat lokasi...";
  AbsenToday? _todayAbsenData;
  bool _isLoading = true;
  String _userToken = '';
  String _currentTime = DateFormat('HH:mm:ss').format(DateTime.now());
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadTokenAndInit();
    _startClock();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startClock() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _currentTime = DateFormat('HH:mm:ss').format(DateTime.now());
      });
    });
  }

  Future<void> _loadTokenAndInit() async {
    final prefs = await SharedPreferences.getInstance();
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
      print("Absen hari ini: ${_todayAbsenData}");

    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) throw 'Layanan lokasi tidak aktif';

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) throw 'Izin lokasi ditolak';
      }
      if (permission == LocationPermission.deniedForever) {
        throw 'Izin lokasi ditolak permanen';
      }

      final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      final placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      final place = placemarks.first;

      if (mounted) {
        setState(() {
          _currentPosition = LatLng(position.latitude, position.longitude);
          _currentAddress = "${place.street}, ${place.locality}";
        });
      }
    } catch (e) {
      if (mounted) setState(() => _currentAddress = 'Gagal dapat lokasi: $e');
    }
  }

  Future<void> _fetchTodayAttendanceStatus() async {
    try {
      final absen = await AbsenService.getAbsenToday(_userToken);
      print("Absen hari ini: ${_todayAbsenData}");
      if (mounted) setState(() => _todayAbsenData = absen);
    } catch (e) {
      if (mounted) setState(() => _todayAbsenData = null);
    }
  }

  Future<void> _handleCheckIn() async {
    if (_currentPosition == null) return;
    try {
      setState(() => _isLoading = true);
      final absen = AbsenRequest(
        status: 'masuk',
        checkInLat: _currentPosition!.latitude,
        checkInLng: _currentPosition!.longitude,
        checkInAddress: _currentAddress,
        attendanceDate: DateFormat('yyyy-MM-dd').format(DateTime.now()),
        checkIn: DateFormat('HH:mm').format(DateTime.now()),
      );
      await AbsenService.checkIn(absen, _userToken);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Check-in berhasil')),
        );
        await _initializeData();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal check-in: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleCheckOut() async {
    try {
      setState(() => _isLoading = true);
      final absen = AbsenCoRequest(
        checkOutLat: _currentPosition!.latitude.toString(),
        checkOutLng: _currentPosition!.longitude.toString(),
        checkOutAddress: _currentAddress,
        attendanceDate: DateFormat('yyyy-MM-dd').format(DateTime.now()),
        checkOut: DateFormat('HH:mm').format(DateTime.now()),
        checkOutLocation: "${_currentPosition!.latitude}, ${_currentPosition!.longitude}",
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
        SnackBar(content: Text('Gagal check-out: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleAjukanIzin() async {
    try {
      setState(() => _isLoading = true);
      final izin = AjukanIzinRequest(
        date: DateFormat('yyyy-MM-dd').format(DateTime.now()),
        alasanIzin: 'Sakit',
      );
      await AbsenService.ajukanIzin(izin, _userToken);
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
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                Positioned.fill(
                  child: _currentPosition == null
                      ? const Center(child: Text('Lokasi tidak tersedia'))
                      : GoogleMap(
                          initialCameraPosition: CameraPosition(
                            target: _currentPosition!,
                            zoom: 17,
                          ),
                          markers: {
                            Marker(
                              markerId: const MarkerId('lokasi'),
                              position: _currentPosition!,
                            ),
                          },
                          onMapCreated: (controller) => _mapController = controller,
                          myLocationEnabled: true,
                          myLocationButtonEnabled: false,
                        ),
                ),
                Positioned(
                  top: 50,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Text(
                      _currentTime,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4)),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text("📍 Lokasi Anda", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        const SizedBox(height: 6),
                        Text(_currentAddress, style: const TextStyle(fontSize: 14)),
                        const SizedBox(height: 12),
                        Text(
                          "Status: ${_todayAbsenData?.status =="masuk"?"Sudah Check In" :'Belum Check In'?? 'Belum Check In'}",
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _todayAbsenData?.checkInTime == null ? _handleCheckIn : null,
                          icon: const Icon(Icons.login),
                          label: const Text("Check In"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            minimumSize: const Size.fromHeight(45),
                          ),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton.icon(
                          onPressed: _todayAbsenData?.checkOutTime == null &&
                                  _todayAbsenData?.checkInTime != null
                              ? _handleCheckOut
                              : null,
                          icon: const Icon(Icons.logout),
                          label: const Text("Check Out"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            minimumSize: const Size.fromHeight(45),
                          ),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton.icon(
                          onPressed: _handleAjukanIzin,
                          icon: const Icon(Icons.event_busy),
                          label: const Text("Ajukan Izin"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            minimumSize: const Size.fromHeight(45),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
