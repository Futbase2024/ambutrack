import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/features/tablas/tipos_paciente/domain/repositories/tipo_paciente_repository.dart';
import 'package:injectable/injectable.dart';

/// Implementación del repositorio de tipos de paciente
/// ✅ Pass-through: Delega directamente al datasource del core
@LazySingleton(as: TipoPacienteRepository)
class TipoPacienteRepositoryImpl implements TipoPacienteRepository {
  /// Constructor sin inyección - usa factory del core
  TipoPacienteRepositoryImpl()
      : _dataSource = TipoPacienteDataSourceFactory.createSupabase();

  final TipoPacienteDataSource _dataSource;

  @override
  Future<List<TipoPacienteEntity>> getAll() async {
    return _dataSource.getAll(); // ✅ Pass-through directo
  }

  @override
  Future<TipoPacienteEntity?> getById(String id) async {
    return _dataSource.getById(id); // ✅ Pass-through directo
  }

  @override
  Future<TipoPacienteEntity> create(TipoPacienteEntity tipoPaciente) async {
    return _dataSource.create(tipoPaciente); // ✅ Pass-through directo
  }

  @override
  Future<TipoPacienteEntity> update(TipoPacienteEntity tipoPaciente) async {
    return _dataSource.update(tipoPaciente); // ✅ Pass-through directo
  }

  @override
  Future<void> delete(String id) async {
    return _dataSource.delete(id); // ✅ Pass-through directo
  }

  @override
  Future<List<TipoPacienteEntity>> getActivos() async {
    return _dataSource.getActivos(); // ✅ Pass-through directo
  }
}
