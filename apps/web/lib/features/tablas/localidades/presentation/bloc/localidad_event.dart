import 'package:ambutrack_core/ambutrack_core.dart';
import 'package:equatable/equatable.dart';

/// Eventos del BLoC de localidades
abstract class LocalidadEvent extends Equatable {
  const LocalidadEvent();

  @override
  List<Object?> get props => <Object?>[];
}

/// Evento para cargar todas las localidades
class LocalidadLoadAllRequested extends LocalidadEvent {
  const LocalidadLoadAllRequested();
}

/// Evento para crear una localidad
class LocalidadCreateRequested extends LocalidadEvent {
  const LocalidadCreateRequested(this.localidad);

  final LocalidadEntity localidad;

  @override
  List<Object?> get props => <Object?>[localidad];
}

/// Evento para actualizar una localidad
class LocalidadUpdateRequested extends LocalidadEvent {
  const LocalidadUpdateRequested(this.localidad);

  final LocalidadEntity localidad;

  @override
  List<Object?> get props => <Object?>[localidad];
}

/// Evento para eliminar una localidad
class LocalidadDeleteRequested extends LocalidadEvent {
  const LocalidadDeleteRequested(this.id);

  final String id;

  @override
  List<Object?> get props => <Object?>[id];
}
