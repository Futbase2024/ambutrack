import '../../core/base_datasource.dart';
import 'entities/tipo_paciente_entity.dart';

/// Contrato para el datasource de tipos de paciente
///
/// Extiende BaseDatasource para operaciones CRUD estándar y define
/// métodos específicos para tipos de paciente.
abstract class TipoPacienteDataSource
    implements BaseDatasource<TipoPacienteEntity> {
  /// Obtiene todos los tipos de paciente activos
  ///
  /// Retorna una lista de tipos de paciente con activo = true.
  Future<List<TipoPacienteEntity>> getActivos();
}
