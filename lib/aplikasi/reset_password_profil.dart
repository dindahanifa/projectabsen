import 'package:flutter/material.dart';
import 'package:projectabsen/aplikasi/otp_resetpassword_profil.dart';
import 'package:projectabsen/aplikasi/otp_resetpassword_profil.dart';

class ResetPasswordProfil extends StatefulWidget {
  const ResetPasswordProfil({super.key});

  @override
  State<ResetPasswordProfil> createState() => _ResetPasswordProfilState();
}

class _ResetPasswordProfilState extends State<ResetPasswordProfil> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  bool _obscureText = true;

  void _goToOtpScreen() {
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

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OtpResetpasswordProfil(
          email: email,
          newPassword: newPass,
        ),
      ),
    );
  }

  Widget _buildPasswordField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      obscureText: label.toLowerCase().contains("password") ? _obscureText : false,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white),
        border: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
        suffixIcon: label.toLowerCase().contains("password")
            ? IconButton(
                icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility),
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
        title: const Text('Reset Password', style: TextStyle(color: Colors.white, fontFamily: 'Intern')),
        backgroundColor: Color(0xff08325b),
        elevation: 0,
        leading: const BackButton(color: Colors.white),
      ),
      backgroundColor: Color(0xff08325b),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            _buildPasswordField('Email', emailController),
            const SizedBox(height: 20),
            _buildPasswordField('New Password', newPasswordController),
            const SizedBox(height: 20),
            _buildPasswordField('Confirm New Password', confirmPasswordController),
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
                onPressed: _goToOtpScreen,
                child: const Text(
                  'UPDATE PASSWORD',
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
