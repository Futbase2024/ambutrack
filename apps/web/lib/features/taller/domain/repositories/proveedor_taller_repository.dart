import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:dartz/dartz.dart';

/// Contrato del repositorio de Proveedores de Taller
abstract class ProveedorTallerRepository {
  Future<Either<Exception, List<ProveedorTallerEntity>>> getAll();
  Future<Either<Exception, ProveedorTallerEntity>> getById(String id);
  Future<Either<Exception, ProveedorTallerEntity>> create(
    ProveedorTallerEntity entity,
  );
  Future<Either<Exception, ProveedorTallerEntity>> update(
    ProveedorTallerEntity entity,
  );
  Future<Either<Exception, void>> delete(String id);
  Future<Either<Exception, List<ProveedorTallerEntity>>> getActivos();
}
