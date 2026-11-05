import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:equatable/equatable.dart';

/// Estados del ProveedorTallerBloc
abstract class ProveedorTallerState extends Equatable {
  const ProveedorTallerState();

  @override
  List<Object?> get props => <Object?>[];
}

/// Estado inicial
class ProveedorTallerInitial extends ProveedorTallerState {
  const ProveedorTallerInitial();
}

/// Estado de carga
class ProveedorTallerLoading extends ProveedorTallerState {
  const ProveedorTallerLoading();
}

/// Estado con datos cargados
class ProveedorTallerLoaded extends ProveedorTallerState {
  const ProveedorTallerLoaded({required this.proveedores});

  final List<ProveedorTallerEntity> proveedores;

  @override
  List<Object?> get props => <Object?>[proveedores];
}

/// Estado de error
class ProveedorTallerError extends ProveedorTallerState {
  const ProveedorTallerError({required this.message});

  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}
