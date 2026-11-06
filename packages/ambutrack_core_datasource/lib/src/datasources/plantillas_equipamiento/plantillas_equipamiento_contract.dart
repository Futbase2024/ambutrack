import 'entities/plantilla_equipamiento_entity.dart';
import 'entities/plantilla_equipamiento_item_entity.dart';

/// Contrato del datasource de plantillas de equipamiento por tipo de vehículo
///
/// Escritura restringida por RLS a `admin` y `jefe_mantenimiento`.
/// La propagación a los vehículos la hacen los triggers de Supabase.
abstract class PlantillasEquipamientoDataSource {
  // ---------------------------------------------------------------- Plantillas

  /// Todas las plantillas (con número de items), ordenadas por nombre
  Future<List<PlantillaEquipamientoEntity>> getAll();

  /// Plantilla por ID
  Future<PlantillaEquipamientoEntity?> getById(String id);

  /// Crea una plantilla (se aplica automáticamente a sus tipos de vehículo)
  Future<PlantillaEquipamientoEntity> create(PlantillaEquipamientoEntity plantilla);

  /// Actualiza una plantilla (si cambian los tipos, se aplica a los nuevos vehículos)
  Future<PlantillaEquipamientoEntity> update(PlantillaEquipamientoEntity plantilla);

  /// Elimina una plantilla (solo `admin`). Las líneas de los vehículos NO se borran:
  /// quedan como `fuera_plantilla`.
  Future<void> delete(String id);

  /// Reaplica la plantilla a todos sus vehículos. Devuelve nº de líneas creadas/adoptadas.
  Future<int> reaplicar(String plantillaId);

  // --------------------------------------------------------------------- Items

  /// Items de una plantilla ordenados por sección y orden
  Future<List<PlantillaEquipamientoItemEntity>> getItems(
    String plantillaId, {
    bool soloActivos = false,
  });

  /// Crea un item (se crea la línea en todos los vehículos del tipo)
  Future<PlantillaEquipamientoItemEntity> createItem(PlantillaEquipamientoItemEntity item);

  /// Actualiza un item. El producto no se puede cambiar.
  Future<PlantillaEquipamientoItemEntity> updateItem(PlantillaEquipamientoItemEntity item);

  /// Activa/desactiva un item (desactivar = sacarlo de la plantilla sin borrar historial)
  Future<void> setItemActivo(String itemId, {required bool activo});

  /// Elimina un item definitivamente (las líneas quedan como `fuera_plantilla`)
  Future<void> deleteItem(String itemId);
}
