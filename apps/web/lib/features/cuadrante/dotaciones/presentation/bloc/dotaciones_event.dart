import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:equatable/equatable.dart';

/// Eventos del BLoC de Dotaciones
abstract class DotacionesEvent extends Equatable {
  const DotacionesEvent();

  @override
  List<Object?> get props => <Object?>[];
}

/// Cargar todas las dotaciones
class DotacionesLoadRequested extends DotacionesEvent {
  const DotacionesLoadRequested();
}

/// Refrescar datos (sin emitir Loading inicial)
class DotacionesRefreshRequested extends DotacionesEvent {
  const DotacionesRefreshRequested();
}

/// Crear una nueva dotación
class DotacionCreateRequested extends DotacionesEvent {
  const DotacionCreateRequested(this.dotacion);

  final DotacionEntity dotacion;

  @override
  List<Object?> get props => <Object?>[dotacion];
}

/// Actualizar una dotación existente
class DotacionUpdateRequested extends DotacionesEvent {
  const DotacionUpdateRequested(this.dotacion);

  final DotacionEntity dotacion;

  @override
  List<Object?> get props => <Object?>[dotacion];
}

/// Eliminar una dotación
class DotacionDeleteRequested extends DotacionesEvent {
  const DotacionDeleteRequested(this.dotacionId);

  final String dotacionId;

  @override
  List<Object?> get props => <Object?>[dotacionId];
}
