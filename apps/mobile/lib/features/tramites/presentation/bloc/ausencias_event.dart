import 'package:ambutrack_core/ambutrack_core.dart';
import 'package:equatable/equatable.dart';

/// Eventos del BLoC de ausencias.
sealed class AusenciasEvent extends Equatable {
  const AusenciasEvent();

  @override
  List<Object?> get props => [];
}

/// Cargar todas las ausencias.
final class AusenciasLoadRequested extends AusenciasEvent {
  const AusenciasLoadRequested();
}

/// Cargar ausencias de un personal específico.
final class AusenciasLoadByPersonalRequested extends AusenciasEvent {
  const AusenciasLoadByPersonalRequested(this.idPersonal);

  final String idPersonal;

  @override
  List<Object?> get props => [idPersonal];
}

/// Cargar ausencias por estado.
final class AusenciasLoadByEstadoRequested extends AusenciasEvent {
  const AusenciasLoadByEstadoRequested(this.estado);

  final EstadoAusencia estado;

  @override
  List<Object?> get props => [estado];
}

/// Cargar ausencias en un rango de fechas.
final class AusenciasLoadByRangoFechasRequested extends AusenciasEvent {
  const AusenciasLoadByRangoFechasRequested({
    required this.fechaInicio,
    required this.fechaFin,
  });

  final DateTime fechaInicio;
  final DateTime fechaFin;

  @override
  List<Object?> get props => [fechaInicio, fechaFin];
}

/// Crear una nueva solicitud de ausencia.
final class AusenciaCreateRequested extends AusenciasEvent {
  const AusenciaCreateRequested(this.ausencia);

  final AusenciaEntity ausencia;

  @override
  List<Object?> get props => [ausencia];
}

/// Actualizar una solicitud de ausencia.
final class AusenciaUpdateRequested extends AusenciasEvent {
  const AusenciaUpdateRequested(this.ausencia);

  final AusenciaEntity ausencia;

  @override
  List<Object?> get props => [ausencia];
}

/// Eliminar/Cancelar una solicitud de ausencia.
final class AusenciaDeleteRequested extends AusenciasEvent {
  const AusenciaDeleteRequested(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}

/// Cargar tipos de ausencias.
final class TiposAusenciaLoadRequested extends AusenciasEvent {
  const TiposAusenciaLoadRequested();
}

/// Observar ausencias en tiempo real.
final class AusenciasWatchRequested extends AusenciasEvent {
  const AusenciasWatchRequested();
}

/// Observar ausencias de un personal en tiempo real.
final class AusenciasWatchByPersonalRequested extends AusenciasEvent {
  const AusenciasWatchByPersonalRequested(this.idPersonal);

  final String idPersonal;

  @override
  List<Object?> get props => [idPersonal];
}
