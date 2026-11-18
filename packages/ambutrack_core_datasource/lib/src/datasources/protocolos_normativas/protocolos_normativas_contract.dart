import 'entities/protocolo_normativa_entity.dart';

/// Contrato del datasource de Protocolos y Normativas
abstract class ProtocolosNormativasDataSource {
  Future<List<ProtocoloNormativaEntity>> getAll();
  Future<ProtocoloNormativaEntity?> getById(String id);
  Future<List<ProtocoloNormativaEntity>> getActivos();
  Future<ProtocoloNormativaEntity> create(ProtocoloNormativaEntity entity);
  Future<ProtocoloNormativaEntity> update(ProtocoloNormativaEntity entity);
  Future<void> delete(String id);
}
