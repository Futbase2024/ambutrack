import 'package:ambutrack_core/ambutrack_core.dart';

/// Repositorio abstracto de vehículos
abstract class VehiculoRepository {
  /// Obtener todos los vehículos
  Future<List<VehiculoEntity>> getAll({
    String? orderBy,
    bool ascending = true,
    int? limit,
  });

  /// Obtener un vehículo por ID
  Future<VehiculoEntity> getById(String id);

  /// Obtener vehículos por estado
  Future<List<VehiculoEntity>> getByEstado(VehiculoEstado estado);

  /// Crear un nuevo vehículo
  Future<VehiculoEntity> create(VehiculoEntity vehiculo);

  /// Actualizar un vehículo existente
  Future<VehiculoEntity> update(VehiculoEntity vehiculo);

  /// Eliminar un vehículo
  Future<void> delete(String id);

  /// Obtener stream de vehículos con actualizaciones en tiempo real
  Stream<List<VehiculoEntity>> watchAll();

  /// Contar vehículos
  Future<int> count();

  /// Buscar vehículos por matrícula
  Future<List<VehiculoEntity>> searchByMatricula(String matricula);
}
