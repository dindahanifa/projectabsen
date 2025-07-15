// UserScreen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:projectabsen/aplikasi/home_absen.dart';
import 'package:projectabsen/aplikasi/lupa_password.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:projectabsen/api/api_user.dart';
import 'package:projectabsen/utils/shared_prefences.dart' as PreferenceHandler;

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});
  static const String id = "/user_screen";

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  final UserService userService = UserService();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool isSignIn = true;
  bool _obscurePassword = true;
  bool isLoading = false;

  int? selectedBatchId;
  int? selectedTrainingId;
  String? selectedGender;

  final List<Map<String, dynamic>> batchList = [
    {"id": 1, "name": "Batch 2"},
  ];

  final List<Map<String, dynamic>> trainingList = [
    {"id": 1, "name": "Data Management Staff"},
    {"id": 2, "name": "Bahasa Inggris"},
    {"id": 3, "name": "Desainer Grafis Madya"},
    {"id": 4, "name": "Tata Boga"},
    {"id": 5, "name": "Tata Busana"},
    {"id": 6, "name": "Perhotelan"},
    {"id": 7, "name": "Teknik Komputer"},
    {"id": 8, "name": "Teknik Jaringan"},
    {"id": 9, "name": "Barista"},
    {"id": 10, "name": "Bahasa Korea"},
    {"id": 11, "name": "Make Up Artist"},
    {"id": 12, "name": "Desainer Multimedia"},
    {"id": 13, "name": "Content Creator"},
    {"id": 14, "name": "Web Programing"},
    {"id": 15, "name": "Digital Marketing"},
    {"id": 16, "name": "Mobile Programing"},
    {"id": 17, "name": "Akutansi Junior"},
    {"id": 18, "name": "Kontruksi Bangunan Dengan CAD"},
  ];

  bool _isEmailValid(String email) {
    final regex = RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");
    return regex.hasMatch(email);
  }

  void _handleSignIn() async {
    setState(() => isLoading = true);
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Email dan Password tidak boleh kosong.'),
        backgroundColor: Colors.white,
      ));
      setState(() => isLoading = false);
      return;
    }

    try {
      final loginRequest = await userService.login(
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (loginRequest["data"] != null) {
        setState(() => isLoading = false);
        final token = loginRequest["data"]['token'];
        final user = loginRequest["data"]['user'];

        await PreferenceHandler.PreferenceHandler.saveToken(token);
        final prefs = await SharedPreferences.getInstance();
        prefs.setString('nama', user['name']);
        prefs.setString('email', user['email']);
        if (user['training_id'] != null) {
          prefs.setString('training_id', user['training_id'].toString());
        }
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
      } else {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Maaf, ${loginRequest["message"]}"),
          backgroundColor: Colors.white,
        ));
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Terjadi kesalahan: $e"),
        backgroundColor: Colors.white,
      ));
    }
  }

  void _handleSignUp() async {
    if (_usernameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        selectedGender == null ||
        selectedBatchId == null ||
        selectedTrainingId == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Semua kolom harus diisi.'),
      ));
      return;
    }

    if (!_isEmailValid(_emailController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Format email tidak valid'),
      ));
      return;
    }

    setState(() => isLoading = true);

    try {
      final registerRequest = await userService.registerUser(
        name: _usernameController.text,
        email: _emailController.text,
        password: _passwordController.text,
        jenisKelamin: selectedGender!,
        batchId: selectedBatchId!,
        trainingId: selectedTrainingId!,
      );

      if (registerRequest["data"] != null) {
        setState(() => isLoading = false);
        final data = registerRequest["data"];
        final user = data["user"];
        final prefs = await SharedPreferences.getInstance();
        prefs.setString('nama', user['name'] ?? '');
        prefs.setString('email', user['email'] ?? '');
        prefs.setString('training_id', user['training_id'].toString());
        setState(() {
          isSignIn = true;
          _usernameController.clear();
          _emailController.clear();
          _passwordController.clear();
          selectedGender = null;
          selectedBatchId = null;
          selectedTrainingId = null;
        });
      } else {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Maaf, ${registerRequest["message"]}"),
          backgroundColor: Colors.white,
        ));
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Terjadi kesalahan: $e"),
        backgroundColor: Colors.white,
      ));
    }
  }

  Widget _buildGenderOption(String gender) {
    final isSelected = selectedGender == gender;
    return GestureDetector(
      onTap: () => setState(() => selectedGender = gender),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              color: isSelected ? Colors.white : Colors.transparent,
            ),
            child: isSelected
                ? Center(
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: Color(0xFF0B3558),
                        shape: BoxShape.circle,
                      ),
                    ),
                  )
                : null,
          ),
          SizedBox(width: 8),
          Text(gender, style: TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Image.asset(
            isSignIn ? 'assets/image/bgdua.png' : 'assets/image/bg.png',
            fit: BoxFit.cover,
            height: double.infinity,
            width: double.infinity,
          ),
          SingleChildScrollView(
            padding: EdgeInsets.all(32),
            child: Column(
              children: [
                SizedBox(height: 80),
                if (isSignIn)
                  Text("Welcome!", style: TextStyle(color: Colors.white, fontSize: 28, fontFamily: 'Intern' )),
                SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () => setState(() => isSignIn = true),
                      child: _buildTapButton('SIGN IN', isSignIn),
                    ),
                    SizedBox(width: 10),
                    GestureDetector(
                      onTap: () => setState(() => isSignIn = false),
                      child: _buildTapButton('SIGN UP', !isSignIn),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                isSignIn ? _buildSignInForm() : _buildSignUpForm(),
                if (isSignIn)
                  TextButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ForgotPasswordScreen())),
                    child: Text('Forget your password?', style: TextStyle(color: Colors.deepOrange)),
                  ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSignInForm() {
    return Column(
      children: [
        _buildInputField(Icons.person, 'Email', false, _emailController),
        SizedBox(height: 20),
        _buildInputField(Icons.lock, 'Password', true, _passwordController),
        SizedBox(height: 40),
        _buildAuthButton('SIGN IN', _handleSignIn),
      ],
    );
  }

  Widget _buildSignUpForm() {
    return Column(
      children: [
        _buildInputField(Icons.person, 'Username', false, _usernameController),
        SizedBox(height: 20),
        _buildInputField(Icons.email, 'Email', false, _emailController),
        SizedBox(height: 20),
        _buildInputField(Icons.lock, 'Password', true, _passwordController),
        SizedBox(height: 20),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Jenis Kelamin", style: TextStyle(color: Colors.white)),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildGenderOption("P"),
                SizedBox(width: 30),
                _buildGenderOption("L"),
              ],
            ),
          ],
        ),
        SizedBox(height: 20),
        _buildDropdownField('Pilih Batch', batchList, selectedBatchId, (val) => setState(() => selectedBatchId = val)),
        SizedBox(height: 20),
        _buildDropdownField('Pilih Pelatihan', trainingList, selectedTrainingId, (val) => setState(() => selectedTrainingId = val)),
        SizedBox(height: 40),
        _buildAuthButton('SIGN UP', _handleSignUp),
      ],
    );
  }

  Widget _buildTapButton(String text, bool isActive) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 25, vertical: 5),
      decoration: BoxDecoration(
        color: isActive ? Colors.white.withOpacity(0.2) : Colors.transparent,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Text(
        text,
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildInputField(IconData icon, String hintText, bool isPassword, TextEditingController controller) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword ? _obscurePassword : false,
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          icon: Icon(icon, color: Colors.white.withOpacity(0.5)),
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
          border: InputBorder.none,
          suffixIcon: isPassword
              ? IconButton(
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  icon: Icon(
                    _obscurePassword ? Icons.visibility : Icons.visibility_off,
                    color: Colors.white.withOpacity(0.7),
                  ),
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildAuthButton(String text, VoidCallback onPressed) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(
          colors: [Color(0xFFB0D9EE), Color(0xFF86B9E7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: MaterialButton(
        onPressed: onPressed,
        padding: EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        child: isLoading
            ? CircularProgressIndicator()
            : Text(
                text,
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

  Widget _buildDropdownField(String hint, List<Map<String, dynamic>> items, int? selectedValue, ValueChanged<int?> onChanged) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: DropdownButtonFormField<int>(
        value: selectedValue,
        dropdownColor: Colors.white,
        hint: Text(hint, style: TextStyle(color: Colors.black.withOpacity(0.6))),
        iconEnabledColor: Colors.black,
        items: items.map((item) => DropdownMenuItem<int>(
          value: item["id"],
          child: Text(item["name"], style: TextStyle(color: Colors.black)),
        )).toList(),
        onChanged: onChanged,
        decoration: InputDecoration(border: InputBorder.none),
      ),
    );
  }
}
