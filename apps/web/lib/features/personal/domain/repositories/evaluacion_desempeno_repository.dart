import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';

/// Repositorio de evaluaciones de desempeño
abstract class EvaluacionDesempenoRepository {
  Future<List<EvaluacionDesempenoEntity>> getAll();
  Future<EvaluacionDesempenoEntity?> getById(String id);
  Future<List<EvaluacionDesempenoEntity>> getByPersonal(String personalId);
  Future<EvaluacionDesempenoEntity> create(EvaluacionDesempenoEntity entity);
  Future<EvaluacionDesempenoEntity> update(EvaluacionDesempenoEntity entity);
  Future<void> delete(String id);
}
