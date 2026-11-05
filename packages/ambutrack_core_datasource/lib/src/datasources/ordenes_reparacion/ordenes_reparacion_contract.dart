import 'entities/orden_reparacion_entity.dart';
import 'entities/orden_reparacion_enums.dart';
import 'entities/repuesto_orden_entity.dart';

/// Contrato del datasource de Órdenes de Reparación (y sus repuestos)
abstract class OrdenesReparacionDataSource {
  // Órdenes
  Future<List<OrdenReparacionEntity>> getAll();
  Future<OrdenReparacionEntity?> getById(String id);
  Future<List<OrdenReparacionEntity>> getByVehiculo(String vehiculoId);
  Future<List<OrdenReparacionEntity>> getByEstado(EstadoOrdenReparacion estado);
  Future<OrdenReparacionEntity> create(OrdenReparacionEntity entity);
  Future<OrdenReparacionEntity> update(OrdenReparacionEntity entity);
  Future<void> delete(String id);

  /// Cambia el estado y registra la fecha asociada al nuevo estado
  Future<OrdenReparacionEntity> cambiarEstado(String id, EstadoOrdenReparacion estado);

  // Repuestos (el coste de repuestos de la orden lo recalcula un trigger)
  Future<List<RepuestoOrdenEntity>> getRepuestos(String ordenId);
  Future<RepuestoOrdenEntity> createRepuesto(RepuestoOrdenEntity entity);
  Future<RepuestoOrdenEntity> updateRepuesto(RepuestoOrdenEntity entity);
  Future<void> deleteRepuesto(String id);
}
