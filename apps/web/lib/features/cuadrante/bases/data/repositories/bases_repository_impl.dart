import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/features/cuadrante/bases/domain/repositories/bases_repository.dart';
import 'package:injectable/injectable.dart';

/// Implementación del repositorio de Bases usando Core Datasource
///
/// Utiliza BasesDataSource del paquete ambutrack_core
/// con implementación Supabase para todas las operaciones
@LazySingleton(as: BasesRepository)
class BasesRepositoryImpl implements BasesRepository {
  BasesRepositoryImpl() {
    // Crear instancia del datasource usando factory del core
    _dataSource = BasesDataSourceFactory.create(
      type: 'supabase',
      config: <String, dynamic>{
        'table': 'bases',
      },
    );
  }

  late final BasesDataSource _dataSource;

  // ==================== CRUD BÁSICO ====================

  @override
  Future<List<BaseCentroEntity>> getAll({int? limit, int? offset}) async {
    try {
      return await _dataSource.getAll(limit: limit, offset: offset);
    } catch (e) {
      throw Exception('Error al obtener bases: $e');
    }
  }

  @override
  Future<BaseCentroEntity?> getById(String id) async {
    try {
      return await _dataSource.getById(id);
    } catch (e) {
      throw Exception('Error al obtener base por ID: $e');
    }
  }

  @override
  Future<BaseCentroEntity> create(BaseCentroEntity base) async {
    try {
      return await _dataSource.create(base);
    } catch (e) {
      throw Exception('Error al crear base: $e');
    }
  }

  @override
  Future<BaseCentroEntity> update(BaseCentroEntity base) async {
    try {
      return await _dataSource.update(base);
    } catch (e) {
      throw Exception('Error al actualizar base: $e');
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      await _dataSource.delete(id);
    } catch (e) {
      throw Exception('Error al eliminar base: $e');
    }
  }

  @override
  Future<bool> exists(String id) async {
    try {
      return await _dataSource.exists(id);
    } catch (e) {
      throw Exception('Error al verificar existencia de base: $e');
    }
  }

  @override
  Future<int> count() async {
    try {
      return await _dataSource.count();
    } catch (e) {
      throw Exception('Error al contar bases: $e');
    }
  }

  // ==================== STREAMING ====================

  @override
  Stream<List<BaseCentroEntity>> watchAll() {
    try {
      return _dataSource.watchAll();
    } catch (e) {
      throw Exception('Error al observar todas las bases: $e');
    }
  }

  @override
  Stream<BaseCentroEntity?> watchById(String id) {
    try {
      return _dataSource.watchById(id);
    } catch (e) {
      throw Exception('Error al observar base por ID: $e');
    }
  }

  // ==================== BATCH OPERATIONS ====================

  @override
  Future<List<BaseCentroEntity>> createBatch(List<BaseCentroEntity> bases) async {
    try {
      return await _dataSource.createBatch(bases);
    } catch (e) {
      throw Exception('Error al crear bases en lote: $e');
    }
  }

  @override
  Future<List<BaseCentroEntity>> updateBatch(List<BaseCentroEntity> bases) async {
    try {
      return await _dataSource.updateBatch(bases);
    } catch (e) {
      throw Exception('Error al actualizar bases en lote: $e');
    }
  }

  @override
  Future<void> deleteBatch(List<String> ids) async {
    try {
      await _dataSource.deleteBatch(ids);
    } catch (e) {
      throw Exception('Error al eliminar bases en lote: $e');
    }
  }

  // ==================== MÉTODOS ESPECÍFICOS ====================

  @override
  Future<List<BaseCentroEntity>> getActivas() async {
    try {
      return await _dataSource.getActivas();
    } catch (e) {
      throw Exception('Error al obtener bases activas: $e');
    }
  }

  @override
  Future<List<BaseCentroEntity>> getByPoblacion(String poblacionId) async {
    try {
      return await _dataSource.getByPoblacion(poblacionId);
    } catch (e) {
      throw Exception('Error al obtener bases por población: $e');
    }
  }

  @override
  Future<BaseCentroEntity> deactivateBase(String baseId) async {
    try {
      return await _dataSource.deactivateBase(baseId);
    } catch (e) {
      throw Exception('Error al desactivar base: $e');
    }
  }

  @override
  Future<BaseCentroEntity> reactivateBase(String baseId) async {
    try {
      return await _dataSource.reactivateBase(baseId);
    } catch (e) {
      throw Exception('Error al reactivar base: $e');
    }
  }
}
