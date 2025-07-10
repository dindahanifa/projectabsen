import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:projectabsen/aplikasi/home_absen.dart';
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
  final TextEditingController _jenisKelaminController = TextEditingController();

  bool isSignIn = true;
  bool _obscurePassword = true;
  bool isLoading = false;

  int? selectedBatchId;
  int? selectedTrainingId;

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
        content: Text('Username dan Password tidak boleh kosong.', style: TextStyle(color: Colors.black)),
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

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Login berhasil!", style: TextStyle(color: Colors.black)),
          backgroundColor: Colors.white,
        ));
        Navigator.pushReplacement(
          context, 
          MaterialPageRoute(builder: (context) => const HomeScreen())
          );
      } else if (loginRequest["errors"] != null) {
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

    setState(() {
      isLoading = false;
    });
    
  }

  void _handleSignUp() async {
  print("Test click");
  print('Selected Training ID: $selectedTrainingId');

    if (_usernameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _jenisKelaminController.text.isEmpty ||
        selectedBatchId == null ||
        selectedTrainingId == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Semua kolom harus diisi.', style: TextStyle(color: Colors.black)),
      ));
      return;
    }

    if (!_isEmailValid(_emailController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Format email tidak valid', style: TextStyle(color: Colors.black)),
      ));
      return;
    }

    setState(() => isLoading = true);

    try {
      final registerRequest = await userService.registerUser(
        name: _usernameController.text,
        email: _emailController.text,
        password: _passwordController.text,
        jenisKelamin: _jenisKelaminController.text,
        batchId: selectedBatchId!,
        trainingId: selectedTrainingId!,
      );

print("registerRequest");
print(registerRequest);
print(registerRequest["errors"]);
print(registerRequest["message"]);
      if (registerRequest["data"] != null) {
      setState(() => isLoading = false);

        final data = registerRequest["data"];
        final user = data["user"];
        final prefs = await SharedPreferences.getInstance();
        prefs.setString('nama', user['name'] ?? '');
        prefs.setString('email', user['email'] ?? '');
        prefs.setString('training_id', user['training_id'].toString());
        
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Register berhasil!", style: TextStyle(color: Colors.black)),
          backgroundColor: Colors.white,
        ));
        Future.delayed(Duration(seconds: 1), () {
          setState(() {
            isSignIn = true;
            _usernameController.clear();
            _emailController.clear();
            _passwordController.clear();
            _jenisKelaminController.clear();
            selectedBatchId = null;
            selectedTrainingId = null;
          });
        });
      } else {
        print("object");
    setState(() => isLoading = false);

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Maaf, ${registerRequest["message"]}", style: TextStyle(color: Colors.black)),
          backgroundColor: Colors.white,
        ));

      }
    } catch (e, stackrace) {
    setState(() => isLoading = false);

      print(e);
      print(stackrace);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Terjadi kesalahan: $e", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
      ));
    }
  }

  Widget _buildDropdownField({
    required String hint,
    required List<Map<String, dynamic>> items,
    required int? selectedValue,
    required ValueChanged<int?> onChanged,
  }) {
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
        items: items.map((item) {
          return DropdownMenuItem<int>(
            value: item["id"],
            child: Text(item["name"], style: TextStyle(color: Colors.black)),
          );
        }).toList(),
        onChanged: onChanged,
        decoration: InputDecoration(border: InputBorder.none),
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
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
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
        child:
        isLoading ==true? CircularProgressIndicator():
         Text(
          text,
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildSignForm() {
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
        _buildInputField(Icons.transgender, 'Jenis Kelamin', false, _jenisKelaminController),
        SizedBox(height: 20),
        _buildDropdownField(
          hint: 'Pilih Batch',
          items: batchList,
          selectedValue: selectedBatchId,
          onChanged: (val) => setState(() => selectedBatchId = val),
        ),
        SizedBox(height: 20),
        _buildDropdownField(
          hint: 'Pilih Pelatihan',
          items: trainingList,
          selectedValue: selectedTrainingId,
          onChanged: (val) => setState(() => selectedTrainingId = val),
        ),
        SizedBox(height: 40),
        _buildAuthButton('SIGN UP', _handleSignUp),
      ],
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _jenisKelaminController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Image.asset('assets/image/bgdua.png', fit: BoxFit.cover),
          ),
          SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Column(
                children: [
                  SizedBox(height: 160),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () => setState(() => isSignIn = true),
                        child: _buildTapButton('SIGN IN', isSignIn),
                      ),
                      SizedBox(width: 20),
                      GestureDetector(
                        onTap: () => setState(() => isSignIn = false),
                        child: _buildTapButton('SIGN UP', !isSignIn),
                      ),
                    ],
                  ),
                  SizedBox(height: 40),
                  isSignIn ? _buildSignForm() : _buildSignUpForm(),
                  SizedBox(height: 30),
                  if (isSignIn)
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        'Forget your password?',
                        style: TextStyle(color: Colors.deepOrange),
                      ),
                    ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTapButton(String text, bool isActive) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 25, vertical: 12),
      decoration: BoxDecoration(
        color: isActive ? Colors.white.withOpacity(0.2) : Colors.transparent,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
