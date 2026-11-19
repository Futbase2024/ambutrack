import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:equatable/equatable.dart';

/// Estados del BLoC de evaluaciones de desempeño
sealed class EvaluacionDesempenoState extends Equatable {
  const EvaluacionDesempenoState();

  @override
  List<Object?> get props => <Object?>[];
}

/// Estado inicial
final class EvaluacionDesempenoInitial extends EvaluacionDesempenoState {
  const EvaluacionDesempenoInitial();
}

/// Cargando
final class EvaluacionDesempenoLoading extends EvaluacionDesempenoState {
  const EvaluacionDesempenoLoading();
}

/// Datos cargados
final class EvaluacionDesempenoLoaded extends EvaluacionDesempenoState {
  const EvaluacionDesempenoLoaded(this.items);

  final List<EvaluacionDesempenoEntity> items;

  @override
  List<Object?> get props => <Object?>[items];
}

/// Error en carga u operación
final class EvaluacionDesempenoError extends EvaluacionDesempenoState {
  const EvaluacionDesempenoError(this.message);

  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}
