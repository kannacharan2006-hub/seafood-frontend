import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/secure_storage.dart';

class Api {
  static const String baseUrl = "http://10.140.52.112:5000";
  //static const String baseUrl = "https://unkilling-hyperexcitably-kaylee.ngrok-free.dev";
  
  static const Duration timeout = Duration(seconds: 10);

  static String _sanitizeString(String input) {
    return input
        .replaceAll(RegExp(r'[\x00-\x1F\x7F]'), '')
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .trim();
  }

  static Map<String, dynamic> _sanitizeBody(Map<String, dynamic>? body) {
    if (body == null) return {};
    final sanitized = <String, dynamic>{};
    for (final entry in body.entries) {
      if (entry.value is String) {
        sanitized[entry.key] = _sanitizeString(entry.value as String);
      } else if (entry.value is Map) {
        sanitized[entry.key] = _sanitizeBody(entry.value as Map<String, dynamic>);
      } else if (entry.value is List) {
        sanitized[entry.key] = entry.value;
      } else {
        sanitized[entry.key] = entry.value;
      }
    }
    return sanitized;
  }

  /* ================= HEADERS ================= */

  static Future<Map<String, String>> _headers() async {
    String? token = await SecureStorage.getToken();

    return {
      "Content-Type": "application/json",
      "Accept": "application/json",
      "X-Requested-With": "XMLHttpRequest",
      "X-Content-Type-Options": "nosniff",
      "X-Frame-Options": "DENY",
      "Cache-Control": "no-store",
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
      final cleanBody = _sanitizeBody(body);

      http.Response response;

      switch (method) {
        case "POST":
          response = await http
              .post(uri, headers: await _headers(), body: jsonEncode(cleanBody))
              .timeout(timeout);
          break;

        case "PUT":
          response = await http
              .put(uri, headers: await _headers(), body: jsonEncode(cleanBody))
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

    if (response.statusCode == 403) {
      throw Exception("Access denied");
    }

    if (response.statusCode >= 500) {
      throw Exception("Server error. Please try later.");
    }

    throw Exception(data["message"] ?? "Request failed");
  }
}
