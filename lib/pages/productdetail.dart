import 'package:flutter/material.dart';
import 'cart.dart'; // Import cart page
import '/data/products.dart'; // IMPORT DATA DUMMY
import '/services/cartservice.dart'; // Import cart service

class ProductDetailPage extends StatefulWidget {
  final int productId;

  const ProductDetailPage({super.key, required this.productId});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  late Map<String, dynamic> product;
  late List<String> productImages;
  late List<Map<String, dynamic>> recommendedProducts;

  int currentImageIndex = 0;
  String selectedSize = '';
  bool isDescriptionExpanded = false;
  bool isFavorite = false;

  final List<String> sizes = ['S', 'M', 'L', 'XL', '2XL'];

  @override
  void initState() {
    super.initState();

   // Ambil data sesuai ID
    product = productsData.firstWhere((p) => p['id'] == widget.productId);

    // Load product images
    productImages = List<String>.from(product['images']);

    // Recommended products
    recommendedProducts = productsData
        .where(
          (p) =>
              p['id'] != product['id'] &&
              (p['category'] == product['category'] ||
                  p['gender'] == product['gender']),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Image Carousel
                    _buildImageCarousel(),

                    // Product Info Section
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Product Name
                          Text(
                            product['name'],
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Product Price
                          Text(
                            product['price'],
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF8B1A1A),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Size Selection
                          const Text(
                            'Size',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildSizeSelector(),
                          const SizedBox(height: 24),

                          // Add to Cart Button
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: selectedSize.isEmpty
                                  ? null
                                  : () {
                                      _showAddedToCartDialog();
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF8B1A1A),
                                disabledBackgroundColor: Colors.grey[300],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                'Add to cart',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: selectedSize.isEmpty
                                      ? Colors.grey
                                      : Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Description Section
                          _buildDescriptionSection(),
                          const SizedBox(height: 24),

                          // Recommended Section
                          const Text(
                            'Recommended for you',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildRecommendedProducts(),
                          const SizedBox(height: 80),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageCarousel() {
    return Stack(
      children: [
        // Image Carousel
        SizedBox(
          height: 400,
          child: PageView.builder(
            itemCount: productImages.length,
            onPageChanged: (index) {
              setState(() {
                currentImageIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return Container(
                color: Colors.grey[200],
                child: Center(
                  child: Image.asset(
                    productImages[index],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.checkroom,
                        size: 100,
                        color: Colors.grey,
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),

        // Back Button
        Positioned(
          top: 16,
          left: 16,
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back,
                color: Colors.black,
                size: 24,
              ),
            ),
          ),
        ),

        // Favorite Button
        Positioned(
          top: 16,
          right: 16,
          child: GestureDetector(
            onTap: () {
              setState(() {
                isFavorite = !isFavorite;
              });
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: isFavorite ? const Color(0xFFE53935) : Colors.black,
                size: 24,
              ),
            ),
          ),
        ),

        // Image Indicators
        Positioned(
          bottom: 16,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              productImages.length,
              (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: currentImageIndex == index
                      ? const Color(0xFFE53935)
                      : Colors.white.withOpacity(0.5),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSizeSelector() {
    return Row(
      children: sizes.map((size) {
        final isSelected = selectedSize == size;
        return Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                selectedSize = size;
              });
            },
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF8B1A1A) : Colors.white,
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF8B1A1A)
                      : Colors.grey[300]!,
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  size,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : Colors.black,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              isDescriptionExpanded = !isDescriptionExpanded;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Description',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Icon(
                  isDescriptionExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: Colors.black,
                ),
              ],
            ),
          ),
        ),
        if (isDescriptionExpanded)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Text(
              'The Manchester United Home Jersey for the 2025/26 season features the iconic red color with black and white accents. Made with advanced moisture-wicking technology to keep you cool and comfortable during intense matches. The jersey includes the official team crest and sponsor logos.\n\nKey Features:\n• 100% Polyester\n• Regular fit\n• Moisture-wicking fabric\n• Official team crest\n• Machine washable',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildRecommendedProducts() {
    return SizedBox(
      height: 280,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: recommendedProducts.length,
        itemBuilder: (context, index) {
          final product = recommendedProducts[index];
          return _buildRecommendedCard(product);
        },
      ),
    );
  }

  Widget _buildRecommendedCard(Map<String, dynamic> product) {
    return GestureDetector(
      onTap: () {
        // Navigate to product detail using pushReplacement
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailPage(productId: product['id']),
          ),
        );
      },
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 12),
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

  Future<void> _showAddedToCartDialog() async {
    // Add item to cart using CartService
    await CartService.addToCart(
      productId: product['id'].toString(),
      name: product['name'],
      size: selectedSize,
      price: int.parse(product['price'].replaceAll(RegExp(r'[^\d]'), '')),
      image: product['image'],
      quantity: 1,
    );

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Color(0xFF4CAF50), size: 28),
            SizedBox(width: 12),
            Text('Added to Cart', style: TextStyle(fontSize: 18)),
          ],
        ),
        content: Text(
          'Size $selectedSize has been added to your cart.',
          style: const TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Continue Shopping',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to cart
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CartPage()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B1A1A),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'View Cart',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
