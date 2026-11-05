import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:equatable/equatable.dart';

/// Eventos del BLoC de Agenda de Pendientes
abstract class AgendaPendienteEvent extends Equatable {
  const AgendaPendienteEvent();

  @override
  List<Object?> get props => <Object?>[];
}

/// Cargar todos los pendientes de la empresa
class AgendaPendienteLoadRequested extends AgendaPendienteEvent {
  const AgendaPendienteLoadRequested({required this.empresaId});

  final String empresaId;

  @override
  List<Object?> get props => <Object?>[empresaId];
}

/// Cargar los pendientes de hoy para el banner del dashboard
class AgendaPendienteLoadHoyRequested extends AgendaPendienteEvent {
  const AgendaPendienteLoadHoyRequested({required this.empresaId});

  final String empresaId;

  @override
  List<Object?> get props => <Object?>[empresaId];
}

/// Crear un nuevo pendiente
class AgendaPendienteCreateRequested extends AgendaPendienteEvent {
  const AgendaPendienteCreateRequested({required this.pendiente});

  final AgendaPendienteEntity pendiente;

  @override
  List<Object?> get props => <Object?>[pendiente];
}

/// Actualizar un pendiente existente
class AgendaPendienteUpdateRequested extends AgendaPendienteEvent {
  const AgendaPendienteUpdateRequested({required this.pendiente});

  final AgendaPendienteEntity pendiente;

  @override
  List<Object?> get props => <Object?>[pendiente];
}

/// Eliminar un pendiente
class AgendaPendienteDeleteRequested extends AgendaPendienteEvent {
  const AgendaPendienteDeleteRequested({required this.id});

  final String id;

  @override
  List<Object?> get props => <Object?>[id];
}

/// Toggle completado/pendiente
class AgendaPendienteCompletadoToggled extends AgendaPendienteEvent {
  const AgendaPendienteCompletadoToggled({
    required this.id,
    required this.completado,
  });

  final String id;
  final bool completado;

  @override
  List<Object?> get props => <Object?>[id, completado];
}

/// Cambiar filtro de búsqueda
class AgendaPendienteSearchChanged extends AgendaPendienteEvent {
  const AgendaPendienteSearchChanged({required this.query});

  final String query;

  @override
  List<Object?> get props => <Object?>[query];
}

/// Actualización recibida vía suscripción en tiempo real
class AgendaPendienteRealtimeUpdated extends AgendaPendienteEvent {
  const AgendaPendienteRealtimeUpdated({required this.pendientesHoy});

  final List<AgendaPendienteEntity> pendientesHoy;

  @override
  List<Object?> get props => <Object?>[pendientesHoy];
}
