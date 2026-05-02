import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CacheService {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  static const String _cachePrefix = 'cache_';

  static Future<void> set(String key, dynamic data, {Duration? ttl}) async {
    final cacheData = {
      'data': data,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'ttl': ttl?.inMilliseconds,
    };
    await _storage.write(
      key: '$_cachePrefix$key',
      value: jsonEncode(cacheData),
    );
  }

  static Future<T?> get<T>(String key) async {
    try {
      final cached = await _storage.read(key: '$_cachePrefix$key');
      if (cached == null) return null;

      final decoded = jsonDecode(cached);
      if (decoded is! Map<String, dynamic>) return null;

      final cacheData = decoded;
      final timestamp = cacheData['timestamp'];
      final ttl = cacheData['ttl'];

      if (timestamp is! int) return null;
      if (ttl is int) {
        final now = DateTime.now().millisecondsSinceEpoch;
        if (now - timestamp > ttl) {
          await remove(key);
          return null;
        }
      }

      final data = cacheData['data'];
      if (data is T) return data;
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<bool> has(String key) async {
    final cached = await _storage.read(key: '$_cachePrefix$key');
    if (cached == null) return false;

    try {
      final decoded = jsonDecode(cached);
      if (decoded is! Map<String, dynamic>) return false;

      final cacheData = decoded;
      final timestamp = cacheData['timestamp'];
      final ttl = cacheData['ttl'];

      if (timestamp is! int) return false;
      if (ttl is int) {
        final now = DateTime.now().millisecondsSinceEpoch;
        if (now - timestamp > ttl) {
          await remove(key);
          return false;
        }
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<void> remove(String key) async {
    await _storage.delete(key: '$_cachePrefix$key');
  }

  static Future<void> clear() async {
    final all = await _storage.readAll();
    final cacheKeys = all.keys.where((key) => key.startsWith(_cachePrefix));
    for (final key in cacheKeys) {
      await _storage.delete(key: key);
    }
  }

  static String _generateKey(String endpoint,
      {Map<String, dynamic>? queryParams}) {
    var key = endpoint.replaceAll('/', '_').replaceAll('-', '_');
    if (queryParams != null && queryParams.isNotEmpty) {
      final sorted = queryParams.entries.toList()
        ..sort((a, b) => a.key.compareTo(b.key));
      key += '_${sorted.map((e) => '${e.key}=${e.value}').join('&')}';
    }
    return key;
  }

  static Future<T?> getOrFetch<T>(
    String endpoint, {
    Duration? ttl,
    Map<String, dynamic>? queryParams,
    required Future<T> Function() fetch,
  }) async {
    final cacheKey = _generateKey(endpoint, queryParams: queryParams);
    final cached = await get<T>(cacheKey);
    if (cached != null) return cached;

    final data = await fetch();
    await set(cacheKey, data, ttl: ttl);
    return data;
  }

  static Future<void> invalidate(String endpoint,
      {Map<String, dynamic>? queryParams}) async {
    final cacheKey = _generateKey(endpoint, queryParams: queryParams);
    await remove(cacheKey);
  }

  static Future<void> invalidatePrefix(String endpointPrefix) async {
    final all = await _storage.readAll();
    final prefix =
        '$_cachePrefix${endpointPrefix.replaceAll('/', '_').replaceAll('-', '_')}';
    for (final key in all.keys) {
      if (key.startsWith(prefix)) {
        await _storage.delete(key: key);
      }
    }
  }
}
