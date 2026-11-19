import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';

/// Contrato para obtener lo necesario para calcular las caducidades del turno
abstract class AlertasTurnoRepository {
  /// Último fichaje del trabajador (para saber si está en turno y con qué vehículo)
  Future<RegistroHorarioEntity?> obtenerUltimoFichaje(String idPersonal);

  /// Vehículo por ID
  Future<VehiculoEntity?> obtenerVehiculo(String id);

  /// Documentación del trabajador
  Future<List<DocumentoPersonalEntity>> obtenerDocumentosPersonal(String idPersonal);

  /// Material (stock) del vehículo
  Future<List<StockVehiculoEntity>> obtenerMaterialVehiculo(String idVehiculo);
}
