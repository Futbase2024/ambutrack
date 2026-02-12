import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/features/tablas/tipos_traslado/domain/repositories/tipo_traslado_repository.dart';
import 'package:injectable/injectable.dart';

/// Implementación del repositorio de tipos de traslado
/// ✅ Pass-through: Delega directamente al datasource del core
@LazySingleton(as: TipoTrasladoRepository)
class TipoTrasladoRepositoryImpl implements TipoTrasladoRepository {
  /// Constructor sin inyección - usa factory del core
  TipoTrasladoRepositoryImpl()
      : _dataSource = TipoTrasladoDataSourceFactory.createSupabase();

  final TipoTrasladoDataSource _dataSource;

  @override
  Future<List<TipoTrasladoEntity>> getAll() async {
    return _dataSource.getAll(); // ✅ Pass-through directo
  }

  @override
  Future<TipoTrasladoEntity?> getById(String id) async {
    return _dataSource.getById(id); // ✅ Pass-through directo
  }

  @override
  Future<TipoTrasladoEntity> create(TipoTrasladoEntity tipo) async {
    return _dataSource.create(tipo); // ✅ Pass-through directo
  }

  @override
  Future<TipoTrasladoEntity> update(TipoTrasladoEntity tipo) async {
    return _dataSource.update(tipo); // ✅ Pass-through directo
  }

  @override
  Future<void> delete(String id) async {
    return _dataSource.delete(id); // ✅ Pass-through directo
  }

  @override
  Future<List<TipoTrasladoEntity>> getActivos() async {
    return _dataSource.getActivos(); // ✅ Pass-through directo
  }
}
