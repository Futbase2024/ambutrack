import 'package:ambutrack_core/ambutrack_core.dart';
import 'package:ambutrack_web/features/tablas/motivos_cancelacion/domain/repositories/motivo_cancelacion_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

/// Implementación del repositorio de motivos de cancelación
@LazySingleton(as: MotivoCancelacionRepository)
class MotivoCancelacionRepositoryImpl implements MotivoCancelacionRepository {
  MotivoCancelacionRepositoryImpl()
      : _dataSource = MotivoCancelacionDataSourceFactory.createSupabase();

  final MotivoCancelacionDataSource _dataSource;

  @override
  Future<List<MotivoCancelacionEntity>> getAll() async {
    try {
      debugPrint('🔄 MotivoCancelacionRepository: Obteniendo todos los motivos...');
      final List<MotivoCancelacionEntity> entities = await _dataSource.getAll();
      debugPrint('✅ MotivoCancelacionRepository: ${entities.length} motivos obtenidos');
      return entities;
    } catch (e) {
      debugPrint('❌ MotivoCancelacionRepository: Error: $e');
      rethrow;
    }
  }

  @override
  Future<MotivoCancelacionEntity?> getById(String id) async {
    try {
      debugPrint('🔄 MotivoCancelacionRepository: Obteniendo motivo por ID...');
      final MotivoCancelacionEntity? entity = await _dataSource.getById(id);
      if (entity == null) {
        debugPrint('⚠️ MotivoCancelacionRepository: Motivo no encontrado');
        return null;
      }
      debugPrint('✅ MotivoCancelacionRepository: Motivo obtenido');
      return entity;
    } catch (e) {
      debugPrint('❌ MotivoCancelacionRepository: Error: $e');
      rethrow;
    }
  }

  @override
  Future<void> create(MotivoCancelacionEntity motivo) async {
    try {
      debugPrint('🔄 MotivoCancelacionRepository: Creando motivo...');
      await _dataSource.create(motivo);
      debugPrint('✅ MotivoCancelacionRepository: Motivo creado exitosamente');
    } catch (e) {
      debugPrint('❌ MotivoCancelacionRepository: Error: $e');
      rethrow;
    }
  }

  @override
  Future<void> update(MotivoCancelacionEntity motivo) async {
    try {
      debugPrint('🔄 MotivoCancelacionRepository: Actualizando motivo...');
      await _dataSource.update(motivo);
      debugPrint('✅ MotivoCancelacionRepository: Motivo actualizado exitosamente');
    } catch (e) {
      debugPrint('❌ MotivoCancelacionRepository: Error: $e');
      rethrow;
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      debugPrint('🔄 MotivoCancelacionRepository: Eliminando motivo...');
      await _dataSource.delete(id);
      debugPrint('✅ MotivoCancelacionRepository: Motivo eliminado exitosamente');
    } catch (e) {
      debugPrint('❌ MotivoCancelacionRepository: Error: $e');
      rethrow;
    }
  }
}
