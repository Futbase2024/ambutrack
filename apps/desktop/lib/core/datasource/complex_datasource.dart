import 'dart:async';

import 'package:ambutrack_desktop/core/datasource/base_datasource.dart';
import 'package:flutter/foundation.dart';

/// DataSource para entidades dinámicas con lógica de negocio
///
/// Características:
/// - Cache de duración moderada (15 minutos por defecto)
/// - CRUD completo con validaciones
/// - Ideal para: usuarios, servicios, vehículos, personal
class ComplexDataSource<T> extends BaseDataSource<T> {
  ComplexDataSource({
    required super.tableName,
    required super.fromMap,
    required super.toMap,
    super.primaryKey,
    this.cacheDuration = const Duration(minutes: 15),
  });

  /// Duración del cache
  final Duration cacheDuration;

  /// Cache de datos por ID
  final Map<String, _CacheEntry<T>> _cache = <String, _CacheEntry<T>>{};

  /// Cache de lista completa
  _CacheEntry<List<T>>? _listCache;

  /// Indica si el cache de un item es válido
  bool _isItemCacheValid(String id) {
    final _CacheEntry<T>? entry = _cache[id];
    if (entry == null) {
      return false;
    }
    return DateTime.now().difference(entry.timestamp) < cacheDuration;
  }

  /// Indica si el cache de lista es válido
  bool get _isListCacheValid {
    if (_listCache == null) {
      return false;
    }
    return DateTime.now().difference(_listCache!.timestamp) < cacheDuration;
  }

  /// Obtener todos los registros (con cache)
  @override
  Future<DataSourceResult<List<T>>> getAll({
    String? orderBy,
    bool ascending = true,
    int? limit,
    int? offset,
    bool forceRefresh = false,
  }) async {
    final Stopwatch stopwatch = Stopwatch()..start();
    debugPrint('💾 ComplexDataSource[$tableName]: getAll() - forceRefresh: $forceRefresh');

    // Retornar cache si es válido y no se fuerza refresh
    if (!forceRefresh && _isListCacheValid && _listCache != null) {
      stopwatch.stop();
      debugPrint('💾 ComplexDataSource[$tableName]: ⚡ Usando cache (${_listCache!.data.length} items) en ${stopwatch.elapsedMilliseconds}ms');
      return DataSourceResult<List<T>>.success(_listCache!.data);
    }

    debugPrint('💾 ComplexDataSource[$tableName]: 🌐 Fetching desde Supabase...');
    // Fetch desde Supabase
    final DataSourceResult<List<T>> result = await super.getAll(
      orderBy: orderBy,
      ascending: ascending,
      limit: limit,
      offset: offset,
    );

    stopwatch.stop();
    debugPrint('💾 ComplexDataSource[$tableName]: Resultado - Success: ${result.isSuccess}, Items: ${result.data?.length ?? 0}, Tiempo total: ${stopwatch.elapsedMilliseconds}ms');

    // Actualizar cache si fue exitoso
    if (result.isSuccess && result.data != null) {
      _listCache = _CacheEntry<List<T>>(result.data!);

      // También actualizar cache individual
      for (final T item in result.data!) {
        final Map<String, dynamic> map = toMap(item);
        final String? id = map[primaryKey]?.toString();
        if (id != null) {
          _cache[id] = _CacheEntry<T>(item);
        }
      }
      debugPrint('💾 ComplexDataSource[$tableName]: ✅ Cache actualizado');
    } else {
      debugPrint('💾 ComplexDataSource[$tableName]: ❌ Error: ${result.error}');
    }

    return result;
  }

  /// Obtener un registro por ID (con cache)
  @override
  Future<DataSourceResult<T>> getById(String id) async {
    // Retornar cache si es válido
    if (_isItemCacheValid(id)) {
      return DataSourceResult<T>.success(_cache[id]!.data);
    }

    // Fetch desde Supabase
    final DataSourceResult<T> result = await super.getById(id);

    // Actualizar cache si fue exitoso
    if (result.isSuccess && result.data != null) {
      _cache[id] = _CacheEntry<T>(result.data as T);
    }

    return result;
  }

