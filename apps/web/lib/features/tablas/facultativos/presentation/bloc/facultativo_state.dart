import 'package:ambutrack_core/ambutrack_core.dart';
import 'package:equatable/equatable.dart';

/// Estados del BLoC de Facultativos
abstract class FacultativoState extends Equatable {
  const FacultativoState();

  @override
  List<Object?> get props => <Object?>[];
}

/// Estado inicial
class FacultativoInitial extends FacultativoState {
  const FacultativoInitial();
}

/// Estado de carga
class FacultativoLoading extends FacultativoState {
  const FacultativoLoading();
}

/// Estado de datos cargados exitosamente
class FacultativoLoaded extends FacultativoState {
  const FacultativoLoaded(this.facultativos);

  final List<FacultativoEntity> facultativos;

  @override
  List<Object?> get props => <Object?>[facultativos];
}

/// Estado de error
class FacultativoError extends FacultativoState {
  const FacultativoError(this.message);

  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}
