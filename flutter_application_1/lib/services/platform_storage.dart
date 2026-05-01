import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PlatformStorage {
  static PlatformStorage? _instance;
  static bool _useSecureStorage = false;
  static FlutterSecureStorage? _secureStorage;
  static SharedPreferences? _prefs;

  static Future<PlatformStorage> get instance async {
    if (_instance != null) return _instance!;

    if (kIsWeb) {
      _prefs = await SharedPreferences.getInstance();
      _useSecureStorage = false;
    } else {
      _secureStorage = const FlutterSecureStorage();
      _useSecureStorage = true;
    }

    _instance = PlatformStorage();
    return _instance!;
  }

  Future<void> write(String key, String value) async {
    if (_useSecureStorage) {
      await _secureStorage!.write(key: key, value: value);
    } else {
      await _prefs!.setString(key, value);
    }
  }

  Future<String?> read(String key) async {
    if (_useSecureStorage) {
      return await _secureStorage!.read(key: key);
    } else {
      return _prefs!.getString(key);
    }
  }

  Future<void> delete(String key) async {
    if (_useSecureStorage) {
      await _secureStorage!.delete(key: key);
    } else {
      await _prefs!.remove(key);
    }
  }

  Future<void> deleteAll() async {
    if (_useSecureStorage) {
      await _secureStorage!.deleteAll();
    } else {
      await _prefs!.clear();
    }
  }

  Future<Map<String, String>> readAll() async {
    if (_useSecureStorage) {
      return await _secureStorage!.readAll();
    } else {
      final result = <String, String>{};
      for (final key in _prefs!.getKeys()) {
        final value = _prefs!.get(key);
        if (value is String) {
          result[key] = value;
        }
      }
      return result;
    }
  }
}
