import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/features/personal/domain/repositories/equipamiento_personal_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

/// Implementación del repositorio de equipamiento personal
@LazySingleton(as: EquipamientoPersonalRepository)
class EquipamientoPersonalRepositoryImpl implements EquipamientoPersonalRepository {
  EquipamientoPersonalRepositoryImpl()
      : _dataSource = EquipamientoPersonalDataSourceFactory.createSupabase();

  final EquipamientoPersonalDataSource _dataSource;

  @override
  Future<List<EquipamientoPersonalEntity>> getAll() async {
    debugPrint('📦 Repository: Solicitando todos los registros...');
    try {
      final List<EquipamientoPersonalEntity> items = await _dataSource.getAll();
      debugPrint('📦 Repository: ✅ ${items.length} items obtenidos');
      return items;
    } catch (e) {
      debugPrint('📦 Repository: ❌ Error: $e');
      rethrow;
    }
  }

  @override
  Future<EquipamientoPersonalEntity> getById(String id) async {
    debugPrint('📦 Repository: Solicitando item por ID: $id');
    return _dataSource.getById(id);
  }

  @override
  Future<List<EquipamientoPersonalEntity>> getByPersonalId(String personalId) async {
    debugPrint('📦 Repository: Solicitando por personalId: $personalId');
    return _dataSource.getByPersonalId(personalId);
  }

  @override
  Future<List<EquipamientoPersonalEntity>> getAsignado() async {
    debugPrint('📦 Repository: Solicitando equipamiento asignado');
    return _dataSource.getAsignado();
  }

  @override
  Future<List<EquipamientoPersonalEntity>> getByTipo(String tipo) async {
    debugPrint('📦 Repository: Solicitando por tipo: $tipo');
    return _dataSource.getByTipo(tipo);
  }

  @override
  Future<EquipamientoPersonalEntity> create(EquipamientoPersonalEntity entity) async {
    debugPrint('📦 Repository: Creando item');
    return _dataSource.create(entity);
  }

  @override
  Future<EquipamientoPersonalEntity> update(EquipamientoPersonalEntity entity) async {
    debugPrint('📦 Repository: Actualizando item: ${entity.id}');
    return _dataSource.update(entity);
  }

  @override
  Future<void> delete(String id) async {
    debugPrint('📦 Repository: Eliminando item: $id');
    await _dataSource.delete(id);
  }

  @override
  Stream<List<EquipamientoPersonalEntity>> watchAll() {
    debugPrint('📦 Repository: Iniciando stream de todos');
    return _dataSource.watchAll();
  }

  @override
  Stream<List<EquipamientoPersonalEntity>> watchByPersonalId(String personalId) {
    debugPrint('📦 Repository: Stream por personalId: $personalId');
    return _dataSource.watchByPersonalId(personalId);
  }
}
