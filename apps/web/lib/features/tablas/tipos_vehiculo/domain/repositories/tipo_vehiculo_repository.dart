import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';

/// Contrato del repositorio de tipos de vehículo
abstract class TipoVehiculoRepository {
  /// Obtiene todos los tipos de vehículo
  Future<List<TipoVehiculoEntity>> getAll();

  /// Obtiene un tipo de vehículo por ID
  Future<TipoVehiculoEntity?> getById(String id);

  /// Crea un nuevo tipo de vehículo
  Future<TipoVehiculoEntity> create(TipoVehiculoEntity tipoVehiculo);

  /// Actualiza un tipo de vehículo existente
  Future<TipoVehiculoEntity> update(TipoVehiculoEntity tipoVehiculo);

  /// Elimina un tipo de vehículo por ID
  Future<void> delete(String id);

  /// Obtiene solo los tipos de vehículo activos
  Future<List<TipoVehiculoEntity>> getActivos();
}
