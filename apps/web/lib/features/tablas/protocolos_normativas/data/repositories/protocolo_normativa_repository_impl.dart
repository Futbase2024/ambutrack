import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/features/tablas/protocolos_normativas/domain/repositories/protocolo_normativa_repository.dart';

/// Implementación del repositorio de protocolos y normativas (pass-through al core datasource)
class ProtocoloNormativaRepositoryImpl implements ProtocoloNormativaRepository {
  ProtocoloNormativaRepositoryImpl() : _dataSource = ProtocolosNormativasDataSourceFactory.createSupabase();

  final ProtocolosNormativasDataSource _dataSource;

  @override
  Future<List<ProtocoloNormativaEntity>> getAll() => _dataSource.getAll();

  @override
  Future<ProtocoloNormativaEntity?> getById(String id) => _dataSource.getById(id);

  @override
  Future<List<ProtocoloNormativaEntity>> getActivos() => _dataSource.getActivos();

  @override
  Future<ProtocoloNormativaEntity> create(ProtocoloNormativaEntity protocolo) => _dataSource.create(protocolo);

  @override
  Future<ProtocoloNormativaEntity> update(ProtocoloNormativaEntity protocolo) => _dataSource.update(protocolo);

  @override
  Future<void> delete(String id) => _dataSource.delete(id);
}
