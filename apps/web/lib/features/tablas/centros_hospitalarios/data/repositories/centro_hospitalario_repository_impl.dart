import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/features/tablas/centros_hospitalarios/domain/repositories/centro_hospitalario_repository.dart';
import 'package:injectable/injectable.dart';

/// Implementación del repositorio de centros hospitalarios usando core datasource
@LazySingleton(as: CentroHospitalarioRepository)
class CentroHospitalarioRepositoryImpl implements CentroHospitalarioRepository {
  CentroHospitalarioRepositoryImpl()
      : _dataSource = CentroHospitalarioDataSourceFactory.createSupabase();

  final CentroHospitalarioDataSource _dataSource;

  @override
  Future<List<CentroHospitalarioEntity>> getAll() async {
    return _dataSource.getAll();
  }

  @override
  Future<CentroHospitalarioEntity> getById(String id) async {
    final CentroHospitalarioEntity? entity = await _dataSource.getById(id);
    if (entity == null) {
      throw Exception('Centro hospitalario con ID $id no encontrado');
    }
    return entity;
  }

  @override
  Future<CentroHospitalarioEntity> create(
    CentroHospitalarioEntity centro,
  ) async {
    return _dataSource.create(centro);
  }

  @override
  Future<CentroHospitalarioEntity> update(
    CentroHospitalarioEntity centro,
  ) async {
    return _dataSource.update(centro);
  }

  @override
  Future<void> delete(String id) async {
    await _dataSource.delete(id);
  }
}
