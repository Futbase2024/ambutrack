import 'dart:async';
import '../typedefs/datasource_typedefs.dart';

/// Mixin that provides caching capabilities to datasources
///
/// This mixin implements an in-memory cache with TTL support
/// and automatic cleanup of expired entries
mixin CacheMixin<T> {
  /// Internal cache storage
  final Map<CacheKey, CacheEntry<T>> _cache = {};

  /// Timer for periodic cache cleanup
  Timer? _cleanupTimer;

  /// Default cache duration (5 minutes)
  Duration get defaultCacheDuration => const Duration(minutes: 5);

  /// How often to run cache cleanup (1 minute)
  Duration get cleanupInterval => const Duration(minutes: 1);

  /// Maximum number of entries in cache
  int get maxCacheSize => 1000;

  /// Retrieves an item from cache
  ///
  /// Returns null if the item is not in cache or has expired
  T? getFromCache(CacheKey key) {
    final entry = _cache[key];
    if (entry == null) return null;

    // Check if entry has expired
    if (_isExpired(entry)) {
      _cache.remove(key);
      return null;
    }

    return entry.data;
  }

  /// Saves an item to cache with optional TTL
  ///
  /// If no TTL is provided, uses the default cache duration
  void saveToCache(CacheKey key, T value, {Duration? ttl}) {
    // Enforce cache size limit
    if (_cache.length >= maxCacheSize) {
      _evictOldestEntries();
    }

    final entry = (
      data: value,
      timestamp: DateTime.now(),
      ttl: ttl ?? defaultCacheDuration,
    );

    _cache[key] = entry;
    _startCleanupTimer();
  }

  /// Removes a specific item from cache
  void removeFromCache(CacheKey key) {
    _cache.remove(key);
  }

  /// Clears all items from cache
  void clearCache() {
    _cache.clear();
    _stopCleanupTimer();
  }

  /// Checks if cache contains a specific key (and it's not expired)
  bool containsInCache(CacheKey key) {
    return getFromCache(key) != null;
  }

  /// Gets the size of the current cache
  int get cacheSize => _cache.length;

  /// Gets cache statistics
  Map<String, dynamic> getCacheStats() {
    final now = DateTime.now();
    var expiredCount = 0;
    var totalSize = 0;

    for (final entry in _cache.values) {
      if (_isExpired(entry)) {
        expiredCount++;
      }
      totalSize++;
    }

    return {
      'totalEntries': totalSize,
      'expiredEntries': expiredCount,
      'validEntries': totalSize - expiredCount,
      'maxSize': maxCacheSize,
      'lastCleanup': now.toIso8601String(),
    };
  }

  /// Manually triggers cache cleanup
  void cleanupExpiredEntries() {
    final keysToRemove = <CacheKey>[];

    for (final entry in _cache.entries) {
      if (_isExpired(entry.value)) {
        keysToRemove.add(entry.key);
      }
    }

    for (final key in keysToRemove) {
      _cache.remove(key);
    }
  }

  /// Creates a cache key from multiple parts
  CacheKey createCacheKey(List<String> parts) {
    return parts.join(':');
  }

  /// Creates a cache key for entity operations
  CacheKey createEntityCacheKey(String operation, String entityId) {
    return '$operation:$entityId';
  }

  /// Creates a cache key for queries
  CacheKey createQueryCacheKey(String operation, Map<String, dynamic> params) {
    final sortedParams = Map.fromEntries(
      params.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    );
    final paramString = sortedParams.entries
        .map((e) => '${e.key}=${e.value}')
        .join('&');
    return '$operation:query:$paramString';
  }

  /// Invalidates cache entries matching a pattern
  void invalidateCachePattern(String pattern) {
    final regex = RegExp(pattern);
    final keysToRemove = _cache.keys.where((key) => regex.hasMatch(key)).toList();

    for (final key in keysToRemove) {
      _cache.remove(key);
    }
  }

  /// Invalidates all cache entries for a specific entity
  void invalidateEntityCache(String entityId) {
    invalidateCachePattern('.*:$entityId\$');
  }

  /// Pre-warms the cache with data
  void preWarmCache(Map<CacheKey, T> data, {Duration? ttl}) {
    for (final entry in data.entries) {
      saveToCache(entry.key, entry.value, ttl: ttl);
    }
  }

  /// Checks if a cache entry has expired
  bool _isExpired(CacheEntry<T> entry) {
    if (entry.ttl == null) return false;
    final expiry = entry.timestamp.add(entry.ttl!);
    return DateTime.now().isAfter(expiry);
  }

  /// Evicts the oldest entries when cache is full
  void _evictOldestEntries() {
    const evictionCount = 100; // Remove 100 entries at once
    final sortedEntries = _cache.entries.toList()
      ..sort((a, b) => a.value.timestamp.compareTo(b.value.timestamp));

    for (var i = 0; i < evictionCount && i < sortedEntries.length; i++) {
      _cache.remove(sortedEntries[i].key);
    }
  }

  /// Starts the periodic cleanup timer
  void _startCleanupTimer() {
    _cleanupTimer?.cancel();
    _cleanupTimer = Timer.periodic(cleanupInterval, (_) {
      cleanupExpiredEntries();
    });
  }

  /// Stops the cleanup timer
  void _stopCleanupTimer() {
    _cleanupTimer?.cancel();
    _cleanupTimer = null;
  }

  /// Disposes cache resources
  void disposeCache() {
    clearCache();
    _stopCleanupTimer();
  }
}