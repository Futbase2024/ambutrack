import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/features/vehiculos/documentacion/domain/repositories/documentacion_vehiculo_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

/// Implementación del repositorio de documentación de vehículos
@LazySingleton(as: DocumentacionVehiculoRepository)
class DocumentacionVehiculoRepositoryImpl
    implements DocumentacionVehiculoRepository {
  DocumentacionVehiculoRepositoryImpl()
      : _dataSource =
            DocumentacionVehiculosDataSourceFactory.createDocumentacionVehiculo();

  final DocumentacionVehiculoDataSource _dataSource;

  @override
  Future<List<DocumentacionVehiculoEntity>> getAll() async {
    debugPrint('📦 DocumentacionVehiculoRepository: Solicitando todos...');
    try {
      final List<DocumentacionVehiculoEntity> documentos = await _dataSource.getAll();
      debugPrint(
          '📦 DocumentacionVehiculoRepository: ✅ ${documentos.length} documentos obtenidos');
      return documentos;
    } catch (e) {
      debugPrint('📦 DocumentacionVehiculoRepository: ❌ Error: $e');
      rethrow;
    }
  }

  @override
  Future<DocumentacionVehiculoEntity?> getById(String id) async {
    debugPrint('📦 DocumentacionVehiculoRepository: Obteniendo id=$id');
    return _dataSource.getById(id);
  }

  @override
  Future<List<DocumentacionVehiculoEntity>> getByVehiculo(
      String vehiculoId) async {
    debugPrint('📦 DocumentacionVehiculoRepository: Por vehículo=$vehiculoId');
    return _dataSource.getByVehiculo(vehiculoId);
  }

  @override
  Future<List<DocumentacionVehiculoEntity>> getByTipoDocumento(
      String tipoDocumentoId) async {
    debugPrint('📦 DocumentacionVehiculoRepository: Por tipo=$tipoDocumentoId');
    return _dataSource.getByTipoDocumento(tipoDocumentoId);
  }

  @override
  Future<List<DocumentacionVehiculoEntity>> getByEstado(String estado) async {
    debugPrint('📦 DocumentacionVehiculoRepository: Por estado=$estado');
    return _dataSource.getByEstado(estado);
  }

  @override
  Future<List<DocumentacionVehiculoEntity>> getProximosAVencer() async {
    debugPrint('📦 DocumentacionVehiculoRepository: Próximos a vencer...');
    return _dataSource.getProximosAVencer();
  }

  @override
  Future<List<DocumentacionVehiculoEntity>> getVencidos() async {
    debugPrint('📦 DocumentacionVehiculoRepository: Vencidos...');
    return _dataSource.getVencidos();
  }

  @override
  Future<DocumentacionVehiculoEntity> create(
      DocumentacionVehiculoEntity entity) async {
    debugPrint('📦 DocumentacionVehiculoRepository: Creando...');
    return _dataSource.create(entity);
  }

  @override
  Future<DocumentacionVehiculoEntity> update(
      DocumentacionVehiculoEntity entity) async {
    debugPrint('📦 DocumentacionVehiculoRepository: Actualizando id=${entity.id}');
    return _dataSource.update(entity);
  }

  @override
  Future<void> delete(String id) async {
    debugPrint('📦 DocumentacionVehiculoRepository: Eliminando id=$id');
    await _dataSource.delete(id);
  }

  @override
  Future<DocumentacionVehiculoEntity> actualizarEstado(String id) async {
    debugPrint('📦 DocumentacionVehiculoRepository: Actualizando estado id=$id');
    return _dataSource.actualizarEstado(id);
  }

  @override
  Future<List<DocumentacionVehiculoEntity>> buscarPorPoliza(
      String numeroPoliza) async {
    debugPrint('📦 DocumentacionVehiculoRepository: Por póliza=$numeroPoliza');
    return _dataSource.buscarPorPoliza(numeroPoliza);
  }

  @override
  Future<List<DocumentacionVehiculoEntity>> buscarPorCompania(
      String compania) async {
    debugPrint('📦 DocumentacionVehiculoRepository: Por compañía=$compania');
    return _dataSource.buscarPorCompania(compania);
  }
}
