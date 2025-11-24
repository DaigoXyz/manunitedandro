import 'package:flutter/material.dart';
import '../services/profileservice.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';


class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();

  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController(text: 'password123');
  final _phoneController = TextEditingController();

  bool _obscurePassword = true;
  bool _loading = true;

  String _headerName = "";
  String _headerEmail = "";
  String _headerPhone = "";
  File? _profileImage;


  @override
  void initState() {
    super.initState();
    _loadProfileFromBackend();
  }

  Future<void> _loadProfileFromBackend() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedImagePath = prefs.getString('local_profile_image');

      if (savedImagePath != null) {
        final file = File(savedImagePath);
        if (file.existsSync()) {
          setState(() {
            _profileImage = file;
          });
        }
      }

      final data = await ProfileService.getMyProfile();

      setState(() {
        _usernameController.text = data["name"] ?? "";
        _emailController.text = data["email"] ?? "";
        _phoneController.text = data["phone"] ?? "";

        _headerName = data["name"] ?? "";
        _headerEmail = data["email"] ?? "";
        _headerPhone = data["phone"] ?? "";
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024, // gambar dikecilin otomatis
        maxHeight: 1024,
        imageQuality: 85, // compress biar tidak rusak
      );

      if (picked == null) return;

      final file = File(picked.path);

      // TEST apakah gambar valid
      final testDecode = await decodeImageFromList(await file.readAsBytes());

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('local_profile_image', file.path);

      setState(() {
        _profileImage = file;
      });
    } catch (e) {
      print("Error pick image: $e");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Gagal memuat gambar. Pilih file JPG/PNG lain."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

Future<void> _deleteProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('local_profile_image');

    setState(() {
      _profileImage = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Foto profil dihapus."),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'My Account',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),

      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF8B1A1A)),
            )
          : _buildForm(),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // FOTO PROFIL
              Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: _profileImage != null
                        ? FileImage(_profileImage!)
                        : const AssetImage('assets/images/profile.png')
                              as ImageProvider,
                  ),

                  // BUTTON CAMERA (GANTI FOTO)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE53935),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: const Icon(
                          Icons.camera_alt,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  // BUTTON HAPUS FOTO
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        shape: BoxShape.circle,
                      ),
                      child: GestureDetector(
                        onTap: _deleteProfileImage,
                        child: const Icon(
                          Icons.delete,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // HEADER NAMA - EMAIL - NO HP (DINAMIS)
              Text(
                _headerName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _headerEmail,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 4),
              Text(
                "(+62)${_headerPhone.replaceFirst("0", "")}",
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),

              const SizedBox(height: 32),

              _buildTextField(
                label: 'Username',
                controller: _usernameController,
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 16),

              _buildTextField(
                label: 'Gmail',
                controller: _emailController,
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),

              _buildTextField(
                label: 'Password',
                controller: _passwordController,
                icon: Icons.lock_outline,
                isPassword: true,
              ),
              const SizedBox(height: 16),

              _buildTextField(
                label: 'No Telfon',
                controller: _phoneController,
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => _saveChanges(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B1A1A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Change',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool isPassword = false,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
        const SizedBox(height: 8),

        TextFormField(
          controller: controller,
          readOnly: true,
          obscureText: isPassword && _obscurePassword,
          keyboardType: keyboardType,
          validator: (value) => value == null || value.isEmpty
              ? "Field ini tidak boleh kosong"
              : null,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[100],
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFE53935)),
            ),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Colors.grey[600],
                    ),
                    onPressed: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                  )
                : null,
          ),
        ),
      ],
    );
  }

  void _saveChanges() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Color(0xFF4CAF50), size: 28),
            SizedBox(width: 12),
            Text('Berhasil', style: TextStyle(fontSize: 18)),
          ],
        ),
        content: const Text(
          'Profil Anda berhasil diperbarui!',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B1A1A),
            ),
            child: const Text('OK', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
