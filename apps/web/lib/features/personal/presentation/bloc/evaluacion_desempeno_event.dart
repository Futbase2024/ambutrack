import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:equatable/equatable.dart';

/// Eventos del BLoC de evaluaciones de desempeño
sealed class EvaluacionDesempenoEvent extends Equatable {
  const EvaluacionDesempenoEvent();

  @override
  List<Object?> get props => <Object?>[];
}

/// Solicita cargar todos los registros
final class EvaluacionDesempenoLoadRequested extends EvaluacionDesempenoEvent {
  const EvaluacionDesempenoLoadRequested();
}

/// Solicita crear un registro
final class EvaluacionDesempenoCreateRequested extends EvaluacionDesempenoEvent {
  const EvaluacionDesempenoCreateRequested(this.entity);

  final EvaluacionDesempenoEntity entity;

  @override
  List<Object?> get props => <Object?>[entity];
}

/// Solicita actualizar un registro
final class EvaluacionDesempenoUpdateRequested extends EvaluacionDesempenoEvent {
  const EvaluacionDesempenoUpdateRequested(this.entity);

  final EvaluacionDesempenoEntity entity;

  @override
  List<Object?> get props => <Object?>[entity];
}

/// Solicita eliminar un registro
final class EvaluacionDesempenoDeleteRequested extends EvaluacionDesempenoEvent {
  const EvaluacionDesempenoDeleteRequested(this.id);

  final String id;

  @override
  List<Object?> get props => <Object?>[id];
}
