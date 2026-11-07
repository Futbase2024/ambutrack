import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:equatable/equatable.dart';

/// Eventos del BLoC de intercambios
abstract class IntercambiosEvent extends Equatable {
  const IntercambiosEvent();

  @override
  List<Object?> get props => <Object?>[];
}

/// Evento para cargar todas las solicitudes
class IntercambiosLoadRequested extends IntercambiosEvent {
  const IntercambiosLoadRequested();
}

/// Evento para cargar solicitudes pendientes de un trabajador
class IntercambiosPendientesTrabajadorRequested extends IntercambiosEvent {
  const IntercambiosPendientesTrabajadorRequested(this.idPersonal);

  final String idPersonal;

  @override
  List<Object?> get props => <Object?>[idPersonal];
}

/// Evento para cargar solicitudes pendientes de responsable
class IntercambiosPendientesResponsableRequested extends IntercambiosEvent {
  const IntercambiosPendientesResponsableRequested();
}

/// Evento para crear nueva solicitud
class IntercambioCreateRequested extends IntercambiosEvent {
  const IntercambioCreateRequested(this.solicitud);

  final SolicitudIntercambioEntity solicitud;

  @override
  List<Object?> get props => <Object?>[solicitud];
}

/// Evento para aprobar solicitud por trabajador
class IntercambioAprobarPorTrabajadorRequested extends IntercambiosEvent {
  const IntercambioAprobarPorTrabajadorRequested({
    required this.idSolicitud,
    required this.idPersonal,
  });

  final String idSolicitud;
  final String idPersonal;

  @override
  List<Object?> get props => <Object?>[idSolicitud, idPersonal];
}

/// Evento para rechazar solicitud por trabajador
class IntercambioRechazarPorTrabajadorRequested extends IntercambiosEvent {
  const IntercambioRechazarPorTrabajadorRequested({
    required this.idSolicitud,
    required this.idPersonal,
    this.motivoRechazo,
  });

  final String idSolicitud;
  final String idPersonal;
  final String? motivoRechazo;

  @override
  List<Object?> get props => <Object?>[idSolicitud, idPersonal, motivoRechazo];
}

/// Evento para aprobar solicitud por responsable
class IntercambioAprobarPorResponsableRequested extends IntercambiosEvent {
  const IntercambioAprobarPorResponsableRequested({
    required this.idSolicitud,
    required this.idResponsable,
    required this.nombreResponsable,
  });

  final String idSolicitud;
  final String idResponsable;
  final String nombreResponsable;

  @override
  List<Object?> get props => <Object?>[
        idSolicitud,
        idResponsable,
        nombreResponsable,
      ];
}

/// Evento para rechazar solicitud por responsable
class IntercambioRechazarPorResponsableRequested extends IntercambiosEvent {
  const IntercambioRechazarPorResponsableRequested({
    required this.idSolicitud,
    required this.idResponsable,
    required this.nombreResponsable,
    this.motivoRechazo,
  });

  final String idSolicitud;
  final String idResponsable;
  final String nombreResponsable;
  final String? motivoRechazo;

  @override
  List<Object?> get props => <Object?>[
        idSolicitud,
        idResponsable,
        nombreResponsable,
        motivoRechazo,
      ];
}

/// Evento para cancelar solicitud
class IntercambioCancelarRequested extends IntercambiosEvent {
  const IntercambioCancelarRequested(this.idSolicitud);

  final String idSolicitud;

  @override
  List<Object?> get props => <Object?>[idSolicitud];
}

/// Evento para refrescar la lista
class IntercambiosRefreshRequested extends IntercambiosEvent {
  const IntercambiosRefreshRequested();
}
