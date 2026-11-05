import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:equatable/equatable.dart';

/// Estados del TallerBloc
abstract class TallerState extends Equatable {
  const TallerState();

  @override
  List<Object?> get props => <Object?>[];
}

/// Estado inicial
class TallerInitial extends TallerState {
  const TallerInitial();
}

/// Estado de carga
class TallerLoading extends TallerState {
  const TallerLoading();
}

/// Estado con datos cargados
class TallerLoaded extends TallerState {
  const TallerLoaded({required this.talleres});

  final List<TallerEntity> talleres;

  @override
  List<Object?> get props => <Object?>[talleres];
}

/// Estado de error
class TallerError extends TallerState {
  const TallerError({required this.message});

  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}
