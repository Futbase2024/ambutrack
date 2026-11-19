import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/features/personal/domain/repositories/vestuario_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

/// Implementación del repositorio de Vestuario
@LazySingleton(as: VestuarioRepository)
class VestuarioRepositoryImpl implements VestuarioRepository {
  VestuarioRepositoryImpl()
      : _dataSource = VestuarioDataSourceFactory.createSupabase();

  final VestuarioDataSource _dataSource;

  @override
  Future<List<VestuarioEntity>> getAll() async {
    debugPrint('📦 Repository: Solicitando todos los registros de vestuario...');
    try {
      final List<VestuarioEntity> items = await _dataSource.getAll();
      debugPrint('📦 Repository: ✅ ${items.length} registros obtenidos');
      return items;
    } catch (e) {
      debugPrint('📦 Repository: ❌ Error: $e');
      rethrow;
    }
  }

  @override
  Future<VestuarioEntity> getById(String id) async {
    debugPrint('📦 Repository: Solicitando vestuario con ID: $id');
    return _dataSource.getById(id);
  }

  @override
  Future<List<VestuarioEntity>> getByPersonalId(String personalId) async {
    debugPrint(
        '📦 Repository: Solicitando vestuario del personal: $personalId');
    return _dataSource.getByPersonalId(personalId);
  }

  @override
  Future<List<VestuarioEntity>> getAsignado() async {
    debugPrint('📦 Repository: Solicitando vestuario asignado...');
    return _dataSource.getAsignado();
  }

  @override
  Future<List<VestuarioEntity>> getByPrenda(String prenda) async {
    debugPrint('📦 Repository: Solicitando vestuario por prenda: $prenda');
    return _dataSource.getByPrenda(prenda);
  }

  @override
  Future<VestuarioEntity> create(VestuarioEntity item) async {
    debugPrint('📦 Repository: Creando vestuario: ${item.prenda}');
    return _dataSource.create(item);
  }

  @override
  Future<VestuarioEntity> update(VestuarioEntity item) async {
    debugPrint('📦 Repository: Actualizando vestuario: ${item.id}');
    return _dataSource.update(item);
  }

  @override
  Future<void> delete(String id) async {
    debugPrint('📦 Repository: Eliminando vestuario: $id');
    await _dataSource.delete(id);
  }

  @override
  Stream<List<VestuarioEntity>> watchAll() {
    debugPrint('📡 Repository: Stream de todos los registros de vestuario');
    return _dataSource.watchAll();
  }

  @override
  Stream<List<VestuarioEntity>> watchByPersonalId(String personalId) {
    debugPrint('📡 Repository: Stream de vestuario del personal: $personalId');
    return _dataSource.watchByPersonalId(personalId);
  }
}
