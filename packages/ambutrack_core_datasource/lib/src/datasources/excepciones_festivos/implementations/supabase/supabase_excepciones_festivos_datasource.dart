import 'package:ambutrack_core_datasource/src/datasources/excepciones_festivos/entities/excepcion_festivo_entity.dart';
import 'package:ambutrack_core_datasource/src/datasources/excepciones_festivos/excepciones_festivos_contract.dart';
import 'package:ambutrack_core_datasource/src/datasources/excepciones_festivos/models/excepcion_festivo_supabase_model.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Implementación de Supabase para ExcepcionesFestivosDataSource
class SupabaseExcepcionesFestivosDataSource implements ExcepcionesFestivosDataSource {
  SupabaseExcepcionesFestivosDataSource(this._supabase);

  final SupabaseClient _supabase;
  static const String _tableName = 'excepciones_calendario';

  @override
  Future<List<ExcepcionFestivoEntity>> getAll() async {
    try {
      debugPrint('📡 DataSource: Obteniendo todas las excepciones/festivos...');

      final List<Map<String, dynamic>> data = await _supabase
          .from(_tableName)
          .select()
          .order('fecha', ascending: false);

      final List<ExcepcionFestivoEntity> items = data
          .map((Map<String, dynamic> json) =>
              ExcepcionFestivoSupabaseModel.fromJson(json).toEntity())
          .toList();

      debugPrint('✅ DataSource: ${items.length} excepciones/festivos obtenidas');
      return items;
    } catch (e, stackTrace) {
      debugPrint('❌ Error al obtener excepciones/festivos: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<List<ExcepcionFestivoEntity>> getActivas() async {
    try {
      debugPrint('📡 DataSource: Obteniendo excepciones/festivos activas...');

      final List<Map<String, dynamic>> data = await _supabase
          .from(_tableName)
          .select()
          .eq('activo', true)
          .order('fecha', ascending: false);

      final List<ExcepcionFestivoEntity> items = data
          .map((Map<String, dynamic> json) =>
              ExcepcionFestivoSupabaseModel.fromJson(json).toEntity())
          .toList();

      debugPrint('✅ DataSource: ${items.length} excepciones/festivos activas');
      return items;
    } catch (e, stackTrace) {
      debugPrint('❌ Error al obtener excepciones/festivos activas: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<List<ExcepcionFestivoEntity>> getByAnio(int anio) async {
    try {
      debugPrint('📡 DataSource: Obteniendo excepciones/festivos del año $anio...');

      final DateTime fechaInicio = DateTime(anio, 1, 1);
      final DateTime fechaFin = DateTime(anio, 12, 31, 23, 59, 59);

      return await getByRangoFechas(
        fechaInicio: fechaInicio,
        fechaFin: fechaFin,
      );
    } catch (e, stackTrace) {
      debugPrint('❌ Error al obtener excepciones/festivos del año $anio: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<List<ExcepcionFestivoEntity>> getByRangoFechas({
    required DateTime fechaInicio,
    required DateTime fechaFin,
  }) async {
    try {
      debugPrint('📡 DataSource: Obteniendo excepciones/festivos entre $fechaInicio y $fechaFin...');

      final List<Map<String, dynamic>> data = await _supabase
          .from(_tableName)
          .select()
          .gte('fecha', fechaInicio.toIso8601String())
          .lte('fecha', fechaFin.toIso8601String())
          .order('fecha', ascending: true);

      final List<ExcepcionFestivoEntity> items = data
          .map((Map<String, dynamic> json) =>
              ExcepcionFestivoSupabaseModel.fromJson(json).toEntity())
          .toList();

      debugPrint('✅ DataSource: ${items.length} excepciones/festivos en el rango');
      return items;
    } catch (e, stackTrace) {
      debugPrint('❌ Error al obtener excepciones/festivos por rango: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<List<ExcepcionFestivoEntity>> getByTipo(String tipo) async {
    try {
      debugPrint('📡 DataSource: Obteniendo excepciones/festivos de tipo $tipo...');

      final List<Map<String, dynamic>> data = await _supabase
          .from(_tableName)
          .select()
          .eq('tipo', tipo)
          .order('fecha', ascending: false);

      final List<ExcepcionFestivoEntity> items = data
          .map((Map<String, dynamic> json) =>
              ExcepcionFestivoSupabaseModel.fromJson(json).toEntity())
          .toList();

      debugPrint('✅ DataSource: ${items.length} excepciones/festivos de tipo $tipo');
      return items;
    } catch (e, stackTrace) {
      debugPrint('❌ Error al obtener excepciones/festivos por tipo: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<ExcepcionFestivoEntity?> getById(String id) async {
    try {
      debugPrint('📡 DataSource: Obteniendo excepción/festivo con ID: $id');

      final Map<String, dynamic> data = await _supabase
          .from(_tableName)
          .select()
          .eq('id', id)
          .single();

      final ExcepcionFestivoEntity item =
          ExcepcionFestivoSupabaseModel.fromJson(data).toEntity();

      debugPrint('✅ DataSource: Excepción/festivo obtenida: ${item.nombre}');
      return item;
    } catch (e, stackTrace) {
      debugPrint('❌ Error al obtener excepción/festivo por ID: $e');
      debugPrint('Stack trace: $stackTrace');
      return null;
    }
  }

  @override
  Future<ExcepcionFestivoEntity> create(ExcepcionFestivoEntity item) async {
    try {
      debugPrint('📡 DataSource: Creando excepción/festivo: ${item.nombre}');

      final ExcepcionFestivoSupabaseModel model =
          ExcepcionFestivoSupabaseModel.fromEntity(item);

      final Map<String, dynamic> data = await _supabase
          .from(_tableName)
          .insert(model.toJson())
          .select()
          .single();

      final ExcepcionFestivoEntity created =
          ExcepcionFestivoSupabaseModel.fromJson(data).toEntity();

      debugPrint('✅ DataSource: Excepción/festivo creada con ID: ${created.id}');
      return created;
    } catch (e, stackTrace) {
      debugPrint('❌ Error al crear excepción/festivo: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<ExcepcionFestivoEntity> update(ExcepcionFestivoEntity item) async {
    try {
      debugPrint('📡 DataSource: Actualizando excepción/festivo: ${item.nombre}');

      final ExcepcionFestivoSupabaseModel model =
          ExcepcionFestivoSupabaseModel.fromEntity(item);

      final Map<String, dynamic> data = await _supabase
          .from(_tableName)
          .update(model.toJson())
          .eq('id', item.id)
          .select()
          .single();

      final ExcepcionFestivoEntity updated =
          ExcepcionFestivoSupabaseModel.fromJson(data).toEntity();

      debugPrint('✅ DataSource: Excepción/festivo actualizada');
      return updated;
    } catch (e, stackTrace) {
      debugPrint('❌ Error al actualizar excepción/festivo: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      debugPrint('📡 DataSource: Eliminando excepción/festivo con ID: $id');

      await _supabase.from(_tableName).delete().eq('id', id);

      debugPrint('✅ DataSource: Excepción/festivo eliminada');
    } catch (e, stackTrace) {
      debugPrint('❌ Error al eliminar excepción/festivo: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<void> toggleActivo(String id, {required bool activo}) async {
    try {
      debugPrint('📡 DataSource: Cambiando estado activo de excepción/festivo $id a $activo');

      await _supabase
          .from(_tableName)
          .update(<String, dynamic>{
            'activo': activo,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', id);

      debugPrint('✅ DataSource: Estado actualizado correctamente');
    } catch (e, stackTrace) {
      debugPrint('❌ Error al cambiar estado: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  @override
  Stream<List<ExcepcionFestivoEntity>> watchAll() {
    debugPrint('👁️ DataSource: Iniciando stream de excepciones/festivos');

    return _supabase
        .from(_tableName)
        .stream(primaryKey: <String>['id'])
        .order('fecha', ascending: false)
        .map((List<Map<String, dynamic>> data) {
          return data
              .map((Map<String, dynamic> json) =>
                  ExcepcionFestivoSupabaseModel.fromJson(json).toEntity())
              .toList();
        });
  }
}