  /// Crear un nuevo registro (invalida cache de lista)
  @override
  Future<DataSourceResult<T>> create(T entity) async {
    final DataSourceResult<T> result = await super.create(entity);

    // Invalidar cache de lista y actualizar cache individual
    if (result.isSuccess && result.data != null) {
      _listCache = null;
      final Map<String, dynamic> map = toMap(result.data as T);
      final String? id = map[primaryKey]?.toString();
      if (id != null) {
        _cache[id] = _CacheEntry<T>(result.data as T);
      }
    }

    return result;
  }

  /// Actualizar un registro (actualiza cache)
  @override
  Future<DataSourceResult<T>> update(String id, T entity) async {
    final DataSourceResult<T> result = await super.update(id, entity);

    // Actualizar cache
    if (result.isSuccess && result.data != null) {
      _cache[id] = _CacheEntry<T>(result.data as T);
      _listCache = null; // Invalidar lista
    }

    return result;
  }

  /// Eliminar un registro (invalida cache)
  @override
  Future<DataSourceResult<void>> delete(String id) async {
    final DataSourceResult<void> result = await super.delete(id);

    // Remover de cache
    if (result.isSuccess) {
      _cache.remove(id);
      _listCache = null;
    }

    return result;
  }

  /// Invalidar todo el cache
  void invalidateCache() {
    _cache.clear();
    _listCache = null;
  }

  /// Invalidar cache de un item específico
  void invalidateItem(String id) {
    _cache.remove(id);
    _listCache = null;
  }

  /// Crear o actualizar (upsert)
  Future<DataSourceResult<T>> upsert(T entity) async {
    try {
      final Map<String, dynamic> data = toMap(entity);
      final List<dynamic> response = await table.upsert(data).select();

      if (response.isEmpty) {
        return DataSourceResult<T>.failure(Exception('No se pudo crear o actualizar el registro'));
      }

      final T result = fromMap(response.first as Map<String, dynamic>);

      // Actualizar cache
      final String? id = data[primaryKey]?.toString();
      if (id != null) {
        _cache[id] = _CacheEntry<T>(result);
      }
      _listCache = null;

      return DataSourceResult<T>.success(result);
    } catch (e) {
      return DataSourceResult<T>.failure(Exception(e.toString()));
    }
  }

  /// Crear múltiples registros
  Future<DataSourceResult<List<T>>> createMany(List<T> entities) async {
    try {
      final List<Map<String, dynamic>> data = entities.map(toMap).toList();
      final List<dynamic> response = await table.insert(data).select();

      final List<T> items = response.map((Object? item) => fromMap(item! as Map<String, dynamic>)).toList();

      // Actualizar cache
      for (final T item in items) {
        final Map<String, dynamic> map = toMap(item);
        final String? id = map[primaryKey]?.toString();
        if (id != null) {
          _cache[id] = _CacheEntry<T>(item);
        }
      }
      _listCache = null;

      return DataSourceResult<List<T>>.success(items);
    } catch (e) {
      return DataSourceResult<List<T>>.failure(Exception(e.toString()));
    }
  }

  /// Eliminar múltiples registros
  Future<DataSourceResult<void>> deleteMany(List<String> ids) async {
    try {
      await table.delete().inFilter(primaryKey, ids);

      // Remover de cache
      for (final String id in ids) {
        _cache.remove(id);
      }
      _listCache = null;

      return const DataSourceResult<void>.success(null);
    } catch (e) {
      return DataSourceResult<void>.failure(Exception(e.toString()));
    }
  }
}

/// Entrada de cache con timestamp
class _CacheEntry<T> {
  _CacheEntry(this.data) : timestamp = DateTime.now();

  final T data;
  final DateTime timestamp;
}
