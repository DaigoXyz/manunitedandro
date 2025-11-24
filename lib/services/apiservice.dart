class ApiService {
  // Ganti ini kalau server berubah
  static const String baseUrl = "http://10.99.25.71:8080/api";

  static String url(String endpoint) {
    return "$baseUrl/$endpoint";
  }
}