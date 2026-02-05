import 'package:ambutrack_core/ambutrack_core.dart';
import 'package:ambutrack_web/features/tablas/provincias/domain/repositories/provincia_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

/// Implementación del repositorio de provincias
@LazySingleton(as: ProvinciaRepository)
class ProvinciaRepositoryImpl implements ProvinciaRepository {
  ProvinciaRepositoryImpl() : _dataSource = ProvinciaDataSourceFactory.createSupabase();

  final ProvinciaDataSource _dataSource;

  @override
  Future<List<ProvinciaEntity>> getAll() async {
    try {
      debugPrint('📡 ProvinciaRepository: Obteniendo todas las provincias...');
      final List<ProvinciaEntity> provincias = await _dataSource.getAll();
      debugPrint('✅ ProvinciaRepository: ${provincias.length} provincias obtenidas');
      return provincias;
    } catch (e) {
      debugPrint('❌ ProvinciaRepository.getAll: Error: $e');
      rethrow;
    }
  }

  @override
  Future<ProvinciaEntity> getById(String id) async {
    try {
      debugPrint('📡 ProvinciaRepository: Obteniendo provincia: $id');
      final ProvinciaEntity? provincia = await _dataSource.getById(id);
      if (provincia == null) {
        throw Exception('Provincia no encontrada');
      }
      debugPrint('✅ ProvinciaRepository: Provincia obtenida');
      return provincia;
    } catch (e) {
      debugPrint('❌ ProvinciaRepository.getById: Error: $e');
      rethrow;
    }
  }

  @override
  Future<ProvinciaEntity> create(ProvinciaEntity provincia) async {
    try {
      debugPrint('📡 ProvinciaRepository: Creando provincia: ${provincia.nombre}');
      final ProvinciaEntity created = await _dataSource.create(provincia);
      debugPrint('✅ ProvinciaRepository: Provincia creada');
      return created;
    } catch (e) {
      debugPrint('❌ ProvinciaRepository.create: Error: $e');
      rethrow;
    }
  }

  @override
  Future<ProvinciaEntity> update(ProvinciaEntity provincia) async {
    try {
      debugPrint('📡 ProvinciaRepository: Actualizando provincia: ${provincia.id}');
      final ProvinciaEntity updated = await _dataSource.update(provincia);
      debugPrint('✅ ProvinciaRepository: Provincia actualizada');
      return updated;
    } catch (e) {
      debugPrint('❌ ProvinciaRepository.update: Error: $e');
      rethrow;
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      debugPrint('📡 ProvinciaRepository: Eliminando provincia: $id');
      await _dataSource.delete(id);
      debugPrint('✅ ProvinciaRepository: Provincia eliminada');
    } catch (e) {
      debugPrint('❌ ProvinciaRepository.delete: Error: $e');
      rethrow;
    }
  }
}
