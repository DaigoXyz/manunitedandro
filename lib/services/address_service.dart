import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/shippingaddressmodel.dart';
import 'apiservice.dart';

class AddressService {

  // Get auth token from SharedPreferences
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  // Get headers with auth token
  static Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // GET - Fetch all user shipping addresses
  static Future<List<ShippingAddress>> getAddresses() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse(ApiService.url("shipping-addresses")),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => ShippingAddress.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized. Please login again.');
      } else {
        throw Exception('Failed to load addresses');
      }
    } catch (e) {
      throw Exception('Error fetching addresses: $e');
    }
  }

  // GET - Fetch single address by ID
  static Future<ShippingAddress> getAddressById(String id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse(ApiService.url("shipping-addresses/$id")),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return ShippingAddress.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 404) {
        throw Exception('Address not found');
      } else {
        throw Exception('Failed to load address');
      }
    } catch (e) {
      throw Exception('Error fetching address: $e');
    }
  }

  // POST - Create new shipping address
  static Future<String> createAddress({
    required String address,
    required String city,
    required String province,
    required String postalCode,
    required String phone,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse(ApiService.url("shipping-addresses")),
        headers: headers,
        body: jsonEncode({
          'address': address,
          'city': city,
          'province': province,
          'postal_code': postalCode,
          'phone': phone,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data['id'];
      } else if (response.statusCode == 400) {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Invalid data');
      } else {
        throw Exception('Failed to create address');
      }
    } catch (e) {
      throw Exception('Error creating address: $e');
    }
  }

  // PUT - Update existing shipping address
  static Future<void> updateAddress({
    required String id,
    required String address,
    required String city,
    required String province,
    required String postalCode,
    required String phone,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse(ApiService.url("shipping-addresses/$id")),
        headers: headers,
        body: jsonEncode({
          'address': address,
          'city': city,
          'province': province,
          'postal_code': postalCode,
          'phone': phone,
        }),
      );

      if (response.statusCode == 200) {
        return;
      } else if (response.statusCode == 404) {
        throw Exception('Address not found');
      } else if (response.statusCode == 403) {
        throw Exception('Unauthorized to update this address');
      } else {
        throw Exception('Failed to update address');
      }
    } catch (e) {
      throw Exception('Error updating address: $e');
    }
  }

  // DELETE - Delete shipping address
  static Future<void> deleteAddress(String id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse(ApiService.url("shipping-addresses/$id")),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return;
      } else if (response.statusCode == 404) {
        throw Exception('Address not found');
      } else if (response.statusCode == 403) {
        throw Exception('Unauthorized to delete this address');
      } else {
        throw Exception('Failed to delete address');
      }
    } catch (e) {
      throw Exception('Error deleting address: $e');
    }
  }
}
