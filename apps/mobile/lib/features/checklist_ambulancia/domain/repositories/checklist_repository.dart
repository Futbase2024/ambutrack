import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';

/// Contrato del repositorio de Checklists de Ambulancia
///
/// La implementación está en:
/// - data/repositories/checklist_repository_impl.dart
abstract class ChecklistRepository {
  /// Obtiene todos los checklists del sistema
  Future<List<ChecklistVehiculoEntity>> getAll();

  /// Obtiene un checklist por ID
  Future<ChecklistVehiculoEntity> getById(String id);

  /// Obtiene los checklists de un vehículo específico
  ///
  /// Útil para ver el historial de checklists de una ambulancia
  Future<List<ChecklistVehiculoEntity>> getHistorialVehiculo(String vehiculoId);

  /// Obtiene el último checklist de un vehículo por tipo
  ///
  /// [vehiculoId] ID del vehículo
  /// [tipo] Tipo de checklist (mensual, preServicio, postServicio)
  ///
  /// Retorna null si no hay checklists previos de ese tipo
  Future<ChecklistVehiculoEntity?> getUltimoChecklist(
    String vehiculoId,
    TipoChecklist tipo,
  );

  /// Obtiene la plantilla de items para un tipo de checklist
  ///
  /// La plantilla contiene los ítems predefinidos que se deben verificar
  /// según el tipo de checklist (pre-servicio, post-servicio, mensual)
  Future<List<ItemChecklistEntity>> getPlantillaItems(TipoChecklist tipo);

  /// Crea un nuevo checklist
  ///
  /// Valida que todos los campos requeridos estén presentes y
  /// guarda el checklist con sus ítems en Supabase
  Future<ChecklistVehiculoEntity> crearChecklist(
    ChecklistVehiculoEntity checklist,
  );

  /// Actualiza un checklist existente
  ///
  /// Permite modificar observaciones o corregir datos
  Future<ChecklistVehiculoEntity> actualizarChecklist(
    ChecklistVehiculoEntity checklist,
  );

  /// Elimina un checklist
  ///
  /// Solo permitido para administradores o en casos excepcionales
  Future<void> eliminarChecklist(String id);

  /// Stream en tiempo real de checklists de un vehículo
  ///
  /// Útil para actualizar la UI cuando se crea un nuevo checklist
  /// desde otro dispositivo o cuando hay cambios
  Stream<List<ChecklistVehiculoEntity>> watchChecklistsVehiculo(
    String vehiculoId,
  );

  /// Obtiene el vehículo asignado al usuario hoy
  ///
  /// Busca en la tabla de turnos el vehículo asignado al personal
  /// en la fecha actual. Retorna null si no tiene vehículo asignado.
  Future<String?> getVehiculoAsignadoHoy(String personalId);

  /// Obtiene todos los vehículos activos de la empresa
  ///
  /// Usado por admin/coordinador para selección manual de vehículo
  /// al crear checklist. Solo muestra vehículos activos.
  Future<List<VehiculoEntity>> getTodosVehiculos(String empresaId);
}
