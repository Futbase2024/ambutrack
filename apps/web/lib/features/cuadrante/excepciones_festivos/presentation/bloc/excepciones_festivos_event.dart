import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:equatable/equatable.dart';

/// Eventos del BLoC de Excepciones/Festivos
abstract class ExcepcionesFestivosEvent extends Equatable {
  const ExcepcionesFestivosEvent();

  @override
  List<Object?> get props => <Object?>[];
}

/// Cargar todas las excepciones/festivos
class ExcepcionesFestivosLoadRequested extends ExcepcionesFestivosEvent {
  const ExcepcionesFestivosLoadRequested();
}

/// Crear una nueva excepción/festivo
class ExcepcionFestivoCreateRequested extends ExcepcionesFestivosEvent {
  const ExcepcionFestivoCreateRequested(this.item);

  final ExcepcionFestivoEntity item;

  @override
  List<Object?> get props => <Object?>[item];
}

/// Actualizar una excepción/festivo
class ExcepcionFestivoUpdateRequested extends ExcepcionesFestivosEvent {
  const ExcepcionFestivoUpdateRequested(this.item);

  final ExcepcionFestivoEntity item;

  @override
  List<Object?> get props => <Object?>[item];
}

/// Eliminar una excepción/festivo
class ExcepcionFestivoDeleteRequested extends ExcepcionesFestivosEvent {
  const ExcepcionFestivoDeleteRequested(this.id);

  final String id;

  @override
  List<Object?> get props => <Object?>[id];
}
