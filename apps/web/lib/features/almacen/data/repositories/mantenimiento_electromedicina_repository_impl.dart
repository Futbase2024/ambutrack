// Imports del core datasource (sistema nuevo de almacén)
import 'package:ambutrack_core/ambutrack_core.dart';
import 'package:ambutrack_web/features/almacen/domain/repositories/mantenimiento_electromedicina_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

/// Implementación del repositorio de Mantenimiento de Electromedicina usando pass-through al datasource
///
/// Siguiendo el patrón establecido en el proyecto: el repositorio es un simple
/// pass-through sin conversiones Entity ↔ Entity ya que usamos las mismas
/// entidades del core datasource
@LazySingleton(as: MantenimientoElectromedicinaRepository)
class MantenimientoElectromedicinaRepositoryImpl
    implements MantenimientoElectromedicinaRepository {
  MantenimientoElectromedicinaRepositoryImpl()
      : _dataSource =
            MantenimientoElectromedicinaDataSourceFactory.createSupabase();

  final MantenimientoElectromedicinaDataSource _dataSource;

  @override
  Future<List<MantenimientoElectromedicinaEntity>> getAll() async {
    debugPrint(
        '📦 MantenimientoElectromedicinaRepository: Solicitando todos los mantenimientos...');
    try {
      final List<MantenimientoElectromedicinaEntity> mantenimientos = await _dataSource.getAll();
      debugPrint(
          '📦 MantenimientoElectromedicinaRepository: ✅ ${mantenimientos.length} mantenimientos obtenidos');
      return mantenimientos;
    } catch (e) {
      debugPrint(
          '📦 MantenimientoElectromedicinaRepository: ❌ Error al obtener mantenimientos: $e');
      rethrow;
    }
  }

  @override
  Future<MantenimientoElectromedicinaEntity?> getById(String id) async {
    debugPrint(
        '📦 MantenimientoElectromedicinaRepository: Solicitando mantenimiento: $id');
    try {
      final MantenimientoElectromedicinaEntity? mantenimiento = await _dataSource.getById(id);
      if (mantenimiento != null) {
        debugPrint(
            '📦 MantenimientoElectromedicinaRepository: ✅ Mantenimiento obtenido');
      } else {
        debugPrint(
            '📦 MantenimientoElectromedicinaRepository: ⚠️ Mantenimiento no encontrado');
      }
      return mantenimiento;
    } catch (e) {
      debugPrint(
          '📦 MantenimientoElectromedicinaRepository: ❌ Error al obtener mantenimiento: $e');
      rethrow;
    }
  }

  @override
  Future<List<MantenimientoElectromedicinaEntity>> getByProducto(
      String productoId) async {
    debugPrint(
        '📦 MantenimientoElectromedicinaRepository: Solicitando mantenimientos del producto: $productoId');
    try {
      final List<MantenimientoElectromedicinaEntity> mantenimientos = await _dataSource.getByProducto(productoId);
      debugPrint(
          '📦 MantenimientoElectromedicinaRepository: ✅ ${mantenimientos.length} mantenimientos obtenidos');
      return mantenimientos;
    } catch (e) {
      debugPrint(
          '📦 MantenimientoElectromedicinaRepository: ❌ Error al obtener mantenimientos por producto: $e');
      rethrow;
    }
  }

  @override
  Future<List<MantenimientoElectromedicinaEntity>> getByTipo(
      TipoMantenimientoElectromedicina tipo) async {
    debugPrint(
        '📦 MantenimientoElectromedicinaRepository: Solicitando mantenimientos de tipo: ${tipo.label}');
    try {
      final List<MantenimientoElectromedicinaEntity> mantenimientos = await _dataSource.getByTipo(tipo);
      debugPrint(
          '📦 MantenimientoElectromedicinaRepository: ✅ ${mantenimientos.length} mantenimientos obtenidos');
      return mantenimientos;
    } catch (e) {
      debugPrint(
          '📦 MantenimientoElectromedicinaRepository: ❌ Error al obtener mantenimientos por tipo: $e');
      rethrow;
    }
  }

  @override
  Future<List<MantenimientoElectromedicinaEntity>> getProximosAVencer(
      {int dias = 30}) async {
    debugPrint(
        '📦 MantenimientoElectromedicinaRepository: Solicitando mantenimientos próximos a vencer (días: $dias)...');
    try {
      final List<MantenimientoElectromedicinaEntity> mantenimientos =
          await _dataSource.getProximosAVencer(dias: dias);
      debugPrint(
          '📦 MantenimientoElectromedicinaRepository: ✅ ${mantenimientos.length} mantenimientos próximos a vencer');
      return mantenimientos;
    } catch (e) {
      debugPrint(
          '📦 MantenimientoElectromedicinaRepository: ❌ Error al obtener mantenimientos próximos a vencer: $e');
      rethrow;
    }
  }

  @override
  Future<List<MantenimientoElectromedicinaEntity>> getVencidos() async {
    debugPrint(
        '📦 MantenimientoElectromedicinaRepository: Solicitando mantenimientos vencidos...');
    try {
      final List<MantenimientoElectromedicinaEntity> mantenimientos = await _dataSource.getVencidos();
      debugPrint(
          '📦 MantenimientoElectromedicinaRepository: ✅ ${mantenimientos.length} mantenimientos vencidos');
      return mantenimientos;
    } catch (e) {
      debugPrint(
          '📦 MantenimientoElectromedicinaRepository: ❌ Error al obtener mantenimientos vencidos: $e');
      rethrow;
    }
  }

  @override
  Future<MantenimientoElectromedicinaEntity> create(
      MantenimientoElectromedicinaEntity mantenimiento) async {
    debugPrint(
        '📦 MantenimientoElectromedicinaRepository: Creando mantenimiento de tipo: ${mantenimiento.tipoMantenimiento.label}');
    try {
      final MantenimientoElectromedicinaEntity created = await _dataSource.create(mantenimiento);
      debugPrint(
          '📦 MantenimientoElectromedicinaRepository: ✅ Mantenimiento creado con ID: ${created.id}');
      return created;
    } catch (e) {
      debugPrint(
          '📦 MantenimientoElectromedicinaRepository: ❌ Error al crear mantenimiento: $e');
      rethrow;
    }
  }

  @override
  Future<MantenimientoElectromedicinaEntity> update(
      MantenimientoElectromedicinaEntity mantenimiento) async {
    debugPrint(
        '📦 MantenimientoElectromedicinaRepository: Actualizando mantenimiento: ${mantenimiento.id}');
    try {
      final MantenimientoElectromedicinaEntity updated = await _dataSource.update(mantenimiento);
      debugPrint(
          '📦 MantenimientoElectromedicinaRepository: ✅ Mantenimiento actualizado');
      return updated;
    } catch (e) {
      debugPrint(
          '📦 MantenimientoElectromedicinaRepository: ❌ Error al actualizar mantenimiento: $e');
      rethrow;
    }
  }

  @override
  Future<void> delete(String id) async {
    debugPrint(
        '📦 MantenimientoElectromedicinaRepository: Eliminando mantenimiento: $id');
    try {
      await _dataSource.delete(id);
      debugPrint(
          '📦 MantenimientoElectromedicinaRepository: ✅ Mantenimiento eliminado');
    } catch (e) {
      debugPrint(
          '📦 MantenimientoElectromedicinaRepository: ❌ Error al eliminar mantenimiento: $e');
      rethrow;
    }
  }

  @override
  Stream<List<MantenimientoElectromedicinaEntity>> watchAll() {
    debugPrint(
        '📦 MantenimientoElectromedicinaRepository: Iniciando stream de todos los mantenimientos');
    return _dataSource.watchAll();
  }

  @override
  Stream<List<MantenimientoElectromedicinaEntity>> watchByProducto(
      String productoId) {
    debugPrint(
        '📦 MantenimientoElectromedicinaRepository: Iniciando stream de mantenimientos del producto: $productoId');
    return _dataSource.watchByProducto(productoId);
  }

  @override
  Stream<List<MantenimientoElectromedicinaEntity>> watchProximosAVencer(
      {int dias = 30}) {
    debugPrint(
        '📦 MantenimientoElectromedicinaRepository: Iniciando stream de mantenimientos próximos a vencer (días: $dias)');
    return _dataSource.watchProximosAVencer(dias: dias);
  }
}
