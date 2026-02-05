import 'package:ambutrack_core/ambutrack_core.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../../domain/repositories/especialidad_repository.dart';

/// Implementación del repositorio de especialidades médicas
/// Patrón pass-through: delega directamente al datasource del core sin conversiones
@LazySingleton(as: EspecialidadRepository)
class EspecialidadRepositoryImpl implements EspecialidadRepository {
  EspecialidadRepositoryImpl() : _dataSource = EspecialidadDataSourceFactory.createSupabase();

  final EspecialidadDataSource _dataSource;

  @override
  Future<List<EspecialidadEntity>> getAll() async {
    debugPrint('📦 EspecialidadRepository: Solicitando especialidades del DataSource...');
    try {
      final List<EspecialidadEntity> especialidades = await _dataSource.getAll();
      debugPrint('📦 EspecialidadRepository: ✅ ${especialidades.length} especialidades obtenidas');
      return especialidades; // ✅ Pass-through directo
    } catch (e) {
      debugPrint('📦 EspecialidadRepository: ❌ Error: $e');
      rethrow;
    }
  }

  @override
  Future<EspecialidadEntity?> getById(String id) async {
    return _dataSource.getById(id);
  }

  @override
  Future<void> create(EspecialidadEntity especialidad) async {
    await _dataSource.create(especialidad);
  }

  @override
  Future<void> update(EspecialidadEntity especialidad) async {
    await _dataSource.update(especialidad);
  }

  @override
  Future<void> delete(String id) async {
    await _dataSource.delete(id);
  }

  @override
  Future<List<EspecialidadEntity>> filterByTipo(String tipo) async {
    return _dataSource.filterByTipo(tipo);
  }

  @override
  Future<List<EspecialidadEntity>> getActivas() async {
    return _dataSource.getActivas();
  }
}
