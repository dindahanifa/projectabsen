import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:projectabsen/aplikasi/reset_passord_user.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String email;

  const OtpVerificationScreen({super.key, required this.email});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final TextEditingController _otpController = TextEditingController();
  bool isSubmitting = false;
  bool isOtpValidLength = false;

  @override
  void initState() {
    super.initState();
    _otpController.addListener(_onOtpChanged);
  }

  void _onOtpChanged() {
    if (!mounted) return;
    setState(() {
      isOtpValidLength = _otpController.text.trim().length == 6;
    });
  }

  Future<void> _submitOtp() async {
    final enteredOtp = _otpController.text.trim();
    if (enteredOtp.length != 6) return;

    setState(() => isSubmitting = true);
    FocusScope.of(context).unfocus();

    try {
      await Future.delayed(const Duration(milliseconds: 300));

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ResetPasswordScreen(
            email: widget.email,
            otp: enteredOtp,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Verifikasi OTP gagal: $e")),
      );
    } finally {
      if (mounted) setState(() => isSubmitting = false);
    }
  }

  @override
  void dispose() {
    _otpController.dispose(); // penting!
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C1D40),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Masukan kode OTP anda',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Kami baru saja mengirimkan kode OTP ke email Anda.\nSilakan masukkan 6 digit kode tersebut di bawah ini.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 32),
              PinCodeTextField(
                appContext: context,
                length: 6,
                controller: _otpController,
                animationType: AnimationType.fade,
                keyboardType: TextInputType.number,
                textStyle: const TextStyle(color: Colors.white),
                pinTheme: PinTheme(
                  shape: PinCodeFieldShape.underline,
                  fieldHeight: 50,
                  fieldWidth: 40,
                  inactiveColor: Colors.white,
                  activeColor: Colors.white,
                  selectedColor: Color(0xFFFFCF50),
                ),
                onChanged: (_) {},
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      isOtpValidLength && !isSubmitting ? _submitOtp : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFCF50),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: isSubmitting
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text(
                          'Kirim OTP',
                          style: TextStyle(color: Colors.white),
                        ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                '© 2025 Dinda Hanifa',
                style: TextStyle(color: Colors.white60, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
