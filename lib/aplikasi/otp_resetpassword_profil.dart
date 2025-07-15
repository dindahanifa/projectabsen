import 'package:flutter/material.dart';
import 'package:projectabsen/model/reset_password.dart';
import 'package:projectabsen/api/api_user.dart'; 

class OtpResetpasswordProfil extends StatefulWidget {
  final String email;
  final String newPassword;

  const OtpResetpasswordProfil({
    super.key,
    required this.email,
    required this.newPassword,
  });

  @override
  State<OtpResetpasswordProfil> createState() => _OtpResetpasswordProfilState();
}

class _OtpResetpasswordProfilState extends State<OtpResetpasswordProfil> {
  final TextEditingController otpController = TextEditingController();
  bool _isLoading = false;

  Future<void> _submitOtp() async {
    final otp = otpController.text.trim();

    if (otp.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kode OTP wajib diisi')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final request = ResetPasswordRequest(
        email: widget.email,
        otp: otp,
        password: widget.newPassword,
      );
      Navigator.popUntil(context, (route) => route.isFirst); 
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal reset password: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enter your OTP code', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xff08325b),
        elevation: 0,
        leading: const BackButton(color: Colors.white),
      ),
      backgroundColor: Color(0xff08325b),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'We just sent you a message, please open it and enter the OTP code in that message below to identify your account.',
              style: TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            TextField(
              controller: otpController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              maxLength: 6,
              style: const TextStyle(fontSize: 24, letterSpacing: 8),
              decoration: const InputDecoration(
                counterText: '',
                border: UnderlineInputBorder(),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _isLoading ? null : _submitOtp,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Color(0xffFFCF50),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Submit OTP', style: TextStyle(color: Colors.white)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Change my phone number'),
            )
          ],
        ),
      ),
    );
  }
}
