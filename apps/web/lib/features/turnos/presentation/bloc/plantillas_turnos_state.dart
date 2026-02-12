import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:equatable/equatable.dart';

/// Estados del BLoC de plantillas de turnos
abstract class PlantillasTurnosState extends Equatable {
  const PlantillasTurnosState();

  @override
  List<Object?> get props => <Object?>[];
}

/// Estado inicial
class PlantillasTurnosInitial extends PlantillasTurnosState {
  const PlantillasTurnosInitial();
}

/// Estado de carga
class PlantillasTurnosLoading extends PlantillasTurnosState {
  const PlantillasTurnosLoading();
}

/// Estado con plantillas cargadas
class PlantillasTurnosLoaded extends PlantillasTurnosState {
  const PlantillasTurnosLoaded(this.plantillas);

  final List<PlantillaTurnoEntity> plantillas;

  @override
  List<Object?> get props => <Object?>[plantillas];
}

/// Estado de error
class PlantillasTurnosError extends PlantillasTurnosState {
  const PlantillasTurnosError(this.message);

  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}

/// Estado cuando se crea exitosamente
class PlantillaTurnoCreated extends PlantillasTurnosState {
  const PlantillaTurnoCreated(this.plantilla);

  final PlantillaTurnoEntity plantilla;

  @override
  List<Object?> get props => <Object?>[plantilla];
}

/// Estado cuando se actualiza exitosamente
class PlantillaTurnoUpdated extends PlantillasTurnosState {
  const PlantillaTurnoUpdated(this.plantilla);

  final PlantillaTurnoEntity plantilla;

  @override
  List<Object?> get props => <Object?>[plantilla];
}

/// Estado cuando se elimina exitosamente
class PlantillaTurnoDeleted extends PlantillasTurnosState {
  const PlantillaTurnoDeleted(this.id);

  final String id;

  @override
  List<Object?> get props => <Object?>[id];
}

/// Estado cuando se duplica exitosamente
class PlantillaTurnoDuplicated extends PlantillasTurnosState {
  const PlantillaTurnoDuplicated(this.plantilla);

  final PlantillaTurnoEntity plantilla;

  @override
  List<Object?> get props => <Object?>[plantilla];
}
