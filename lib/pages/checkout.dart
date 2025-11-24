import 'package:flutter/material.dart';
import '/services/cartservice.dart';
import '/services/checkoutservice.dart';
import '/models/shippingaddressmodel.dart';
import '../services/profileservice.dart';
import 'shipping_address.dart';
import 'profile.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  List<CheckoutItem> items = [];
  String selectedPaymentMethod = 'COD';
  ShippingAddress? selectedAddress;
  String? userName;

  // Check if address is set
  bool get hasAddress => selectedAddress != null;

  // Address text (only when address exists)
  String get shippingAddressText {
    if (selectedAddress != null) {
      final displayName = userName ?? 'Loading...';
      return '$displayName  ${selectedAddress!.formattedPhone}\n'
          '${selectedAddress!.address}, ${selectedAddress!.city}, ${selectedAddress!.province} ${selectedAddress!.postalCode}';
    }
    return '';
  }

  final double shippingCost = 200000;

  @override
  void initState() {
    super.initState();
    _loadCheckoutItems();
    _loadUserProfile();
  }

Future<void> _loadUserProfile() async {
    try {
      final profile = await ProfileService.getMyProfile();
      if (mounted) {
        setState(() {
          userName =
              profile['name'] ?? profile['fullName'] ?? profile['username'];
        });
      }
    } catch (e) {
      print('Error loading profile: $e');
    }
  }
  Future<void> _loadCheckoutItems() async {
    final raw = await CheckoutService.getCheckoutItems();

    setState(() {
      items = raw
          .map(
            (e) => CheckoutItem(
              id: e['id'],
              name: e['name'],
              size: e['size'],
              price: e['price'],
              quantity: e['quantity'],
              image: e['image'],
            ),
          )
          .toList();
    });
  }

  double get subtotal =>
      items.fold(0, (sum, item) => sum + (item.price * item.quantity));

  double get total => subtotal + shippingCost;

  String formatCurrency(double amount) {
    return 'Rp${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      extendBody: true,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Checkout',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: items.isEmpty
            ? const Center(
                child: Text(
                  'Silahkan pilih barang yang ingin di checkout di cart',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              )
            : Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          const SizedBox(height: 8),
                          _buildShippingAddressSection(),
                          const SizedBox(height: 8),
                          _buildProductsSection(),
                          const SizedBox(height: 8),
                          _buildPaymentMethodSection(),
                          const SizedBox(height: 8),
                          _buildOrderSummarySection(),
                          const SizedBox(height: 24),

                          // BATAL + CHECKOUT BUTTONS
                          Padding(
                            padding: const EdgeInsets.only(
                              right: 15,
                              left: 200,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                SizedBox(
                                  width: 200,
                                  height: 45,
                                  child: OutlinedButton(
                                    onPressed: () async {
                                      await CheckoutService.clearCheckout();
                                      setState(() {
                                        items = [];
                                      });
                                    },
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(
                                        color: Color(0xFF8B1A1A),
                                        width: 1.5,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: const Text(
                                      'Batal Checkout',
                                      style: TextStyle(
                                        color: Color(0xFF8B1A1A),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 12),

                                // Tombol Checkout
                                SizedBox(
                                  width: 200,
                                  height: 50,
                                  child: ElevatedButton(
                                    onPressed: hasAddress
                                        ? _confirmCheckout
                                        : _showNoAddressWarning,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: hasAddress
                                          ? const Color(0xFF8B1A1A)
                                          : Colors.grey[400],
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: const Text(
                                      'Checkout',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
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

  Widget _buildShippingAddressSection() {
    return GestureDetector(
      onTap: () => _selectAddress(),
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              hasAddress ? Icons.location_on : Icons.location_off_outlined,
              color: hasAddress ? const Color(0xFFE53935) : Colors.grey[400],
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (hasAddress)
                    Text(
                      shippingAddressText,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                        height: 1.4,
                      ),
                    )
                  else
                    Text(
                      'Silahkan set atau tambahkan alamat pengiriman anda',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[500],
                        fontStyle: FontStyle.italic,
                        height: 1.4,
                      ),
                    ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  void _showNoAddressWarning() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.white),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Silahkan pilih atau tambahkan alamat pengiriman terlebih dahulu',
              ),
            ),
          ],
        ),
        backgroundColor: Colors.orange[700],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        action: SnackBarAction(
          label: 'Tambah',
          textColor: Colors.white,
          onPressed: () => _selectAddress(),
        ),
      ),
    );
  }

  void _selectAddress() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ShippingAddressPage(isSelecting: true),
      ),
    );

    if (result != null && result is ShippingAddress) {
      setState(() {
        selectedAddress = result;
      });
    }
  }

  Widget _buildProductsSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Products List
          ...items.map((item) => _buildProductItem(item)).toList(),

          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 12),

          // Total Products Summary
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total ${items.length} Produk',
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
              Text(
                formatCurrency(subtotal),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProductItem(CheckoutItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 70,
              height: 70,
              color: Colors.grey[200],
              child: Image.asset(
                item.image,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.checkroom,
                    size: 35,
                    color: Colors.grey,
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Product Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  item.size,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      formatCurrency(item.price.toDouble()),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF8B1A1A),
                      ),
                    ),
                    Text(
                      '${item.quantity}x',
                      style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Metode Pembayaran',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),

          // COD Option
          _buildPaymentOption(
            'COD',
            'COD - Cash On Delivery',
            Icons.local_shipping_outlined,
          ),

          const SizedBox(height: 12),

          // E-Wallet Option
          _buildPaymentOption(
            'E-Wallet',
            'E-Wallet',
            Icons.credit_card,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption(String value, String label, IconData icon) {
    final isSelected = selectedPaymentMethod == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPaymentMethod = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? const Color(0xFFE53935) : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
          color: isSelected ? const Color(0xFFFFEBEE) : Colors.white,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFE53935) : Colors.grey[200],
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : Colors.grey[600],
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: Colors.black,
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Color(0xFFE53935),
                size: 22,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummarySection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Rincian Pemesanan',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Text(
                '23 November 2025',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Subtotal
          _buildSummaryRow('Subtotal Pesanan', formatCurrency(subtotal)),
          const SizedBox(height: 8),

          // Shipping Cost
          _buildSummaryRow('Subtotal Pengiriman', formatCurrency(shippingCost)),
          const SizedBox(height: 12),

          const Divider(),
          const SizedBox(height: 12),

          // Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Pembayaran',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Text(
                formatCurrency(total),
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF8B1A1A),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[700])),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      height: 90,
      color: Colors.transparent,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Floating background bar dengan cekungan di KIRI
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
                child: Container(
                  height: 65,
                  child: Row(
                    children: [
                      // Left icon - space for floating cart button
                      Expanded(child: Container()),

                      // Center icon - Home
                      Expanded(
                        child: IconButton(
                          icon: const Icon(
                            Icons.home_outlined,
                            color: Colors.white,
                            size: 28,
                          ),
                          onPressed: () {
                            Navigator.popUntil(
                              context,
                              (route) => route.isFirst,
                            );
                          },
                        ),
                      ),

                      // Right icon - Profile
                      Expanded(
                        child: IconButton(
                          icon: const Icon(
                            Icons.person_outline,
                            color: Colors.white,
                            size: 28,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ProfilePage(),
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

          // Floating Cart Button (LEFT) - positioned to align with notch
          Positioned(
            bottom: 90,
            left: 50,
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                width: 58,
                height: 58,
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
                child: const Icon(
                  Icons.payments,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmCheckout() async {
    final selectedIds = items.map((e) => e.id).toList();
    await CartService.removeSelectedItems(selectedIds);
    await CheckoutService.clearCheckout();

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Color(0xFF4CAF50), size: 28),
            SizedBox(width: 12),
            Text('Order Confirmed'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pesanan kamu berhasil dibuat!',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),
            if (hasAddress) ...[
              Text(
                'Alamat Pengiriman:',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              const SizedBox(height: 4),
              Text(
                '${selectedAddress!.address}, ${selectedAddress!.city}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
            ],
            Text(
              'Metode Pembayaran: $selectedPaymentMethod',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            Text(
              'Total: ${formatCurrency(total)}',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color(0xFF8B1A1A),
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // close dialog
              Navigator.popUntil(context, (route) => route.isFirst);
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
    double notchStartX = 60; // Position notch on LEFT side

    // Top-left corner FIX (no artifact)
    path.moveTo(0, cornerRadius);
    path.quadraticBezierTo(-1, 0, cornerRadius, 0);

    // Top edge until notch starts (LEFT SIDE)
    path.lineTo(notchStartX - notchWidth / 2, 0);

    // Left side of notch - curve going up
    path.quadraticBezierTo(
      notchStartX - notchWidth / 2 + 15,
      0,
      notchStartX - notchWidth / 2 + 20,
      0,
    );

    // Main notch curve
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

    // Right side of notch - curve back down
    path.quadraticBezierTo(
      notchStartX + notchWidth / 2 - 15,
      0,
      notchStartX + notchWidth / 2,
      0,
    );

    // Continue top edge to top-right corner
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

class CheckoutItem {
  final String id;
  final String name;
  final String size;
  final int price;
  final int quantity;
  final String image;

  CheckoutItem({
    required this.id,
    required this.name,
    required this.size,
    required this.price,
    required this.quantity,
    required this.image,
  });
}
