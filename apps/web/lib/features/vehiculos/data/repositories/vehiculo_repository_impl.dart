import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/features/vehiculos/domain/repositories/vehiculo_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

/// Implementación del repositorio de vehículos con Supabase
@LazySingleton(as: VehiculoRepository)
class VehiculoRepositoryImpl implements VehiculoRepository {
  VehiculoRepositoryImpl() : _dataSource = VehiculoDataSourceFactory.createSupabase();

  final VehiculoDataSource _dataSource;

  @override
  Future<List<VehiculoEntity>> getAll({
    String? orderBy,
    bool ascending = true,
    int? limit,
  }) async {
    debugPrint('📦 VehiculoRepository: Solicitando vehículos del DataSource...');
    try {
      final List<VehiculoEntity> vehiculos = await _dataSource.getAll(limit: limit);
      debugPrint('📦 VehiculoRepository: ✅ ${vehiculos.length} vehículos obtenidos');
      return vehiculos;
    } catch (e) {
      debugPrint('📦 VehiculoRepository: ❌ Error: $e');
      rethrow;
    }
  }

  @override
  Future<VehiculoEntity> getById(String id) async {
    final VehiculoEntity? entity = await _dataSource.getById(id);
    if (entity == null) {
      throw Exception('Vehículo con ID $id no encontrado');
    }
    return entity;
  }

  @override
  Future<List<VehiculoEntity>> getByEstado(VehiculoEstado estado) async {
    return _dataSource.getByEstado(estado);
  }

  @override
  Future<VehiculoEntity> create(VehiculoEntity vehiculo) async {
    return _dataSource.create(vehiculo);
  }

  @override
  Future<VehiculoEntity> update(VehiculoEntity vehiculo) async {
    return _dataSource.update(vehiculo);
  }

  @override
  Future<void> delete(String id) async {
    await _dataSource.delete(id);
  }

  @override
  Future<void> setSillaElectrica(List<String> vehiculoIds, {required bool tiene}) async {
    await _dataSource.setSillaElectrica(vehiculoIds, tiene: tiene);
  }

  @override
  Stream<List<VehiculoEntity>> watchAll() {
    return _dataSource.watchAll();
  }

  @override
  Future<int> count() async {
    return _dataSource.count();
  }

  @override
  Future<List<VehiculoEntity>> searchByMatricula(String matricula) async {
    return _dataSource.searchByMatricula(matricula);
  }
}
