import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';

/// Contrato del repositorio de protocolos y normativas
abstract class ProtocoloNormativaRepository {
  Future<List<ProtocoloNormativaEntity>> getAll();
  Future<ProtocoloNormativaEntity?> getById(String id);
  Future<List<ProtocoloNormativaEntity>> getActivos();
  Future<ProtocoloNormativaEntity> create(ProtocoloNormativaEntity protocolo);
  Future<ProtocoloNormativaEntity> update(ProtocoloNormativaEntity protocolo);
  Future<void> delete(String id);
}
