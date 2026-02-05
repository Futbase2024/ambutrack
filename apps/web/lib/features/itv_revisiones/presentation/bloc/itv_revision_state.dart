import 'package:ambutrack_core/ambutrack_core.dart';
import 'package:equatable/equatable.dart';

/// Estados de ITV/Revisiones
abstract class ItvRevisionState extends Equatable {
  const ItvRevisionState();

  @override
  List<Object?> get props => <Object?>[];
}

/// Estado inicial
class ItvRevisionInitial extends ItvRevisionState {
  const ItvRevisionInitial();
}

/// Estado de carga
class ItvRevisionLoading extends ItvRevisionState {
  const ItvRevisionLoading();
}

/// Estado de datos cargados
class ItvRevisionLoaded extends ItvRevisionState {
  const ItvRevisionLoaded({required this.itvRevisiones});

  final List<ItvRevisionEntity> itvRevisiones;

  @override
  List<Object?> get props => <Object?>[itvRevisiones];
}

/// Estado de operación exitosa
class ItvRevisionOperationSuccess extends ItvRevisionState {
  const ItvRevisionOperationSuccess({required this.message});

  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}

/// Estado de error
class ItvRevisionError extends ItvRevisionState {
  const ItvRevisionError({required this.message});

  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}
