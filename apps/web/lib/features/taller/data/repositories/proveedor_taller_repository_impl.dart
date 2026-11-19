import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/features/taller/domain/repositories/proveedor_taller_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: ProveedorTallerRepository)
class ProveedorTallerRepositoryImpl implements ProveedorTallerRepository {
  ProveedorTallerRepositoryImpl()
      : _dataSource = ProveedoresTallerDataSourceFactory.createSupabase();

  final ProveedoresTallerDataSource _dataSource;

  @override
  Future<Either<Exception, List<ProveedorTallerEntity>>> getAll() async {
    try {
      debugPrint('📦 ProveedorTallerRepository: Solicitando proveedores...');
      final List<ProveedorTallerEntity> entities = await _dataSource.getAll();
      debugPrint(
        '✅ ProveedorTallerRepository: ${entities.length} proveedores',
      );
      return Right<Exception, List<ProveedorTallerEntity>>(entities);
    } catch (e) {
      debugPrint('❌ ProveedorTallerRepository: Error: $e');
      return Left<Exception, List<ProveedorTallerEntity>>(
        Exception('Error al obtener proveedores: $e'),
      );
    }
  }

  @override
  Future<Either<Exception, ProveedorTallerEntity>> getById(String id) async {
    try {
      debugPrint('📦 ProveedorTallerRepository: Obteniendo proveedor $id...');
      final ProveedorTallerEntity? entity = await _dataSource.getById(id);
      if (entity == null) {
        return Left<Exception, ProveedorTallerEntity>(
          Exception('Proveedor no encontrado'),
        );
      }
      return Right<Exception, ProveedorTallerEntity>(entity);
    } catch (e) {
      debugPrint('❌ ProveedorTallerRepository: Error: $e');
      return Left<Exception, ProveedorTallerEntity>(
        Exception('Error al obtener proveedor: $e'),
      );
    }
  }

  @override
  Future<Either<Exception, ProveedorTallerEntity>> create(
    ProveedorTallerEntity entity,
  ) async {
    try {
      debugPrint(
        '📦 ProveedorTallerRepository: Creando "${entity.nombre}"...',
      );
      final ProveedorTallerEntity created = await _dataSource.create(entity);
      debugPrint('✅ ProveedorTallerRepository: Creado ID ${created.id}');
      return Right<Exception, ProveedorTallerEntity>(created);
    } catch (e) {
      debugPrint('❌ ProveedorTallerRepository: Error: $e');
      return Left<Exception, ProveedorTallerEntity>(
        Exception('Error al crear proveedor: $e'),
      );
    }
  }

  @override
  Future<Either<Exception, ProveedorTallerEntity>> update(
    ProveedorTallerEntity entity,
  ) async {
    try {
      debugPrint(
        '📦 ProveedorTallerRepository: Actualizando ${entity.id}...',
      );
      final ProveedorTallerEntity updated = await _dataSource.update(entity);
      debugPrint('✅ ProveedorTallerRepository: Actualizado');
      return Right<Exception, ProveedorTallerEntity>(updated);
    } catch (e) {
      debugPrint('❌ ProveedorTallerRepository: Error: $e');
      return Left<Exception, ProveedorTallerEntity>(
        Exception('Error al actualizar proveedor: $e'),
      );
    }
  }

  @override
  Future<Either<Exception, void>> delete(String id) async {
    try {
      debugPrint('📦 ProveedorTallerRepository: Eliminando $id...');
      await _dataSource.delete(id);
      debugPrint('✅ ProveedorTallerRepository: Eliminado');
      return const Right<Exception, void>(null);
    } catch (e) {
      debugPrint('❌ ProveedorTallerRepository: Error: $e');
      return Left<Exception, void>(
        Exception('Error al eliminar proveedor: $e'),
      );
    }
  }

  @override
  Future<Either<Exception, List<ProveedorTallerEntity>>> getActivos() async {
    try {
      debugPrint('📦 ProveedorTallerRepository: Obteniendo activos...');
      final List<ProveedorTallerEntity> entities = await _dataSource
          .getActivos();
      return Right<Exception, List<ProveedorTallerEntity>>(entities);
    } catch (e) {
      debugPrint('❌ ProveedorTallerRepository: Error: $e');
      return Left<Exception, List<ProveedorTallerEntity>>(
        Exception('Error al obtener proveedores activos: $e'),
      );
    }
  }
}
