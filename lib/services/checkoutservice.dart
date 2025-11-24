import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CheckoutService {
  static const String _checkoutKey = 'checkout_items';

  /// Simpan item checkout ke SharedPreferences
  static Future<void> saveCheckoutItems(List<Map<String, dynamic>> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_checkoutKey, jsonEncode(items));
  }

  /// Ambil item checkout
  static Future<List<Map<String, dynamic>>> getCheckoutItems() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_checkoutKey);

    if (jsonStr == null) return [];
    try {
      return List<Map<String, dynamic>>.from(jsonDecode(jsonStr));
    } catch (e) {
      return [];
    }
  }

  /// Bersihkan semua item checkout
  static Future<void> clearCheckout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_checkoutKey);
  }
}
