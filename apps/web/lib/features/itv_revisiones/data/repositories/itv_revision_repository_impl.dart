import 'package:ambutrack_core/ambutrack_core.dart';
import 'package:ambutrack_web/features/itv_revisiones/domain/repositories/itv_revision_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

/// Implementación del repositorio de ITV y Revisiones
@LazySingleton(as: ItvRevisionRepository)
class ItvRevisionRepositoryImpl implements ItvRevisionRepository {
  ItvRevisionRepositoryImpl() : _dataSource = ItvRevisionDataSourceFactory.createSupabase();

  final ItvRevisionDataSource _dataSource;

  @override
  Future<List<ItvRevisionEntity>> getAll() async {
    try {
      debugPrint('🔄 ItvRevisionRepository: Obteniendo todas las ITV/Revisiones...');
      final List<ItvRevisionEntity> entities = await _dataSource.getAll();
      debugPrint('✅ ItvRevisionRepository: ${entities.length} ITV/Revisiones obtenidas');
      return entities;
    } catch (e, stackTrace) {
      debugPrint('❌ ItvRevisionRepository: Error al obtener ITV/Revisiones: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<List<ItvRevisionEntity>> getByVehiculo(String vehiculoId) async {
    try {
      debugPrint('🔄 ItvRevisionRepository: Obteniendo ITV/Revisiones del vehículo...');
      final List<ItvRevisionEntity> entities = await _dataSource.getByVehiculo(vehiculoId);
      debugPrint('✅ ItvRevisionRepository: ${entities.length} ITV/Revisiones obtenidas');
      return entities;
    } catch (e, stackTrace) {
      debugPrint('❌ ItvRevisionRepository: Error al obtener ITV/Revisiones por vehículo: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<ItvRevisionEntity?> getById(String id) async {
    try {
      debugPrint('🔄 ItvRevisionRepository: Obteniendo ITV/Revisión por ID...');
      final ItvRevisionEntity? entity = await _dataSource.getById(id);
      if (entity == null) {
        debugPrint('⚠️ ItvRevisionRepository: ITV/Revisión no encontrada');
        return null;
      }
      debugPrint('✅ ItvRevisionRepository: ITV/Revisión obtenida');
      return entity;
    } catch (e, stackTrace) {
      debugPrint('❌ ItvRevisionRepository: Error al obtener ITV/Revisión por ID: $e');
      debugPrint('Stack trace: $stackTrace');
      return null;
    }
  }

  @override
  Future<void> create(ItvRevisionEntity itvRevision) async {
    try {
      debugPrint('🔄 ItvRevisionRepository: Creando ITV/Revisión...');
      await _dataSource.create(itvRevision);
      debugPrint('✅ ItvRevisionRepository: ITV/Revisión creada');
    } catch (e, stackTrace) {
      debugPrint('❌ ItvRevisionRepository: Error al crear ITV/Revisión: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<void> update(ItvRevisionEntity itvRevision) async {
    try {
      debugPrint('🔄 ItvRevisionRepository: Actualizando ITV/Revisión...');
      await _dataSource.update(itvRevision);
      debugPrint('✅ ItvRevisionRepository: ITV/Revisión actualizada');
    } catch (e, stackTrace) {
      debugPrint('❌ ItvRevisionRepository: Error al actualizar ITV/Revisión: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      debugPrint('🔄 ItvRevisionRepository: Eliminando ITV/Revisión...');
      await _dataSource.delete(id);
      debugPrint('✅ ItvRevisionRepository: ITV/Revisión eliminada');
    } catch (e, stackTrace) {
      debugPrint('❌ ItvRevisionRepository: Error al eliminar ITV/Revisión: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<List<ItvRevisionEntity>> getProximasVencer(int dias) async {
    try {
      debugPrint('🔄 ItvRevisionRepository: Obteniendo ITV/Revisiones próximas a vencer...');
      final List<ItvRevisionEntity> entities = await _dataSource.getProximasVencer(dias);
      debugPrint('✅ ItvRevisionRepository: ${entities.length} ITV/Revisiones próximas a vencer');
      return entities;
    } catch (e, stackTrace) {
      debugPrint('❌ ItvRevisionRepository: Error al obtener ITV/Revisiones próximas a vencer: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }
}
