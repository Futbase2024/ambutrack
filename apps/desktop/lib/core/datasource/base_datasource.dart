import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Resultado de operaciones de datasource
class DataSourceResult<T> {
  const DataSourceResult.success(this.data) : error = null;
  const DataSourceResult.failure(this.error) : data = null;

  final T? data;
  final Exception? error;

  bool get isSuccess => error == null;
  bool get isFailure => error != null;
}

/// Clase base abstracta para datasources con Supabase
///
/// Proporciona operaciones CRUD básicas y manejo de errores
abstract class BaseDataSource<T> {
  BaseDataSource({
    required this.tableName,
    required this.fromMap,
    required this.toMap,
    String? primaryKey,
  }) : primaryKey = primaryKey ?? 'id';

  /// Nombre de la tabla en Supabase
  final String tableName;

  /// Nombre de la columna de clave primaria
  final String primaryKey;

  /// Función para convertir Map a entidad
  final T Function(Map<String, dynamic> map) fromMap;

  /// Función para convertir entidad a Map
  final Map<String, dynamic> Function(T entity) toMap;

  /// Cliente de Supabase
  SupabaseClient get client => Supabase.instance.client;

  /// Referencia a la tabla
  SupabaseQueryBuilder get table => client.from(tableName);

  /// Obtener todos los registros
  Future<DataSourceResult<List<T>>> getAll({
    String? orderBy,
    bool ascending = true,
    int? limit,
    int? offset,
  }) async {
    try {
      final Stopwatch stopwatch = Stopwatch()..start();

      dynamic query = table.select();

      if (orderBy != null) {
        query = query.order(orderBy, ascending: ascending);
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      if (offset != null && offset > 0) {
        query = query.range(offset, offset + (limit ?? 100) - 1);
      }

      final dynamic rawResponse = await query;
      final int networkTime = stopwatch.elapsedMilliseconds;

      final List<Map<String, dynamic>> response = (rawResponse as List<dynamic>).cast<Map<String, dynamic>>();
      final int castTime = stopwatch.elapsedMilliseconds;

      final List<T> items = response.map(fromMap).toList();
      final int parseTime = stopwatch.elapsedMilliseconds;

      stopwatch.stop();
      debugPrint('⏱️ BaseDataSource[$tableName].getAll() - Total: ${stopwatch.elapsedMilliseconds}ms');
      debugPrint('   📡 Network: ${networkTime}ms');
      debugPrint('   🔄 Cast: ${castTime - networkTime}ms');
      debugPrint('   🔧 Parse: ${parseTime - castTime}ms');
      debugPrint('   📊 Items: ${items.length}');

      return DataSourceResult<List<T>>.success(items);
    } catch (e) {
      return DataSourceResult<List<T>>.failure(Exception(e.toString()));
    }
  }

  /// Obtener un registro por ID
  Future<DataSourceResult<T>> getById(String id) async {
    try {
      final Map<String, dynamic> response = await table.select().eq(primaryKey, id).single();
      return DataSourceResult<T>.success(fromMap(response));
    } catch (e) {
      return DataSourceResult<T>.failure(Exception(e.toString()));
    }
  }

  /// Crear un nuevo registro
  Future<DataSourceResult<T>> create(T entity) async {
    try {
      final Map<String, dynamic> data = toMap(entity);
      final Map<String, dynamic> response = await table.insert(data).select().single();
      return DataSourceResult<T>.success(fromMap(response));
    } catch (e) {
      return DataSourceResult<T>.failure(Exception(e.toString()));
    }
  }

  /// Actualizar un registro existente
  Future<DataSourceResult<T>> update(String id, T entity) async {
    try {
      final Map<String, dynamic> data = toMap(entity);
      final Map<String, dynamic> response = await table.update(data).eq(primaryKey, id).select().single();
      return DataSourceResult<T>.success(fromMap(response));
    } catch (e) {
      return DataSourceResult<T>.failure(Exception(e.toString()));
    }
  }

  /// Eliminar un registro
  Future<DataSourceResult<void>> delete(String id) async {
    try {
      await table.delete().eq(primaryKey, id);
      return const DataSourceResult<void>.success(null);
    } catch (e) {
      return DataSourceResult<void>.failure(Exception(e.toString()));
    }
  }

  /// Buscar registros con filtro
  Future<DataSourceResult<List<T>>> query({
    required String column,
    required Object value,
    String? orderBy,
    bool ascending = true,
    int? limit,
  }) async {
    try {
      dynamic queryBuilder = table.select().eq(column, value);

      if (orderBy != null) {
        queryBuilder = queryBuilder.order(orderBy, ascending: ascending);
      }

      if (limit != null) {
        queryBuilder = queryBuilder.limit(limit);
      }

      final dynamic rawResponse = await queryBuilder;
      final List<Map<String, dynamic>> response = (rawResponse as List<dynamic>).cast<Map<String, dynamic>>();
      final List<T> items = response.map(fromMap).toList();
      return DataSourceResult<List<T>>.success(items);
    } catch (e) {
      return DataSourceResult<List<T>>.failure(Exception(e.toString()));
    }
  }

  /// Contar registros
  Future<DataSourceResult<int>> count() async {
    try {
      final dynamic response = await table.select().count(CountOption.exact);
      final int count = (response as PostgrestResponse<dynamic>).count;
      return DataSourceResult<int>.success(count);
    } catch (e) {
      return DataSourceResult<int>.failure(Exception(e.toString()));
    }
  }
}
