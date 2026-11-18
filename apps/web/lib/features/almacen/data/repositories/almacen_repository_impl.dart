import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart' hide MovimientoStockEntity, StockDataSource;
import 'package:ambutrack_web/features/almacen/domain/repositories/almacen_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

/// Implementación del repositorio de Almacén General usando Supabase
///
/// Pass-through directo al datasource sin conversiones
@LazySingleton(as: AlmacenRepository)
class AlmacenRepositoryImpl implements AlmacenRepository {
  AlmacenRepositoryImpl()
      : _proveedorDataSource = ProveedorDataSourceFactory.createSupabase();

  final ProveedorDataSource _proveedorDataSource;

  // ============================================
  // PROVEEDORES (con Supabase)
  // ============================================

  @override
  Future<List<ProveedorEntity>> getAllProveedores() async {
    debugPrint('📦 AlmacenRepository: Solicitando todos los proveedores...');
    try {
      final List<ProveedorEntity> proveedores = await _proveedorDataSource.getAll();
      debugPrint('📦 AlmacenRepository: ✅ ${proveedores.length} proveedores obtenidos');
      return proveedores;
    } catch (e) {
      debugPrint('📦 AlmacenRepository: ❌ Error al obtener proveedores: $e');
      rethrow;
    }
  }

  @override
  Future<ProveedorEntity> getProveedorById(String id) async {
    debugPrint('📦 AlmacenRepository: Solicitando proveedor $id...');
    try {
      final ProveedorEntity? proveedor = await _proveedorDataSource.getById(id);
      if (proveedor == null) {
        throw Exception('Proveedor con id $id no encontrado');
      }
      debugPrint('📦 AlmacenRepository: ✅ Proveedor obtenido');
      return proveedor;
    } catch (e) {
      debugPrint('📦 AlmacenRepository: ❌ Error al obtener proveedor: $e');
      rethrow;
    }
  }

  @override
  Future<ProveedorEntity> createProveedor(ProveedorEntity proveedor) async {
    debugPrint('📦 AlmacenRepository: Creando proveedor ${proveedor.nombreComercial}...');
    try {
      final ProveedorEntity created = await _proveedorDataSource.create(proveedor);
      debugPrint('📦 AlmacenRepository: ✅ Proveedor creado');
      return created;
    } catch (e) {
      debugPrint('📦 AlmacenRepository: ❌ Error al crear proveedor: $e');
      rethrow;
    }
  }

  @override
  Future<ProveedorEntity> updateProveedor(ProveedorEntity proveedor) async {
    debugPrint('📦 AlmacenRepository: Actualizando proveedor ${proveedor.id}...');
    try {
      final ProveedorEntity updated = await _proveedorDataSource.update(proveedor);
      debugPrint('📦 AlmacenRepository: ✅ Proveedor actualizado');
      return updated;
    } catch (e) {
      debugPrint('📦 AlmacenRepository: ❌ Error al actualizar proveedor: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteProveedor(String id) async {
    debugPrint('📦 AlmacenRepository: Eliminando proveedor $id...');
    try {
      await _proveedorDataSource.delete(id);
      debugPrint('📦 AlmacenRepository: ✅ Proveedor eliminado');
    } catch (e) {
      debugPrint('📦 AlmacenRepository: ❌ Error al eliminar proveedor: $e');
      rethrow;
    }
  }

  @override
  Future<List<ProveedorEntity>> searchProveedores(String query) async {
    debugPrint('📦 AlmacenRepository: Buscando proveedores: "$query"...');
    try {
      final List<ProveedorEntity> proveedores = await _proveedorDataSource.search(query);
      debugPrint('📦 AlmacenRepository: ✅ ${proveedores.length} proveedores encontrados');
      return proveedores;
    } catch (e) {
      debugPrint('📦 AlmacenRepository: ❌ Error al buscar proveedores: $e');
      rethrow;
    }
  }

  @override
  Future<List<ProveedorEntity>> getProveedoresActivos() async {
    debugPrint('📦 AlmacenRepository: Solicitando proveedores activos...');
    try {
      final List<ProveedorEntity> proveedores = await _proveedorDataSource.getActivos();
      debugPrint('📦 AlmacenRepository: ✅ ${proveedores.length} proveedores activos');
      return proveedores;
    } catch (e) {
      debugPrint('📦 AlmacenRepository: ❌ Error al obtener proveedores activos: $e');
      rethrow;
    }
  }
}
