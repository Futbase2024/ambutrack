import '../../../../core/datasources/registros_horarios/registros_horarios_datasource.dart';
import '../../domain/repositories/registro_horario_repository.dart';

/// Implementación del RegistroHorarioRepository
///
/// Pass-through directo al datasource (sin conversiones Entity ↔ Entity).
class RegistroHorarioRepositoryImpl implements RegistroHorarioRepository {
  RegistroHorarioRepositoryImpl()
      : _dataSource = RegistrosHorariosDataSourceFactory.createSupabase();

  final RegistrosHorariosDataSource _dataSource;

  @override
  Future<RegistroHorarioEntity> crear(RegistroHorarioEntity registro) async {
    return await _dataSource.crear(registro);
  }

  @override
  Future<List<RegistroHorarioEntity>> obtenerPorPersonal(
    String personalId, {
    int limit = 10,
  }) async {
    return await _dataSource.obtenerPorPersonal(personalId, limit: limit);
  }

  @override
  Future<RegistroHorarioEntity?> obtenerUltimo(String personalId) async {
    return await _dataSource.obtenerUltimo(personalId);
  }

  @override
  Future<List<RegistroHorarioEntity>> obtenerPorRangoFechas(
    String personalId,
    DateTime inicio,
    DateTime fin,
  ) async {
    return await _dataSource.obtenerPorRangoFechas(personalId, inicio, fin);
  }

  @override
  Future<List<RegistroHorarioEntity>> obtenerTodos(String personalId) async {
    return await _dataSource.obtenerTodos(personalId);
  }
}
