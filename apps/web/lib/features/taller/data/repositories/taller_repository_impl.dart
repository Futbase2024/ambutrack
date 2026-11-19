import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/features/taller/domain/repositories/taller_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: TallerRepository)
class TallerRepositoryImpl implements TallerRepository {
  TallerRepositoryImpl()
      : _dataSource = TalleresDataSourceFactory.createSupabase();

  final TalleresDataSource _dataSource;

  @override
  Future<Either<Exception, List<TallerEntity>>> getAll() async {
    try {
      debugPrint('📦 TallerRepository: Solicitando todos los talleres...');
      final List<TallerEntity> entities = await _dataSource.getAll();
      debugPrint('✅ TallerRepository: ${entities.length} talleres obtenidos');
      return Right<Exception, List<TallerEntity>>(entities);
    } catch (e) {
      debugPrint('❌ TallerRepository: Error al obtener talleres: $e');
      return Left<Exception, List<TallerEntity>>(
        Exception('Error al obtener talleres: $e'),
      );
    }
  }

  @override
  Future<Either<Exception, TallerEntity>> getById(String id) async {
    try {
      debugPrint('📦 TallerRepository: Obteniendo taller $id...');
      final TallerEntity? entity = await _dataSource.getById(id);
      if (entity == null) {
        return Left<Exception, TallerEntity>(
          Exception('Taller no encontrado'),
        );
      }
      return Right<Exception, TallerEntity>(entity);
    } catch (e) {
      debugPrint('❌ TallerRepository: Error al obtener taller: $e');
      return Left<Exception, TallerEntity>(
        Exception('Error al obtener taller: $e'),
      );
    }
  }

  @override
  Future<Either<Exception, TallerEntity>> create(TallerEntity entity) async {
    try {
      debugPrint('📦 TallerRepository: Creando taller "${entity.nombre}"...');
      final TallerEntity created = await _dataSource.create(entity);
      debugPrint('✅ TallerRepository: Taller creado con ID ${created.id}');
      return Right<Exception, TallerEntity>(created);
    } catch (e) {
      debugPrint('❌ TallerRepository: Error al crear taller: $e');
      return Left<Exception, TallerEntity>(
        Exception('Error al crear taller: $e'),
      );
    }
  }

  @override
  Future<Either<Exception, TallerEntity>> update(TallerEntity entity) async {
    try {
      debugPrint('📦 TallerRepository: Actualizando taller ${entity.id}...');
      final TallerEntity updated = await _dataSource.update(entity);
      debugPrint('✅ TallerRepository: Taller actualizado');
      return Right<Exception, TallerEntity>(updated);
    } catch (e) {
      debugPrint('❌ TallerRepository: Error al actualizar taller: $e');
      return Left<Exception, TallerEntity>(
        Exception('Error al actualizar taller: $e'),
      );
    }
  }

  @override
  Future<Either<Exception, void>> delete(String id) async {
    try {
      debugPrint('📦 TallerRepository: Eliminando taller $id...');
      await _dataSource.delete(id);
      debugPrint('✅ TallerRepository: Taller eliminado');
      return const Right<Exception, void>(null);
    } catch (e) {
      debugPrint('❌ TallerRepository: Error al eliminar taller: $e');
      return Left<Exception, void>(
        Exception('Error al eliminar taller: $e'),
      );
    }
  }

  @override
  Future<Either<Exception, List<TallerEntity>>> getActivos() async {
    try {
      debugPrint('📦 TallerRepository: Obteniendo talleres activos...');
      final List<TallerEntity> entities = await _dataSource.getActivos();
      return Right<Exception, List<TallerEntity>>(entities);
    } catch (e) {
      debugPrint('❌ TallerRepository: Error al obtener talleres activos: $e');
      return Left<Exception, List<TallerEntity>>(
        Exception('Error al obtener talleres activos: $e'),
      );
    }
  }
}
