import 'package:ambutrack_core/ambutrack_core.dart';
import 'package:equatable/equatable.dart';

/// Eventos del BLoC de Excepciones/Festivos
abstract class ExcepcionesFestivosEvent extends Equatable {
  const ExcepcionesFestivosEvent();

  @override
  List<Object?> get props => <Object?>[];
}

/// Evento para cargar todas las excepciones/festivos
class ExcepcionesFestivosLoadRequested extends ExcepcionesFestivosEvent {
  const ExcepcionesFestivosLoadRequested();
}

/// Evento para crear una nueva excepción/festivo
class ExcepcionFestivoCreateRequested extends ExcepcionesFestivosEvent {
  const ExcepcionFestivoCreateRequested(this.item);

  final ExcepcionFestivoEntity item;

  @override
  List<Object?> get props => <Object?>[item];
}

/// Evento para actualizar una excepción/festivo
class ExcepcionFestivoUpdateRequested extends ExcepcionesFestivosEvent {
  const ExcepcionFestivoUpdateRequested(this.item);

  final ExcepcionFestivoEntity item;

  @override
  List<Object?> get props => <Object?>[item];
}

/// Evento para eliminar una excepción/festivo
class ExcepcionFestivoDeleteRequested extends ExcepcionesFestivosEvent {
  const ExcepcionFestivoDeleteRequested(this.id);

  final String id;

  @override
  List<Object?> get props => <Object?>[id];
}

/// Evento para cambiar el estado activo
class ExcepcionFestivoToggleActivoRequested extends ExcepcionesFestivosEvent {
  const ExcepcionFestivoToggleActivoRequested(this.id, {required this.activo});

  final String id;
  final bool activo;

  @override
  List<Object?> get props => <Object?>[id, activo];
}
