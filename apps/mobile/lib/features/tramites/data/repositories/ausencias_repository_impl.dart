import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../../domain/repositories/ausencias_repository.dart';

/// Implementación del repositorio de ausencias.
/// Patrón pass-through: delega directamente al datasource sin conversiones.
@LazySingleton(as: AusenciasRepository)
class AusenciasRepositoryImpl implements AusenciasRepository {
  AusenciasRepositoryImpl()
      : _dataSource = AusenciaDataSourceFactory.createSupabase();

  final AusenciaDataSource _dataSource;

  @override
  Future<List<AusenciaEntity>> getAll() async {
    debugPrint('📦 AusenciasRepository: Solicitando todas las ausencias...');
    try {
      final items = await _dataSource.getAll();
      debugPrint(
          '📦 AusenciasRepository: ✅ ${items.length} ausencias obtenidas');
      return items;
    } catch (e) {
      debugPrint('📦 AusenciasRepository: ❌ Error: $e');
      rethrow;
    }
  }

  @override
  Future<List<AusenciaEntity>> getByPersonal(String idPersonal) async {
    debugPrint(
        '📦 AusenciasRepository: Obteniendo ausencias del personal: $idPersonal');
    try {
      final items = await _dataSource.getByPersonal(idPersonal);
      debugPrint(
          '📦 AusenciasRepository: ✅ ${items.length} ausencias obtenidas para el personal');
      return items;
    } catch (e) {
      debugPrint('📦 AusenciasRepository: ❌ Error: $e');
      rethrow;
    }
  }

  @override
  Future<List<AusenciaEntity>> getByEstado(EstadoAusencia estado) async {
    debugPrint(
        '📦 AusenciasRepository: Obteniendo ausencias con estado: $estado');
    try {
      final items = await _dataSource.getByEstado(estado);
      debugPrint(
          '📦 AusenciasRepository: ✅ ${items.length} ausencias obtenidas');
      return items;
    } catch (e) {
      debugPrint('📦 AusenciasRepository: ❌ Error: $e');
      rethrow;
    }
  }

  @override
  Future<List<AusenciaEntity>> getByRangoFechas({
    required DateTime fechaInicio,
    required DateTime fechaFin,
  }) async {
    debugPrint(
        '📦 AusenciasRepository: Obteniendo ausencias entre $fechaInicio y $fechaFin');
    try {
      final items = await _dataSource.getByRangoFechas(
        fechaInicio: fechaInicio,
        fechaFin: fechaFin,
      );
      debugPrint(
          '📦 AusenciasRepository: ✅ ${items.length} ausencias obtenidas');
      return items;
    } catch (e) {
      debugPrint('📦 AusenciasRepository: ❌ Error: $e');
      rethrow;
    }
  }

  @override
  Future<AusenciaEntity> getById(String id) async {
    debugPrint('📦 AusenciasRepository: Obteniendo ausencia ID: $id');
    return await _dataSource.getById(id);
  }

  @override
  Future<AusenciaEntity> create(AusenciaEntity ausencia) async {
    debugPrint('📦 AusenciasRepository: Creando ausencia...');
    try {
      final created = await _dataSource.create(ausencia);
      debugPrint('📦 AusenciasRepository: ✅ Ausencia creada: ${created.id}');
      return created;
    } catch (e) {
      debugPrint('📦 AusenciasRepository: ❌ Error al crear: $e');
      rethrow;
    }
  }

  @override
  Future<AusenciaEntity> update(AusenciaEntity ausencia) async {
    debugPrint(
        '📦 AusenciasRepository: Actualizando ausencia ID: ${ausencia.id}');
    try {
      final updated = await _dataSource.update(ausencia);
      debugPrint('📦 AusenciasRepository: ✅ Ausencia actualizada');
      return updated;
    } catch (e) {
      debugPrint('📦 AusenciasRepository: ❌ Error al actualizar: $e');
      rethrow;
    }
  }

  @override
  Future<void> delete(String id) async {
    debugPrint('📦 AusenciasRepository: Eliminando ausencia ID: $id');
    try {
      await _dataSource.delete(id);
      debugPrint('📦 AusenciasRepository: ✅ Ausencia eliminada');
    } catch (e) {
      debugPrint('📦 AusenciasRepository: ❌ Error al eliminar: $e');
      rethrow;
    }
  }

  @override
  Stream<List<AusenciaEntity>> watchAll() {
    debugPrint('📦 AusenciasRepository: Observando todas las ausencias...');
    return _dataSource.watchAll();
  }

  @override
  Stream<List<AusenciaEntity>> watchByPersonal(String idPersonal) {
    debugPrint(
        '📦 AusenciasRepository: Observando ausencias del personal: $idPersonal');
    return _dataSource.watchByPersonal(idPersonal);
  }
}
