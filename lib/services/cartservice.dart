import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class CartService {
  static const String _cartKey = 'cart_items';

  // Add item to cart
  static Future<void> addToCart({
    required String productId,
    required String name,
    required String size,
    required int price,
    required String image,
    int quantity = 1,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final cartJson = prefs.getString(_cartKey);

    List<Map<String, dynamic>> cartItems = [];

    if (cartJson != null) {
      cartItems = List<Map<String, dynamic>>.from(jsonDecode(cartJson));
    }

    // Check if item with same product and size already exists
    final uniqueId = '${productId}_$size';

    int existingIndex = cartItems.indexWhere((item) => item['id'] == uniqueId);


    if (existingIndex != -1) {
      // Item exists, increment quantity
      cartItems[existingIndex]['quantity'] += quantity;
    } else {
      // Add new item
      cartItems.add({
        'id': '${productId}_$size', // Unique ID combining product and size
        'name': name,
        'size': size,
        'price': price,
        'quantity': quantity,
        'image': image,
        'isSelected': false,
      });
    }

    // Save to SharedPreferences
    await prefs.setString(_cartKey, jsonEncode(cartItems));
  }

  // Get cart items count
  static Future<int> getCartItemsCount() async {
    final prefs = await SharedPreferences.getInstance();
    final cartJson = prefs.getString(_cartKey);

    if (cartJson != null) {
      final List<dynamic> cartItems = jsonDecode(cartJson);
      return cartItems.length;
    }

    return 0;
  }

  // Clear cart
  static Future<void> clearCart() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cartKey);
  }

  // Remove selected items from cart (after checkout)
  static Future<void> removeSelectedItems(List<String> selectedItemIds) async {
    final prefs = await SharedPreferences.getInstance();
    final cartJson = prefs.getString(_cartKey);

    if (cartJson != null) {
      List<Map<String, dynamic>> cartItems = List<Map<String, dynamic>>.from(
        jsonDecode(cartJson),
      );

      // Remove items with matching IDs
      cartItems.removeWhere((item) => selectedItemIds.contains(item['id']));

      // Save updated cart
      await prefs.setString(_cartKey, jsonEncode(cartItems));
    }
  }
}
