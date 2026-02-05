import 'package:ambutrack_core/ambutrack_core.dart';
import 'package:ambutrack_web/features/turnos/domain/repositories/turnos_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

/// Implementación del repositorio de turnos (pass-through a core datasource)
@LazySingleton(as: TurnosRepository)
class TurnosRepositoryImpl implements TurnosRepository {
  TurnosRepositoryImpl() : _dataSource = TurnoDataSourceFactory.createSupabase();

  final TurnoDataSource _dataSource;

  @override
  Future<List<TurnoEntity>> getAll() async {
    debugPrint('📦 TurnosRepository: Solicitando todos los turnos...');
    try {
      final List<TurnoEntity> turnos = await _dataSource.getAll();
      debugPrint('📦 TurnosRepository: ✅ ${turnos.length} turnos obtenidos');
      return turnos;
    } catch (e) {
      debugPrint('📦 TurnosRepository: ❌ Error: $e');
      rethrow;
    }
  }

  @override
  Future<List<TurnoEntity>> getByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    debugPrint('📦 TurnosRepository: Solicitando turnos entre $startDate y $endDate...');
    try {
      final List<TurnoEntity> turnos = await _dataSource.getByDateRange(
        startDate: startDate,
        endDate: endDate,
      );
      debugPrint('📦 TurnosRepository: ✅ ${turnos.length} turnos encontrados en el rango');
      return turnos;
    } catch (e) {
      debugPrint('📦 TurnosRepository: ❌ Error: $e');
      rethrow;
    }
  }

  @override
  Future<List<TurnoEntity>> getByPersonal(String idPersonal) async {
    debugPrint('📦 TurnosRepository: Solicitando turnos del personal $idPersonal...');
    try {
      final List<TurnoEntity> turnos = await _dataSource.getByPersonal(idPersonal);
      debugPrint('📦 TurnosRepository: ✅ ${turnos.length} turnos del personal');
      return turnos;
    } catch (e) {
      debugPrint('📦 TurnosRepository: ❌ Error: $e');
      rethrow;
    }
  }

  @override
  Future<TurnoEntity> create(TurnoEntity turno) async {
    debugPrint('📦 TurnosRepository: Creando turno...');
    try {
      final TurnoEntity created = await _dataSource.create(turno);
      debugPrint('📦 TurnosRepository: ✅ Turno creado con ID ${created.id}');
      return created;
    } catch (e) {
      debugPrint('📦 TurnosRepository: ❌ Error: $e');
      rethrow;
    }
  }

  @override
  Future<void> update(TurnoEntity turno) async {
    debugPrint('📦 TurnosRepository: Actualizando turno ${turno.id}...');
    try {
      await _dataSource.update(turno);
      debugPrint('📦 TurnosRepository: ✅ Turno actualizado');
    } catch (e) {
      debugPrint('📦 TurnosRepository: ❌ Error: $e');
      rethrow;
    }
  }

  @override
  Future<void> delete(String id) async {
    debugPrint('📦 TurnosRepository: Eliminando turno $id...');
    try {
      await _dataSource.delete(id);
      debugPrint('📦 TurnosRepository: ✅ Turno eliminado');
    } catch (e) {
      debugPrint('📦 TurnosRepository: ❌ Error: $e');
      rethrow;
    }
  }

  @override
  Future<bool> hasConflicts({
    required String idPersonal,
    required DateTime fechaInicio,
    required DateTime fechaFin,
    String? excludeTurnoId,
    String? horaInicio,
    String? horaFin,
  }) async {
    debugPrint('📦 TurnosRepository: Verificando conflictos para personal $idPersonal...');
    debugPrint('   Horario: ${horaInicio ?? 'N/A'} - ${horaFin ?? 'N/A'}');
    try {
      final bool hasConflict = await _dataSource.hasConflicts(
        idPersonal: idPersonal,
        fechaInicio: fechaInicio,
        fechaFin: fechaFin,
        excludeTurnoId: excludeTurnoId,
        horaInicio: horaInicio,
        horaFin: horaFin,
      );
      debugPrint('📦 TurnosRepository: ${hasConflict ? '⚠️ Hay conflictos' : '✅ Sin conflictos'}');
      return hasConflict;
    } catch (e) {
      debugPrint('📦 TurnosRepository: ❌ Error: $e');
      rethrow;
    }
  }
}
