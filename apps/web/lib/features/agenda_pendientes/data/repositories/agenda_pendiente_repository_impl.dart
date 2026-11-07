import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../../domain/repositories/agenda_pendiente_repository.dart';

/// Implementación del repositorio de agenda de pendientes
///
/// Delega todas las operaciones al datasource via Factory pattern.
/// Pass-through directo sin conversiones Entity↔Entity.
@LazySingleton(as: AgendaPendienteRepository)
class AgendaPendienteRepositoryImpl implements AgendaPendienteRepository {
  AgendaPendienteRepositoryImpl()
      : _dataSource = AgendaPendienteDataSourceFactory.createSupabase();

  final AgendaPendienteDataSource _dataSource;

  @override
  Future<List<AgendaPendienteEntity>> getAll() async {
    debugPrint('📋 AgendaPendienteRepository: getAll()');
    return _dataSource.getAll();
  }

  @override
  Future<AgendaPendienteEntity?> getById(String id) async {
    debugPrint('📋 AgendaPendienteRepository: getById($id)');
    return _dataSource.getById(id);
  }

  @override
  Future<List<AgendaPendienteEntity>> getByEmpresa(String empresaId) async {
    debugPrint('📋 AgendaPendienteRepository: getByEmpresa($empresaId)');
    return _dataSource.getByEmpresa(empresaId);
  }

  @override
  Future<List<AgendaPendienteEntity>> getPendientesHoy(
    String empresaId,
  ) async {
    debugPrint(
      '📋 AgendaPendienteRepository: getPendientesHoy($empresaId)',
    );
    return _dataSource.getPendientesHoy(empresaId);
  }

  @override
  Future<AgendaPendienteEntity> create(
    AgendaPendienteEntity pendiente,
  ) async {
    debugPrint(
      '📋 AgendaPendienteRepository: create(${pendiente.nombreApellidos})',
    );
    return _dataSource.create(pendiente);
  }

  @override
  Future<AgendaPendienteEntity> update(
    AgendaPendienteEntity pendiente,
  ) async {
    debugPrint(
      '📋 AgendaPendienteRepository: update(${pendiente.id})',
    );
    return _dataSource.update(pendiente);
  }

  @override
  Future<void> delete(String id) async {
    debugPrint('📋 AgendaPendienteRepository: delete($id)');
    return _dataSource.delete(id);
  }

  @override
  Future<void> marcarCompletado(String id, {required bool completado}) async {
    debugPrint(
      '📋 AgendaPendienteRepository: marcarCompletado($id, $completado)',
    );
    return _dataSource.marcarCompletado(id, completado);
  }

  @override
  Stream<List<AgendaPendienteEntity>> watchAll() {
    debugPrint('📋 AgendaPendienteRepository: watchAll()');
    return _dataSource.watchAll();
  }
}
