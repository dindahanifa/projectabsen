import 'package:flutter/material.dart';
import 'package:projectabsen/aplikasi/otp_resetpassword_profil.dart';
import 'package:projectabsen/api/api_user.dart';
import 'package:projectabsen/model/reset_password.dart';

class ResetPasswordProfil extends StatefulWidget {
  // untuk mengirim password baru
  const ResetPasswordProfil({super.key});

  @override
  State<ResetPasswordProfil> createState() => _ResetPasswordProfilState();
}

// untuk menangani reset password
class _ResetPasswordProfilState extends State<ResetPasswordProfil> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  bool _obscureText = true;
  bool _isLoading = false;

  Future<void> _goToOtpScreen() async {
    final email = emailController.text.trim();
    final newPass = newPasswordController.text.trim();
    final confirmPass = confirmPasswordController.text.trim();

    if (email.isEmpty || newPass.isEmpty || confirmPass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Semua field wajib diisi')),
      );
      return;
    }

    if (newPass != confirmPass) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password tidak cocok')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final request = ResetPasswordRequest(
        email: email,
        password: newPass,
      );

      final userService = UserService();
      final response = await userService.resetPassword(request);

      final msg = response.message ?? 'OTP berhasil dikirim ke email';

      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg))
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OtpResetpasswordProfil(
            email: email,
            newPassword: newPass,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengirim OTP: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
  
  // untuk field password

  Widget _buildPasswordField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      obscureText: label.toLowerCase().contains("password") ? _obscureText : false,
      style: const TextStyle(color: Colors.white),
      cursorColor: Colors.amber,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white),
        border: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.amber),
        ),
        suffixIcon: label.toLowerCase().contains("password")
            ? IconButton(
                icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility, color: Colors.white),
                onPressed: () => setState(() => _obscureText = !_obscureText),
              )
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Setel ulang kata sandi', style: TextStyle(color: Colors.white, fontFamily: 'Intern')),
        backgroundColor: const Color(0xFF0C1D40),
        elevation: 0,
        leading: const BackButton(color: Colors.white),
      ),
      backgroundColor: const Color(0xFF0C1D40),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        // Form untuk reset password
        child: Column(
          children: [
            _buildPasswordField('Email', emailController),
            const SizedBox(height: 20),
            _buildPasswordField('Kata sandi baru', newPasswordController),
            const SizedBox(height: 20),
            _buildPasswordField('Konfirmasi kata sandi baru', confirmPasswordController),
            const SizedBox(height: 40),
            Container(
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFCF50), Color(0xFFDDEB9D)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextButton(
                onPressed: _isLoading ? null : _goToOtpScreen,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.black)
                    : const Text(
                        'PERBAHARUI KATA SANDI',
                        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                      ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
