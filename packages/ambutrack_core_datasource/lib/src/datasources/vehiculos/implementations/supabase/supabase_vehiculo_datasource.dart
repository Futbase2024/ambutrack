import 'package:supabase_flutter/supabase_flutter.dart';

import '../../vehiculos_contract.dart';
import '../../entities/vehiculos_entity.dart';
import '../../models/vehiculo_supabase_model.dart';

/// Implementación del datasource de vehículos con Supabase
class SupabaseVehiculoDataSource implements VehiculoDataSource {
  /// Constructor con cliente de Supabase y nombre de tabla configurables
  SupabaseVehiculoDataSource({
    SupabaseClient? supabase,
    String tableName = 'tvehiculos',
  })  : _supabase = supabase ?? Supabase.instance.client,
        _tableName = tableName;

  final SupabaseClient _supabase;
  final String _tableName;

  // ========== CACHÉ EN MEMORIA (ESTÁTICO) ==========

  /// Caché en memoria ESTÁTICO de la lista de vehículos
  /// Al ser estático, persiste entre diferentes instancias del DataSource
  static List<VehiculoEntity>? _cachedVehiculos;

  /// Timestamp de la última actualización del caché (ESTÁTICO)
  static DateTime? _cacheTimestamp;

  /// Duración del caché (5 minutos)
  static const Duration _cacheDuration = Duration(minutes: 5);

  /// Verifica si el caché es válido
  static bool get _isCacheValid {
    if (_cachedVehiculos == null || _cacheTimestamp == null) {
      return false;
    }

    final Duration elapsed = DateTime.now().difference(_cacheTimestamp!);
    return elapsed < _cacheDuration;
  }

  /// Limpia el caché manualmente
  static void clearCache() {
    _cachedVehiculos = null;
    _cacheTimestamp = null;
    // ignore: avoid_print
    print('📦 SupabaseVehiculoDataSource: 🗑️ Caché limpiado manualmente');
  }

  // ========== MÉTODOS DE BaseDatasource ==========

  @override
  Future<List<VehiculoEntity>> getAll({
    int? limit,
    int? offset,
  }) async {
    try {
      final DateTime startTime = DateTime.now();

      // Si no hay paginación, intentar usar caché
      if (limit == null && offset == null && _isCacheValid) {
        final Duration cacheAge = DateTime.now().difference(_cacheTimestamp!);
        // ignore: avoid_print
        print('📦 SupabaseVehiculoDataSource: ✅ Usando caché (${_cachedVehiculos!.length} vehículos, edad: ${cacheAge.inSeconds}s)');
        return _cachedVehiculos!;
      }

      // ignore: avoid_print
      print('📦 SupabaseVehiculoDataSource: 🔄 Cargando desde Supabase (caché ${_isCacheValid ? "válido pero con paginación" : "inválido o vacío"})...');

      // SELECT con todos los campos que mapea VehiculoSupabaseModel (excluye fotos/documentos
      // y demás columnas pesadas). Si se añade un campo al modelo, AÑADIRLO AQUÍ también,
      // o el formulario de edición lo sobrescribirá con null al guardar.
      const String selectFields = '''
        id,
        created_at,
        updated_at,
        matricula,
        tipo_vehiculo,
        categoria,
        marca,
        modelo,
        anio_fabricacion,
        numero_bastidor,
        estado,
        empresa_id,
        proxima_itv,
        fecha_vencimiento_seguro,
        homologacion_sanitaria,
        fecha_vencimiento_homologacion,
        numero_interno,
        alias,
        clasificacion,
        km_actual,
        ubicacion_actual,
        requiere_cap,
        tiene_silla_electrica,
        numero_carros,
        tiene_soporte_silla_electrica,
        capacidad_pasajeros,
        capacidad_camilla,
        equipamiento,
        fecha_adquisicion,
        observaciones,
        ultimo_mantenimiento,
        proximo_mantenimiento,
        km_proximo_mantenimiento,
        created_by,
        updated_by
      ''';

      dynamic query = _supabase.from(_tableName).select(selectFields);

      if (offset != null) {
        query = query.range(offset, offset + (limit ?? 100) - 1);
      } else if (limit != null) {
        query = query.limit(limit);
      }

      final dynamic response = await query.order('matricula', ascending: true);

      final List<VehiculoEntity> vehiculos = (response as List)
          .map((json) => VehiculoSupabaseModel.fromJson(json as Map<String, dynamic>).toEntity())
          .toList();

      // Solo cachear si no hay paginación
      if (limit == null && offset == null) {
        _cachedVehiculos = vehiculos;
        _cacheTimestamp = DateTime.now();
        final Duration elapsed = DateTime.now().difference(startTime);
        // ignore: avoid_print
        print('📦 SupabaseVehiculoDataSource: ✅ Caché actualizado (${vehiculos.length} vehículos, tiempo: ${elapsed.inMilliseconds}ms)');
      }

      return vehiculos;
    } catch (e) {
      throw Exception('Error al obtener vehículos: $e');
    }
  }

