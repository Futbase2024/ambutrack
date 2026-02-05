import 'package:ambutrack_core/ambutrack_core.dart';

/// Repositorio abstracto para ITV y Revisiones
abstract class ItvRevisionRepository {
  /// Obtiene todas las ITV/Revisiones
  Future<List<ItvRevisionEntity>> getAll();

  /// Obtiene ITV/Revisiones por vehículo
  Future<List<ItvRevisionEntity>> getByVehiculo(String vehiculoId);

  /// Obtiene una ITV/Revisión por ID
  Future<ItvRevisionEntity?> getById(String id);

  /// Crea una nueva ITV/Revisión
  Future<void> create(ItvRevisionEntity itvRevision);

  /// Actualiza una ITV/Revisión existente
  Future<void> update(ItvRevisionEntity itvRevision);

  /// Elimina una ITV/Revisión
  Future<void> delete(String id);

  /// Obtiene ITV/Revisiones próximas a vencer (en días)
  Future<List<ItvRevisionEntity>> getProximasVencer(int dias);
}
