import 'package:flutter/material.dart';
import 'editprofile.dart';
import 'orderhistory.dart';
import 'wishlist.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String userName = '';
  String userEmail = '';
  String userPhone = '';
  bool isLoading = true;

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("jwt_token");

    if (token == null) {
      print("Token kosong");
      return;
    }

    try {
      final url = Uri.parse("http://10.250.92.85:8080/api/me");

      final response = await http.get(
        url,
        headers: {"Authorization": "Bearer $token"},
      );

      print("Response: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          userName = data["name"] ?? "-";
          userEmail = data["email"] ?? "-";
          userPhone = data["phone"] ?? "-";
          isLoading = false;
        });
      } else {
        print("Gagal load user: ${response.statusCode}");
        print(response.body);
      }
    } catch (e) {
      print("Error load user: $e");
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("jwt_token");

    if (token == null) {
      Navigator.pushNamedAndRemoveUntil(context, "/login", (route) => false);
      return;
    }

    try {
      final url = Uri.parse("http://10.250.92.85:8080/api/logout");

      final response = await http.post(
        url,
        headers: {"Authorization": "Bearer $token"},
      );

      print("Logout response: ${response.body}");

      // Apapun respon BE, hapus token lokal
      await prefs.remove("jwt_token");
      await prefs.remove("user_id");

      Navigator.pushNamedAndRemoveUntil(context, "/login", (route) => false);
    } catch (e) {
      print("Logout error: $e");
    }
  }


  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBody: true,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 24),

                    _buildMenuItem(
                      icon: Icons.person,
                      title: 'Edit Profil',
                      subtitle: 'Ubah informasi Pribadi Anda',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const EditProfilePage(),
                          ),
                        );
                      },
                    ),

                    _buildMenuItem(
                      icon: Icons.inventory,
                      title: 'Riwayat Pesanan',
                      subtitle: 'Lihat pesanan yang pernah dibeli',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const OrderHistoryPage(),
                          ),
                        );
                      },
                    ),

                    _buildMenuItem(
                      icon: Icons.favorite,
                      title: 'Wishlist',
                      subtitle: 'Produk yang anda sukai',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const WishlistPage(),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 24),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: OutlinedButton.icon(
                          onPressed: () => _showLogoutDialog(),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color: Color(0xFFE53935),
                              width: 2,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(
                            Icons.logout,
                            color: Color(0xFFE53935),
                          ),
                          label: const Text(
                            'Keluar',
                            style: TextStyle(
                              color: Color(0xFFE53935),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF991B1B), Color(0xFFE30613)],
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.white,
                child: CircleAvatar(
                  radius: 38,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: const AssetImage(
                    'assets/images/profile.png',
                  ),
                  onBackgroundImageError: (_, __) {},
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Color(0xFFE53935), width: 2),
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    size: 16,
                    color: Color(0xFFE53935),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 20),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isLoading ? "Loading..." : userName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isLoading ? "-" : userEmail,
                  style: const TextStyle(fontSize: 13, color: Colors.white),
                ),
                const SizedBox(height: 2),
                Text(
                  isLoading ? "-" : userPhone,
                  style: const TextStyle(fontSize: 13, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: Color(0xFFE53935),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),

            Icon(Icons.chevron_right, color: Colors.grey[400], size: 28),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      height: 90,
      color: Colors.transparent,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            bottom: 50,
            left: 20,
            right: 20,
            child: Container(
              height: 65,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                    offset: Offset(0, 8),
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: CustomPaint(
                painter: BottomNavBarPainter(),
                child: Row(
                  children: [
                    Expanded(
                      child: IconButton(
                        icon: Icon(
                          Icons.local_offer_outlined,
                          color: Colors.white,
                          size: 28,
                        ),
                        onPressed: () {},
                      ),
                    ),
                    Expanded(
                      child: IconButton(
                        icon: Icon(
                          Icons.home_outlined,
                          color: Colors.white,
                          size: 28,
                        ),
                        onPressed: () {
                          Navigator.popUntil(context, (route) => route.isFirst);
                        },
                      ),
                    ),
                    Expanded(child: Container()),
                  ],
                ),
              ),
            ),
          ),

          Positioned(
            bottom: 90,
            right: 48,
            child: GestureDetector(
              onTap: () {},
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Color(0xFF8B1A1A),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person, color: Colors.white, size: 28),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.logout, color: Color(0xFFE53935), size: 28),
            SizedBox(width: 12),
            Text('Keluar', style: TextStyle(fontSize: 18)),
          ],
        ),
        content: const Text(
          'Apakah Anda yakin ingin keluar?',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              logout();
            },
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFE53935),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Keluar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class BottomNavBarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFE53935)
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final path = Path();

    double cornerRadius = 30;
    double notchWidth = 120;
    double notchDepth = 32;
    double notchStartX = size.width - 60;

    path.moveTo(0, cornerRadius);
    path.quadraticBezierTo(0, 0, cornerRadius, 0);

    path.lineTo(notchStartX - notchWidth / 2, 0);

    path.quadraticBezierTo(
      notchStartX - notchWidth / 2 + 15,
      0,
      notchStartX - notchWidth / 2 + 20,
      0,
    );

    path.quadraticBezierTo(
      notchStartX - 25,
      notchDepth,
      notchStartX,
      notchDepth,
    );

    path.quadraticBezierTo(
      notchStartX + 25,
      notchDepth,
      notchStartX + notchWidth / 2 - 20,
      0,
    );

    path.quadraticBezierTo(
      notchStartX + notchWidth / 2 - 15,
      0,
      notchStartX + notchWidth / 2,
      0,
    );

    path.lineTo(size.width - cornerRadius, 0);
    path.quadraticBezierTo(size.width, 0, size.width, cornerRadius);

    path.lineTo(size.width, size.height - cornerRadius);
    path.quadraticBezierTo(
      size.width,
      size.height,
      size.width - cornerRadius,
      size.height,
    );

    path.lineTo(cornerRadius, size.height);
    path.quadraticBezierTo(0, size.height, 0, size.height - cornerRadius);

    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
