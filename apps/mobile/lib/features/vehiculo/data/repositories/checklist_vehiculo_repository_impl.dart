import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:flutter/foundation.dart';

import '../../domain/repositories/checklist_vehiculo_repository.dart';

/// Implementación del repositorio de checklists de vehículos
class ChecklistVehiculoRepositoryImpl implements ChecklistVehiculoRepository {
  ChecklistVehiculoRepositoryImpl()
      : _dataSource = ChecklistVehiculoDataSourceFactory.createSupabase();

  final ChecklistVehiculoDataSource _dataSource;

  @override
  Future<List<ChecklistVehiculoEntity>> getAll() async {
    debugPrint('📦 Repository: Solicitando todos los checklists...');
    return await _dataSource.getAll();
  }

  @override
  Future<ChecklistVehiculoEntity> getById(String id) async {
    debugPrint('📦 Repository: Obteniendo checklist con ID: $id');
    return await _dataSource.getById(id);
  }

  @override
  Future<List<ChecklistVehiculoEntity>> getByVehiculoId(
    String vehiculoId,
  ) async {
    debugPrint(
      '📦 Repository: Obteniendo checklists del vehículo: $vehiculoId',
    );
    return await _dataSource.getByVehiculoId(vehiculoId);
  }

  @override
  Future<ChecklistVehiculoEntity?> getUltimoChecklist(
    String vehiculoId,
    TipoChecklist tipo,
  ) async {
    debugPrint(
      '📦 Repository: Obteniendo último checklist tipo ${tipo.nombre} del vehículo: $vehiculoId',
    );
    return await _dataSource.getUltimoChecklist(vehiculoId, tipo);
  }

  @override
  Future<List<ItemChecklistEntity>> getPlantillaItems(
    TipoChecklist tipo,
  ) async {
    debugPrint(
      '📦 Repository: Obteniendo plantilla de items para tipo: ${tipo.nombre}',
    );
    return await _dataSource.getPlantillaItems(tipo);
  }

  @override
  Future<ChecklistVehiculoEntity> create(ChecklistVehiculoEntity entity) async {
    debugPrint('📦 Repository: Creando nuevo checklist...');
    return await _dataSource.create(entity);
  }

  @override
  Future<ChecklistVehiculoEntity> update(ChecklistVehiculoEntity entity) async {
    debugPrint('📦 Repository: Actualizando checklist con ID: ${entity.id}');
    return await _dataSource.update(entity);
  }

  @override
  Future<void> delete(String id) async {
    debugPrint('📦 Repository: Eliminando checklist con ID: $id');
    return await _dataSource.delete(id);
  }

  @override
  Stream<List<ChecklistVehiculoEntity>> watchByVehiculoId(
    String vehiculoId,
  ) {
    debugPrint(
      '📦 Repository: Observando checklists del vehículo: $vehiculoId',
    );
    return _dataSource.watchByVehiculoId(vehiculoId);
  }
}
