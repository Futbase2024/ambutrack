import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:equatable/equatable.dart';

abstract class CategoriaVehiculoEvent extends Equatable {
  const CategoriaVehiculoEvent();
  @override
  List<Object?> get props => <Object?>[];
}

class CategoriaVehiculoLoadAllRequested extends CategoriaVehiculoEvent {
  const CategoriaVehiculoLoadAllRequested();
}

class CategoriaVehiculoCreateRequested extends CategoriaVehiculoEvent {
  const CategoriaVehiculoCreateRequested(this.categoria);
  final CategoriaVehiculoEntity categoria;
  @override
  List<Object?> get props => <Object?>[categoria];
}

class CategoriaVehiculoUpdateRequested extends CategoriaVehiculoEvent {
  const CategoriaVehiculoUpdateRequested(this.categoria);
  final CategoriaVehiculoEntity categoria;
  @override
  List<Object?> get props => <Object?>[categoria];
}

class CategoriaVehiculoDeleteRequested extends CategoriaVehiculoEvent {
  const CategoriaVehiculoDeleteRequested(this.id);
  final String id;
  @override
  List<Object?> get props => <Object?>[id];
}
