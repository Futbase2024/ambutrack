import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';

/// Contrato del repositorio de plantillas de turnos
abstract class PlantillaTurnoRepository {
  /// Obtiene todas las plantillas activas
  Future<List<PlantillaTurnoEntity>> getAll();

  /// Obtiene una plantilla por ID
  Future<PlantillaTurnoEntity?> getById(String id);

  /// Crea una nueva plantilla
  Future<PlantillaTurnoEntity> create(PlantillaTurnoEntity plantilla);

  /// Actualiza una plantilla existente
  Future<PlantillaTurnoEntity> update(PlantillaTurnoEntity plantilla);

  /// Elimina una plantilla (soft delete)
  Future<void> delete(String id);

  /// Duplica una plantilla existente
  Future<PlantillaTurnoEntity> duplicate(String id);
}
