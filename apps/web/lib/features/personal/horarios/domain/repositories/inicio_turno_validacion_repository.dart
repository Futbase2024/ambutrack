import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';

/// Repositorio de validación de inicios de turno por coordinación
///
/// Usa la entidad del core: InicioTurnoEntity
abstract class InicioTurnoValidacionRepository {
  /// Inicios de turno en un rango de fechas (más recientes primero)
  Future<List<InicioTurnoEntity>> getByRango({required DateTime desde, required DateTime hasta});

  /// Inicios de turno pendientes de validar
  Future<List<InicioTurnoEntity>> getPendientesValidacion();

  /// Aprueba o rechaza un inicio de turno pendiente
  Future<InicioTurnoEntity> validar({required String id, required bool aprobado, String? motivoRechazo});

  /// URL firmada temporal (1 h) de la foto del cuentakilómetros
  Future<String> getUrlFotoKm(String ruta);
}
