import 'entities/certificacion_entity.dart';

/// Contrato para el datasource de certificaciones
abstract class CertificacionDataSource {
  /// Obtiene todos los certificaciones
  Future<List<CertificacionEntity>> getAll();

  /// Obtiene una certificación por ID
  Future<CertificacionEntity> getById(String id);

  /// Obtiene certificaciones activas
  Future<List<CertificacionEntity>> getActivas();

  /// Obtiene una certificación por código
  Future<CertificacionEntity?> getByCodigo(String codigo);

  /// Crea una nueva certificación
  Future<CertificacionEntity> create(CertificacionEntity entity);

  /// Actualiza una certificación existente
  Future<CertificacionEntity> update(CertificacionEntity entity);

  /// Elimina una certificación
  Future<void> delete(String id);

  /// Stream de todas las certificaciones
  Stream<List<CertificacionEntity>> watchAll();

  /// Stream de certificaciones activas
  Stream<List<CertificacionEntity>> watchActivas();
}
