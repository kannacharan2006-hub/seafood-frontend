import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/secure_storage.dart';
import '../services/cache_service.dart';
import '../services/connectivity_service.dart';
import 'app_config.dart';

class Api {
  static String get baseUrl => AppConfig.baseUrl;
  static const Duration timeout = Duration(seconds: 30);
  static Future<String>? _refreshingToken;
  static bool _isRefreshing = false;
  static bool _cacheEnabled = true;

  static void setCacheEnabled(bool enabled) {
    _cacheEnabled = enabled;
  }

  static Future<Map<String, String>> _headers() async {
    String? token = await SecureStorage.getToken();
    return {
      "Content-Type": "application/json",
      "Accept": "application/json",
      if (token != null) "Authorization": "Bearer $token",
    };
  }

  static Future<String> _refreshToken() async {
    if (_refreshingToken != null) {
      return _refreshingToken!;
    }

    final completer = Completer<String>();
    _refreshingToken = completer.future;

    try {
      final result = await _doRefreshToken();
      completer.complete(result);
      return result;
    } catch (e) {
      completer.completeError(e);
      rethrow;
    } finally {
      _refreshingToken = null;
    }
  }

  static Future<String> _doRefreshToken() async {
    final refreshToken = await SecureStorage.getRefreshToken();
    if (refreshToken == null) {
      await _logout();
      throw Exception("Session expired. Please login again.");
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
        throw Exception("Session expired. Please login again.");
      }
    } catch (e) {
      await _logout();
      throw Exception("Session expired. Please login again.");
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
    Duration? cacheTtl,
  }) async {
    // Check connectivity before making API call
    final hasConnection = await ConnectivityService().checkConnection();
    if (!hasConnection) {
      throw Exception(
          "No internet connection. Please check your network and try again.");
    }

    try {
      final uri = Uri.parse("$baseUrl$endpoint");
      http.Response response;

      if (method == "GET" && _cacheEnabled && cacheTtl != null) {
        final cached = await CacheService.get(endpoint);
        if (cached != null) return cached;
      }

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
            return _request(method, endpoint, body: body, retry: false);
          } catch (e) {
            _isRefreshing = false;
            rethrow;
          }
        } else {
          await _refreshingToken;
          return _request(method, endpoint, body: body, retry: false);
        }
      }

      final result = _handleResponse(response);

      if (method == "GET" &&
          _cacheEnabled &&
          cacheTtl != null &&
          response.statusCode >= 200 &&
          response.statusCode < 300) {
        await CacheService.set(endpoint, result, ttl: cacheTtl);
      }

      if (method == "POST" || method == "PUT" || method == "DELETE") {
        await CacheService.invalidatePrefix(endpoint.split('?').first);
      }

      return result;
    } catch (e) {
      rethrow;
    }
  }

  static Future<dynamic> get(String endpoint, {Duration? cacheTtl}) {
    return _request("GET", endpoint, cacheTtl: cacheTtl);
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
      message = data["message"] ?? data["Message"] ?? data["error"];
    }

    final errorMsg = message ?? _getDefaultErrorMessage(response.statusCode);
    throw Exception(errorMsg);
  }

  static String _getDefaultErrorMessage(int statusCode) {
    switch (statusCode) {
      case 400:
        return 'Invalid request. Please check your input.';
      case 403:
        return 'You do not have permission to perform this action.';
      case 404:
        return 'The requested resource was not found.';
      case 429:
        return 'Too many requests. Please wait a moment and try again.';
      case 500:
      case 502:
      case 503:
        return 'Server error. Please try again later.';
      default:
        return 'Request failed with status $statusCode';
    }
  }

  static Future<void> logout() async {
    await _logout();
  }
}
