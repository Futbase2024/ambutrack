import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/features/cuadrante/asignaciones/domain/repositories/asignacion_vehiculo_turno_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

/// Implementación del repositorio de asignaciones
/// Pattern: Pass-through directo al datasource
@LazySingleton(as: AsignacionVehiculoTurnoRepository)
class AsignacionVehiculoTurnoRepositoryImpl
    implements AsignacionVehiculoTurnoRepository {
  AsignacionVehiculoTurnoRepositoryImpl()
      : _dataSource = AsignacionVehiculoTurnoDataSourceFactory.createSupabase();

  final AsignacionVehiculoTurnoDataSource _dataSource;

  @override
  Future<List<AsignacionVehiculoTurnoEntity>> getAll() async {
    debugPrint('📦 Repository: Solicitando todas las asignaciones...');
    try {
      final List<AsignacionVehiculoTurnoEntity> items = await _dataSource.getAll();
      debugPrint('📦 Repository: ✅ ${items.length} asignaciones obtenidas');
      return items;
    } catch (e) {
      debugPrint('📦 Repository: ❌ Error: $e');
      rethrow;
    }
  }

  @override
  Future<AsignacionVehiculoTurnoEntity> getById(String id) async {
    debugPrint('📦 Repository: Solicitando asignación por ID: $id');
    try {
      final AsignacionVehiculoTurnoEntity? item = await _dataSource.getById(id);
      if (item == null) {
        throw Exception('Asignación no encontrada con ID: $id');
      }
      debugPrint('📦 Repository: ✅ Asignación obtenida');
      return item;
    } catch (e) {
      debugPrint('📦 Repository: ❌ Error: $e');
      rethrow;
    }
  }

  @override
  Future<AsignacionVehiculoTurnoEntity> create(
    AsignacionVehiculoTurnoEntity entity,
  ) async {
    debugPrint('📦 Repository: Creando asignación...');
    try {
      final AsignacionVehiculoTurnoEntity item = await _dataSource.create(entity);
      debugPrint('📦 Repository: ✅ Asignación creada');
      return item;
    } catch (e) {
      debugPrint('📦 Repository: ❌ Error: $e');
      rethrow;
    }
  }

  @override
  Future<AsignacionVehiculoTurnoEntity> update(
    AsignacionVehiculoTurnoEntity entity,
  ) async {
    debugPrint('📦 Repository: Actualizando asignación...');
    try {
      final AsignacionVehiculoTurnoEntity item = await _dataSource.update(entity);
      debugPrint('📦 Repository: ✅ Asignación actualizada');
      return item;
    } catch (e) {
      debugPrint('📦 Repository: ❌ Error: $e');
      rethrow;
    }
  }

  @override
  Future<void> delete(String id) async {
    debugPrint('📦 Repository: Eliminando asignación: $id');
    try {
      await _dataSource.delete(id);
      debugPrint('📦 Repository: ✅ Asignación eliminada');
    } catch (e) {
      debugPrint('📦 Repository: ❌ Error: $e');
      rethrow;
    }
  }

  @override
  Future<List<AsignacionVehiculoTurnoEntity>> getByFecha(DateTime fecha) async {
    debugPrint('📦 Repository: Solicitando asignaciones por fecha: $fecha');
    try {
      final List<AsignacionVehiculoTurnoEntity> items = await _dataSource.getByFecha(fecha);
      debugPrint('📦 Repository: ✅ ${items.length} asignaciones obtenidas');
      return items;
    } catch (e) {
      debugPrint('📦 Repository: ❌ Error: $e');
      rethrow;
    }
  }

  @override
  Future<List<AsignacionVehiculoTurnoEntity>> getByRangoFechas(
    DateTime inicio,
    DateTime fin,
  ) async {
    debugPrint('📦 Repository: Solicitando asignaciones por rango...');
    try {
      final List<AsignacionVehiculoTurnoEntity> items = await _dataSource.getByRangoFechas(inicio, fin);
      debugPrint('📦 Repository: ✅ ${items.length} asignaciones obtenidas');
      return items;
    } catch (e) {
      debugPrint('📦 Repository: ❌ Error: $e');
      rethrow;
    }
  }

  @override
  Future<List<AsignacionVehiculoTurnoEntity>> getByVehiculo(
    String vehiculoId,
    DateTime fecha,
  ) async {
    debugPrint('📦 Repository: Solicitando asignaciones por vehículo...');
    try {
      final List<AsignacionVehiculoTurnoEntity> items = await _dataSource.getByVehiculo(vehiculoId, fecha);
      debugPrint('📦 Repository: ✅ ${items.length} asignaciones obtenidas');
      return items;
    } catch (e) {
      debugPrint('📦 Repository: ❌ Error: $e');
      rethrow;
    }
  }

  @override
  Future<List<AsignacionVehiculoTurnoEntity>> getByEstado(String estado) async {
    debugPrint('📦 Repository: Solicitando asignaciones por estado: $estado');
    try {
      final List<AsignacionVehiculoTurnoEntity> items = await _dataSource.getByEstado(estado);
      debugPrint('📦 Repository: ✅ ${items.length} asignaciones obtenidas');
      return items;
    } catch (e) {
      debugPrint('📦 Repository: ❌ Error: $e');
      rethrow;
    }
  }
}
