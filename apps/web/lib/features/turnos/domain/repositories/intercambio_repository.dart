import 'package:ambutrack_core/ambutrack_core.dart';

/// Repositorio para gestión de intercambios de turnos
abstract class IntercambioRepository {
  /// Obtiene todas las solicitudes de intercambio
  Future<List<SolicitudIntercambioEntity>> getAll();

  /// Obtiene solicitudes pendientes de aprobación de un trabajador específico
  Future<List<SolicitudIntercambioEntity>> getPendientesPorTrabajador(
    String idPersonal,
  );

  /// Obtiene solicitudes pendientes de aprobación de responsable
  Future<List<SolicitudIntercambioEntity>> getPendientesResponsable();

  /// Obtiene historial de intercambios de un trabajador
  Future<List<SolicitudIntercambioEntity>> getHistorialPorPersonal(
    String idPersonal,
  );

  /// Crea una nueva solicitud de intercambio
  Future<void> create(SolicitudIntercambioEntity solicitud);

  /// Actualiza una solicitud existente
  Future<void> update(SolicitudIntercambioEntity solicitud);

  /// Elimina una solicitud (solo si está pendiente)
  Future<void> delete(String id);

  /// Aprueba solicitud por parte del trabajador destino
  Future<void> aprobarPorTrabajador({
    required String idSolicitud,
    required String idPersonal,
  });

  /// Rechaza solicitud por parte del trabajador destino
  Future<void> rechazarPorTrabajador({
    required String idSolicitud,
    required String idPersonal,
    String? motivoRechazo,
  });

  /// Aprueba solicitud por parte del responsable
  Future<void> aprobarPorResponsable({
    required String idSolicitud,
    required String idResponsable,
    required String nombreResponsable,
  });

  /// Rechaza solicitud por parte del responsable
  Future<void> rechazarPorResponsable({
    required String idSolicitud,
    required String idResponsable,
    required String nombreResponsable,
    String? motivoRechazo,
  });

  /// Cancela una solicitud por parte del solicitante
  Future<void> cancelar(String idSolicitud);

  /// Ejecuta el intercambio de turnos (actualiza idPersonal en ambos turnos)
  Future<void> ejecutarIntercambio({
    required String idTurno1,
    required String idTurno2,
    required String idPersonal1,
    required String idPersonal2,
  });
}
