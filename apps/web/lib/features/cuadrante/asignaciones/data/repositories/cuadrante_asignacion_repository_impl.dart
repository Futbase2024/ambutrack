import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/features/cuadrante/asignaciones/domain/repositories/cuadrante_asignacion_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

/// Implementación del repositorio de asignaciones de cuadrante
@LazySingleton(as: CuadranteAsignacionRepository)
class CuadranteAsignacionRepositoryImpl implements CuadranteAsignacionRepository {
  CuadranteAsignacionRepositoryImpl()
      : _dataSource = CuadranteAsignacionDataSourceFactory.createSupabase();

  final CuadranteAsignacionDataSource _dataSource;

  @override
  Future<CuadranteAsignacionEntity> create(CuadranteAsignacionEntity asignacion) async {
    debugPrint('📦 Repository: Creando asignación...');
    try {
      final CuadranteAsignacionEntity result = await _dataSource.create(asignacion);
      debugPrint('📦 Repository: ✅ Asignación creada');
      return result;
    } catch (e) {
      debugPrint('📦 Repository: ❌ Error al crear: $e');
      rethrow;
    }
  }

  @override
  Future<CuadranteAsignacionEntity> update(CuadranteAsignacionEntity asignacion) async {
    debugPrint('📦 Repository: Actualizando asignación ${asignacion.id}...');
    try {
      final CuadranteAsignacionEntity result = await _dataSource.update(asignacion);
      debugPrint('📦 Repository: ✅ Asignación actualizada');
      return result;
    } catch (e) {
      debugPrint('📦 Repository: ❌ Error al actualizar: $e');
      rethrow;
    }
  }

  @override
  Future<void> delete(String id) async {
    debugPrint('📦 Repository: Eliminando asignación $id...');
    try {
      await _dataSource.delete(id);
      debugPrint('📦 Repository: ✅ Asignación eliminada');
    } catch (e) {
      debugPrint('📦 Repository: ❌ Error al eliminar: $e');
      rethrow;
    }
  }

  @override
  Future<CuadranteAsignacionEntity?> getById(String id) async {
    debugPrint('📦 Repository: Obteniendo asignación $id...');
    try {
      final CuadranteAsignacionEntity? result = await _dataSource.getById(id);
      debugPrint('📦 Repository: ✅ Asignación obtenida');
      return result;
    } catch (e) {
      debugPrint('📦 Repository: ❌ Error al obtener: $e');
      rethrow;
    }
  }

  @override
  Future<List<CuadranteAsignacionEntity>> getAll() async {
    debugPrint('📦 Repository: Obteniendo todas las asignaciones...');
    try {
      final List<CuadranteAsignacionEntity> result = await _dataSource.getAll();
      debugPrint('📦 Repository: ✅ ${result.length} asignaciones obtenidas');
      return result;
    } catch (e) {
      debugPrint('📦 Repository: ❌ Error al obtener: $e');
      rethrow;
    }
  }

  @override
  Future<List<CuadranteAsignacionEntity>> getByFecha(DateTime fecha) async {
    debugPrint('📦 Repository: Obteniendo asignaciones del ${fecha.toIso8601String()}...');
    try {
      final List<CuadranteAsignacionEntity> result = await _dataSource.getByFecha(fecha);
      debugPrint('📦 Repository: ✅ ${result.length} asignaciones obtenidas');
      return result;
    } catch (e) {
      debugPrint('📦 Repository: ❌ Error al obtener: $e');
      rethrow;
    }
  }

  @override
  Future<List<CuadranteAsignacionEntity>> getByRangoFechas({
    required DateTime fechaInicio,
    required DateTime fechaFin,
  }) async {
    debugPrint('📦 Repository: Obteniendo asignaciones del rango ${fechaInicio.toIso8601String()} - ${fechaFin.toIso8601String()}...');
    try {
      final List<CuadranteAsignacionEntity> result = await _dataSource.getByFechaRange(
        fechaInicio: fechaInicio,
        fechaFin: fechaFin,
      );
      debugPrint('📦 Repository: ✅ ${result.length} asignaciones obtenidas');
      return result;
    } catch (e) {
      debugPrint('📦 Repository: ❌ Error al obtener: $e');
      rethrow;
    }
  }