  @override
  Future<VehiculoEntity?> getById(String id) async {
    try {
      final Map<String, dynamic>? response = await _supabase
          .from(_tableName)
          .select()
          .eq('id', id)
          .maybeSingle();

      if (response == null) {
        return null;
      }

      return VehiculoSupabaseModel.fromJson(response).toEntity();
    } catch (e) {
      throw Exception('Error al obtener vehículo por ID: $e');
    }
  }

  @override
  Future<VehiculoEntity> create(VehiculoEntity entity) async {
    try {
      final model = VehiculoSupabaseModel.fromEntity(entity);
      final json = model.toJson();

      // Eliminar campos UUID vacíos para evitar errores de PostgreSQL
      final List<String> uuidFields = ['id', 'created_by', 'updated_by', 'empresa_id'];
      for (final String field in uuidFields) {
        if (json[field] == null || json[field] == '') {
          json.remove(field);
        }
      }

      // Eliminar campos de fecha null opcionales
      if (json['updated_at'] == null) {
        json.remove('updated_at');
      }

      final Map<String, dynamic> response = await _supabase
          .from(_tableName)
          .insert(json)
          .select()
          .single();

      // Invalidar caché después de crear
      SupabaseVehiculoDataSource.clearCache();

      return VehiculoSupabaseModel.fromJson(response).toEntity();
    } catch (e) {
      throw Exception('Error al crear vehículo: $e');
    }
  }

  @override
  Future<VehiculoEntity> update(VehiculoEntity entity) async {
    try {
      final model = VehiculoSupabaseModel.fromEntity(entity);
      final json = model.toJson();

      // Eliminar campos inmutables/autogenerados que no deben actualizarse
      json.remove('id');
      json.remove('created_at');
      json.remove('empresa_id'); // empresa_id no debe cambiar después de la creación

      // Eliminar campos UUID vacíos para evitar errores
      final List<String> uuidFields = ['created_by', 'updated_by'];
      for (final String field in uuidFields) {
        if (json[field] == null || json[field] == '') {
          json.remove(field);
        }
      }

      final Map<String, dynamic> response = await _supabase
          .from(_tableName)
          .update(json)
          .eq('id', entity.id)
          .select()
          .single();

      // Invalidar caché después de actualizar
      SupabaseVehiculoDataSource.clearCache();

      return VehiculoSupabaseModel.fromJson(response).toEntity();
    } catch (e) {
      throw Exception('Error al actualizar vehículo: $e');
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      await _supabase
          .from(_tableName)
          .delete()
          .eq('id', id);

      // Invalidar caché después de eliminar
      SupabaseVehiculoDataSource.clearCache();
    } catch (e) {
      throw Exception('Error al eliminar vehículo: $e');
    }
  }

  @override
  Stream<List<VehiculoEntity>> watchAll({String? orderBy, bool ascending = true}) {
    try {
      return _supabase
          .from(_tableName)
          .stream(primaryKey: ['id'])
          .order(orderBy ?? 'matricula', ascending: ascending)
          .map((data) {
            return data
                .map((json) => VehiculoSupabaseModel.fromJson(json).toEntity())
                .toList();
          });
    } catch (e) {
      throw Exception('Error en stream de vehículos: $e');
    }
  }

