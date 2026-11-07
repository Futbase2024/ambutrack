import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';

/// Contrato del repositorio de Órdenes de Reparación (incluye sus repuestos)
abstract class OrdenReparacionRepository {
  Future<List<OrdenReparacionEntity>> getAll();
  Future<OrdenReparacionEntity?> getById(String id);
  Future<List<OrdenReparacionEntity>> getByVehiculo(String vehiculoId);
  Future<OrdenReparacionEntity> create(OrdenReparacionEntity entity);
  Future<OrdenReparacionEntity> update(OrdenReparacionEntity entity);
  Future<void> delete(String id);
  Future<OrdenReparacionEntity> cambiarEstado(String id, EstadoOrdenReparacion estado);

  Future<List<RepuestoOrdenEntity>> getRepuestos(String ordenId);
  Future<List<RepuestoOrdenEntity>> getAllRepuestos();
  Future<RepuestoOrdenEntity> createRepuesto(RepuestoOrdenEntity entity);
  Future<RepuestoOrdenEntity> updateRepuesto(RepuestoOrdenEntity entity);
  Future<void> deleteRepuesto(String id);
}
