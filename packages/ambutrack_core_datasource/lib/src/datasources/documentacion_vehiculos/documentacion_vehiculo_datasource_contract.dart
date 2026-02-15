import 'entities/documentacion_vehiculo_entity.dart';

/// Contract para el DataSource de Documentación de Vehículos
/// Define las operaciones que debe implementar cualquier datasource
abstract class DocumentacionVehiculoDataSource {
  /// Obtiene todos los registros de documentación
  Future<List<DocumentacionVehiculoEntity>> getAll();

  /// Obtiene un registro de documentación por ID
  Future<DocumentacionVehiculoEntity?> getById(String id);

  /// Obtiene documentación por vehículo
  Future<List<DocumentacionVehiculoEntity>> getByVehiculo(String vehiculoId);

  /// Obtiene documentación por tipo de documento
  Future<List<DocumentacionVehiculoEntity>> getByTipoDocumento(String tipoDocumentoId);

  /// Obtiene documentación por estado
  Future<List<DocumentacionVehiculoEntity>> getByEstado(String estado);

  /// Obtiene documentos próximos a vencer (dentro de los días de alerta)
  Future<List<DocumentacionVehiculoEntity>> getProximosAVencer();

  /// Obtiene documentos vencidos
  Future<List<DocumentacionVehiculoEntity>> getVencidos();

  /// Crea un nuevo registro de documentación
  Future<DocumentacionVehiculoEntity> create(DocumentacionVehiculoEntity entity);

  /// Actualiza un registro de documentación existente
  Future<DocumentacionVehiculoEntity> update(DocumentacionVehiculoEntity entity);

  /// Elimina un registro de documentación por ID
  Future<void> delete(String id);

  /// Actualiza el estado de un documento (calcula automáticamente)
  Future<DocumentacionVehiculoEntity> actualizarEstado(String id);

  /// Busca documentos por número de póliza
  Future<List<DocumentacionVehiculoEntity>> buscarPorPoliza(String numeroPoliza);

  /// Busca documentos por compañía
  Future<List<DocumentacionVehiculoEntity>> buscarPorCompania(String compania);
}
