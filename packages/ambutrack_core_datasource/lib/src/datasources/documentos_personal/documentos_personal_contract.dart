import 'entities/documento_personal_entity.dart';

/// Contrato del datasource de Documentación del Personal
abstract class DocumentosPersonalDataSource {
  /// Todos los documentos (caducidad más próxima primero, sin caducidad al final)
  Future<List<DocumentoPersonalEntity>> getAll();
  Future<DocumentoPersonalEntity?> getById(String id);
  Future<List<DocumentoPersonalEntity>> getByPersonal(String personalId);
  Future<DocumentoPersonalEntity> create(DocumentoPersonalEntity entity);
  Future<DocumentoPersonalEntity> update(DocumentoPersonalEntity entity);
  Future<void> delete(String id);
}
