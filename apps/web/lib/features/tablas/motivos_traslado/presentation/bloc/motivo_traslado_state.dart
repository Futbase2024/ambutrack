import 'package:ambutrack_core/ambutrack_core.dart';
import 'package:equatable/equatable.dart';

/// Estados del BLoC de motivos de traslado
abstract class MotivoTrasladoState extends Equatable {
  /// Constructor
  const MotivoTrasladoState();

  @override
  List<Object?> get props => <Object?>[];
}

/// Estado inicial
class MotivoTrasladoInitial extends MotivoTrasladoState {
  /// Constructor
  const MotivoTrasladoInitial();
}

/// Estado de carga
class MotivoTrasladoLoading extends MotivoTrasladoState {
  /// Constructor
  const MotivoTrasladoLoading();
}

/// Estado con datos cargados
class MotivoTrasladoLoaded extends MotivoTrasladoState {
  /// Constructor
  const MotivoTrasladoLoaded(this.motivos);

  /// Lista de motivos
  final List<MotivoTrasladoEntity> motivos;

  @override
  List<Object?> get props => <Object?>[motivos];
}

/// Estado de error
class MotivoTrasladoError extends MotivoTrasladoState {
  /// Constructor
  const MotivoTrasladoError(this.message);

  /// Mensaje de error
  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}

/// Estado de operación en progreso
class MotivoTrasladoOperationInProgress extends MotivoTrasladoState {
  /// Constructor
  const MotivoTrasladoOperationInProgress(this.motivos);

  /// Lista de motivos actual
  final List<MotivoTrasladoEntity> motivos;

  @override
  List<Object?> get props => <Object?>[motivos];
}

/// Estado de operación exitosa
class MotivoTrasladoOperationSuccess extends MotivoTrasladoState {
  /// Constructor
  const MotivoTrasladoOperationSuccess(this.motivos, this.message);

  /// Lista de motivos actualizada
  final List<MotivoTrasladoEntity> motivos;

  /// Mensaje de éxito
  final String message;

  @override
  List<Object?> get props => <Object?>[motivos, message];
}
