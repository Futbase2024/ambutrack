import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:equatable/equatable.dart';

/// Eventos del BLoC de plantillas de equipamiento
abstract class PlantillasEquipamientoEvent extends Equatable {
  const PlantillasEquipamientoEvent();

  @override
  List<Object?> get props => <Object?>[];
}

/// Carga las plantillas y los items de la plantilla seleccionada
class PlantillasLoadRequested extends PlantillasEquipamientoEvent {
  const PlantillasLoadRequested();
}

/// Cambia la plantilla seleccionada
class PlantillaSelected extends PlantillasEquipamientoEvent {
  const PlantillaSelected(this.plantillaId);

  final String plantillaId;

  @override
  List<Object?> get props => <Object?>[plantillaId];
}

/// Crea o actualiza una plantilla
class PlantillaSaveRequested extends PlantillasEquipamientoEvent {
  const PlantillaSaveRequested(this.plantilla, {required this.esNueva});

  final PlantillaEquipamientoEntity plantilla;
  final bool esNueva;

  @override
  List<Object?> get props => <Object?>[plantilla, esNueva];
}

/// Elimina una plantilla
class PlantillaDeleteRequested extends PlantillasEquipamientoEvent {
  const PlantillaDeleteRequested(this.plantillaId);

  final String plantillaId;

  @override
  List<Object?> get props => <Object?>[plantillaId];
}

/// Reaplica la plantilla seleccionada a todos sus vehículos
class PlantillaReaplicarRequested extends PlantillasEquipamientoEvent {
  const PlantillaReaplicarRequested();
}

/// Crea o actualiza un item
class PlantillaItemSaveRequested extends PlantillasEquipamientoEvent {
  const PlantillaItemSaveRequested(this.item, {required this.esNuevo});

  final PlantillaEquipamientoItemEntity item;
  final bool esNuevo;

  @override
  List<Object?> get props => <Object?>[item, esNuevo];
}

/// Activa o desactiva un item
class PlantillaItemActivoRequested extends PlantillasEquipamientoEvent {
  const PlantillaItemActivoRequested({required this.itemId, required this.activo});

  final String itemId;
  final bool activo;

  @override
  List<Object?> get props => <Object?>[itemId, activo];
}

/// Elimina un item definitivamente
class PlantillaItemDeleteRequested extends PlantillasEquipamientoEvent {
  const PlantillaItemDeleteRequested(this.itemId);

  final String itemId;

  @override
  List<Object?> get props => <Object?>[itemId];
}
