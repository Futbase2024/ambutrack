import 'package:ambutrack_core/ambutrack_core.dart';
import 'package:equatable/equatable.dart';

/// Estados del BLoC de Historial Médico
sealed class HistorialMedicoState extends Equatable {
  const HistorialMedicoState();

  @override
  List<Object?> get props => <Object?>[];
}

/// Estado inicial
final class HistorialMedicoInitial extends HistorialMedicoState {
  const HistorialMedicoInitial();
}

/// Estado de carga
final class HistorialMedicoLoading extends HistorialMedicoState {
  const HistorialMedicoLoading();
}

/// Estado de datos cargados exitosamente
final class HistorialMedicoLoaded extends HistorialMedicoState {
  const HistorialMedicoLoaded(this.items);

  final List<HistorialMedicoEntity> items;

  @override
  List<Object?> get props => <Object?>[items];
}

/// Estado de error
final class HistorialMedicoError extends HistorialMedicoState {
  const HistorialMedicoError(this.message);

  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}
