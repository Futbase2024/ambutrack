import 'package:ambutrack_core/ambutrack_core.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../../domain/repositories/tipo_ausencia_repository.dart';

/// Implementación del repositorio de Tipos de Ausencia (pass-through)
@LazySingleton(as: TipoAusenciaRepository)
class TipoAusenciaRepositoryImpl implements TipoAusenciaRepository {
  TipoAusenciaRepositoryImpl()
      : _dataSource = TipoAusenciaDataSourceFactory.createSupabase();

  final TipoAusenciaDataSource _dataSource;

  @override
  Future<List<TipoAusenciaEntity>> getAll() async {
    debugPrint('📦 TipoAusenciaRepository: Solicitando todos los tipos...');
    try {
      final List<TipoAusenciaEntity> items = await _dataSource.getAll();
      debugPrint('📦 TipoAusenciaRepository: ✅ ${items.length} tipos obtenidos');
      return items;
    } catch (e) {
      debugPrint('📦 TipoAusenciaRepository: ❌ Error: $e');
      rethrow;
    }
  }

  @override
  Future<TipoAusenciaEntity> getById(String id) async {
    debugPrint('📦 TipoAusenciaRepository: Solicitando tipo ID: $id');
    try {
      final TipoAusenciaEntity item = await _dataSource.getById(id);
      debugPrint('📦 TipoAusenciaRepository: ✅ Tipo obtenido');
      return item;
    } catch (e) {
      debugPrint('📦 TipoAusenciaRepository: ❌ Error: $e');
      rethrow;
    }
  }

  @override
  Future<TipoAusenciaEntity> create(TipoAusenciaEntity tipoAusencia) async {
    debugPrint('📦 TipoAusenciaRepository: Creando tipo: ${tipoAusencia.nombre}');
    try {
      final TipoAusenciaEntity created = await _dataSource.create(tipoAusencia);
      debugPrint('📦 TipoAusenciaRepository: ✅ Tipo creado');
      return created;
    } catch (e) {
      debugPrint('📦 TipoAusenciaRepository: ❌ Error: $e');
      rethrow;
    }
  }

  @override
  Future<TipoAusenciaEntity> update(TipoAusenciaEntity tipoAusencia) async {
    debugPrint('📦 TipoAusenciaRepository: Actualizando tipo ID: ${tipoAusencia.id}');
    try {
      final TipoAusenciaEntity updated = await _dataSource.update(tipoAusencia);
      debugPrint('📦 TipoAusenciaRepository: ✅ Tipo actualizado');
      return updated;
    } catch (e) {
      debugPrint('📦 TipoAusenciaRepository: ❌ Error: $e');
      rethrow;
    }
  }

  @override
  Future<void> delete(String id) async {
    debugPrint('📦 TipoAusenciaRepository: Eliminando tipo ID: $id');
    try {
      await _dataSource.delete(id);
      debugPrint('📦 TipoAusenciaRepository: ✅ Tipo eliminado');
    } catch (e) {
      debugPrint('📦 TipoAusenciaRepository: ❌ Error: $e');
      rethrow;
    }
  }

  @override
  Stream<List<TipoAusenciaEntity>> watchAll() {
    debugPrint('📦 TipoAusenciaRepository: Iniciando stream...');
    return _dataSource.watchAll();
  }
}
