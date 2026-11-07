import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';

/// Contrato del repositorio de checklists de vehículos
abstract class ChecklistVehiculoRepository {
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
