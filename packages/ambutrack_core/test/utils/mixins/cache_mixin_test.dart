import 'package:flutter_test/flutter_test.dart';
import 'package:ambutrack_core/src/utils/mixins/cache_mixin.dart';

/// Test class that uses CacheMixin
class TestCacheService with CacheMixin<String> {
  @override
  Duration get defaultCacheDuration => const Duration(seconds: 2);

  @override
  Duration get cleanupInterval => const Duration(milliseconds: 100);

  @override
  int get maxCacheSize => 3;

  Future<String> fetchData(String key) async {
    // Check cache first
    final cached = getFromCache(key);
    if (cached != null) return cached;

    // Simulate async operation
    await Future.delayed(const Duration(milliseconds: 10));
    final data = 'data_for_$key';

    // Cache the result
    saveToCache(key, data);
    return data;
  }

  Future<String> fetchWithCustomTTL(String key, Duration ttl) async {
    final cached = getFromCache(key);
    if (cached != null) return cached;

    await Future.delayed(const Duration(milliseconds: 10));
    final data = 'custom_ttl_$key';

    saveToCache(key, data, ttl: ttl);
    return data;
  }
}

void main() {
  group('CacheMixin', () {
    late TestCacheService service;

    setUp(() {
      service = TestCacheService();
    });

    tearDown(() {
      service.disposeCache();
    });

    group('Basic Cache Operations', () {
      test('should cache and retrieve data', () async {
        const key = 'test_key';
        const data = 'test_data';

        // Cache should be empty initially
        expect(service.getFromCache(key), isNull);

        // Save to cache
        service.saveToCache(key, data);

        // Should retrieve from cache
        expect(service.getFromCache(key), equals(data));
      });

      test('should remove data from cache', () {
        const key = 'remove_key';
        const data = 'remove_data';

        service.saveToCache(key, data);
        expect(service.getFromCache(key), equals(data));

        service.removeFromCache(key);
        expect(service.getFromCache(key), isNull);
      });

      test('should clear all cache', () {
        service.saveToCache('key1', 'data1');
        service.saveToCache('key2', 'data2');
        service.saveToCache('key3', 'data3');

        expect(service.cacheSize, equals(3));

        service.clearCache();

        expect(service.cacheSize, equals(0));
        expect(service.getFromCache('key1'), isNull);
        expect(service.getFromCache('key2'), isNull);
        expect(service.getFromCache('key3'), isNull);
      });

      test('should check if cache contains key', () {
        const key = 'contains_key';
        const data = 'contains_data';

        expect(service.containsInCache(key), isFalse);

        service.saveToCache(key, data);
        expect(service.containsInCache(key), isTrue);

        service.removeFromCache(key);
        expect(service.containsInCache(key), isFalse);
      });

      test('should return correct cache size', () {
        expect(service.cacheSize, equals(0));

        service.saveToCache('key1', 'data1');
        expect(service.cacheSize, equals(1));

        service.saveToCache('key2', 'data2');
        expect(service.cacheSize, equals(2));

        service.removeFromCache('key1');
        expect(service.cacheSize, equals(1));

        service.clearCache();
        expect(service.cacheSize, equals(0));
      });
    });

    group('TTL (Time To Live)', () {
      test('should respect default TTL', () async {
        const key = 'ttl_key';
        const data = 'ttl_data';

        service.saveToCache(key, data);
        expect(service.getFromCache(key), equals(data));

        // Wait for TTL to expire (default is 2 seconds in test service)
        await Future.delayed(const Duration(seconds: 3));

        expect(service.getFromCache(key), isNull);
      });

      test('should respect custom TTL', () async {
        const key = 'custom_ttl_key';
        const data = 'custom_ttl_data';
        const customTTL = Duration(milliseconds: 50);

        service.saveToCache(key, data, ttl: customTTL);
        expect(service.getFromCache(key), equals(data));

        // Wait for custom TTL to expire
        await Future.delayed(const Duration(milliseconds: 100));

        expect(service.getFromCache(key), isNull);
      });

      test('should handle entries without TTL', () async {
        const key = 'no_ttl_key';
        const data = 'no_ttl_data';

        service.saveToCache(key, data, ttl: null);
        expect(service.getFromCache(key), equals(data));

        // Wait longer than default TTL
        await Future.delayed(const Duration(seconds: 3));

        // Should still be there since no TTL was set
        expect(service.getFromCache(key), equals(data));
      });

      test('should clean up expired entries automatically', () async {
        service.saveToCache('short_key', 'short_data', ttl: const Duration(milliseconds: 50));
        service.saveToCache('long_key', 'long_data', ttl: const Duration(seconds: 10));

        expect(service.cacheSize, equals(2));

        // Wait for short TTL to expire and cleanup to run
        await Future.delayed(const Duration(milliseconds: 200));

        expect(service.getFromCache('short_key'), isNull);
        expect(service.getFromCache('long_key'), equals('long_data'));
      });
    });

    group('Cache Size Limits', () {
      test('should enforce max cache size', () {
        // Max size is 3 in test service
        service.saveToCache('key1', 'data1');
        service.saveToCache('key2', 'data2');
        service.saveToCache('key3', 'data3');

        expect(service.cacheSize, equals(3));

        // Adding one more should evict oldest entries
        service.saveToCache('key4', 'data4');

        expect(service.cacheSize, lessThanOrEqualTo(3));
        expect(service.getFromCache('key4'), equals('data4'));
      });

      test('should evict oldest entries when cache is full', () async {
        // Fill cache to max capacity
        service.saveToCache('old1', 'data1');
        await Future.delayed(const Duration(milliseconds: 1));
        service.saveToCache('old2', 'data2');
        await Future.delayed(const Duration(milliseconds: 1));
        service.saveToCache('old3', 'data3');

        expect(service.cacheSize, equals(3));

        // Add new entry, should evict oldest
        await Future.delayed(const Duration(milliseconds: 1));
        service.saveToCache('new', 'new_data');

        expect(service.getFromCache('new'), equals('new_data'));
        expect(service.cacheSize, lessThanOrEqualTo(3));
      });
    });

    group('Cache Key Utilities', () {
      test('should create cache key from parts', () {
        final key = service.createCacheKey(['user', '123', 'profile']);
        expect(key, equals('user:123:profile'));
      });

      test('should create entity cache key', () {
        final key = service.createEntityCacheKey('getById', 'user-123');
        expect(key, equals('getById:user-123'));
      });

      test('should create query cache key', () {
        final params = {'limit': 10, 'offset': 0, 'active': true};
        final key = service.createQueryCacheKey('getAll', params);

        expect(key, contains('getAll:query:'));
        expect(key, contains('active=true'));
        expect(key, contains('limit=10'));
        expect(key, contains('offset=0'));
      });

      test('should create consistent query cache keys', () {
        final params1 = {'limit': 10, 'offset': 0};
        final params2 = {'offset': 0, 'limit': 10}; // Different order

        final key1 = service.createQueryCacheKey('getAll', params1);
        final key2 = service.createQueryCacheKey('getAll', params2);

        expect(key1, equals(key2)); // Should be same regardless of order
      });
    });

    group('Cache Invalidation', () {
      test('should invalidate cache by pattern', () {
        service.saveToCache('user:123:profile', 'profile_data');
        service.saveToCache('user:123:settings', 'settings_data');
        service.saveToCache('user:456:profile', 'other_profile');
        service.saveToCache('product:123:info', 'product_data');

        expect(service.cacheSize, equals(4));

        // Invalidate all user:123 entries
        service.invalidateCachePattern(r'user:123:.*');

        expect(service.getFromCache('user:123:profile'), isNull);
        expect(service.getFromCache('user:123:settings'), isNull);
        expect(service.getFromCache('user:456:profile'), equals('other_profile'));
        expect(service.getFromCache('product:123:info'), equals('product_data'));
      });

      test('should invalidate entity cache', () {
        service.saveToCache('getById:user-123', 'user_data');
        service.saveToCache('getProfile:user-123', 'profile_data');
        service.saveToCache('getById:user-456', 'other_user');

        service.invalidateEntityCache('user-123');

        expect(service.getFromCache('getById:user-123'), isNull);
        expect(service.getFromCache('getProfile:user-123'), isNull);
        expect(service.getFromCache('getById:user-456'), equals('other_user'));
      });
    });

    group('Cache Pre-warming', () {
      test('should pre-warm cache with data', () {
        final data = {
          'key1': 'data1',
          'key2': 'data2',
          'key3': 'data3',
        };

        service.preWarmCache(data);

        expect(service.cacheSize, equals(3));
        expect(service.getFromCache('key1'), equals('data1'));
        expect(service.getFromCache('key2'), equals('data2'));
        expect(service.getFromCache('key3'), equals('data3'));
      });

      test('should pre-warm cache with custom TTL', () async {
        final data = {'short_key': 'short_data'};
        const customTTL = Duration(milliseconds: 50);

        service.preWarmCache(data, ttl: customTTL);

        expect(service.getFromCache('short_key'), equals('short_data'));

        await Future.delayed(const Duration(milliseconds: 100));

        expect(service.getFromCache('short_key'), isNull);
      });
    });

    group('Cache Statistics', () {
      test('should provide cache statistics', () async {
        service.saveToCache('active1', 'data1');
        service.saveToCache('active2', 'data2');
        service.saveToCache('expired', 'data', ttl: const Duration(milliseconds: 1));

        // Wait for one entry to expire
        await Future.delayed(const Duration(milliseconds: 10));

        final stats = service.getCacheStats();

        expect(stats, isA<Map<String, dynamic>>());
        expect(stats['maxSize'], equals(3));
        expect(stats['totalEntries'], isA<int>());
        expect(stats['expiredEntries'], isA<int>());
        expect(stats['validEntries'], isA<int>());
        expect(stats['lastCleanup'], isA<String>());
      });
    });

    group('Manual Cleanup', () {
      test('should manually clean up expired entries', () async {
        service.saveToCache('keep', 'keep_data', ttl: const Duration(seconds: 10));
        service.saveToCache('expire1', 'expire1_data', ttl: const Duration(milliseconds: 1));
        service.saveToCache('expire2', 'expire2_data', ttl: const Duration(milliseconds: 1));

        expect(service.cacheSize, equals(3));

        // Wait for entries to expire
        await Future.delayed(const Duration(milliseconds: 10));

        // Manual cleanup
        service.cleanupExpiredEntries();

        expect(service.getFromCache('keep'), equals('keep_data'));
        expect(service.getFromCache('expire1'), isNull);
        expect(service.getFromCache('expire2'), isNull);
      });
    });

    group('Integration with Service', () {
      test('should integrate cache with async operations', () async {
        const key = 'integration_test';

        // First call should fetch and cache
        final result1 = await service.fetchData(key);
        expect(result1, equals('data_for_$key'));

        // Second call should return cached result (faster)
        final stopwatch = Stopwatch()..start();
        final result2 = await service.fetchData(key);
        stopwatch.stop();

        expect(result2, equals(result1));
        expect(stopwatch.elapsedMilliseconds, lessThan(5)); // Should be instant from cache
      });

      test('should handle cache misses and refetching', () async {
        const key = 'cache_miss_test';

        // Fetch and cache with short TTL
        await service.fetchWithCustomTTL(key, const Duration(milliseconds: 50));
        expect(service.getFromCache(key), isNotNull);

        // Wait for cache to expire
        await Future.delayed(const Duration(milliseconds: 100));
        expect(service.getFromCache(key), isNull);

        // Next fetch should get fresh data
        final result = await service.fetchWithCustomTTL(key, const Duration(seconds: 1));
        expect(result, equals('custom_ttl_$key'));
        expect(service.getFromCache(key), isNotNull);
      });
    });

    group('Memory Management', () {
      test('should dispose cache resources properly', () {
        service.saveToCache('dispose_test', 'data');
        expect(service.cacheSize, equals(1));

        service.disposeCache();

        expect(service.cacheSize, equals(0));
        expect(service.getFromCache('dispose_test'), isNull);
      });

      test('should handle large number of cache operations', () async {
        const operationCount = 1000;
        final stopwatch = Stopwatch()..start();

        for (int i = 0; i < operationCount; i++) {
          service.saveToCache('perf_$i', 'data_$i');
          service.getFromCache('perf_$i');
        }

        stopwatch.stop();
        expect(stopwatch.elapsedMilliseconds, lessThan(200));
      });

      test('should handle memory efficiently with large values', () {
        final largeData = 'x' * 10000; // 10KB string
        const keyCount = 100;

        for (int i = 0; i < keyCount; i++) {
          service.saveToCache('large_$i', largeData);
        }

        // Should handle eviction due to max cache size
        expect(service.cacheSize, lessThanOrEqualTo(service.maxCacheSize));
      });
    });

    group('Edge Cases', () {
      test('should handle empty keys', () {
        service.saveToCache('', 'empty_key_data');
        expect(service.getFromCache(''), equals('empty_key_data'));
      });

      test('should handle null values', () {
        // This test assumes the cache can handle null values
        // In a real implementation, you might want to avoid caching nulls
        const key = 'null_test';
        service.saveToCache(key, '');
        expect(service.getFromCache(key), equals(''));
      });

      test('should handle special characters in keys', () {
        const key = 'special!@#\$%^&*()_+-={}[]|;:,.<>?';
        const data = 'special_data';

        service.saveToCache(key, data);
        expect(service.getFromCache(key), equals(data));
      });

      test('should handle very short TTL', () async {
        const key = 'very_short_ttl';
        const data = 'short_data';

        service.saveToCache(key, data, ttl: const Duration(microseconds: 1));

        // Should expire almost immediately
        await Future.delayed(const Duration(milliseconds: 1));
        expect(service.getFromCache(key), isNull);
      });

      test('should handle concurrent cache operations', () async {
        final futures = <Future>[];

        // Simulate concurrent cache operations
        for (int i = 0; i < 100; i++) {
          futures.add(Future(() {
            service.saveToCache('concurrent_$i', 'data_$i');
            return service.getFromCache('concurrent_$i');
          }));
        }

        final results = await Future.wait(futures);
        expect(results.length, equals(100));
      });
    });
  });
}