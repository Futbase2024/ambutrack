import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';

/// Contrato para resolver el turno en curso del trabajador al fichar
///
/// Agrupa las consultas necesarias para iniciar turno desde la app:
/// turno vigente del cuadrante, vehículos operativos y plantillas.
abstract class TurnoActualRepository {
  /// Turno del cuadrante que contiene el momento actual (o null)
  Future<TurnoEntity?> obtenerTurnoVigente(String idPersonal);

  /// Turnos de otros trabajadores en el mismo vehículo ahora mismo
  Future<List<TurnoEntity>> obtenerCompaneros({
    required String idVehiculo,
    required String idPersonalExcluido,
  });

  /// Próximo turno planificado a partir de mañana
  Future<TurnoEntity?> obtenerProximoTurno(String idPersonal);

  /// Crea un turno (desde la app: origen app, sin validar)
  Future<TurnoEntity> crearTurno(TurnoEntity turno);

  /// Actualiza un turno (ej: cambio de vehículo)
  Future<TurnoEntity> actualizarTurno(TurnoEntity turno);

  /// Vehículo por ID
  Future<VehiculoEntity?> obtenerVehiculo(String id);

  /// Vehículos en estado activo (operativos)
  Future<List<VehiculoEntity>> obtenerVehiculosOperativos();

  /// Plantillas de turno activas (Mañana, Tarde, Noche, 12h, 24h...)
  Future<List<PlantillaTurnoEntity>> obtenerPlantillas();
}
