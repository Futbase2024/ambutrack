import 'package:ambutrack_core/ambutrack_core.dart';
import 'package:ambutrack_web/features/mantenimiento/domain/repositories/mantenimiento_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

/// Implementación del repositorio de mantenimientos (pass-through a core datasource)
@LazySingleton(as: MantenimientoRepository)
class MantenimientoRepositoryImpl implements MantenimientoRepository {
  MantenimientoRepositoryImpl()
      : _dataSource = MantenimientoDataSourceFactory.createSupabase();

  final MantenimientoDataSource _dataSource;

  @override
  Future<Either<Exception, List<MantenimientoEntity>>> getAll() async {
    try {
      debugPrint('📦 MantenimientoRepository: Obteniendo mantenimientos');
      final List<MantenimientoEntity> entities = await _dataSource.getAll();
      debugPrint('✅ MantenimientoRepository: ${entities.length} mantenimientos obtenidos');
      return Right<Exception, List<MantenimientoEntity>>(entities);
    } catch (e) {
      debugPrint('❌ MantenimientoRepository Error: $e');
      return Left<Exception, List<MantenimientoEntity>>(Exception('Error al obtener mantenimientos: $e'));
    }
  }

  @override
  Future<Either<Exception, List<MantenimientoEntity>>> getByVehiculo(
    String vehiculoId,
  ) async {
    try {
      debugPrint('📦 MantenimientoRepository: Obteniendo mantenimientos del vehículo $vehiculoId');
      final List<MantenimientoEntity> entities =
          await _dataSource.getByVehiculo(vehiculoId);
      debugPrint('✅ MantenimientoRepository: ${entities.length} mantenimientos del vehículo obtenidos');
      return Right<Exception, List<MantenimientoEntity>>(entities);
    } catch (e) {
      debugPrint('❌ MantenimientoRepository Error: $e');
      return Left<Exception, List<MantenimientoEntity>>(Exception('Error al obtener mantenimientos del vehículo: $e'));
    }
  }

  @override
  Future<Either<Exception, MantenimientoEntity>> getById(String id) async {
    try {
      debugPrint('📦 MantenimientoRepository: Obteniendo mantenimiento $id');
      final MantenimientoEntity? entity = await _dataSource.getById(id);
      if (entity == null) {
        throw Exception('Mantenimiento no encontrado');
      }
      debugPrint('✅ MantenimientoRepository: Mantenimiento obtenido');
      return Right<Exception, MantenimientoEntity>(entity);
    } catch (e) {
      debugPrint('❌ MantenimientoRepository Error: $e');
      return Left<Exception, MantenimientoEntity>(Exception('Error al obtener mantenimiento: $e'));
    }
  }

  @override
  Future<Either<Exception, MantenimientoEntity>> create(
    MantenimientoEntity mantenimiento,
  ) async {
    try {
      debugPrint('📦 MantenimientoRepository: Creando mantenimiento');
      final MantenimientoEntity entity = await _dataSource.create(mantenimiento);
      debugPrint('✅ MantenimientoRepository: Mantenimiento creado con ID ${entity.id}');
      return Right<Exception, MantenimientoEntity>(entity);
    } catch (e) {
      debugPrint('❌ MantenimientoRepository Error: $e');
      return Left<Exception, MantenimientoEntity>(Exception('Error al crear mantenimiento: $e'));
    }
  }

  @override
  Future<Either<Exception, MantenimientoEntity>> update(
    MantenimientoEntity mantenimiento,
  ) async {
    try {
      debugPrint('📦 MantenimientoRepository: Actualizando mantenimiento ${mantenimiento.id}');
      final MantenimientoEntity entity = await _dataSource.update(mantenimiento);
      debugPrint('✅ MantenimientoRepository: Mantenimiento actualizado');
      return Right<Exception, MantenimientoEntity>(entity);
    } catch (e) {
      debugPrint('❌ MantenimientoRepository Error: $e');
      return Left<Exception, MantenimientoEntity>(Exception('Error al actualizar mantenimiento: $e'));
    }
  }

  @override
  Future<Either<Exception, void>> delete(String id) async {
    try {
      debugPrint('📦 MantenimientoRepository: Eliminando mantenimiento $id');
      await _dataSource.delete(id);
      debugPrint('✅ MantenimientoRepository: Mantenimiento eliminado');
      return const Right<Exception, void>(null);
    } catch (e) {
      debugPrint('❌ MantenimientoRepository Error: $e');
      return Left<Exception, void>(Exception('Error al eliminar mantenimiento: $e'));
    }
  }

  @override
  Future<Either<Exception, List<MantenimientoEntity>>> getProximos(int dias) async {
    try {
      debugPrint('📦 MantenimientoRepository: Obteniendo mantenimientos próximos ($dias días)');
      final List<MantenimientoEntity> entities = await _dataSource.getProximos(dias);
      debugPrint('✅ MantenimientoRepository: ${entities.length} mantenimientos próximos obtenidos');
      return Right<Exception, List<MantenimientoEntity>>(entities);
    } catch (e) {
      debugPrint('❌ MantenimientoRepository Error: $e');
      return Left<Exception, List<MantenimientoEntity>>(Exception('Error al obtener mantenimientos próximos: $e'));
    }
  }

  @override
  Future<Either<Exception, List<MantenimientoEntity>>> getVencidos() async {
    try {
      debugPrint('📦 MantenimientoRepository: Obteniendo mantenimientos vencidos');
      final List<MantenimientoEntity> entities = await _dataSource.getVencidos();
      debugPrint('✅ MantenimientoRepository: ${entities.length} mantenimientos vencidos obtenidos');
      return Right<Exception, List<MantenimientoEntity>>(entities);
    } catch (e) {
      debugPrint('❌ MantenimientoRepository Error: $e');
      return Left<Exception, List<MantenimientoEntity>>(Exception('Error al obtener mantenimientos vencidos: $e'));
    }
  }
}
