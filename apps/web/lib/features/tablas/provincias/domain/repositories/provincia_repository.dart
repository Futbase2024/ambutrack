import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';

/// Contrato del repositorio de provincias
abstract class ProvinciaRepository {
  /// Obtiene todas las provincias
  Future<List<ProvinciaEntity>> getAll();

  /// Obtiene una provincia por ID
  Future<ProvinciaEntity> getById(String id);

  /// Crea una nueva provincia
  Future<ProvinciaEntity> create(ProvinciaEntity provincia);

  /// Actualiza una provincia existente
  Future<ProvinciaEntity> update(ProvinciaEntity provincia);

  /// Elimina una provincia por ID
  Future<void> delete(String id);
}
