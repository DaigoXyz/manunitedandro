import 'package:flutter/material.dart';
import 'productdetail.dart';

class OrderHistoryPage extends StatefulWidget {
  const OrderHistoryPage({super.key});

  @override
  State<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  // Sample order history data
  final List<OrderItem> orders = [
    OrderItem(
      productName: 'Manchester United Womens 25/26 Home Jersey',
      size: '2XL',
      price: 1375000,
      quantity: 2,
      image: 'assets/images/jersey1.png',
      orderDate: '23 November 2025',
    ),
    OrderItem(
      productName: 'Manchester United Womens 25/26 Home Authentic Jersey',
      size: 'L',
      price: 1916360,
      quantity: 1,
      image: 'assets/images/banner2.png',
      orderDate: '20 November 2025',
    ),
  ];

  final List<Map<String, dynamic>> productsData = [
    {
      'id': 1,
      'name': 'Manchester United Womens 25/26 Home Jersey',
      'price': 1375000,
      'image': 'assets/images/jersey1.png',
      'category': 'Jersey',
      'gender': 'Woman',
    },
    {
      'id': 2,
      'name': 'Manchester United Womens 25/26 Home Authentic Jersey',
      'price': 1916360,
      'image': 'assets/images/banner2.png',
      'category': 'Jersey',
      'gender': 'Woman',
    },
  ];

  String formatCurrency(double amount) {
    return 'Rp${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
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
          'Riwayat Pesanan',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: orders.isEmpty
          ? _buildEmptyState()
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView.builder(
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  return _buildOrderCard(orders[index]);
                },
              ),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_bag_outlined, size: 100, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Belum ada riwayat pesanan',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Mulai belanja sekarang!',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(OrderItem order) {
    double itemTotal = order.price.toDouble() * order.quantity.toDouble();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // PRODUCT HEADER
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 80,
                  height: 80,
                  color: Colors.grey[200],
                  child: Image.asset(
                    order.image,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.checkroom,
                        size: 40,
                        color: Colors.grey,
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.productName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      order.size,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      formatCurrency(order.price.toDouble()),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF8B1A1A),
                      ),
                    ),
                  ],
                ),
              ),

              Text(
                '${order.quantity}x',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Divider(color: Colors.grey[300]),

          const SizedBox(height: 8),

          // TOTAL PER PRODUCT
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total (${order.quantity} Produk)',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                formatCurrency(itemTotal.toDouble()),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // BUTTON BELI LAGI
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: () => _buyAgainSingle(order),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B1A1A),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Beli lagi',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _buyAgainSingle(OrderItem order) {
    final matchedProduct = productsData.firstWhere(
      (p) => p['name'] == order.productName,
      orElse: () => {},
    );

    if (matchedProduct.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Produk tidak ditemukan")),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailPage(
          productId: matchedProduct['id'],
        ),
      ),
    );
  }
}
class OrderItem {
  final String productName;
  final String size;
  final int price;
  final int quantity;
  final String image;
  final String orderDate;

  OrderItem({
    required this.productName,
    required this.size,
    required this.price,
    required this.quantity,
    required this.image,
    required this.orderDate,
  });
}
