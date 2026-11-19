import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:dartz/dartz.dart';

/// Contrato del repositorio de Talleres
abstract class TallerRepository {
  Future<Either<Exception, List<TallerEntity>>> getAll();
  Future<Either<Exception, TallerEntity>> getById(String id);
  Future<Either<Exception, TallerEntity>> create(TallerEntity entity);
  Future<Either<Exception, TallerEntity>> update(TallerEntity entity);
  Future<Either<Exception, void>> delete(String id);
  Future<Either<Exception, List<TallerEntity>>> getActivos();
}
