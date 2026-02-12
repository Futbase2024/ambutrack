import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/features/vacaciones/domain/repositories/vacaciones_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

/// Implementación del repositorio de Vacaciones usando datasource
@LazySingleton(as: VacacionesRepository)
class VacacionesRepositoryImpl implements VacacionesRepository {
  VacacionesRepositoryImpl()
      : _dataSource = VacacionesDataSourceFactory.createSupabase();

  final VacacionesDataSource _dataSource;

  @override
  Future<List<VacacionesEntity>> getAll() async {
    debugPrint('📦 VacacionesRepository: Solicitando todas las vacaciones...');
    try {
      final List<VacacionesEntity> items = await _dataSource.getAll();
      debugPrint('📦 VacacionesRepository: ✅ ${items.length} vacaciones obtenidas');
      return items;
    } catch (e) {
      debugPrint('📦 VacacionesRepository: ❌ Error: $e');
      rethrow;
    }
  }

  @override
  Future<VacacionesEntity> getById(String id) async {
    debugPrint('📦 VacacionesRepository: Solicitando vacación con ID: $id');
    return _dataSource.getById(id);
  }

  @override
  Future<List<VacacionesEntity>> getByPersonalId(String idPersonal) async {
    debugPrint('📦 VacacionesRepository: Solicitando vacaciones del personal: $idPersonal');
    return _dataSource.getByPersonalId(idPersonal);
  }

  @override
  Future<VacacionesEntity> create(VacacionesEntity entity) async {
    debugPrint('📦 VacacionesRepository: Creando vacación...');
    return _dataSource.create(entity);
  }

  @override
  Future<VacacionesEntity> update(VacacionesEntity entity) async {
    debugPrint('📦 VacacionesRepository: Actualizando vacación: ${entity.id}');
    return _dataSource.update(entity);
  }

  @override
  Future<void> delete(String id) async {
    debugPrint('📦 VacacionesRepository: Eliminando vacación: $id');
    await _dataSource.delete(id);
  }

  @override
  Stream<List<VacacionesEntity>> watchAll() {
    debugPrint('📦 VacacionesRepository: Iniciando observación de vacaciones...');
    return _dataSource.watchAll();
  }

  @override
  Stream<List<VacacionesEntity>> watchByPersonalId(String idPersonal) {
    debugPrint('📦 VacacionesRepository: Observando vacaciones del personal: $idPersonal');
    return _dataSource.watchByPersonalId(idPersonal);
  }
}
