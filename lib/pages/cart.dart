import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'checkout.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<CartItem> cartItems = [];
  final double shippingCost = 200000;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCartItems();
  }

  // Load cart items from SharedPreferences
  Future<void> _loadCartItems() async {
    final prefs = await SharedPreferences.getInstance();
    final cartJson = prefs.getString('cart_items');

    if (cartJson != null) {
      final List<dynamic> decoded = jsonDecode(cartJson);
      setState(() {
        cartItems = decoded.map((item) => CartItem.fromJson(item)).toList();
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Save cart items to SharedPreferences
  Future<void> _saveCartItems() async {
    final prefs = await SharedPreferences.getInstance();
    final cartJson = jsonEncode(
      cartItems.map((item) => item.toJson()).toList(),
    );
    await prefs.setString('cart_items', cartJson);
  }

  bool get isAllSelected {
    return cartItems.isNotEmpty && cartItems.every((item) => item.isSelected);
  }

  int get selectedItemsCount {
    return cartItems.where((item) => item.isSelected).length;
  }

  double get subtotal {
    return cartItems
        .where((item) => item.isSelected)
        .fold(0, (sum, item) => sum + (item.price * item.quantity));
  }

  double get total {
    return selectedItemsCount > 0 ? subtotal + shippingCost : 0;
  }

  void toggleSelectAll() {
    setState(() {
      bool newValue = !isAllSelected;
      for (var item in cartItems) {
        item.isSelected = newValue;
      }
    });
    _saveCartItems();
  }

  void toggleItemSelection(String itemId) {
    setState(() {
      final item = cartItems.firstWhere((item) => item.id == itemId);
      item.isSelected = !item.isSelected;
    });
    _saveCartItems();
  }

  void incrementQuantity(String itemId) {
    setState(() {
      final item = cartItems.firstWhere((item) => item.id == itemId);
      item.quantity++;
    });
    _saveCartItems();
  }

  void decrementQuantity(String itemId) {
    setState(() {
      final item = cartItems.firstWhere((item) => item.id == itemId);
      if (item.quantity > 1) {
        item.quantity--;
      }
    });
    _saveCartItems();
  }

  void removeItem(String itemId) {
    setState(() {
      cartItems.removeWhere((item) => item.id == itemId);
    });
    _saveCartItems();
  }

  String formatCurrency(double amount) {
    return 'Rp${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'My Cart',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF8B1A1A)),
            )
          : cartItems.isEmpty
          ? _buildEmptyCart()
          : Column(
              children: [
                // Select All Section
                _buildSelectAllSection(),

                // Cart Items List
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      return _buildCartItem(cartItems[index]);
                    },
                  ),
                ),

                // Bottom Summary Section
                _buildBottomSummary(),
              ],
            ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 100,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Your cart is empty',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add items to get started',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B1A1A),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Start Shopping',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectAllSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: toggleSelectAll,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isAllSelected ? const Color(0xFF8B1A1A) : Colors.white,
                border: Border.all(
                  color: isAllSelected
                      ? const Color(0xFF8B1A1A)
                      : Colors.grey[400]!,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: isAllSelected
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'Select All',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(CartItem item) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Checkbox
          GestureDetector(
            onTap: () => toggleItemSelection(item.id),
            child: Container(
              width: 24,
              height: 24,
              margin: const EdgeInsets.only(top: 8),
              decoration: BoxDecoration(
                color: item.isSelected ? const Color(0xFF8B1A1A) : Colors.white,
                border: Border.all(
                  color: item.isSelected
                      ? const Color(0xFF8B1A1A)
                      : Colors.grey[400]!,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: item.isSelected
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
          ),
          const SizedBox(width: 12),

          // Product Image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 80,
              height: 80,
              color: Colors.grey[200],
              child: Image.asset(
                item.image,
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

          // Product Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Name
                Text(
                  item.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),

                // Size
                Text(
                  'Ukuran: ${item.size}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),

                // Price
                Text(
                  formatCurrency(item.price.toDouble()),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF8B1A1A),
                  ),
                ),
                const SizedBox(height: 8),

                // Quantity Controls and Delete
                Row(
                  children: [
                    // Quantity Controls
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          // Decrement Button
                          InkWell(
                            onTap: () => decrementQuantity(item.id),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              child: const Icon(Icons.remove, size: 16),
                            ),
                          ),
                          // Quantity
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              '${item.quantity}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          // Increment Button
                          InkWell(
                            onTap: () => incrementQuantity(item.id),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              child: const Icon(Icons.add, size: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    // Delete Button
                    IconButton(
                      onPressed: () => _showDeleteConfirmation(item),
                      icon: Icon(
                        Icons.delete_outline,
                        color: Colors.grey[600],
                        size: 20,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
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

  Widget _buildBottomSummary() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Subtotal
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Subtotal',
                    style: TextStyle(fontSize: 14, color: Colors.black),
                  ),
                  Text(
                    formatCurrency(subtotal),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Shipping Cost
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Ongkir',
                    style: TextStyle(fontSize: 14, color: Colors.black),
                  ),
                  Text(
                    selectedItemsCount > 0
                        ? formatCurrency(shippingCost)
                        : 'Rp0',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              const Divider(),
              const SizedBox(height: 8),

              // Total
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    formatCurrency(total),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF8B1A1A),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Checkout Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: selectedItemsCount > 0
                      ? () => _proceedToCheckout()
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B1A1A),
                    disabledBackgroundColor: Colors.grey[300],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    selectedItemsCount > 0
                        ? 'Lanjut ke pembayaran ($selectedItemsCount item)'
                        : 'Pilih item untuk checkout',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: selectedItemsCount > 0
                          ? Colors.white
                          : Colors.grey,
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

  void _showDeleteConfirmation(CartItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Remove Item',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to remove "${item.name}" from your cart?',
          style: const TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              removeItem(item.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Item removed from cart'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE53935),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Remove', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _proceedToCheckout() {
    final selectedItems = cartItems.where((item) => item.isSelected).toList();

    // Convert CartItem to CheckoutItem
    final checkoutItems = selectedItems.map((cartItem) {
      return CheckoutItem(
        id: cartItem.id,
        name: cartItem.name,
        size: cartItem.size,
        price: cartItem.price,
        quantity: cartItem.quantity,
        image: cartItem.image,
      );
    }).toList();

    // Navigate to checkout page with selected items
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CheckoutPage(items: checkoutItems),
      ),
    ).then((_) {
      // Reload cart when coming back from checkout
      _loadCartItems();
    });
  }
}

// Cart Item Model
class CartItem {
  final String id;
  final String name;
  final String size;
  final int price;
  int quantity;
  final String image;
  bool isSelected;

  CartItem({
    required this.id,
    required this.name,
    required this.size,
    required this.price,
    required this.quantity,
    required this.image,
    this.isSelected = false,
  });

  // Convert CartItem to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'size': size,
      'price': price,
      'quantity': quantity,
      'image': image,
      'isSelected': isSelected,
    };
  }

  // Create CartItem from JSON
  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'],
      name: json['name'],
      size: json['size'],
      price: json['price'],
      quantity: json['quantity'],
      image: json['image'],
      isSelected: json['isSelected'] ?? false,
    );
  }
}
