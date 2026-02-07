import '../checklist_vehiculo/entities/checklist_vehiculo_entity.dart';
import '../checklist_vehiculo/entities/item_checklist_entity.dart';

/// Contrato de operaciones para Checklists de Vehículos
abstract class ChecklistVehiculoDataSource {
  /// Obtiene todos los checklists
  Future<List<ChecklistVehiculoEntity>> getAll();

  /// Obtiene un checklist por ID
  Future<ChecklistVehiculoEntity> getById(String id);

  /// Obtiene checklists de un vehículo específico
  Future<List<ChecklistVehiculoEntity>> getByVehiculoId(String vehiculoId);

  /// Obtiene el último checklist de un vehículo por tipo
  Future<ChecklistVehiculoEntity?> getUltimoChecklist(
    String vehiculoId,
    TipoChecklist tipo,
  );

  /// Obtiene la plantilla de items para un tipo de checklist
  Future<List<ItemChecklistEntity>> getPlantillaItems(TipoChecklist tipo);

  /// Crea un nuevo checklist
  Future<ChecklistVehiculoEntity> create(ChecklistVehiculoEntity entity);

  /// Actualiza un checklist existente
  Future<ChecklistVehiculoEntity> update(ChecklistVehiculoEntity entity);

  /// Elimina un checklist
  Future<void> delete(String id);

  /// Stream en tiempo real de checklists de un vehículo
  Stream<List<ChecklistVehiculoEntity>> watchByVehiculoId(String vehiculoId);
}
