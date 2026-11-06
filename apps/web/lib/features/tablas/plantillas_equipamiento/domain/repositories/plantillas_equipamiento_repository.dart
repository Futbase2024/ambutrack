import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';

/// Repositorio de plantillas de equipamiento por tipo de vehículo
abstract class PlantillasEquipamientoRepository {
  Future<List<PlantillaEquipamientoEntity>> getAll();

  Future<PlantillaEquipamientoEntity> create(PlantillaEquipamientoEntity plantilla);

  Future<PlantillaEquipamientoEntity> update(PlantillaEquipamientoEntity plantilla);

  Future<void> delete(String id);

  /// Reaplica la plantilla a todos sus vehículos. Devuelve nº de líneas creadas
  Future<int> reaplicar(String plantillaId);

  Future<List<PlantillaEquipamientoItemEntity>> getItems(String plantillaId);

  Future<PlantillaEquipamientoItemEntity> createItem(PlantillaEquipamientoItemEntity item);

  Future<PlantillaEquipamientoItemEntity> updateItem(PlantillaEquipamientoItemEntity item);

  Future<void> setItemActivo(String itemId, {required bool activo});

  Future<void> deleteItem(String itemId);
}
