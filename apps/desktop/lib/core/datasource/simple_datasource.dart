import 'dart:async';

import 'package:ambutrack_desktop/core/datasource/base_datasource.dart';

/// DataSource para datos estáticos o de referencia
///
/// Características:
/// - Cache de larga duración (60 minutos por defecto)
/// - Actualizaciones poco frecuentes
/// - Ideal para: catálogos, tipos, categorías, configuraciones
class SimpleDataSource<T> extends BaseDataSource<T> {
  SimpleDataSource({
    required super.tableName,
    required super.fromMap,
    required super.toMap,
    super.primaryKey,
    this.cacheDuration = const Duration(minutes: 60),
  });

  /// Duración del cache
  final Duration cacheDuration;

  /// Cache de datos
  List<T>? _cache;

  /// Timestamp del último fetch
  DateTime? _lastFetch;

  /// Indica si el cache es válido
  bool get _isCacheValid {
    if (_cache == null || _lastFetch == null) {
      return false;
    }
    return DateTime.now().difference(_lastFetch!) < cacheDuration;
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
    // Retornar cache si es válido y no se fuerza refresh
    if (!forceRefresh && _isCacheValid && _cache != null) {
      return DataSourceResult<List<T>>.success(_cache!);
    }

    // Fetch desde Supabase
    final DataSourceResult<List<T>> result = await super.getAll(
      orderBy: orderBy,
      ascending: ascending,
      limit: limit,
      offset: offset,
    );

    // Actualizar cache si fue exitoso
    if (result.isSuccess) {
      _cache = result.data;
      _lastFetch = DateTime.now();
    }

    return result;
  }

  /// Invalidar el cache
  void invalidateCache() {
    _cache = null;
    _lastFetch = null;
  }

  /// Refrescar el cache
  Future<DataSourceResult<List<T>>> refresh({
    String? orderBy,
    bool ascending = true,
  }) async {
    return getAll(
      orderBy: orderBy,
      ascending: ascending,
      forceRefresh: true,
    );
  }

  /// Obtener un registro por ID (busca en cache primero)
  Future<DataSourceResult<T>> getByIdCached(
    String id, {
    String? idField,
  }) async {
    // Buscar en cache primero
    if (_isCacheValid && _cache != null) {
      try {
        final T? item = _cache!.firstWhere(
          (T item) {
            final Map<String, dynamic> map = toMap(item);
            return map[idField ?? primaryKey] == id;
          },
        );
        if (item != null) {
          return DataSourceResult<T>.success(item);
        }
      } catch (_) {
        // No encontrado en cache, buscar en BD
      }
    }

    // Buscar en base de datos
    return super.getById(id);
  }
}
