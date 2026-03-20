import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/secure_storage.dart';


class Api {
  static const String baseUrl = "http://172.22.42.235:5000";
  //static const String baseUrl = "https://unkilling-hyperexcitably-kaylee.ngrok-free.dev";
  
  static const Duration timeout = Duration(seconds: 10);

  /* ================= HEADERS ================= */

  static Future<Map<String, String>> _headers() async {
    String? token = await SecureStorage.getToken();

    return {
      "Content-Type": "application/json",
      if (token != null) "Authorization": "Bearer $token",
    };
  }

  /* ================= GENERIC REQUEST ================= */

  static Future<dynamic> _request(
    String method,
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    try {
      final uri = Uri.parse("$baseUrl$endpoint");

      http.Response response;

      switch (method) {
        case "POST":
          response = await http
              .post(uri, headers: await _headers(), body: jsonEncode(body))
              .timeout(timeout);
          break;

        case "PUT":
          response = await http
              .put(uri, headers: await _headers(), body: jsonEncode(body))
              .timeout(timeout);
          break;

        case "DELETE":
          response = await http
              .delete(uri, headers: await _headers())
              .timeout(timeout);
          break;

        default:
          response = await http
              .get(uri, headers: await _headers())
              .timeout(timeout);
      }

      return _handleResponse(response);
    } catch (e) {
      throw Exception("Network error. Please check your connection.");
    }
  }

  /* ================= PUBLIC METHODS ================= */

  static Future<dynamic> get(String endpoint) {
    return _request("GET", endpoint);
  }

  static Future<dynamic> post(String endpoint, Map<String, dynamic> body) {
    return _request("POST", endpoint, body: body);
  }

  static Future<dynamic> put(String endpoint, Map<String, dynamic> body) {
    return _request("PUT", endpoint, body: body);
  }

  static Future<dynamic> delete(String endpoint) {
    return _request("DELETE", endpoint);
  }

  /* ================= RESPONSE HANDLER ================= */

  static dynamic _handleResponse(http.Response response) {
    dynamic data;

    try {
      data = jsonDecode(response.body);
    } catch (_) {
      data = {"message": "Invalid server response"};
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    }

    if (response.statusCode == 401) {
      SecureStorage.deleteToken();
      throw Exception("Session expired. Please login again.");
    }

    throw Exception(data["message"] ?? "Request failed");
  }
}
