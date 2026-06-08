import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:equatable/equatable.dart';

/// Estados del BLoC de Bases
abstract class BasesState extends Equatable {
  const BasesState();

  @override
  List<Object?> get props => <Object?>[];
}

/// Estado inicial
class BasesInitial extends BasesState {
  const BasesInitial();
}

/// Estado de carga
class BasesLoading extends BasesState {
  const BasesLoading();
}

/// Estado con datos cargados
class BasesLoaded extends BasesState {
  const BasesLoaded(this.bases);

  final List<BaseCentroEntity> bases;

  @override
  List<Object?> get props => <Object?>[bases];
}

/// Estado de error
class BasesError extends BasesState {
  const BasesError(this.message);

  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}
