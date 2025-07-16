import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:projectabsen/api/api_user.dart';
import 'package:projectabsen/utils/shared_prefences.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:projectabsen/aplikasi/reset_password_profil.dart';
import 'package:projectabsen/aplikasi/user_absen.dart';

class EditProfilScreen extends StatefulWidget {
  const EditProfilScreen({super.key});

  @override
  State<EditProfilScreen> createState() => _EditProfilScreenState();
}

class _EditProfilScreenState extends State<EditProfilScreen> {
  final _formKey = GlobalKey<FormState>();
  final UserService userService = UserService();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  File? _imageFile;
  String? imageUrl;
  final ImagePicker _picker = ImagePicker();

  String? batchId;
  String? mulaiBatch;
  String? akhirBatch;
  String? namaTraining;

  bool _isPicking = false;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final data = await userService.getProfile();
      final user = data['data'];

      setState(() {
        nameController.text = user['name'] ?? '';
        emailController.text = user['email'] ?? '';
        imageUrl = user['profile_photo_url'];
        batchId = user['batch_ke']?.toString();
        mulaiBatch = user['batch']?['start_date'];
        akhirBatch = user['batch']?['end_date'];
        namaTraining = user['training_title'];
      });
    } catch (e) {
      print("❌ Gagal mengambil data profil: $e");
    }
  }

  String formatTanggal(String? tanggal) {
    if (tanggal == null || tanggal.isEmpty) return '-';
    try {
      final parsedDate = DateTime.parse(tanggal);
      return DateFormat('dd MMMM yyyy', 'id_ID').format(parsedDate);
    } catch (e) {
      try {
        final parsedAlt = DateFormat('dd-MM-yyyy').parse(tanggal.split('T').first);
        return DateFormat('dd MMMM yyyy', 'id_ID').format(parsedAlt);
      } catch (e) {
        return '--';
      }
    }
  }

  Future<void> _updatePhoto(File imageFile) async {
    try {
      final response = await userService.updatePhotoProfile(imageFile);
      if (response != null && response.containsKey('data')) {
        final newPhotoUrl = response['data']['profile_photo'];
        if (newPhotoUrl != null && newPhotoUrl.isNotEmpty) {
          await PreferenceHandler.saveProfilePhoto(newPhotoUrl);
          setState(() {
            imageUrl = newPhotoUrl;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Foto profil berhasil diperbarui')),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal update foto: $e')),
      );
    }
  }

  Future<void> _simpanPerubahan() async {
    if (!_formKey.currentState!.validate()) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Center(
          child: Text(
            'Simpan Perubahan?',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.blue,
            ),
          ),
        ),
        content: const Text(
          'Apakah Anda yakin ingin menyimpan perubahan profil?',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 15),
        ),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actionsPadding: const EdgeInsets.only(bottom: 12),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal', style: TextStyle(color: Colors.black)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Simpan', style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await userService.updateProfile(nameController.text.trim());
      if (_imageFile != null) {
        await _updatePhoto(_imageFile!);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil berhasil diperbarui')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memperbarui profil: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C1D40),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0C1D40),
        elevation: 0,
        title: const Text('Informasi Diri', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          TextButton(
            onPressed: _simpanPerubahan,
            child: const Text('Ubah Profil', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          if (_isPicking) return;
                          _isPicking = true;
                          try {
                            final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
                            if (pickedFile != null) {
                              final file = File(pickedFile.path);
                              setState(() {
                                _imageFile = file;
                              });
                              await _updatePhoto(file);
                            }
                          } finally {
                            _isPicking = false;
                          }
                        },
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.grey.shade300,
                              backgroundImage: _imageFile != null
                                  ? FileImage(_imageFile!)
                                  : (imageUrl != null
                                      ? NetworkImage(imageUrl!) as ImageProvider
                                      : null),
                              child: _imageFile == null && imageUrl == null
                                  ? const Icon(Icons.person, size: 50, color: Colors.white)
                                  : null,
                            ),
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
                              child: const Icon(Icons.edit, color: Colors.white, size: 18),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildSection(
                        title: 'Informasi Pribadi',
                        children: [
                          _buildTextField(label: 'Username', controller: nameController, required: true),
                          _buildTextField(label: 'E-mail', controller: emailController, required: true),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const ResetPasswordProfil()),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Row(
                                children: const [
                                  SizedBox(width: 1),
                                  Text(
                                    'Setel ulang kata sandi',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.blue,
                                      decoration: TextDecoration.underline,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      _buildTrainingInfo(),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              title: const Center(
                                child: Text(
                                  'Keluar Akun?',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                              content: const Text(
                                'Apakah Anda yakin ingin keluar dari akun ini?',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 15),
                              ),
                              actionsAlignment: MainAxisAlignment.spaceEvenly,
                              actionsPadding: const EdgeInsets.only(bottom: 12),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: const Text('Batal', style: TextStyle(color: Colors.black)),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Keluar', style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true) {
                            final prefs = await SharedPreferences.getInstance();
                            await prefs.clear();

                            if (!context.mounted) return;
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(builder: (context) => const UserScreen()),
                              (route) => false,
                            );
                          }
                        },
                        icon: const Icon(Icons.logout),
                        label: const Text('Logout'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                      const Spacer(),
                      const Align(
                        alignment: Alignment.center,
                        child: Padding(
                          padding: EdgeInsets.only(top: 16.0, bottom: 8.0),
                          child: Text(
                            '© 2025 Dinda Hanifa',
                            style: TextStyle(color: Colors.white60, fontSize: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required List<Widget> children}) {
    return Card(
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({required String label, required TextEditingController controller, bool required = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        validator: required ? (value) => value == null || value.trim().isEmpty ? '$label wajib diisi' : null : null,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.grey),
          border: const UnderlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(vertical: 4),
        ),
      ),
    );
  }

  Widget _buildTrainingInfo() {
    return Card(
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(top: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Informasi Akademik/Training',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.groups, 'Batch', batchId ?? '-'),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.calendar_today, 'Mulai Batch', mulaiBatch != null ? formatTanggal(mulaiBatch) : '-'),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.calendar_today_outlined, 'Akhir Batch', formatTanggal(akhirBatch)),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.school, 'Pelatihan', namaTraining ?? '-'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[700]),
        const SizedBox(width: 10),
        Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w600)),
        Flexible(child: Text(value, overflow: TextOverflow.ellipsis)),
      ],
    );
  }
}