  @override
  Future<List<CuadranteAsignacionEntity>> getByPersonal({
    required String idPersonal,
    DateTime? fecha,
  }) async {
    debugPrint('📦 Repository: Obteniendo asignaciones del personal $idPersonal...');
    try {
      final List<CuadranteAsignacionEntity> result;
      if (fecha != null) {
        result = await _dataSource.getByPersonalAndFecha(
          idPersonal: idPersonal,
          fecha: fecha,
        );
      } else {
        result = await _dataSource.getByPersonal(idPersonal);
      }
      debugPrint('📦 Repository: ✅ ${result.length} asignaciones obtenidas');
      return result;
    } catch (e) {
      debugPrint('📦 Repository: ❌ Error al obtener: $e');
      rethrow;
    }
  }

  @override
  Future<List<CuadranteAsignacionEntity>> getByVehiculo({
    required String idVehiculo,
    DateTime? fecha,
  }) async {
    debugPrint('📦 Repository: Obteniendo asignaciones del vehículo $idVehiculo...');
    try {
      final List<CuadranteAsignacionEntity> result;
      if (fecha != null) {
        result = await _dataSource.getByVehiculoAndFecha(
          idVehiculo: idVehiculo,
          fecha: fecha,
        );
      } else {
        result = await _dataSource.getByVehiculo(idVehiculo);
      }
      debugPrint('📦 Repository: ✅ ${result.length} asignaciones obtenidas');
      return result;
    } catch (e) {
      debugPrint('📦 Repository: ❌ Error al obtener: $e');
      rethrow;
    }
  }

  @override
  Future<List<CuadranteAsignacionEntity>> getByDotacion({
    required String idDotacion,
    DateTime? fecha,
  }) async {
    debugPrint('📦 Repository: Obteniendo asignaciones de la dotación $idDotacion...');
    try {
      final List<CuadranteAsignacionEntity> result;
      if (fecha != null) {
        result = await _dataSource.getByDotacionAndFecha(
          idDotacion: idDotacion,
          fecha: fecha,
        );
      } else {
        result = await _dataSource.getByDotacion(idDotacion);
      }
      debugPrint('📦 Repository: ✅ ${result.length} asignaciones obtenidas');
      return result;
    } catch (e) {
      debugPrint('📦 Repository: ❌ Error al obtener: $e');
      rethrow;
    }
  }

  @override
  Future<List<CuadranteAsignacionEntity>> getByEstado(EstadoAsignacion estado) async {
    debugPrint('📦 Repository: Obteniendo asignaciones con estado ${estado.value}...');
    try {
      final List<CuadranteAsignacionEntity> result = await _dataSource.getByEstado(estado);
      debugPrint('📦 Repository: ✅ ${result.length} asignaciones obtenidas');
      return result;
    } catch (e) {
      debugPrint('📦 Repository: ❌ Error al obtener: $e');
      rethrow;
    }
  }

  @override
  Future<bool> hasConflictPersonal({
    required String idPersonal,
    required DateTime fecha,
    required String horaInicio,
    required String horaFin,
    required bool cruzaMedianoche,
    String? excludeId,
  }) async {
    debugPrint('📦 Repository: Verificando conflictos para personal $idPersonal...');
    try {
      final bool result = await _dataSource.hasConflictPersonal(
        idPersonal: idPersonal,
        fecha: fecha,
        horaInicio: horaInicio,
        horaFin: horaFin,
        cruzaMedianoche: cruzaMedianoche,
        excludeAsignacionId: excludeId,
      );
      debugPrint('📦 Repository: ✅ Conflicto: $result');
      return result;
    } catch (e) {
      debugPrint('📦 Repository: ❌ Error al verificar: $e');
      rethrow;
    }
  }

