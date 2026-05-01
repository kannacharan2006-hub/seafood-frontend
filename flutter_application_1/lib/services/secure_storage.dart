import 'platform_storage.dart';

class SecureStorage {
  static const String _tokenKey = "auth_token";
  static const String _refreshTokenKey = "refresh_token";
  static const String _sessionKey = "session_time";

  static Future<void> saveToken(String token) async {
    final storage = await PlatformStorage.instance;
    await storage.write(_tokenKey, token);
    await storage.write(
      _sessionKey,
      DateTime.now().millisecondsSinceEpoch.toString(),
    );
  }

  static Future<void> saveRefreshToken(String refreshToken) async {
    final storage = await PlatformStorage.instance;
    await storage.write(_refreshTokenKey, refreshToken);
  }

  static Future<String?> getToken() async {
    final storage = await PlatformStorage.instance;
    final token = await storage.read(_tokenKey);
    if (token == null) return null;

    final sessionTimeStr = await storage.read(_sessionKey);
    if (sessionTimeStr == null) return token;

    final sessionTime = int.tryParse(sessionTimeStr);
    if (sessionTime == null) return token;

    final now = DateTime.now().millisecondsSinceEpoch;
    const sessionDurationHours = 24;
    final sessionDuration =
        const Duration(hours: sessionDurationHours).inMilliseconds;

    if (now - sessionTime > sessionDuration) {
      await deleteToken();
      await deleteRefreshToken();
      return null;
    }

    return token;
  }

  static Future<String?> getRefreshToken() async {
    final storage = await PlatformStorage.instance;
    return await storage.read(_refreshTokenKey);
  }

  static Future<bool> isLoggedIn() async {
    final storage = await PlatformStorage.instance;
    final token = await storage.read(_tokenKey);
    return token != null && token.isNotEmpty;
  }

  static Future<void> deleteToken() async {
    final storage = await PlatformStorage.instance;
    await storage.delete(_tokenKey);
    await storage.delete(_sessionKey);
  }

  static Future<void> deleteRefreshToken() async {
    final storage = await PlatformStorage.instance;
    await storage.delete(_refreshTokenKey);
  }

  static Future<void> clearAll() async {
    final storage = await PlatformStorage.instance;
    await storage.deleteAll();
  }

  static Future<void> saveData(String key, String value) async {
    final storage = await PlatformStorage.instance;
    await storage.write(key, value);
  }

  static Future<String?> getData(String key) async {
    final storage = await PlatformStorage.instance;
    return await storage.read(key);
  }
}
