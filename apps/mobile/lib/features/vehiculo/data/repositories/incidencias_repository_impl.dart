import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../../domain/repositories/incidencias_repository.dart';

/// Implementación del repositorio de incidencias del vehículo.
@LazySingleton(as: IncidenciasRepository)
class IncidenciasRepositoryImpl implements IncidenciasRepository {
  IncidenciasRepositoryImpl()
      : _dataSource = IncidenciaVehiculoDataSourceFactory.createSupabase();

  final IncidenciaVehiculoDataSource _dataSource;

  @override
  Future<List<IncidenciaVehiculoEntity>> getAll() async {
    debugPrint('📦 IncidenciasRepository: Solicitando todas las incidencias...');
    return await _dataSource.getAll();
  }

  @override
  Future<IncidenciaVehiculoEntity> getById(String id) async {
    debugPrint('📦 IncidenciasRepository: Solicitando incidencia ID: $id');
    return await _dataSource.getById(id);
  }

  @override
  Future<List<IncidenciaVehiculoEntity>> getByVehiculoId(
      String vehiculoId) async {
    debugPrint(
        '📦 IncidenciasRepository: Solicitando incidencias del vehículo: $vehiculoId');
    return await _dataSource.getByVehiculoId(vehiculoId);
  }

  @override
  Future<List<IncidenciaVehiculoEntity>> getByEstado(
      EstadoIncidencia estado) async {
    debugPrint(
        '📦 IncidenciasRepository: Solicitando incidencias con estado: ${estado.name}');
    return await _dataSource.getByEstado(estado);
  }

  @override
  Future<IncidenciaVehiculoEntity> create(
      IncidenciaVehiculoEntity incidencia) async {
    debugPrint('📦 IncidenciasRepository: Creando nueva incidencia...');
    return await _dataSource.create(incidencia);
  }

  @override
  Future<IncidenciaVehiculoEntity> update(
      IncidenciaVehiculoEntity incidencia) async {
    debugPrint(
        '📦 IncidenciasRepository: Actualizando incidencia ID: ${incidencia.id}');
    return await _dataSource.update(incidencia);
  }

  @override
  Future<void> delete(String id) async {
    debugPrint('📦 IncidenciasRepository: Eliminando incidencia ID: $id');
    return await _dataSource.delete(id);
  }

  @override
  Stream<List<IncidenciaVehiculoEntity>> watchByVehiculoId(
      String vehiculoId) {
    debugPrint(
        '📦 IncidenciasRepository: Observando incidencias del vehículo: $vehiculoId');
    return _dataSource.watchByVehiculoId(vehiculoId);
  }
}
