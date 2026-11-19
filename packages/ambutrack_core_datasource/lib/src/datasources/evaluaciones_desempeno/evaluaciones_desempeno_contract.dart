import 'entities/evaluacion_desempeno_entity.dart';

/// Contrato del datasource de Evaluaciones de Desempeño
abstract class EvaluacionesDesempenoDataSource {
  /// Todas las evaluaciones (más recientes primero)
  Future<List<EvaluacionDesempenoEntity>> getAll();
  Future<EvaluacionDesempenoEntity?> getById(String id);
  Future<List<EvaluacionDesempenoEntity>> getByPersonal(String personalId);
  Future<EvaluacionDesempenoEntity> create(EvaluacionDesempenoEntity entity);
  Future<EvaluacionDesempenoEntity> update(EvaluacionDesempenoEntity entity);
  Future<void> delete(String id);
}
