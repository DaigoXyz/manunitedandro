import 'package:flutter/material.dart';
import 'productdetail.dart';
import 'cart.dart';
import 'profile.dart';
import 'checkout.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String selectedCategory = 'Jersey';
  String selectedGender = 'Woman';
  String searchQuery = '';
  int currentBannerIndex = 0;

  final List<Map<String, dynamic>> banners = [
    {
      'title': 'The Iconic Red Jersey,\nFeel the Pride on Your Chest',
      'image': 'assets/images/banners1.png',
      'color': const Color(0xFFFFB3BA),
    },
    {
      'title': 'Premium Retro Outfit\nFeel Elegance On & Off The Pitch',
      'image': 'assets/images/banners2.png',
      'color': const Color(0xFF4DB8AC),
    },
    {
      'title': 'Premium Jacket\nStyle On & Off The Pitch',
      'image': 'assets/images/banners3.png',
      'color': const Color(0xFF4DB8AC),
    },
  ];

final List<Map<String, dynamic>> products = [
    {
      'id': 1,
      'name': 'Manchester United Womens 25/26 Home Jersey',
      'price': 'Rp1.375.000',
      'image': 'assets/images/jersey1.png',
      'category': 'Jersey',
      'gender': 'Woman',
    },
    {
      'id': 2,
      'name': 'Manchester United Man 25/26 Home Jersey',
      'price': 'Rp1.375.000',
      'image': 'assets/images/jersey2.png',
      'category': 'Jersey',
      'gender': 'Man',
    },
    {
      'id': 3,
      'name': 'Manchester United Mens Travel Jacket 2025',
      'price': 'Rp1.150.000',
      'image': 'assets/images/jacket1.png',
      'category': 'Jacket',
      'gender': 'Man',
    },
    {
      'id': 4,
      'name': 'Manchester United Mens Training Long 24/25',
      'price': 'Rp799.000',
      'image': 'assets/images/pants1.png',
      'category': 'Pants/Short',
      'gender': 'Man',
    },
  ];

  List<Map<String, dynamic>> get filteredProducts {
    return products.where((product) {
      // Filter kategori
      final matchesCategory = selectedCategory == product['category'];

      // Filter gender — ALL berarti tampilkan semua
      final matchesGender = selectedGender == 'All'
          ? true
          : product['gender'] == selectedGender;

      // Filter search query (case-insensitive)
      final matchesSearch = product['name'].toString().toLowerCase().contains(
        searchQuery.toLowerCase(),
      );

      return matchesCategory && matchesGender && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBody: true, // Important for transparent navbar
      body: SafeArea(
        bottom: false, // Allow content to extend behind navbar
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  // Profile Picture
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.grey[300],
                    child: const Icon(
                      Icons.person,
                      size: 28,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Greeting
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hello, Devils!',
                          style: TextStyle(fontSize: 14, color: Colors.black54),
                        ),
                        Text(
                          'John Doe',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Icons
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.shopping_bag_outlined, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      shape: BoxShape.circle,
                    ),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CartPage(),
                          ),
                        );
                      },
                      child: const Icon(Icons.shopping_cart_outlined, size: 24),
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),

                    // Banner Carousel
                    SizedBox(
                      height: 150,
                      child: PageView.builder(
                        itemCount: banners.length,
                        onPageChanged: (index) {
                          setState(() {
                            currentBannerIndex = index;
                          });
                        },
                        itemBuilder: (context, index) {
                          final banner = banners[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    banner['color'].withOpacity(0.9),
                                    banner['color'].withOpacity(0.6),
                                  ],
                                ),
                              ),
                              child: Stack(
                                children: [
                                  Positioned.fill(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: Transform.translate(
                                        offset: const Offset(
                                          -50,
                                          0,
                                        ), // ⬅️ geser kiri 20px (ubah bebas)
                                        child: Transform.scale(
                                          scale:
                                              1.15, // ⬅️ zoom image (1.0 = normal)
                                          child: Image.asset(
                                            banner['image'],
                                            fit: BoxFit.fitHeight,
                                            alignment: Alignment
                                                .centerRight, // tetap kanan
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                                  return const Center(
                                                    child: Icon(
                                                      Icons.broken_image,
                                                      size: 60,
                                                      color: Colors.white54,
                                                    ),
                                                  );
                                                },
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                  // TEXT
                                  Positioned(
                                    left: 20,
                                    top: 20,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          width: 180,
                                          child: Text(
                                            banner['title'],
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                              height: 1.3,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        ElevatedButton(
                                          onPressed: () {},
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(
                                              0xFFE53935,
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 20,
                                              vertical: 10,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                          ),
                                          child: const Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                'Shop Now',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              SizedBox(width: 8),
                                              Icon(
                                                Icons.arrow_forward,
                                                size: 16,
                                                color: Colors.white,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Dots Indicator
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        banners.length,
                        (index) => Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: currentBannerIndex == index
                                ? Colors.grey[300]
                                : const Color(0xFFE30613),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Search Bar
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: TextField(
                        onChanged: (value) {
                          setState(() {
                            searchQuery = value;
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Cari produk kami, di sini',
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          prefixIcon: Icon(
                            Icons.search,
                            color: Colors.grey[400],
                          ),
                          filled: true,
                          fillColor: Colors.grey[100],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 12,
                          ),
                        ),
                      )
                    ),

                    const SizedBox(height: 24),

                    // Categories Title
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        'Categories',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Category Buttons
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        children: [
                          _buildCategoryButton('Jersey'),
                          const SizedBox(width: 12),
                          _buildCategoryButton('Jacket'),
                          const SizedBox(width: 12),
                          _buildCategoryButton('Pants/Short'),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Gender Filter
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        children: [
                          _buildGenderCheckbox('Woman'),
                          const SizedBox(width: 24),
                          _buildGenderCheckbox('Man'),
                          const SizedBox(width: 24),
                          _buildGenderCheckbox('All'),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Product Grid
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.65,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                            ),
                        itemCount: filteredProducts.length,
                        itemBuilder: (context, index) {
                          final product = filteredProducts[index];
                          return _buildProductCard(product);
                        },
                      ),
                    ),

                    const SizedBox(height: 140), // Extra space for navbar
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

  Widget _buildCategoryButton(String category) {
    final isSelected = selectedCategory == category;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCategory = category;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF8B1A1A) : Colors.grey[300],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          category,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildGenderCheckbox(String gender) {
    final isSelected = selectedGender == gender;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedGender = gender;
        });
      },
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF8B1A1A) : Colors.white,
              border: Border.all(
                color: isSelected ? const Color(0xFF8B1A1A) : Colors.grey,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            child: isSelected
                ? const Icon(Icons.check, size: 14, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 8),
          Text(
            gender,
            style: const TextStyle(fontSize: 14, color: Colors.black),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailPage(productId: product['id']),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          // Product Image
          Stack(
            children: [
              Container(
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Center(
                  child: Image.asset(
                      product['image'],
                      fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.checkroom,
                        size: 60,
                        color: Colors.grey,
                      );
                    },
                  ),
                ),
              ),
              // Favorite Icon
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.favorite_border,
                    size: 20,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
          // Product Info
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product['price'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF8B1A1A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  product['name'],
                  style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    ),
    );
  }

  Widget _buildBottomNavBar() {
    return SizedBox(
      height: 90,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Floating background bar dengan cekungan di atas (TRANSPARAN)
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
                    offset: const Offset(0, 8),
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: CustomPaint(
                painter: BottomNavBarPainter(),
                child: SizedBox(
                  height: 65,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Left icon
                      Expanded(
                        child: IconButton(
                          icon: const Icon(
                            Icons.payments,
                            color: Colors.white,
                            size: 26,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const CheckoutPage(),
                              ),
                            );
                          },
                        ),
                      ),

                      // Center spacer for floating home button
                      const SizedBox(width: 80),

                      // Right icon
                      Expanded(
                        child: IconButton(
                          icon: const Icon(
                            Icons.person_outline,
                            color: Colors.white,
                            size: 26,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const ProfilePage(),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Floating Home Button (center) - positioned higher
          Positioned(
            bottom: 90,
            left: MediaQuery.of(context).size.width / 2 - 32,
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFF8B1A1A),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.home, color: Colors.white, size: 30),
            ),
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
      ..style = PaintingStyle.fill;

    final path = Path();

    double cornerRadius = 30;
    double notchWidth = 120;
    double notchDepth = 32;

    // Start from top-left
    path.moveTo(0, cornerRadius);
    path.quadraticBezierTo(0, 0, cornerRadius, 0);

    // Top edge until notch starts
    path.lineTo(size.width / 2 - notchWidth / 2, 0);

    // Left side of notch - curve going up
    path.quadraticBezierTo(
      size.width / 2 - notchWidth / 2 + 15,
      0,
      size.width / 2 - notchWidth / 2 + 20,
      0,
    );

    // Main notch curve
    path.quadraticBezierTo(
      size.width / 2 - 25,
      notchDepth,
      size.width / 2,
      notchDepth,
    );

    path.quadraticBezierTo(
      size.width / 2 + 25,
      notchDepth,
      size.width / 2 + notchWidth / 2 - 20,
      0,
    );

    // Right side of notch - curve back down
    path.quadraticBezierTo(
      size.width / 2 + notchWidth / 2 - 15,
      0,
      size.width / 2 + notchWidth / 2,
      0,
    );

    // Top edge to top-right corner
    path.lineTo(size.width - cornerRadius, 0);
    path.quadraticBezierTo(size.width, 0, size.width, cornerRadius);

    // Right edge
    path.lineTo(size.width, size.height - cornerRadius);
    path.quadraticBezierTo(
      size.width,
      size.height,
      size.width - cornerRadius,
      size.height,
    );

    // Bottom edge
    path.lineTo(cornerRadius, size.height);
    path.quadraticBezierTo(0, size.height, 0, size.height - cornerRadius);

    // Left edge back to start
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
