import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../../domain/repositories/historial_medico_repository.dart';

/// Implementación del repositorio de Historial Médico usando datasource
@LazySingleton(as: HistorialMedicoRepository)
class HistorialMedicoRepositoryImpl implements HistorialMedicoRepository {
  HistorialMedicoRepositoryImpl() : _dataSource = HistorialMedicoDataSourceFactory.createSupabase();

  final HistorialMedicoDataSource _dataSource;

  @override
  Future<List<HistorialMedicoEntity>> getAll() async {
    debugPrint('📦 Repository: Solicitando todos los registros de historial médico...');
    try {
      final List<HistorialMedicoEntity> items = await _dataSource.getAll();
      debugPrint('📦 Repository: ✅ ${items.length} registros obtenidos');
      return items;
    } catch (e) {
      debugPrint('📦 Repository: ❌ Error: $e');
      rethrow;
    }
  }

  @override
  Future<HistorialMedicoEntity> getById(String id) async {
    debugPrint('📦 Repository: Solicitando registro con ID: $id');
    try {
      final HistorialMedicoEntity item = await _dataSource.getById(id);
      debugPrint('📦 Repository: ✅ Registro obtenido');
      return item;
    } catch (e) {
      debugPrint('📦 Repository: ❌ Error: $e');
      rethrow;
    }
  }

  @override
  Future<List<HistorialMedicoEntity>> getByPersonalId(String personalId) async {
    debugPrint('📦 Repository: Solicitando historial del personal: $personalId');
    try {
      final List<HistorialMedicoEntity> items = await _dataSource.getByPersonalId(personalId);
      debugPrint('📦 Repository: ✅ ${items.length} registros obtenidos');
      return items;
    } catch (e) {
      debugPrint('📦 Repository: ❌ Error: $e');
      rethrow;
    }
  }

  @override
  Future<List<HistorialMedicoEntity>> getProximosACaducar() async {
    debugPrint('📦 Repository: Solicitando reconocimientos próximos a caducar...');
    try {
      final List<HistorialMedicoEntity> items = await _dataSource.getProximosACaducar();
      debugPrint('📦 Repository: ✅ ${items.length} reconocimientos próximos a caducar');
      return items;
    } catch (e) {
      debugPrint('📦 Repository: ❌ Error: $e');
      rethrow;
    }
  }

  @override
  Future<List<HistorialMedicoEntity>> getCaducados() async {
    debugPrint('📦 Repository: Solicitando reconocimientos caducados...');
    try {
      final List<HistorialMedicoEntity> items = await _dataSource.getCaducados();
      debugPrint('📦 Repository: ✅ ${items.length} reconocimientos caducados');
      return items;
    } catch (e) {
      debugPrint('📦 Repository: ❌ Error: $e');
      rethrow;
    }
  }

  @override
  Future<HistorialMedicoEntity> create(HistorialMedicoEntity entity) async {
    debugPrint('📦 Repository: Creando nuevo registro de historial médico...');
    try {
      final HistorialMedicoEntity item = await _dataSource.create(entity);
      debugPrint('📦 Repository: ✅ Registro creado');
      return item;
    } catch (e) {
      debugPrint('📦 Repository: ❌ Error: $e');
      rethrow;
    }
  }

  @override
  Future<HistorialMedicoEntity> update(HistorialMedicoEntity entity) async {
    debugPrint('📦 Repository: Actualizando registro de historial médico: ${entity.id}');
    try {
      final HistorialMedicoEntity item = await _dataSource.update(entity);
      debugPrint('📦 Repository: ✅ Registro actualizado');
      return item;
    } catch (e) {
      debugPrint('📦 Repository: ❌ Error: $e');
      rethrow;
    }
  }

  @override
  Future<void> delete(String id) async {
    debugPrint('📦 Repository: Eliminando registro: $id');
    try {
      await _dataSource.delete(id);
      debugPrint('📦 Repository: ✅ Registro eliminado');
    } catch (e) {
      debugPrint('📦 Repository: ❌ Error: $e');
      rethrow;
    }
  }

  @override
  Stream<List<HistorialMedicoEntity>> watchAll() {
    debugPrint('📦 Repository: Iniciando stream de todos los registros');
    return _dataSource.watchAll();
  }

  @override
  Stream<List<HistorialMedicoEntity>> watchByPersonalId(String personalId) {
    debugPrint('📦 Repository: Iniciando stream del personal: $personalId');
    return _dataSource.watchByPersonalId(personalId);
  }
}
