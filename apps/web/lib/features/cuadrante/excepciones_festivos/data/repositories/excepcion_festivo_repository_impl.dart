import 'package:ambutrack_core/ambutrack_core.dart';
import 'package:ambutrack_web/features/cuadrante/excepciones_festivos/domain/repositories/excepcion_festivo_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

/// Implementación del repositorio de Excepciones/Festivos
@LazySingleton(as: ExcepcionFestivoRepository)
class ExcepcionFestivoRepositoryImpl implements ExcepcionFestivoRepository {
  ExcepcionFestivoRepositoryImpl()
      : _dataSource = ExcepcionesFestivosDataSourceFactory.createSupabase();

  final ExcepcionesFestivosDataSource _dataSource;

  @override
  Future<List<ExcepcionFestivoEntity>> getAll() async {
    debugPrint('📦 Repository: Solicitando todas las excepciones/festivos...');
    try {
      final List<ExcepcionFestivoEntity> items = await _dataSource.getAll();
      debugPrint('📦 Repository: ✅ ${items.length} excepciones/festivos obtenidas');
      return items;
    } catch (e) {
      debugPrint('📦 Repository: ❌ Error: $e');
      rethrow;
    }
  }

  @override
  Future<List<ExcepcionFestivoEntity>> getActivas() async {
    debugPrint('📦 Repository: Solicitando excepciones/festivos activas...');
    try {
      final List<ExcepcionFestivoEntity> items = await _dataSource.getActivas();
      debugPrint('📦 Repository: ✅ ${items.length} activas');
      return items;
    } catch (e) {
      debugPrint('📦 Repository: ❌ Error: $e');
      rethrow;
    }
  }

  @override
  Future<List<ExcepcionFestivoEntity>> getByAnio(int anio) async {
    debugPrint('📦 Repository: Solicitando excepciones/festivos del año $anio...');
    try {
      final List<ExcepcionFestivoEntity> items = await _dataSource.getByAnio(anio);
      debugPrint('📦 Repository: ✅ ${items.length} items del año $anio');
      return items;
    } catch (e) {
      debugPrint('📦 Repository: ❌ Error: $e');
      rethrow;
    }
  }

  @override
  Future<List<ExcepcionFestivoEntity>> getByRangoFechas({
    required DateTime fechaInicio,
    required DateTime fechaFin,
  }) async {
    debugPrint('📦 Repository: Solicitando excepciones/festivos en rango...');
    try {
      final List<ExcepcionFestivoEntity> items = await _dataSource.getByRangoFechas(
        fechaInicio: fechaInicio,
        fechaFin: fechaFin,
      );
      debugPrint('📦 Repository: ✅ ${items.length} items en el rango');
      return items;
    } catch (e) {
      debugPrint('📦 Repository: ❌ Error: $e');
      rethrow;
    }
  }

  @override
  Future<List<ExcepcionFestivoEntity>> getByTipo(String tipo) async {
    debugPrint('📦 Repository: Solicitando excepciones/festivos de tipo $tipo...');
    try {
      final List<ExcepcionFestivoEntity> items = await _dataSource.getByTipo(tipo);
      debugPrint('📦 Repository: ✅ ${items.length} items de tipo $tipo');
      return items;
    } catch (e) {
      debugPrint('📦 Repository: ❌ Error: $e');
      rethrow;
    }
  }

  @override
  Future<ExcepcionFestivoEntity?> getById(String id) async {
    debugPrint('📦 Repository: Solicitando excepción/festivo por ID...');
    try {
      final ExcepcionFestivoEntity? item = await _dataSource.getById(id);
      if (item != null) {
        debugPrint('📦 Repository: ✅ Item encontrado');
      } else {
        debugPrint('📦 Repository: ⚠️ Item no encontrado');
      }
      return item;
    } catch (e) {
      debugPrint('📦 Repository: ❌ Error: $e');
      rethrow;
    }
  }

  @override
  Future<ExcepcionFestivoEntity> create(ExcepcionFestivoEntity item) async {
    debugPrint('📦 Repository: Creando excepción/festivo...');
    try {
      final ExcepcionFestivoEntity created = await _dataSource.create(item);
      debugPrint('📦 Repository: ✅ Creado con ID: ${created.id}');
      return created;
    } catch (e) {
      debugPrint('📦 Repository: ❌ Error: $e');
      rethrow;
    }
  }

  @override
  Future<ExcepcionFestivoEntity> update(ExcepcionFestivoEntity item) async {
    debugPrint('📦 Repository: Actualizando excepción/festivo...');
    try {
      final ExcepcionFestivoEntity updated = await _dataSource.update(item);
      debugPrint('📦 Repository: ✅ Actualizado');
      return updated;
    } catch (e) {
      debugPrint('📦 Repository: ❌ Error: $e');
      rethrow;
    }
  }

  @override
  Future<void> delete(String id) async {
    debugPrint('📦 Repository: Eliminando excepción/festivo...');
    try {
      await _dataSource.delete(id);
      debugPrint('📦 Repository: ✅ Eliminado');
    } catch (e) {
      debugPrint('📦 Repository: ❌ Error: $e');
      rethrow;
    }
  }

  @override
  Future<void> toggleActivo(String id, {required bool activo}) async {
    debugPrint('📦 Repository: Cambiando estado activo...');
    try {
      await _dataSource.toggleActivo(id, activo: activo);
      debugPrint('📦 Repository: ✅ Estado actualizado');
    } catch (e) {
      debugPrint('📦 Repository: ❌ Error: $e');
      rethrow;
    }
  }

  @override
  Stream<List<ExcepcionFestivoEntity>> watchAll() {
    debugPrint('📦 Repository: Iniciando stream...');
    return _dataSource.watchAll();
  }
}
