import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:equatable/equatable.dart';

/// Eventos del ProveedorTallerBloc
abstract class ProveedorTallerEvent extends Equatable {
  const ProveedorTallerEvent();

  @override
  List<Object?> get props => <Object?>[];
}

/// Cargar todos los proveedores
class ProveedorTallerLoadRequested extends ProveedorTallerEvent {
  const ProveedorTallerLoadRequested();
}

/// Crear un nuevo proveedor
class ProveedorTallerCreateRequested extends ProveedorTallerEvent {
  const ProveedorTallerCreateRequested({required this.proveedor});

  final ProveedorTallerEntity proveedor;

  @override
  List<Object?> get props => <Object?>[proveedor];
}

/// Actualizar un proveedor
class ProveedorTallerUpdateRequested extends ProveedorTallerEvent {
  const ProveedorTallerUpdateRequested({required this.proveedor});

  final ProveedorTallerEntity proveedor;

  @override
  List<Object?> get props => <Object?>[proveedor];
}

/// Eliminar un proveedor
class ProveedorTallerDeleteRequested extends ProveedorTallerEvent {
  const ProveedorTallerDeleteRequested({required this.id});

  final String id;

  @override
  List<Object?> get props => <Object?>[id];
}
