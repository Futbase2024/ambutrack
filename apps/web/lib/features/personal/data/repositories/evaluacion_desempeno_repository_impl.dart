import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/features/personal/domain/repositories/evaluacion_desempeno_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

/// Implementación pass-through del repositorio de evaluaciones de desempeño
@LazySingleton(as: EvaluacionDesempenoRepository)
class EvaluacionDesempenoRepositoryImpl implements EvaluacionDesempenoRepository {
  EvaluacionDesempenoRepositoryImpl() : _dataSource = EvaluacionesDesempenoDataSourceFactory.createSupabase();

  final EvaluacionesDesempenoDataSource _dataSource;

  @override
  Future<List<EvaluacionDesempenoEntity>> getAll() async {
    debugPrint('📦 EvaluacionDesempenoRepository: solicitando todos los registros...');
    return _dataSource.getAll();
  }

  @override
  Future<EvaluacionDesempenoEntity?> getById(String id) => _dataSource.getById(id);

  @override
  Future<List<EvaluacionDesempenoEntity>> getByPersonal(String personalId) => _dataSource.getByPersonal(personalId);

  @override
  Future<EvaluacionDesempenoEntity> create(EvaluacionDesempenoEntity entity) {
    debugPrint('📦 EvaluacionDesempenoRepository: creando ${entity.id}');
    return _dataSource.create(entity);
  }

  @override
  Future<EvaluacionDesempenoEntity> update(EvaluacionDesempenoEntity entity) {
    debugPrint('📦 EvaluacionDesempenoRepository: actualizando ${entity.id}');
    return _dataSource.update(entity);
  }

  @override
  Future<void> delete(String id) {
    debugPrint('📦 EvaluacionDesempenoRepository: eliminando $id');
    return _dataSource.delete(id);
  }
}
