import 'package:flutter/material.dart';
import 'package:projectabsen/api/api_user.dart';
import 'package:projectabsen/model/reset_password.dart';
import 'package:projectabsen/aplikasi/succes_screen.dart';

class ResetPasswordScreen extends StatefulWidget {
  // untuk mengirim email dan OTP
  final String email;
  final String otp;

  const ResetPasswordScreen({super.key, required this.email, required this.otp});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

// untuk mengirim  reset password ke API

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _isStrong = false;
  bool _loading = false;

  final _userService = UserService();

  void _checkPasswordStrength(String password) {
    setState(() {
      _isStrong = password.length >= 8 &&
          RegExp(r'[A-Z]').hasMatch(password) &&
          RegExp(r'[a-z]').hasMatch(password) &&
          RegExp(r'[0-9]').hasMatch(password);
    });
  }
  
  // untuk mengirim password baru ke API

  Future<void> _submitNewPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      final request = ResetPasswordRequest(
        email: widget.email,
        otp: widget.otp,
        password: _newPasswordController.text.trim(),
      );

      final response = await _userService.resetPassword(request);

      if (!mounted) return;

      Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const PasswordSuccessScreen()),
      );

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal reset password: $e")),
      );
    } finally {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C1D40),
      body: SafeArea(
        // untuk menampilkan form reset password
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                // judul halaman
                const SizedBox(height: 16),
                const Text(
                  "Sukses!",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                // deskripsi halaman
                const SizedBox(height: 8),
                const Text(
                  "Mari buat kata sandi baru untuk akun Anda.",
                  style: TextStyle(fontSize: 15, color: Colors.white),
                ),
                // input untuk password baru
                const SizedBox(height: 32),
                TextFormField(
                  controller: _newPasswordController,
                  obscureText: _obscureNewPassword,
                  onChanged: _checkPasswordStrength,
                  decoration: InputDecoration(
                    labelText: 'Kata sandi baru*',
                    labelStyle: const TextStyle(color: Colors.white),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureNewPassword ? Icons.visibility_off : Icons.visibility,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureNewPassword = !_obscureNewPassword;
                        });
                      },
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  style: const TextStyle(color: Colors.white),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password wajib diisi';
                    }
                    if (!_isStrong) {
                      return 'Gunakan minimal 8 karakter kombinasi huruf dan angka';
                    }
                    return null;
                  },
                ),
                // indikator kekuatan password
                const SizedBox(height: 8),
                if (_newPasswordController.text.isNotEmpty)
                  Row(
                    children: [
                      Icon(
                        _isStrong ? Icons.check_circle : Icons.error,
                        color: _isStrong ? Colors.green : Colors.red,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _isStrong ? 'Strong password!' : 'Weak password',
                        style: TextStyle(
                          color: _isStrong ? Colors.green : Colors.red,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                // input untuk konfirmasi password
                const SizedBox(height: 24),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  decoration: InputDecoration(
                    labelText: 'Konfirmasi kata sandi baru*',
                    labelStyle: const TextStyle(color: Colors.white),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  style: const TextStyle(color: Colors.white),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Konfirmasi password wajib diisi';
                    }
                    if (value != _newPasswordController.text) {
                      return 'Password tidak cocok';
                    }
                    return null;
                  },
                ),
                // untuk kirim password
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _submitNewPassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xffFFCF50),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _loading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Kirim kata sandi baru',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
