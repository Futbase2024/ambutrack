import 'entities/almacen_entity.dart';

/// Contrato para el DataSource de Almacenes
///
/// Define las operaciones CRUD básicas para gestionar almacenes
/// (Base Central y Vehículos).
abstract class AlmacenDataSource {
  /// Obtiene todos los almacenes activos
  Future<List<AlmacenEntity>> getAll();

  /// Obtiene un almacén por ID
  Future<AlmacenEntity?> getById(String id);

  /// Obtiene el almacén de Base Central
  Future<AlmacenEntity?> getBaseCentral();

  /// Obtiene todos los almacenes de tipo Vehículo
  Future<List<AlmacenEntity>> getAlmacenesVehiculos();

  /// Obtiene el almacén asociado a un vehículo específico
  Future<AlmacenEntity?> getByVehiculoId(String idVehiculo);

  /// Crea un nuevo almacén
  Future<AlmacenEntity> create(AlmacenEntity almacen);

  /// Actualiza un almacén existente
  Future<AlmacenEntity> update(AlmacenEntity almacen);

  /// Elimina un almacén (soft delete: activo = false)
  Future<void> delete(String id);

  /// Stream para observar cambios en todos los almacenes
  Stream<List<AlmacenEntity>> watchAll();

  /// Stream para observar cambios en un almacén específico
  Stream<AlmacenEntity?> watchById(String id);
}
