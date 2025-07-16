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

      final userService = UserService();
      final response = await userService.resetPassword(request);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response.message ?? 'Password berhasil direset')),
      );

      Navigator.popUntil(context, (route) => route.isFirst);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal reset password: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C1D40),
      appBar: AppBar(
        title: const Text(
          'Masukkan Kode OTP',
          style: TextStyle(color: Colors.white, fontFamily: 'Intern'),
        ),
        backgroundColor: const Color(0xFF0C1D40),
        elevation: 0,
        leading: const BackButton(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Kami baru saja mengirimi Anda pesan. Silakan buka dan masukkan kode OTP tersebut di bawah ini untuk verifikasi akun Anda.',
              style: TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            TextField(
              controller: otpController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              maxLength: 6,
              style: const TextStyle(
                color: Color(0xFFFFCF50),
                fontSize: 24,
                letterSpacing: 8,
              ),
              cursorColor: Color(0xFFFFCF50),
              decoration: const InputDecoration(
                counterText: '',
                border: UnderlineInputBorder(),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.amber),
                ),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _isLoading ? null : _submitOtp,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: const Color(0xFFFFCF50),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'Submit OTP',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