  @override
  Stream<VehiculoEntity?> watchById(String id) {
    try {
      return _supabase
          .from(_tableName)
          .stream(primaryKey: ['id'])
          .eq('id', id)
          .map((data) {
            if (data.isEmpty) {
              return null;
            }
            return VehiculoSupabaseModel.fromJson(data.first).toEntity();
          });
    } catch (e) {
      throw Exception('Error en stream de vehículo por ID: $e');
    }
  }

  @override
  Future<int> count() async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select()
          .count();
      return response.count;
    } catch (e) {
      throw Exception('Error al contar vehículos: $e');
    }
  }

  @override
  Future<void> clear() async {
    try {
      await _supabase.from(_tableName).delete().neq('id', '00000000-0000-0000-0000-000000000000');
    } catch (e) {
      throw Exception('Error al limpiar vehículos: $e');
    }
  }

  @override
  Future<List<VehiculoEntity>> createBatch(List<VehiculoEntity> entities) async {
    try {
      final models = entities.map((e) => VehiculoSupabaseModel.fromEntity(e).toJson()).toList();

      final List<dynamic> response = await _supabase
          .from(_tableName)
          .insert(models)
          .select();

      return response
          .map((json) => VehiculoSupabaseModel.fromJson(json as Map<String, dynamic>).toEntity())
          .toList();
    } catch (e) {
      throw Exception('Error al crear vehículos en lote: $e');
    }
  }

  @override
  Future<List<VehiculoEntity>> updateBatch(List<VehiculoEntity> entities) async {
    try {
      final List<VehiculoEntity> updated = [];
      for (final entity in entities) {
        final result = await update(entity);
        updated.add(result);
      }
      return updated;
    } catch (e) {
      throw Exception('Error al actualizar vehículos en lote: $e');
    }
  }

  @override
  Future<void> setSillaElectrica(List<String> vehiculoIds, {required bool tiene}) async {
    try {
      await _supabase.rpc<void>(
        'fn_set_silla_electrica',
        params: <String, dynamic>{'p_vehiculo_ids': vehiculoIds, 'p_tiene': tiene},
      );
      SupabaseVehiculoDataSource.clearCache();
    } catch (e) {
      throw Exception('Error al cambiar la silla eléctrica: $e');
    }
  }

  @override
  Future<void> deleteBatch(List<String> ids) async {
    try {
      await _supabase
          .from(_tableName)
          .delete()
          .inFilter('id', ids);
    } catch (e) {
      throw Exception('Error al eliminar vehículos en lote: $e');
    }
  }

  @override
  Future<bool> exists(String id) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select('id')
          .eq('id', id)
          .maybeSingle();
      return response != null;
    } catch (e) {
      throw Exception('Error al verificar existencia del vehículo: $e');
    }
  }

  // ========== MÉTODOS ESPECÍFICOS DE VEHÍCULOS ==========

  @override
  Future<List<VehiculoEntity>> searchByMatricula(String matricula) async {
    try {
      final List<dynamic> response = await _supabase
          .from(_tableName)
          .select()
          .ilike('matricula', '%$matricula%')
          .order('matricula');

      return response
          .map((json) => VehiculoSupabaseModel.fromJson(json as Map<String, dynamic>).toEntity())
          .toList();
    } catch (e) {
      throw Exception('Error al buscar vehículos por matrícula: $e');
    }
  }

  @override
  Future<List<VehiculoEntity>> getByEstado(VehiculoEstado estado) async {
    try {
      final String estadoString = _estadoToString(estado);
      final List<dynamic> response = await _supabase
          .from(_tableName)
          .select()
          .eq('estado', estadoString)
          .order('matricula');

      return response
          .map((json) => VehiculoSupabaseModel.fromJson(json as Map<String, dynamic>).toEntity())
          .toList();
    } catch (e) {
      throw Exception('Error al obtener vehículos por estado: $e');
    }
  }

  /// Convierte VehiculoEstado a string para Supabase
  String _estadoToString(VehiculoEstado estado) {
    switch (estado) {
      case VehiculoEstado.activo:
        return 'activo';
      case VehiculoEstado.mantenimiento:
        return 'mantenimiento';
      case VehiculoEstado.reparacion:
        return 'reparacion';
      case VehiculoEstado.baja:
        return 'baja';
    }
  }
}
