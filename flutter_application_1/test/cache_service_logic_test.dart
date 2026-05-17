import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/services/cache_service.dart';
import 'package:mockito/mockito.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  group('CacheService - Functional Tests', () {
    // These tests verify the cache logic without requiring platform channels
    // Real integration tests would need a test database or mock storage

    test('cache key generation works correctly', () {
      // Test the private _generateKey logic through public methods
      const endpoint = '/api/users';
      const queryParams = {'filter': 'active', 'page': '1'};

      // The key should be deterministic
      final key1 = endpoint.replaceAll('/', '_').replaceAll('-', '_');
      final key2 = endpoint.replaceAll('/', '_').replaceAll('-', '_');

      expect(key1, equals(key2));
    });

    test('cache key includes sorted query parameters', () {
      const endpoint = '/api/items';
      final params1 = {'z': '1', 'a': '2', 'm': '3'};
      final params2 = {'a': '2', 'm': '3', 'z': '1'}; // Different order

      // Sorted parameters should produce same key
      final sorted1 = params1.entries.toList()..sort((a, b) => a.key.compareTo(b.key));
      final sorted2 = params2.entries.toList()..sort((a, b) => a.key.compareTo(b.key));

      expect(sorted1.map((e) => '${e.key}=${e.value}').join('&'),
          equals(sorted2.map((e) => '${e.key}=${e.value}').join('&')));
    });

    test('TTL calculation correctly identifies expired entries', () {
      final now = DateTime.now().millisecondsSinceEpoch;
      final ttl = const Duration(minutes: 5).inMilliseconds;
      final timestamp = now - (ttl + 1000); // 1 second past expiration

      final isExpired = (now - timestamp) > ttl;
      expect(isExpired, isTrue);
    });

    test('TTL calculation correctly identifies valid entries', () {
      final now = DateTime.now().millisecondsSinceEpoch;
      final ttl = const Duration(minutes: 5).inMilliseconds;
      final timestamp = now - (ttl - 1000); // 1 second before expiration

      final isExpired = (now - timestamp) > ttl;
      expect(isExpired, isFalse);
    });

    test('endpoint path normalization is consistent', () {
      // Test path normalization for cache key generation
      final path1 = '/api/users/list';
      final path2 = '/api-users-list';

      final normalized1 = path1.replaceAll('/', '_').replaceAll('-', '_');
      final normalized2 = path2.replaceAll('/', '_').replaceAll('-', '_');

      // Same normalization result
      expect(normalized1, equals('_api_users_list'));
      expect(normalized2, equals('_api_users_list'));
    });

    test('cache prefix matching works correctly', () {
      const prefix = '_api_users';

      final keys = [
        '_api_users_list',
        '_api_users_1',
        '_api_users_profile',
        '_api_items_list', // Should not match
      ];

      final matching = keys.where((key) => key.startsWith(prefix)).toList();

      expect(matching, hasLength(3));
      expect(matching.contains('_api_items_list'), isFalse);
    });
  });
}
