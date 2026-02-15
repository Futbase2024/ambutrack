import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/features/vehiculos/documentacion/domain/repositories/tipo_documento_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

/// Implementación del repositorio de tipos de documento de vehículo
@LazySingleton(as: TipoDocumentoRepository)
class TipoDocumentoRepositoryImpl implements TipoDocumentoRepository {
  TipoDocumentoRepositoryImpl()
      : _dataSource = DocumentacionVehiculosDataSourceFactory.createTipoDocumento();

  final TipoDocumentoDataSource _dataSource;

  @override
  Future<List<TipoDocumentoEntity>> getAll() async {
    debugPrint('📦 TipoDocumentoRepository: Solicitando todos los tipos...');
    try {
      final List<TipoDocumentoEntity> tipos = await _dataSource.getAll();
      debugPrint('📦 TipoDocumentoRepository: ✅ ${tipos.length} tipos obtenidos');
      return tipos;
    } catch (e) {
      debugPrint('📦 TipoDocumentoRepository: ❌ Error: $e');
      rethrow;
    }
  }

  @override
  Future<TipoDocumentoEntity?> getById(String id) async {
    debugPrint('📦 TipoDocumentoRepository: Obteniendo id=$id');
    return _dataSource.getById(id);
  }

  @override
  Future<List<TipoDocumentoEntity>> getByCategoria(String categoria) async {
    debugPrint('📦 TipoDocumentoRepository: Obteniendo por categoría=$categoria');
    return _dataSource.getByCategoria(categoria);
  }

  @override
  Future<List<TipoDocumentoEntity>> getActivos() async {
    debugPrint('📦 TipoDocumentoRepository: Obteniendo activos...');
    return _dataSource.getActivos();
  }

  @override
  Future<TipoDocumentoEntity> create(TipoDocumentoEntity entity) async {
    debugPrint('📦 TipoDocumentoRepository: Creando...');
    return _dataSource.create(entity);
  }

  @override
  Future<TipoDocumentoEntity> update(TipoDocumentoEntity entity) async {
    debugPrint('📦 TipoDocumentoRepository: Actualizando id=${entity.id}');
    return _dataSource.update(entity);
  }

  @override
  Future<void> delete(String id) async {
    debugPrint('📦 TipoDocumentoRepository: Eliminando id=$id');
    await _dataSource.delete(id);
  }

  @override
  Future<TipoDocumentoEntity> desactivar(String id) async {
    debugPrint('📦 TipoDocumentoRepository: Desactivando id=$id');
    return _dataSource.desactivar(id);
  }
}
