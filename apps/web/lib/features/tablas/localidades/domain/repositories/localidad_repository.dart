import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';

/// Contrato del repositorio de localidades
abstract class LocalidadRepository {
  /// Obtiene todas las localidades
  Future<List<LocalidadEntity>> getAll();

  /// Obtiene una localidad por ID
  Future<LocalidadEntity> getById(String id);

  /// Crea una nueva localidad
  Future<LocalidadEntity> create(LocalidadEntity localidad);

  /// Actualiza una localidad existente
  Future<LocalidadEntity> update(LocalidadEntity localidad);

  /// Elimina una localidad por ID
  Future<void> delete(String id);
}
