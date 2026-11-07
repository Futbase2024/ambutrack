import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:equatable/equatable.dart';

/// Estados del BLoC de equipamiento personal
sealed class EquipamientoPersonalState extends Equatable {
  const EquipamientoPersonalState();

  @override
  List<Object?> get props => <Object?>[];
}

/// Estado inicial
final class EquipamientoPersonalInitial extends EquipamientoPersonalState {
  const EquipamientoPersonalInitial();
}

/// Estado de carga
final class EquipamientoPersonalLoading extends EquipamientoPersonalState {
  const EquipamientoPersonalLoading();
}

/// Estado de carga exitosa
final class EquipamientoPersonalLoaded extends EquipamientoPersonalState {
  const EquipamientoPersonalLoaded(this.items);

  final List<EquipamientoPersonalEntity> items;

  @override
  List<Object?> get props => <Object?>[items];
}

/// Estado de error
final class EquipamientoPersonalError extends EquipamientoPersonalState {
  const EquipamientoPersonalError(this.message);

  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}
