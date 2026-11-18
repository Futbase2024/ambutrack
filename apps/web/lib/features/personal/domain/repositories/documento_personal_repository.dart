import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';

/// Repositorio de documentación del personal
abstract class DocumentoPersonalRepository {
  Future<List<DocumentoPersonalEntity>> getAll();
  Future<DocumentoPersonalEntity?> getById(String id);
  Future<List<DocumentoPersonalEntity>> getByPersonal(String personalId);
  Future<DocumentoPersonalEntity> create(DocumentoPersonalEntity entity);
  Future<DocumentoPersonalEntity> update(DocumentoPersonalEntity entity);
  Future<void> delete(String id);
}
