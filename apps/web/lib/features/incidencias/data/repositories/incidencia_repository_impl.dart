import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/features/incidencias/domain/repositories/incidencia_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

/// Implementación del repositorio de incidencias con Supabase
@LazySingleton(as: IncidenciaRepository)
class IncidenciaRepositoryImpl implements IncidenciaRepository {
  IncidenciaRepositoryImpl()
      : _dataSource = IncidenciaDataSourceFactory.createSupabase();

  final IncidenciaDataSource _dataSource;

  @override
  Future<List<IncidenciaEntity>> getAll() async {
    debugPrint('📋 IncidenciaRepository: Solicitando todas las incidencias');
    return _dataSource.getAll();
  }

  @override
  Future<IncidenciaEntity?> getById(String id) async {
    debugPrint('📋 IncidenciaRepository: Obteniendo incidencia $id');
    return _dataSource.getById(id);
  }

  @override
  Future<IncidenciaEntity> create(IncidenciaEntity incidencia) async {
    debugPrint('📋 IncidenciaRepository: Creando incidencia');
    return _dataSource.create(incidencia);
  }

  @override
  Future<IncidenciaEntity> update(IncidenciaEntity incidencia) async {
    debugPrint('📋 IncidenciaRepository: Actualizando incidencia ${incidencia.id}');
    return _dataSource.update(incidencia);
  }

  @override
  Future<void> delete(String id) async {
    debugPrint('📋 IncidenciaRepository: Eliminando incidencia $id');
    await _dataSource.delete(id);
  }

  @override
  Stream<List<IncidenciaEntity>> watchAll() {
    debugPrint('📋 IncidenciaRepository: Escuchando stream de incidencias');
    return _dataSource.watchAll();
  }
}
