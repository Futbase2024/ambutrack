import 'package:ambutrack_core/ambutrack_core.dart';
import 'package:dartz/dartz.dart';

/// Repository abstracto para mantenimientos
abstract class MantenimientoRepository {
  /// Obtiene todos los mantenimientos
  Future<Either<Exception, List<MantenimientoEntity>>> getAll();

  /// Obtiene mantenimientos por vehículo
  Future<Either<Exception, List<MantenimientoEntity>>> getByVehiculo(
    String vehiculoId,
  );

  /// Obtiene un mantenimiento por ID
  Future<Either<Exception, MantenimientoEntity>> getById(String id);

  /// Crea un nuevo mantenimiento
  Future<Either<Exception, MantenimientoEntity>> create(
    MantenimientoEntity mantenimiento,
  );

  /// Actualiza un mantenimiento existente
  Future<Either<Exception, MantenimientoEntity>> update(
    MantenimientoEntity mantenimiento,
  );

  /// Elimina un mantenimiento
  Future<Either<Exception, void>> delete(String id);

  /// Obtiene mantenimientos programados próximos
  Future<Either<Exception, List<MantenimientoEntity>>> getProximos(
    int dias,
  );

  /// Obtiene mantenimientos vencidos
  Future<Either<Exception, List<MantenimientoEntity>>> getVencidos();
}
