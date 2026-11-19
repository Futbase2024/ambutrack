import 'entities/taller_entity.dart';

/// Contrato del datasource de Talleres
abstract class TalleresDataSource {
  Future<List<TallerEntity>> getAll();
  Future<TallerEntity?> getById(String id);
  Future<TallerEntity> create(TallerEntity entity);
  Future<TallerEntity> update(TallerEntity entity);
  Future<void> delete(String id);
  Future<List<TallerEntity>> getByTipo(String tipo);
  Future<List<TallerEntity>> getActivos();
  Future<int> count();
}
