import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../entities/mantenimiento_electromedicina_entity.dart';
import '../../mantenimiento_electromedicina_contract.dart';
import '../../models/mantenimiento_electromedicina_supabase_model.dart';

/// Implementación de MantenimientoElectromedicinaDataSource usando Supabase
class SupabaseMantenimientoElectromedicinaDataSource
    implements MantenimientoElectromedicinaDataSource {
  SupabaseMantenimientoElectromedicinaDataSource(this._supabase);

  final SupabaseClient _supabase;
  static const String _tableName = 'mantenimiento_electromedicina';

  @override
  Future<List<MantenimientoElectromedicinaEntity>> getAll() async {
    try {
      debugPrint('=æ Mantenimiento DS: Obteniendo todos los mantenimientos...');

      final List<dynamic> data = await _supabase
          .from(_tableName)
          .select()
          .order('fecha_mantenimiento', ascending: false)
          .limit(200);

      final List<MantenimientoElectromedicinaEntity> mantenimientos = data
          .map((json) =>
              MantenimientoElectromedicinaSupabaseModel.fromJson(json).toEntity())
          .toList();

      debugPrint(
          '=æ Mantenimiento DS:  ${mantenimientos.length} mantenimientos obtenidos');
      return mantenimientos;
    } catch (e) {
      debugPrint('=æ Mantenimiento DS: L Error al obtener mantenimientos: $e');
      rethrow;
    }
  }

  @override
  Future<MantenimientoElectromedicinaEntity?> getById(String id) async {
    try {
      debugPrint('=æ Mantenimiento DS: Obteniendo mantenimiento con ID: $id');

      final Map<String, dynamic>? data =
          await _supabase.from(_tableName).select().eq('id', id).maybeSingle();

      if (data == null) {
        debugPrint('=æ Mantenimiento DS:   Mantenimiento no encontrado');
        return null;
      }

      final MantenimientoElectromedicinaEntity mantenimiento =
          MantenimientoElectromedicinaSupabaseModel.fromJson(data).toEntity();

      debugPrint('=æ Mantenimiento DS:  Mantenimiento obtenido');
      return mantenimiento;
    } catch (e) {
      debugPrint('=æ Mantenimiento DS: L Error al obtener mantenimiento: $e');
      rethrow;
    }
  }

  @override
  Future<List<MantenimientoElectromedicinaEntity>> getByProducto(
    String idProducto,
  ) async {
    try {
      debugPrint(
          '=æ Mantenimiento DS: Obteniendo mantenimientos del producto: $idProducto');

      final List<dynamic> data = await _supabase
          .from(_tableName)
          .select()
          .eq('id_producto', idProducto)
          .order('fecha_mantenimiento', ascending: false);

      final List<MantenimientoElectromedicinaEntity> mantenimientos = data
          .map((json) =>
              MantenimientoElectromedicinaSupabaseModel.fromJson(json).toEntity())
          .toList();

      debugPrint(
          '=æ Mantenimiento DS:  ${mantenimientos.length} mantenimientos del producto');
      return mantenimientos;
    } catch (e) {
      debugPrint(
          '=æ Mantenimiento DS: L Error al obtener mantenimientos del producto: $e');
      rethrow;
    }
  }

  @override
  Future<List<MantenimientoElectromedicinaEntity>> getByNumeroSerie(
    String numeroSerie,
  ) async {
    try {
      debugPrint(
          '=æ Mantenimiento DS: Obteniendo mantenimientos del nº serie: $numeroSerie');

      final List<dynamic> data = await _supabase
          .from(_tableName)
          .select()
          .eq('numero_serie', numeroSerie)
          .order('fecha_mantenimiento', ascending: false);

      final List<MantenimientoElectromedicinaEntity> mantenimientos = data
          .map((json) =>
              MantenimientoElectromedicinaSupabaseModel.fromJson(json).toEntity())
          .toList();

      debugPrint(
          '=æ Mantenimiento DS:  ${mantenimientos.length} mantenimientos del equipo');
      return mantenimientos;
    } catch (e) {
      debugPrint(
          '=æ Mantenimiento DS: L Error al obtener mantenimientos por nº serie: $e');
      rethrow;
    }
  }

  @override
  Future<List<MantenimientoElectromedicinaEntity>> getByVehiculo(
    String idVehiculo,
  ) async {
    try {
      debugPrint(
          '=æ Mantenimiento DS: Obteniendo mantenimientos del vehículo: $idVehiculo');

      final List<dynamic> data = await _supabase
          .from(_tableName)
          .select()
          .eq('id_vehiculo', idVehiculo)
          .order('fecha_mantenimiento', ascending: false);

      final List<MantenimientoElectromedicinaEntity> mantenimientos = data
          .map((json) =>
              MantenimientoElectromedicinaSupabaseModel.fromJson(json).toEntity())
          .toList();

      debugPrint(
          '=æ Mantenimiento DS:  ${mantenimientos.length} mantenimientos del vehículo');
      return mantenimientos;
    } catch (e) {
      debugPrint(
          '=æ Mantenimiento DS: L Error al obtener mantenimientos del vehículo: $e');
      rethrow;
    }
  }

  @override
  Future<List<MantenimientoElectromedicinaEntity>> getByTipo(
    TipoMantenimientoElectromedicina tipo,
  ) async {
    try {
      debugPrint(
          '=æ Mantenimiento DS: Obteniendo mantenimientos de tipo: ${tipo.label}');

      final List<dynamic> data = await _supabase
          .from(_tableName)
          .select()
          .eq('tipo_mantenimiento', tipo.code)
          .order('fecha_mantenimiento', ascending: false);

      final List<MantenimientoElectromedicinaEntity> mantenimientos = data
          .map((json) =>
              MantenimientoElectromedicinaSupabaseModel.fromJson(json).toEntity())
          .toList();

      debugPrint(
          '=æ Mantenimiento DS:  ${mantenimientos.length} mantenimientos de ${tipo.label}');
      return mantenimientos;
    } catch (e) {
      debugPrint(
          '=æ Mantenimiento DS: L Error al obtener mantenimientos por tipo: $e');
      rethrow;
    }
  }

  @override
  Future<List<MantenimientoElectromedicinaEntity>> getByResultado(
    ResultadoMantenimiento resultado,
  ) async {
    try {
      debugPrint(
          '=æ Mantenimiento DS: Obteniendo mantenimientos con resultado: ${resultado.label}');

      final List<dynamic> data = await _supabase
          .from(_tableName)
          .select()
          .eq('resultado', resultado.code)
          .order('fecha_mantenimiento', ascending: false);

      final List<MantenimientoElectromedicinaEntity> mantenimientos = data
          .map((json) =>
              MantenimientoElectromedicinaSupabaseModel.fromJson(json).toEntity())
          .toList();

      debugPrint(
          '=æ Mantenimiento DS:  ${mantenimientos.length} mantenimientos con ${resultado.label}');
      return mantenimientos;
    } catch (e) {
      debugPrint(
          '=æ Mantenimiento DS: L Error al obtener mantenimientos por resultado: $e');
      rethrow;
    }
  }

  @override
  Future<List<MantenimientoElectromedicinaEntity>> getProximosAVencer({
    int dias = 30,
  }) async {
    try {
      debugPrint(
          '=æ Mantenimiento DS: Obteniendo mantenimientos próximos a vencer ($dias días)');

      final DateTime hoy = DateTime.now();
      final DateTime limite = hoy.add(Duration(days: dias));

      final List<dynamic> data = await _supabase
          .from(_tableName)
          .select()
          .not('proximo_mantenimiento', 'is', null)
          .gte('proximo_mantenimiento', hoy.toIso8601String())
          .lte('proximo_mantenimiento', limite.toIso8601String())
          .order('proximo_mantenimiento', ascending: true);

      final List<MantenimientoElectromedicinaEntity> mantenimientos = data
          .map((json) =>
              MantenimientoElectromedicinaSupabaseModel.fromJson(json).toEntity())
          .toList();

      debugPrint(
          '=æ Mantenimiento DS:  ${mantenimientos.length} mantenimientos próximos a vencer');
      return mantenimientos;
    } catch (e) {
      debugPrint(
          '=æ Mantenimiento DS: L Error al obtener mantenimientos próximos a vencer: $e');
      rethrow;
    }
  }

  @override
  Future<List<MantenimientoElectromedicinaEntity>> getVencidos() async {
    try {
      debugPrint('=æ Mantenimiento DS: Obteniendo mantenimientos vencidos...');

      final DateTime hoy = DateTime.now();

      final List<dynamic> data = await _supabase
          .from(_tableName)
          .select()
          .not('proximo_mantenimiento', 'is', null)
          .lt('proximo_mantenimiento', hoy.toIso8601String())
          .order('proximo_mantenimiento', ascending: true);

      final List<MantenimientoElectromedicinaEntity> mantenimientos = data
          .map((json) =>
              MantenimientoElectromedicinaSupabaseModel.fromJson(json).toEntity())
          .toList();

      debugPrint(
          '=æ Mantenimiento DS:  ${mantenimientos.length} mantenimientos vencidos');
      return mantenimientos;
    } catch (e) {
      debugPrint('=æ Mantenimiento DS: L Error al obtener mantenimientos vencidos: $e');
      rethrow;
    }
  }

  @override
  Future<List<MantenimientoElectromedicinaEntity>> getEquiposNoAptos() async {
    try {
      debugPrint('=æ Mantenimiento DS: Obteniendo equipos NO APTOS...');

      // Subquery para obtener el último mantenimiento de cada equipo
      // con resultado NO_APTO o EN_REPARACION
      final List<dynamic> data = await _supabase
          .from(_tableName)
          .select()
          .inFilter('resultado', ['NO_APTO', 'EN_REPARACION'])
          .order('fecha_mantenimiento', ascending: false);

      final List<MantenimientoElectromedicinaEntity> mantenimientos = data
          .map((json) =>
              MantenimientoElectromedicinaSupabaseModel.fromJson(json).toEntity())
          .toList();

      debugPrint('=æ Mantenimiento DS:  ${mantenimientos.length} equipos no aptos');
      return mantenimientos;
    } catch (e) {
      debugPrint('=æ Mantenimiento DS: L Error al obtener equipos no aptos: $e');
      rethrow;
    }
  }

  @override
  Future<List<MantenimientoElectromedicinaEntity>> getByFechaRange({
    required DateTime desde,
    required DateTime hasta,
  }) async {
    try {
      debugPrint(
          '=æ Mantenimiento DS: Obteniendo mantenimientos entre $desde y $hasta');

      final List<dynamic> data = await _supabase
          .from(_tableName)
          .select()
          .gte('fecha_mantenimiento', desde.toIso8601String())
          .lte('fecha_mantenimiento', hasta.toIso8601String())
          .order('fecha_mantenimiento', ascending: false);

      final List<MantenimientoElectromedicinaEntity> mantenimientos = data
          .map((json) =>
              MantenimientoElectromedicinaSupabaseModel.fromJson(json).toEntity())
          .toList();

      debugPrint(
          '=æ Mantenimiento DS:  ${mantenimientos.length} mantenimientos en el rango');
      return mantenimientos;
    } catch (e) {
      debugPrint(
          '=æ Mantenimiento DS: L Error al obtener mantenimientos por rango: $e');
      rethrow;
    }
  }

  @override
  Future<MantenimientoElectromedicinaEntity> create(
    MantenimientoElectromedicinaEntity mantenimiento,
  ) async {
    try {
      debugPrint('=æ Mantenimiento DS: Creando mantenimiento...');

      final MantenimientoElectromedicinaSupabaseModel model =
          MantenimientoElectromedicinaSupabaseModel.fromEntity(mantenimiento);
      final Map<String, dynamic> data =
          await _supabase.from(_tableName).insert(model.toJson()).select().single();

      final MantenimientoElectromedicinaEntity createdMantenimiento =
          MantenimientoElectromedicinaSupabaseModel.fromJson(data).toEntity();

      debugPrint('=æ Mantenimiento DS:  Mantenimiento creado');
      return createdMantenimiento;
    } catch (e) {
      debugPrint('=æ Mantenimiento DS: L Error al crear mantenimiento: $e');
      rethrow;
    }
  }

  @override
  Future<MantenimientoElectromedicinaEntity> update(
    MantenimientoElectromedicinaEntity mantenimiento,
  ) async {
    try {
      debugPrint('=æ Mantenimiento DS: Actualizando mantenimiento...');

      final MantenimientoElectromedicinaSupabaseModel model =
          MantenimientoElectromedicinaSupabaseModel.fromEntity(mantenimiento);
      final Map<String, dynamic> data = await _supabase
          .from(_tableName)
          .update(model.toJson())
          .eq('id', mantenimiento.id)
          .select()
          .single();

      final MantenimientoElectromedicinaEntity updatedMantenimiento =
          MantenimientoElectromedicinaSupabaseModel.fromJson(data).toEntity();

      debugPrint('=æ Mantenimiento DS:  Mantenimiento actualizado');
      return updatedMantenimiento;
    } catch (e) {
      debugPrint('=æ Mantenimiento DS: L Error al actualizar mantenimiento: $e');
      rethrow;
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      debugPrint('=æ Mantenimiento DS: Eliminando mantenimiento: $id');

      await _supabase.from(_tableName).delete().eq('id', id);

      debugPrint('=æ Mantenimiento DS:  Mantenimiento eliminado');
    } catch (e) {
      debugPrint('=æ Mantenimiento DS: L Error al eliminar mantenimiento: $e');
      rethrow;
    }
  }

  @override
  Stream<List<MantenimientoElectromedicinaEntity>> watchAll() {
    debugPrint('=æ Mantenimiento DS: Observando cambios en mantenimientos...');

    return _supabase
        .from(_tableName)
        .stream(primaryKey: ['id'])
        .order('fecha_mantenimiento', ascending: false)
        .limit(200)
        .map((data) => data
            .map((json) =>
                MantenimientoElectromedicinaSupabaseModel.fromJson(json).toEntity())
            .toList());
  }

  @override
  Stream<List<MantenimientoElectromedicinaEntity>> watchByProducto(
    String idProducto,
  ) {
    debugPrint(
        '=æ Mantenimiento DS: Observando mantenimientos del producto: $idProducto');

    return _supabase
        .from(_tableName)
        .stream(primaryKey: ['id'])
        .eq('id_producto', idProducto)
        .order('fecha_mantenimiento', ascending: false)
        .map((data) => data
            .map((json) =>
                MantenimientoElectromedicinaSupabaseModel.fromJson(json).toEntity())
            .toList());
  }

  @override
  Stream<List<MantenimientoElectromedicinaEntity>> watchProximosAVencer({
    int dias = 30,
  }) {
    debugPrint(
        '=æ Mantenimiento DS: Observando mantenimientos próximos a vencer ($dias días)');

    final DateTime hoy = DateTime.now();
    final DateTime limite = hoy.add(Duration(days: dias));

    return _supabase
        .from(_tableName)
        .stream(primaryKey: ['id'])
        .map((data) {
          // Filtrar en memoria ya que stream no soporta .not(), .gte(), .lte()
          return data
              .where((json) {
                final proximoMantenimiento = json['proximo_mantenimiento'];
                if (proximoMantenimiento == null) return false;

                final fecha = DateTime.parse(proximoMantenimiento as String);
                return fecha.isAfter(hoy) && fecha.isBefore(limite);
              })
              .map((json) =>
                  MantenimientoElectromedicinaSupabaseModel.fromJson(json).toEntity())
              .toList()
                ..sort((a, b) => a.proximoMantenimiento!.compareTo(b.proximoMantenimiento!));
        });
  }
}
