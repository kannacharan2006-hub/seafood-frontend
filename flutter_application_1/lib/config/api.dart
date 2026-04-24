import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/secure_storage.dart';
import 'app_config.dart';

class Api {
  static String get baseUrl => AppConfig.baseUrl;
  static const Duration timeout = Duration(seconds: 30);
  static bool _isRefreshing = false;
  static final List<Function()> _pendingRequests = [];

  static Future<Map<String, String>> _headers() async {
    String? token = await SecureStorage.getToken();
    return {
      "Content-Type": "application/json",
      "Accept": "application/json",
      if (token != null) "Authorization": "Bearer $token",
    };
  }

  static Future<String> _refreshToken() async {
    final refreshToken = await SecureStorage.getRefreshToken();
    if (refreshToken == null) {
      throw Exception("No refresh token");
    }

    try {
      final uri = Uri.parse("$baseUrl/api/auth/refresh-token");
      final response = await http
          .post(
            uri,
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({"refreshToken": refreshToken}),
          )
          .timeout(timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final newToken = data['data']['token'];
        await SecureStorage.saveToken(newToken);
        return newToken;
      } else {
        await _logout();
        throw Exception("Session expired");
      }
    } catch (e) {
      await _logout();
      throw Exception("Session expired");
    }
  }

  static Future<void> _logout() async {
    final refreshToken = await SecureStorage.getRefreshToken();
    final token = await SecureStorage.getToken();

    if (token != null && refreshToken != null) {
      try {
        await http
            .post(
              Uri.parse("$baseUrl/api/auth/logout"),
              headers: {
                "Content-Type": "application/json",
                "Authorization": "Bearer $token",
              },
              body: jsonEncode({"refreshToken": refreshToken}),
            )
            .timeout(timeout);
      } catch (_) {}
    }
    await SecureStorage.clearAll();
  }

  static Future<dynamic> _request(
    String method,
    String endpoint, {
    Map<String, dynamic>? body,
    bool retry = true,
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
          response =
              await http.get(uri, headers: await _headers()).timeout(timeout);
      }

      if (response.statusCode == 401 && retry) {
        if (!_isRefreshing) {
          _isRefreshing = true;
          try {
            await _refreshToken();
            _isRefreshing = false;
            for (final callback in _pendingRequests) {
              callback();
            }
            _pendingRequests.clear();
            return _request(method, endpoint, body: body, retry: false);
          } catch (e) {
            _isRefreshing = false;
            _pendingRequests.clear();
            rethrow;
          }
        } else {
          final completer = Completer<dynamic>();
          _pendingRequests.add(() async {
            try {
              final result =
                  await _request(method, endpoint, body: body, retry: true);
              completer.complete(result);
            } catch (e) {
              completer.completeError(e);
            }
          });
          return completer.future;
        }
      }

      return _handleResponse(response);
    } catch (e) {
      rethrow;
    }
  }

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

  static dynamic _handleResponse(http.Response response) {
    dynamic data;

    try {
      data = jsonDecode(response.body);
    } catch (_) {
      data = {
        "message":
            response.body.isNotEmpty ? response.body : "Invalid server response"
      };
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    }

    if (response.statusCode == 401) {
      throw Exception("Session expired. Please login again.");
    }

    String? message;
    if (data is Map) {
      message = data["message"] ?? data["Message"];
    }
    throw Exception(message ?? "Request failed");
  }

  static Future<void> logout() async {
    await _logout();
  }
}
