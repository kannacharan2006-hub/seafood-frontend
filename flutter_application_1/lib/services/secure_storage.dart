import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  static const String _tokenKey = "auth_token";
  static const String _sessionKey = "session_time";

  /* ================= SAVE TOKEN ================= */

  static Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
    await _storage.write(
      key: _sessionKey,
      value: DateTime.now().millisecondsSinceEpoch.toString(),
    );
  }

  /* ================= GET TOKEN ================= */

  static Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  /* ================= CHECK LOGIN ================= */

  static Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: _tokenKey);
    return token != null && token.isNotEmpty;
  }

  /* ================= DELETE TOKEN ================= */

  static Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _sessionKey);
  }

  /* ================= CLEAR ALL ================= */

  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
