import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/features/servicios/operativa/domain/repositories/generacion_traslados_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

/// Implementación pass-through del repositorio de generación de traslados
@LazySingleton(as: GeneracionTrasladosRepository)
class GeneracionTrasladosRepositoryImpl implements GeneracionTrasladosRepository {
  GeneracionTrasladosRepositoryImpl()
      : _dataSource = GeneracionTrasladosDataSourceFactory.createSupabase();

  final GeneracionTrasladosDataSource _dataSource;

  @override
  Future<ResultadoGeneracionTrasladosEntity> generarPeriodo({
    required DateTime desde,
    required DateTime hasta,
  }) {
    debugPrint('📦 GeneracionTrasladosRepository: Solicitando generación...');
    return _dataSource.generarPeriodo(desde: desde, hasta: hasta);
  }
}
