import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/features/personal/domain/repositories/documento_personal_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

/// Implementación pass-through del repositorio de documentación del personal
@LazySingleton(as: DocumentoPersonalRepository)
class DocumentoPersonalRepositoryImpl implements DocumentoPersonalRepository {
  DocumentoPersonalRepositoryImpl() : _dataSource = DocumentosPersonalDataSourceFactory.createSupabase();

  final DocumentosPersonalDataSource _dataSource;

  @override
  Future<List<DocumentoPersonalEntity>> getAll() async {
    debugPrint('📦 DocumentoPersonalRepository: solicitando todos los registros...');
    return _dataSource.getAll();
  }

  @override
  Future<DocumentoPersonalEntity?> getById(String id) => _dataSource.getById(id);

  @override
  Future<List<DocumentoPersonalEntity>> getByPersonal(String personalId) => _dataSource.getByPersonal(personalId);

  @override
  Future<DocumentoPersonalEntity> create(DocumentoPersonalEntity entity) {
    debugPrint('📦 DocumentoPersonalRepository: creando ${entity.id}');
    return _dataSource.create(entity);
  }

  @override
  Future<DocumentoPersonalEntity> update(DocumentoPersonalEntity entity) {
    debugPrint('📦 DocumentoPersonalRepository: actualizando ${entity.id}');
    return _dataSource.update(entity);
  }

  @override
  Future<void> delete(String id) {
    debugPrint('📦 DocumentoPersonalRepository: eliminando $id');
    return _dataSource.delete(id);
  }
}
