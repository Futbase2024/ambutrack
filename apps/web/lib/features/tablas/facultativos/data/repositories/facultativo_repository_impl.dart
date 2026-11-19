import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/features/tablas/facultativos/domain/repositories/facultativo_repository.dart';
import 'package:injectable/injectable.dart';

/// Implementación del repositorio de Facultativos
///
/// PATRÓN PASS-THROUGH: Este repositorio delega directamente al datasource
/// del core package SIN conversiones entre entidades.
@LazySingleton(as: FacultativoRepository)
class FacultativoRepositoryImpl implements FacultativoRepository {
  FacultativoRepositoryImpl()
      : _dataSource = FacultativoDataSourceFactory.createSupabase();

  final FacultativoDataSource _dataSource;

  @override
  Future<List<FacultativoEntity>> getAll() async {
    return _dataSource.getAll(); // ✅ Pass-through directo
  }

  @override
  Future<FacultativoEntity?> getById(String id) async {
    return _dataSource.getById(id); // ✅ Pass-through directo
  }

  @override
  Future<FacultativoEntity> create(FacultativoEntity facultativo) async {
    return _dataSource.create(facultativo); // ✅ Pass-through directo
  }

  @override
  Future<FacultativoEntity> update(FacultativoEntity facultativo) async {
    return _dataSource.update(facultativo); // ✅ Pass-through directo
  }

  @override
  Future<void> delete(String id) async {
    await _dataSource.delete(id); // ✅ Pass-through directo
  }

  @override
  Future<List<FacultativoEntity>> getActivos() async {
    return _dataSource.getActivos(); // ✅ Pass-through directo
  }

  @override
  Future<List<FacultativoEntity>> filterByEspecialidad(
    String especialidadId,
  ) async {
    return _dataSource
        .filterByEspecialidad(especialidadId); // ✅ Pass-through directo
  }
}
