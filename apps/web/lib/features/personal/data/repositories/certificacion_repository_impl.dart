import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/features/personal/domain/repositories/certificacion_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

/// Implementación del repositorio de certificaciones
@LazySingleton(as: CertificacionRepository)
class CertificacionRepositoryImpl implements CertificacionRepository {
  CertificacionRepositoryImpl()
      : _dataSource = CertificacionDataSourceFactory.createSupabase();

  final CertificacionDataSource _dataSource;

  @override
  Future<List<CertificacionEntity>> getAll() async {
    debugPrint('📦 CertificacionRepository: Solicitando todos los registros...');
    try {
      final List<CertificacionEntity> items = await _dataSource.getAll();
      debugPrint('📦 CertificacionRepository: ✅ ${items.length} items obtenidos');
      return items;
    } catch (e) {
      debugPrint('📦 CertificacionRepository: ❌ Error: $e');
      rethrow;
    }
  }

  @override
  Future<CertificacionEntity> getById(String id) async {
    debugPrint('📦 CertificacionRepository: Solicitando item por ID: $id');
    return _dataSource.getById(id);
  }

  @override
  Future<List<CertificacionEntity>> getActivas() async {
    debugPrint('📦 CertificacionRepository: Solicitando certificaciones activas');
    return _dataSource.getActivas();
  }

  @override
  Future<CertificacionEntity?> getByCodigo(String codigo) async {
    debugPrint('📦 CertificacionRepository: Solicitando por código: $codigo');
    return _dataSource.getByCodigo(codigo);
  }

  @override
  Future<CertificacionEntity> create(CertificacionEntity entity) async {
    debugPrint('📦 CertificacionRepository: Creando item');
    return _dataSource.create(entity);
  }

  @override
  Future<CertificacionEntity> update(CertificacionEntity entity) async {
    debugPrint('📦 CertificacionRepository: Actualizando item: ${entity.id}');
    return _dataSource.update(entity);
  }

  @override
  Future<void> delete(String id) async {
    debugPrint('📦 CertificacionRepository: Eliminando item: $id');
    await _dataSource.delete(id);
  }

  @override
  Stream<List<CertificacionEntity>> watchAll() {
    debugPrint('📦 CertificacionRepository: Iniciando stream de todos');
    return _dataSource.watchAll();
  }

  @override
  Stream<List<CertificacionEntity>> watchActivas() {
    debugPrint('📦 CertificacionRepository: Stream de activos');
    return _dataSource.watchActivas();
  }
}
