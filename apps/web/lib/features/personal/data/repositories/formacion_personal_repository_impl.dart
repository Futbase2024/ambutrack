import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/features/personal/domain/repositories/formacion_personal_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

/// Implementación del repositorio de formación personal
@LazySingleton(as: FormacionPersonalRepository)
class FormacionPersonalRepositoryImpl implements FormacionPersonalRepository {
  FormacionPersonalRepositoryImpl()
      : _dataSource = FormacionPersonalDataSourceFactory.createSupabase();

  final FormacionPersonalDataSource _dataSource;

  @override
  Future<List<FormacionPersonalEntity>> getAll() async {
    debugPrint('📦 FormacionPersonalRepository: Solicitando todos los registros...');
    try {
      final List<FormacionPersonalEntity> items = await _dataSource.getAll();
      debugPrint('📦 FormacionPersonalRepository: ✅ ${items.length} items obtenidos');
      return items;
    } catch (e) {
      debugPrint('📦 FormacionPersonalRepository: ❌ Error: $e');
      rethrow;
    }
  }

  @override
  Future<FormacionPersonalEntity> getById(String id) async {
    debugPrint('📦 FormacionPersonalRepository: Solicitando item por ID: $id');
    return _dataSource.getById(id);
  }

  @override
  Future<List<FormacionPersonalEntity>> getByPersonalId(String personalId) async {
    debugPrint('📦 FormacionPersonalRepository: Solicitando por personalId: $personalId');
    return _dataSource.getByPersonalId(personalId);
  }

  @override
  Future<List<FormacionPersonalEntity>> getVigentes() async {
    debugPrint('📦 FormacionPersonalRepository: Solicitando formación vigente');
    return _dataSource.getVigentes();
  }

  @override
  Future<List<FormacionPersonalEntity>> getProximasVencer() async {
    debugPrint('📦 FormacionPersonalRepository: Solicitando formación próxima a vencer');
    return _dataSource.getProximasVencer();
  }

  @override
  Future<List<FormacionPersonalEntity>> getVencidas() async {
    debugPrint('📦 FormacionPersonalRepository: Solicitando formación vencida');
    return _dataSource.getVencidas();
  }

  @override
  Future<List<FormacionPersonalEntity>> getByEstado(String estado) async {
    debugPrint('📦 FormacionPersonalRepository: Solicitando por estado: $estado');
    return _dataSource.getByEstado(estado);
  }

  @override
  Future<FormacionPersonalEntity> create(FormacionPersonalEntity entity) async {
    debugPrint('📦 FormacionPersonalRepository: Creando item');
    return _dataSource.create(entity);
  }

  @override
  Future<FormacionPersonalEntity> update(FormacionPersonalEntity entity) async {
    debugPrint('📦 FormacionPersonalRepository: Actualizando item: ${entity.id}');
    return _dataSource.update(entity);
  }

  @override
  Future<void> delete(String id) async {
    debugPrint('📦 FormacionPersonalRepository: Eliminando item: $id');
    await _dataSource.delete(id);
  }

  @override
  Stream<List<FormacionPersonalEntity>> watchAll() {
    debugPrint('📦 FormacionPersonalRepository: Iniciando stream de todos');
    return _dataSource.watchAll();
  }

  @override
  Stream<List<FormacionPersonalEntity>> watchByPersonalId(String personalId) {
    debugPrint('📦 FormacionPersonalRepository: Stream por personalId: $personalId');
    return _dataSource.watchByPersonalId(personalId);
  }
}
