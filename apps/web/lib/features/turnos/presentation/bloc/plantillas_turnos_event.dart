import 'package:ambutrack_core/ambutrack_core.dart';
import 'package:equatable/equatable.dart';

/// Eventos del BLoC de plantillas de turnos
abstract class PlantillasTurnosEvent extends Equatable {
  const PlantillasTurnosEvent();

  @override
  List<Object?> get props => <Object?>[];
}

/// Solicita cargar todas las plantillas
class PlantillasTurnosLoadRequested extends PlantillasTurnosEvent {
  const PlantillasTurnosLoadRequested();
}

/// Solicita refrescar las plantillas
class PlantillasTurnosRefreshRequested extends PlantillasTurnosEvent {
  const PlantillasTurnosRefreshRequested();
}

/// Solicita crear una nueva plantilla
class PlantillaTurnoCreateRequested extends PlantillasTurnosEvent {
  const PlantillaTurnoCreateRequested(this.plantilla);

  final PlantillaTurnoEntity plantilla;

  @override
  List<Object?> get props => <Object?>[plantilla];
}

/// Solicita actualizar una plantilla existente
class PlantillaTurnoUpdateRequested extends PlantillasTurnosEvent {
  const PlantillaTurnoUpdateRequested(this.plantilla);

  final PlantillaTurnoEntity plantilla;

  @override
  List<Object?> get props => <Object?>[plantilla];
}

/// Solicita eliminar una plantilla (soft delete)
class PlantillaTurnoDeleteRequested extends PlantillasTurnosEvent {
  const PlantillaTurnoDeleteRequested(this.id);

  final String id;

  @override
  List<Object?> get props => <Object?>[id];
}

/// Solicita duplicar una plantilla
class PlantillaTurnoDuplicateRequested extends PlantillasTurnosEvent {
  const PlantillaTurnoDuplicateRequested(this.id);

  final String id;

  @override
  List<Object?> get props => <Object?>[id];
}
