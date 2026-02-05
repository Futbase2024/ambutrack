import 'package:ambutrack_core/ambutrack_core.dart';
import 'package:equatable/equatable.dart';

abstract class CategoriaVehiculoState extends Equatable {
  const CategoriaVehiculoState();
  @override
  List<Object?> get props => <Object?>[];
}

class CategoriaVehiculoInitial extends CategoriaVehiculoState {
  const CategoriaVehiculoInitial();
}

class CategoriaVehiculoLoading extends CategoriaVehiculoState {
  const CategoriaVehiculoLoading();
}

class CategoriaVehiculoLoaded extends CategoriaVehiculoState {
  const CategoriaVehiculoLoaded(this.categorias);
  final List<CategoriaVehiculoEntity> categorias;
  @override
  List<Object?> get props => <Object?>[categorias];
}

class CategoriaVehiculoError extends CategoriaVehiculoState {
  const CategoriaVehiculoError(this.message);
  final String message;
  @override
  List<Object?> get props => <Object?>[message];
}
