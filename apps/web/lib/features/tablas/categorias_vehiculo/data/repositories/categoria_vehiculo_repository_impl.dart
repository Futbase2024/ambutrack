import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/features/tablas/categorias_vehiculo/domain/repositories/categoria_vehiculo_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: CategoriaVehiculoRepository)
class CategoriaVehiculoRepositoryImpl implements CategoriaVehiculoRepository {
  CategoriaVehiculoRepositoryImpl() : _dataSource = CategoriaVehiculoDataSourceFactory.createSupabase();
  final CategoriaVehiculoDataSource _dataSource;

  @override
  Future<List<CategoriaVehiculoEntity>> getAll() async {
    debugPrint('📦 Repository: Solicitando categorías...');
    return _dataSource.getAll();
  }

  @override
  Future<CategoriaVehiculoEntity?> getById(String id) => _dataSource.getById(id);

  @override
  Future<CategoriaVehiculoEntity> create(CategoriaVehiculoEntity categoria) => _dataSource.create(categoria);

  @override
  Future<CategoriaVehiculoEntity> update(CategoriaVehiculoEntity categoria) => _dataSource.update(categoria);

  @override
  Future<void> delete(String id) => _dataSource.delete(id);

  @override
  Stream<List<CategoriaVehiculoEntity>> watchAll() => _dataSource.watchAll();
}
