import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';

/// Contrato del Repository para Tipos de Documento de Vehículo
abstract class TipoDocumentoRepository {
  /// Obtiene todos los tipos de documento
  Future<List<TipoDocumentoEntity>> getAll();

  /// Obtiene un tipo de documento por ID
  Future<TipoDocumentoEntity?> getById(String id);

  /// Obtiene tipos de documento por categoría
  Future<List<TipoDocumentoEntity>> getByCategoria(String categoria);

  /// Obtiene solo tipos de documento activos
  Future<List<TipoDocumentoEntity>> getActivos();

  /// Crea un nuevo tipo de documento
  Future<TipoDocumentoEntity> create(TipoDocumentoEntity entity);

  /// Actualiza un tipo de documento existente
  Future<TipoDocumentoEntity> update(TipoDocumentoEntity entity);

  /// Elimina un tipo de documento por ID
  Future<void> delete(String id);

  /// Desactiva un tipo de documento (soft delete)
  Future<TipoDocumentoEntity> desactivar(String id);
}
