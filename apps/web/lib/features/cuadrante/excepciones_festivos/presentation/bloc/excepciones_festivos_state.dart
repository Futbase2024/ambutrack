import 'package:ambutrack_core/ambutrack_core.dart';
import 'package:equatable/equatable.dart';

/// Estados del BLoC de Excepciones/Festivos
abstract class ExcepcionesFestivosState extends Equatable {
  const ExcepcionesFestivosState();

  @override
  List<Object?> get props => <Object?>[];
}

/// Estado inicial
class ExcepcionesFestivosInitial extends ExcepcionesFestivosState {
  const ExcepcionesFestivosInitial();
}

/// Estado de carga
class ExcepcionesFestivosLoading extends ExcepcionesFestivosState {
  const ExcepcionesFestivosLoading();
}

/// Estado con datos cargados
class ExcepcionesFestivosLoaded extends ExcepcionesFestivosState {
  const ExcepcionesFestivosLoaded(this.items);

  final List<ExcepcionFestivoEntity> items;

  @override
  List<Object?> get props => <Object?>[items];
}

/// Estado de error
class ExcepcionesFestivosError extends ExcepcionesFestivosState {
  const ExcepcionesFestivosError(this.message);

  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}

/// Estado de operación exitosa (CREATE, UPDATE, DELETE)
class ExcepcionFestivoOperationSuccess extends ExcepcionesFestivosState {
  const ExcepcionFestivoOperationSuccess(this.items, this.message);

  final List<ExcepcionFestivoEntity> items;
  final String message;

  @override
  List<Object?> get props => <Object?>[items, message];
}
