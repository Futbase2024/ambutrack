import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/features/personal/domain/repositories/curso_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

/// Implementación del repositorio de cursos
@LazySingleton(as: CursoRepository)
class CursoRepositoryImpl implements CursoRepository {
  CursoRepositoryImpl()
      : _dataSource = CursoDataSourceFactory.createSupabase();

  final CursoDataSource _dataSource;

  @override
  Future<List<CursoEntity>> getAll() async {
    debugPrint('📦 CursoRepository: Solicitando todos los registros...');
    try {
      final List<CursoEntity> items = await _dataSource.getAll();
      debugPrint('📦 CursoRepository: ✅ ${items.length} items obtenidos');
      return items;
    } catch (e) {
      debugPrint('📦 CursoRepository: ❌ Error: $e');
      rethrow;
    }
  }

  @override
  Future<CursoEntity> getById(String id) async {
    debugPrint('📦 CursoRepository: Solicitando item por ID: $id');
    return _dataSource.getById(id);
  }

  @override
  Future<List<CursoEntity>> getActivos() async {
    debugPrint('📦 CursoRepository: Solicitando cursos activos');
    return _dataSource.getActivos();
  }

  @override
  Future<List<CursoEntity>> getByTipo(String tipo) async {
    debugPrint('📦 CursoRepository: Solicitando por tipo: $tipo');
    return _dataSource.getByTipo(tipo);
  }

  @override
  Future<CursoEntity> create(CursoEntity entity) async {
    debugPrint('📦 CursoRepository: Creando item');
    return _dataSource.create(entity);
  }

  @override
  Future<CursoEntity> update(CursoEntity entity) async {
    debugPrint('📦 CursoRepository: Actualizando item: ${entity.id}');
    return _dataSource.update(entity);
  }

  @override
  Future<void> delete(String id) async {
    debugPrint('📦 CursoRepository: Eliminando item: $id');
    await _dataSource.delete(id);
  }

  @override
  Stream<List<CursoEntity>> watchAll() {
    debugPrint('📦 CursoRepository: Iniciando stream de todos');
    return _dataSource.watchAll();
  }

  @override
  Stream<List<CursoEntity>> watchActivos() {
    debugPrint('📦 CursoRepository: Stream de activos');
    return _dataSource.watchActivos();
  }
}
