class ApiService {
  // Ganti ini kalau server berubah
  static const String baseUrl = "http://192.168.137.1:8080/api";

  static String url(String endpoint) {
    return "$baseUrl/$endpoint";
  }
}