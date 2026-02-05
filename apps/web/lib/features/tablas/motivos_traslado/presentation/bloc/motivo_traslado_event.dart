import 'package:ambutrack_core/ambutrack_core.dart';
import 'package:equatable/equatable.dart';

/// Eventos del BLoC de motivos de traslado
abstract class MotivoTrasladoEvent extends Equatable {
  /// Constructor
  const MotivoTrasladoEvent();

  @override
  List<Object?> get props => <Object?>[];
}

/// Evento para cargar todos los motivos de traslado
class MotivoTrasladoLoadAllRequested extends MotivoTrasladoEvent {
  /// Constructor
  const MotivoTrasladoLoadAllRequested();
}

/// Evento para crear un motivo de traslado
class MotivoTrasladoCreateRequested extends MotivoTrasladoEvent {
  /// Constructor
  const MotivoTrasladoCreateRequested(this.motivo);

  /// Motivo a crear
  final MotivoTrasladoEntity motivo;

  @override
  List<Object?> get props => <Object?>[motivo];
}

/// Evento para actualizar un motivo de traslado
class MotivoTrasladoUpdateRequested extends MotivoTrasladoEvent {
  /// Constructor
  const MotivoTrasladoUpdateRequested(this.motivo);

  /// Motivo a actualizar
  final MotivoTrasladoEntity motivo;

  @override
  List<Object?> get props => <Object?>[motivo];
}

/// Evento para eliminar un motivo de traslado
class MotivoTrasladoDeleteRequested extends MotivoTrasladoEvent {
  /// Constructor
  const MotivoTrasladoDeleteRequested(this.id);

  /// ID del motivo a eliminar
  final String id;

  @override
  List<Object?> get props => <Object?>[id];
}

/// Evento para suscribirse a cambios en tiempo real
class MotivoTrasladoSubscribeRequested extends MotivoTrasladoEvent {
  /// Constructor
  const MotivoTrasladoSubscribeRequested();
}

/// Evento para actualizar desde el stream
class MotivoTrasladoStreamUpdated extends MotivoTrasladoEvent {
  /// Constructor
  const MotivoTrasladoStreamUpdated(this.motivos);

  /// Lista de motivos actualizada
  final List<MotivoTrasladoEntity> motivos;

  @override
  List<Object?> get props => <Object?>[motivos];
}
