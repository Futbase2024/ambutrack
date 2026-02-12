import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../../domain/repositories/ausencia_repository.dart';

/// Implementación del repositorio de Ausencias (pass-through)
@LazySingleton(as: AusenciaRepository)
class AusenciaRepositoryImpl implements AusenciaRepository {
  AusenciaRepositoryImpl() : _dataSource = AusenciaDataSourceFactory.createSupabase();

  final AusenciaDataSource _dataSource;

  @override
  Future<List<AusenciaEntity>> getAll() async {
    debugPrint('📦 AusenciaRepository: Solicitando todas las ausencias...');
    try {
      final List<AusenciaEntity> items = await _dataSource.getAll();
      debugPrint('📦 AusenciaRepository: ✅ ${items.length} ausencias obtenidas');
      return items;
    } catch (e) {
      debugPrint('📦 AusenciaRepository: ❌ Error: $e');
      rethrow;
    }
  }

  @override
  Future<List<AusenciaEntity>> getByPersonal(String idPersonal) async {
    debugPrint('📦 AusenciaRepository: Solicitando ausencias de personal: $idPersonal');
    try {
      final List<AusenciaEntity> items = await _dataSource.getByPersonal(idPersonal);
      debugPrint('📦 AusenciaRepository: ✅ ${items.length} ausencias obtenidas');
      return items;
    } catch (e) {
      debugPrint('📦 AusenciaRepository: ❌ Error: $e');
      rethrow;
    }
  }

  @override
  Future<List<AusenciaEntity>> getByEstado(EstadoAusencia estado) async {
    debugPrint('📦 AusenciaRepository: Solicitando ausencias en estado: ${estado.toJson()}');
    try {
      final List<AusenciaEntity> items = await _dataSource.getByEstado(estado);
      debugPrint('📦 AusenciaRepository: ✅ ${items.length} ausencias obtenidas');
      return items;
    } catch (e) {
      debugPrint('📦 AusenciaRepository: ❌ Error: $e');
      rethrow;
    }
  }

  @override
  Future<List<AusenciaEntity>> getByRangoFechas({
    required DateTime fechaInicio,
    required DateTime fechaFin,
  }) async {
    debugPrint('📦 AusenciaRepository: Solicitando ausencias entre $fechaInicio y $fechaFin');
    try {
      final List<AusenciaEntity> items = await _dataSource.getByRangoFechas(
        fechaInicio: fechaInicio,
        fechaFin: fechaFin,
      );
      debugPrint('📦 AusenciaRepository: ✅ ${items.length} ausencias obtenidas');
      return items;
    } catch (e) {
      debugPrint('📦 AusenciaRepository: ❌ Error: $e');
      rethrow;
    }
  }

  @override
  Future<AusenciaEntity> getById(String id) async {
    debugPrint('📦 AusenciaRepository: Solicitando ausencia ID: $id');
    try {
      final AusenciaEntity item = await _dataSource.getById(id);
      debugPrint('📦 AusenciaRepository: ✅ Ausencia obtenida');
      return item;
    } catch (e) {
      debugPrint('📦 AusenciaRepository: ❌ Error: $e');
      rethrow;
    }
  }

  @override
  Future<AusenciaEntity> create(AusenciaEntity ausencia) async {
    debugPrint('📦 AusenciaRepository: Creando ausencia para personal: ${ausencia.idPersonal}');
    try {
      final AusenciaEntity created = await _dataSource.create(ausencia);
      debugPrint('📦 AusenciaRepository: ✅ Ausencia creada');
      return created;
    } catch (e) {
      debugPrint('📦 AusenciaRepository: ❌ Error: $e');
      rethrow;
    }
  }

  @override
  Future<AusenciaEntity> update(AusenciaEntity ausencia) async {
    debugPrint('📦 AusenciaRepository: Actualizando ausencia ID: ${ausencia.id}');
    try {
      final AusenciaEntity updated = await _dataSource.update(ausencia);
      debugPrint('📦 AusenciaRepository: ✅ Ausencia actualizada');
      return updated;
    } catch (e) {
      debugPrint('📦 AusenciaRepository: ❌ Error: $e');
      rethrow;
    }
  }

  @override
  Future<AusenciaEntity> aprobar({
    required String idAusencia,
    required String aprobadoPor,
    String? observaciones,
  }) async {
    debugPrint('📦 AusenciaRepository: Aprobando ausencia ID: $idAusencia');
    try {
      final AusenciaEntity aprobada = await _dataSource.aprobar(
        idAusencia: idAusencia,
        aprobadoPor: aprobadoPor,
        observaciones: observaciones,
      );
      debugPrint('📦 AusenciaRepository: ✅ Ausencia aprobada');
      return aprobada;
    } catch (e) {
      debugPrint('📦 AusenciaRepository: ❌ Error: $e');
      rethrow;
    }
  }

  @override
  Future<AusenciaEntity> rechazar({
    required String idAusencia,
    required String aprobadoPor,
    String? observaciones,
  }) async {
    debugPrint('📦 AusenciaRepository: Rechazando ausencia ID: $idAusencia');
    try {
      final AusenciaEntity rechazada = await _dataSource.rechazar(
        idAusencia: idAusencia,
        aprobadoPor: aprobadoPor,
        observaciones: observaciones,
      );
      debugPrint('📦 AusenciaRepository: ✅ Ausencia rechazada');
      return rechazada;
    } catch (e) {
      debugPrint('📦 AusenciaRepository: ❌ Error: $e');
      rethrow;
    }
  }

  @override
  Future<void> delete(String id) async {
    debugPrint('📦 AusenciaRepository: Eliminando ausencia ID: $id');
    try {
      await _dataSource.delete(id);
      debugPrint('📦 AusenciaRepository: ✅ Ausencia eliminada');
    } catch (e) {
      debugPrint('📦 AusenciaRepository: ❌ Error: $e');
      rethrow;
    }
  }

  @override
  Stream<List<AusenciaEntity>> watchAll() {
    debugPrint('📦 AusenciaRepository: Iniciando stream de ausencias...');
    return _dataSource.watchAll();
  }

  @override
  Stream<List<AusenciaEntity>> watchByPersonal(String idPersonal) {
    debugPrint('📦 AusenciaRepository: Iniciando stream para personal: $idPersonal');
    return _dataSource.watchByPersonal(idPersonal);
  }
}
