import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/features/taller/domain/repositories/orden_reparacion_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

/// Repositorio pass-through de Órdenes de Reparación
@LazySingleton(as: OrdenReparacionRepository)
class OrdenReparacionRepositoryImpl implements OrdenReparacionRepository {
  OrdenReparacionRepositoryImpl() : _dataSource = OrdenesReparacionDataSourceFactory.createSupabase();

  final OrdenesReparacionDataSource _dataSource;

  Future<T> _run<T>(String operacion, Future<T> Function() action) async {
    try {
      debugPrint('📦 OrdenReparacionRepository: $operacion...');
      return await action();
    } catch (e) {
      debugPrint('❌ OrdenReparacionRepository: Error en $operacion: $e');
      rethrow;
    }
  }

  @override
  Future<List<OrdenReparacionEntity>> getAll() => _run('getAll', _dataSource.getAll);

  @override
  Future<OrdenReparacionEntity?> getById(String id) => _run('getById $id', () => _dataSource.getById(id));

  @override
  Future<List<OrdenReparacionEntity>> getByVehiculo(String vehiculoId) =>
      _run('getByVehiculo $vehiculoId', () => _dataSource.getByVehiculo(vehiculoId));

  @override
  Future<OrdenReparacionEntity> create(OrdenReparacionEntity entity) =>
      _run('create', () => _dataSource.create(entity));

  @override
  Future<OrdenReparacionEntity> update(OrdenReparacionEntity entity) =>
      _run('update ${entity.id}', () => _dataSource.update(entity));

  @override
  Future<void> delete(String id) => _run('delete $id', () => _dataSource.delete(id));

  @override
  Future<OrdenReparacionEntity> cambiarEstado(String id, EstadoOrdenReparacion estado) =>
      _run('cambiarEstado $id → ${estado.value}', () => _dataSource.cambiarEstado(id, estado));

  @override
  Future<List<RepuestoOrdenEntity>> getRepuestos(String ordenId) =>
      _run('getRepuestos $ordenId', () => _dataSource.getRepuestos(ordenId));

  @override
  Future<RepuestoOrdenEntity> createRepuesto(RepuestoOrdenEntity entity) =>
      _run('createRepuesto', () => _dataSource.createRepuesto(entity));

  @override
  Future<RepuestoOrdenEntity> updateRepuesto(RepuestoOrdenEntity entity) =>
      _run('updateRepuesto ${entity.id}', () => _dataSource.updateRepuesto(entity));

  @override
  Future<void> deleteRepuesto(String id) => _run('deleteRepuesto $id', () => _dataSource.deleteRepuesto(id));
}
