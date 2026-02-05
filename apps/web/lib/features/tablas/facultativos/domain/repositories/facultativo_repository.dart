import 'package:ambutrack_core/ambutrack_core.dart';

/// Contrato del repositorio de Facultativos
///
/// IMPORTANTE: Este repositorio sigue el patrón pass-through,
/// delegando directamente al datasource sin conversiones.
abstract class FacultativoRepository {
  /// Obtiene todos los facultativos
  Future<List<FacultativoEntity>> getAll();

  /// Obtiene un facultativo por ID
  Future<FacultativoEntity?> getById(String id);

  /// Crea un nuevo facultativo
  Future<FacultativoEntity> create(FacultativoEntity facultativo);

  /// Actualiza un facultativo existente
  Future<FacultativoEntity> update(FacultativoEntity facultativo);

  /// Elimina un facultativo por ID
  Future<void> delete(String id);

  /// Obtiene todos los facultativos activos
  Future<List<FacultativoEntity>> getActivos();

  /// Filtra facultativos por especialidad
  Future<List<FacultativoEntity>> filterByEspecialidad(String especialidadId);
}
