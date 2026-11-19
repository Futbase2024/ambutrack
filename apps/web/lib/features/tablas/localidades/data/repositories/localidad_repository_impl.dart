import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/features/tablas/localidades/domain/repositories/localidad_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

/// Implementación del repositorio de localidades con Supabase
@LazySingleton(as: LocalidadRepository)
class LocalidadRepositoryImpl implements LocalidadRepository {
  LocalidadRepositoryImpl() : _dataSource = LocalidadDataSourceFactory.createSupabase();

  final LocalidadDataSource _dataSource;

  @override
  Future<List<LocalidadEntity>> getAll() async {
    debugPrint('📦 LocalidadRepository: Solicitando localidades del DataSource...');
    try {
      final List<LocalidadEntity> localidades = await _dataSource.getAll();
      debugPrint('📦 LocalidadRepository: ✅ ${localidades.length} localidades obtenidas');
      return localidades;
    } catch (e) {
      debugPrint('📦 LocalidadRepository: ❌ Error: $e');
      rethrow;
    }
  }

  @override
  Future<LocalidadEntity> getById(String id) async {
    final LocalidadEntity? entity = await _dataSource.getById(id);
    if (entity == null) {
      throw Exception('Localidad con ID $id no encontrada');
    }
    return entity;
  }

  @override
  Future<LocalidadEntity> create(LocalidadEntity localidad) async {
    return _dataSource.create(localidad);
  }

  @override
  Future<LocalidadEntity> update(LocalidadEntity localidad) async {
    return _dataSource.update(localidad);
  }

  @override
  Future<void> delete(String id) async {
    await _dataSource.delete(id);
  }
}