  @override
  Future<bool> hasConflictVehiculo({
    required String idVehiculo,
    required DateTime fecha,
    required String horaInicio,
    required String horaFin,
    required bool cruzaMedianoche,
    String? excludeId,
  }) async {
    debugPrint('📦 Repository: Verificando conflictos para vehículo $idVehiculo...');
    try {
      final bool result = await _dataSource.hasConflictVehiculo(
        idVehiculo: idVehiculo,
        fecha: fecha,
        horaInicio: horaInicio,
        horaFin: horaFin,
        cruzaMedianoche: cruzaMedianoche,
        excludeAsignacionId: excludeId,
      );
      debugPrint('📦 Repository: ✅ Conflicto: $result');
      return result;
    } catch (e) {
      debugPrint('📦 Repository: ❌ Error al verificar: $e');
      rethrow;
    }
  }

  @override
  Future<bool> isDotacionUnidadAsignada({
    required String idDotacion,
    required int numeroUnidad,
    required DateTime fecha,
    required String horaInicio,
    required String horaFin,
    required bool cruzaMedianoche,
    String? excludeId,
  }) async {
    debugPrint('📦 Repository: Verificando asignación de dotación $idDotacion unidad $numeroUnidad...');
    try {
      final bool result = await _dataSource.isDotacionUnidadAsignada(
        idDotacion: idDotacion,
        fecha: fecha,
        numeroUnidad: numeroUnidad,
        excludeAsignacionId: excludeId,
      );
      debugPrint('📦 Repository: ✅ Ya asignada: $result');
      return result;
    } catch (e) {
      debugPrint('📦 Repository: ❌ Error al verificar: $e');
      rethrow;
    }
  }

  @override
  Future<CuadranteAsignacionEntity> confirmar({
    required String id,
    required String confirmadaPor,
  }) async {
    debugPrint('📦 Repository: Confirmando asignación $id...');
    try {
      final CuadranteAsignacionEntity result = await _dataSource.confirmar(
        id: id,
        confirmadaPor: confirmadaPor,
      );
      debugPrint('📦 Repository: ✅ Asignación confirmada');
      return result;
    } catch (e) {
      debugPrint('📦 Repository: ❌ Error al confirmar: $e');
      rethrow;
    }
  }

  @override
  Future<CuadranteAsignacionEntity> cancelar(String id) async {
    debugPrint('📦 Repository: Cancelando asignación $id...');
    try {
      final CuadranteAsignacionEntity result = await _dataSource.cancelar(id);
      debugPrint('📦 Repository: ✅ Asignación cancelada');
      return result;
    } catch (e) {
      debugPrint('📦 Repository: ❌ Error al cancelar: $e');
      rethrow;
    }
  }

  @override
  Future<CuadranteAsignacionEntity> completar({
    required String id,
    double? kmFinal,
    int? serviciosRealizados,
    String? observaciones,
  }) async {
    debugPrint('📦 Repository: Completando asignación $id...');
    try {
      final CuadranteAsignacionEntity result = await _dataSource.completar(
        id: id,
        kmFinal: kmFinal,
        serviciosRealizados: serviciosRealizados,
      );
      debugPrint('📦 Repository: ✅ Asignación completada');
      return result;
    } catch (e) {
      debugPrint('📦 Repository: ❌ Error al completar: $e');
      rethrow;
    }
  }

  @override
  Stream<List<CuadranteAsignacionEntity>> watchAll() {
    debugPrint('📦 Repository: Iniciando stream de todas las asignaciones...');
    return _dataSource.watchAll();
  }

  @override
  Stream<List<CuadranteAsignacionEntity>> watchByFecha(DateTime fecha) {
    debugPrint('📦 Repository: Iniciando stream de asignaciones del ${fecha.toIso8601String()}...');
    return _dataSource.watchByFecha(fecha);
  }

  @override
  Stream<List<CuadranteAsignacionEntity>> watchByPersonal(String idPersonal) {
    debugPrint('📦 Repository: Iniciando stream de asignaciones del personal $idPersonal...');
    return _dataSource.watchByPersonal(idPersonal);
  }

  @override
  Stream<List<CuadranteAsignacionEntity>> watchByDotacion(String idDotacion) {
    debugPrint('📦 Repository: Iniciando stream de asignaciones de la dotación $idDotacion...');
    return _dataSource.watchByDotacion(idDotacion);
  }
}
