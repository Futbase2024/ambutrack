import 'package:ambutrack_core/ambutrack_core.dart';

/// Contrato del repositorio de categorías de vehículo
abstract class CategoriaVehiculoRepository {
  Future<List<CategoriaVehiculoEntity>> getAll();
  Future<CategoriaVehiculoEntity?> getById(String id);
  Future<CategoriaVehiculoEntity> create(CategoriaVehiculoEntity categoria);
  Future<CategoriaVehiculoEntity> update(CategoriaVehiculoEntity categoria);
  Future<void> delete(String id);
  Stream<List<CategoriaVehiculoEntity>> watchAll();
}
