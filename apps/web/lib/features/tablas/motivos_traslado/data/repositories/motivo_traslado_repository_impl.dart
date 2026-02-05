import 'package:ambutrack_core/ambutrack_core.dart';
import 'package:ambutrack_web/features/tablas/motivos_traslado/domain/repositories/motivo_traslado_repository.dart';
import 'package:injectable/injectable.dart';

/// Implementación del repositorio de motivos de traslado usando core datasource
@LazySingleton(as: MotivoTrasladoRepository)
class MotivoTrasladoRepositoryImpl implements MotivoTrasladoRepository {
  MotivoTrasladoRepositoryImpl()
      : _dataSource = MotivoTrasladoDataSourceFactory.createSupabase();

  final MotivoTrasladoDataSource _dataSource;

  @override
  Future<List<MotivoTrasladoEntity>> getAll() async {
    return _dataSource.getAll();
  }

  @override
  Future<MotivoTrasladoEntity?> getById(String id) async {
    return _dataSource.getById(id);
  }

  @override
  Future<void> create(MotivoTrasladoEntity motivo) async {
    await _dataSource.create(motivo);
  }

  @override
  Future<void> update(MotivoTrasladoEntity motivo) async {
    await _dataSource.update(motivo);
  }

  @override
  Future<void> delete(String id) async {
    await _dataSource.delete(id);
  }

  @override
  Stream<List<MotivoTrasladoEntity>> watchAll() {
    return _dataSource.watchAll();
  }
}
