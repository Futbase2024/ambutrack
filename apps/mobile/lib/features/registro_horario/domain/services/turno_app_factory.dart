import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:uuid/uuid.dart';

/// Crea turnos desde la app (sin turno planificado en el cuadrante)
class TurnoAppFactory {
  const TurnoAppFactory._();

  /// Construye el turno creado desde la app a partir de una plantilla.
  ///
  /// Si el turno de hoy aún no ha empezado pero el de ayer sigue en curso
  /// (ej: noche 23:00-07:00 fichando a las 00:30) se usa el de ayer.
  static TurnoEntity desdePlantilla(
    TPersonalEntity personal,
    PlantillaTurnoEntity plantilla,
    String idVehiculo,
  ) {
    final DateTime ahora = DateTime.now();
    final DateTime hoy = DateTime(ahora.year, ahora.month, ahora.day);
    final String nombre = '${personal.nombre} ${personal.apellidos}'.trim().toUpperCase();

    TurnoEntity turnoDel(DateTime dia) => TurnoEntity(
          id: const Uuid().v4(),
          idPersonal: personal.id,
          nombrePersonal: nombre,
          tipoTurno: plantilla.tipoTurno,
          fechaInicio: dia,
          fechaFin: dia,
          horaInicio: plantilla.horaInicio,
          horaFin: plantilla.horaFin,
          idContrato: personal.contratoId,
          idBase: personal.baseId,
          categoriaPersonal: personal.categoria,
          idVehiculo: idVehiculo,
          idDotacion: personal.dotacionId,
          observaciones: 'Creado desde la app al iniciar turno (${plantilla.nombre})',
          origen: OrigenTurno.app,
          validado: false,
        );

    TurnoEntity turno = turnoDel(hoy);
    final TurnoEntity deAyer = turnoDel(hoy.subtract(const Duration(days: 1)));
    if (turno.inicioReal.subtract(const Duration(hours: 1)).isAfter(ahora) &&
        deAyer.finReal.isAfter(ahora)) {
      turno = deAyer;
    }
    // En UTC: un DateTime local sin offset se guardaría como UTC en BD
    return turno.copyWith(fechaInicio: turno.inicioReal.toUtc(), fechaFin: turno.finReal.toUtc());
  }
}
