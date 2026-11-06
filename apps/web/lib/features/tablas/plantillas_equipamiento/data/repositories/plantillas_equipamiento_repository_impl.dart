import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/features/tablas/plantillas_equipamiento/domain/repositories/plantillas_equipamiento_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

/// Implementación pass-through al datasource core de plantillas de equipamiento
@LazySingleton(as: PlantillasEquipamientoRepository)
class PlantillasEquipamientoRepositoryImpl implements PlantillasEquipamientoRepository {
  PlantillasEquipamientoRepositoryImpl()
      : _dataSource = PlantillasEquipamientoDataSourceFactory.createSupabase();

  final PlantillasEquipamientoDataSource _dataSource;

  @override
  Future<List<PlantillaEquipamientoEntity>> getAll() {
    debugPrint('📦 PlantillasEquipamientoRepository: getAll');
    return _dataSource.getAll();
  }

  @override
  Future<PlantillaEquipamientoEntity> create(PlantillaEquipamientoEntity plantilla) =>
      _dataSource.create(plantilla);

  @override
  Future<PlantillaEquipamientoEntity> update(PlantillaEquipamientoEntity plantilla) =>
      _dataSource.update(plantilla);

  @override
  Future<void> delete(String id) => _dataSource.delete(id);

  @override
  Future<int> reaplicar(String plantillaId) => _dataSource.reaplicar(plantillaId);

  @override
  Future<List<PlantillaEquipamientoItemEntity>> getItems(String plantillaId) =>
      _dataSource.getItems(plantillaId);

  @override
  Future<PlantillaEquipamientoItemEntity> createItem(PlantillaEquipamientoItemEntity item) =>
      _dataSource.createItem(item);

  @override
  Future<PlantillaEquipamientoItemEntity> updateItem(PlantillaEquipamientoItemEntity item) =>
      _dataSource.updateItem(item);

  @override
  Future<void> setItemActivo(String itemId, {required bool activo}) =>
      _dataSource.setItemActivo(itemId, activo: activo);

  @override
  Future<void> deleteItem(String itemId) => _dataSource.deleteItem(itemId);
}
