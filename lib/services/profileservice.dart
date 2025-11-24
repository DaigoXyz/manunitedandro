import 'dart:convert';
import 'apiservice.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ProfileService {
  static Future<Map<String, dynamic>> getMyProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("jwt_token");

    if (token == null) throw Exception("Token tidak ditemukan");

    final url = Uri.parse(ApiService.url("me"));

    final response = await http.get(
      url,
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Gagal mengambil profile");
    }
  }
}
