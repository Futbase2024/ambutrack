import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:equatable/equatable.dart';

/// Eventos del BLoC de Historial Médico
sealed class HistorialMedicoEvent extends Equatable {
  const HistorialMedicoEvent();

  @override
  List<Object?> get props => <Object?>[];
}

/// Evento para cargar todos los registros
final class HistorialMedicoLoadRequested extends HistorialMedicoEvent {
  const HistorialMedicoLoadRequested();
}

/// Evento para cargar historial de un personal específico
final class HistorialMedicoLoadByPersonalRequested extends HistorialMedicoEvent {
  const HistorialMedicoLoadByPersonalRequested(this.personalId);

  final String personalId;

  @override
  List<Object?> get props => <Object?>[personalId];
}

/// Evento para cargar reconocimientos próximos a caducar
final class HistorialMedicoLoadProximosACaducarRequested extends HistorialMedicoEvent {
  const HistorialMedicoLoadProximosACaducarRequested();
}

/// Evento para cargar reconocimientos caducados
final class HistorialMedicoLoadCaducadosRequested extends HistorialMedicoEvent {
  const HistorialMedicoLoadCaducadosRequested();
}

/// Evento para crear un nuevo registro
final class HistorialMedicoCreateRequested extends HistorialMedicoEvent {
  const HistorialMedicoCreateRequested(this.entity);

  final HistorialMedicoEntity entity;

  @override
  List<Object?> get props => <Object?>[entity];
}

/// Evento para actualizar un registro
final class HistorialMedicoUpdateRequested extends HistorialMedicoEvent {
  const HistorialMedicoUpdateRequested(this.entity);

  final HistorialMedicoEntity entity;

  @override
  List<Object?> get props => <Object?>[entity];
}

/// Evento para eliminar un registro
final class HistorialMedicoDeleteRequested extends HistorialMedicoEvent {
  const HistorialMedicoDeleteRequested(this.id);

  final String id;

  @override
  List<Object?> get props => <Object?>[id];
}
