import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../../domain/repositories/vacaciones_repository.dart';

/// Implementación del repositorio de vacaciones.
/// Patrón pass-through: delega directamente al datasource sin conversiones.
@LazySingleton(as: VacacionesRepository)
class VacacionesRepositoryImpl implements VacacionesRepository {
  VacacionesRepositoryImpl()
      : _dataSource = VacacionesDataSourceFactory.createSupabase();

  final VacacionesDataSource _dataSource;

  @override
  Future<List<VacacionesEntity>> getAll() async {
    debugPrint('📦 VacacionesRepository: Solicitando todas las vacaciones...');
    try {
      final items = await _dataSource.getAll();
      debugPrint(
          '📦 VacacionesRepository: ✅ ${items.length} vacaciones obtenidas');
      return items;
    } catch (e) {
      debugPrint('📦 VacacionesRepository: ❌ Error: $e');
      rethrow;
    }
  }

  @override
  Future<VacacionesEntity> getById(String id) async {
    debugPrint('📦 VacacionesRepository: Obteniendo vacación ID: $id');
    return await _dataSource.getById(id);
  }

  @override
  Future<List<VacacionesEntity>> getByPersonalId(String idPersonal) async {
    debugPrint(
        '📦 VacacionesRepository: Obteniendo vacaciones del personal: $idPersonal');
    try {
      final items = await _dataSource.getByPersonalId(idPersonal);
      debugPrint(
          '📦 VacacionesRepository: ✅ ${items.length} vacaciones obtenidas para el personal');
      return items;
    } catch (e) {
      debugPrint('📦 VacacionesRepository: ❌ Error: $e');
      rethrow;
    }
  }

  @override
  Future<VacacionesEntity> create(VacacionesEntity entity) async {
    debugPrint('📦 VacacionesRepository: Creando vacación...');
    try {
      final created = await _dataSource.create(entity);
      debugPrint('📦 VacacionesRepository: ✅ Vacación creada: ${created.id}');
      return created;
    } catch (e) {
      debugPrint('📦 VacacionesRepository: ❌ Error al crear: $e');
      rethrow;
    }
  }

  @override
  Future<VacacionesEntity> update(VacacionesEntity entity) async {
    debugPrint(
        '📦 VacacionesRepository: Actualizando vacación ID: ${entity.id}');
    try {
      final updated = await _dataSource.update(entity);
      debugPrint('📦 VacacionesRepository: ✅ Vacación actualizada');
      return updated;
    } catch (e) {
      debugPrint('📦 VacacionesRepository: ❌ Error al actualizar: $e');
      rethrow;
    }
  }

  @override
  Future<void> delete(String id) async {
    debugPrint('📦 VacacionesRepository: Eliminando vacación ID: $id');
    try {
      await _dataSource.delete(id);
      debugPrint('📦 VacacionesRepository: ✅ Vacación eliminada');
    } catch (e) {
      debugPrint('📦 VacacionesRepository: ❌ Error al eliminar: $e');
      rethrow;
    }
  }

  @override
  Stream<List<VacacionesEntity>> watchAll() {
    debugPrint('📦 VacacionesRepository: Observando todas las vacaciones...');
    return _dataSource.watchAll();
  }

  @override
  Stream<List<VacacionesEntity>> watchByPersonalId(String idPersonal) {
    debugPrint(
        '📦 VacacionesRepository: Observando vacaciones del personal: $idPersonal');
    return _dataSource.watchByPersonalId(idPersonal);
  }
}
