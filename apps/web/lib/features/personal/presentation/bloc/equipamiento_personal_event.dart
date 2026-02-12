import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:equatable/equatable.dart';

/// Eventos del BLoC de equipamiento personal
sealed class EquipamientoPersonalEvent extends Equatable {
  const EquipamientoPersonalEvent();

  @override
  List<Object?> get props => <Object?>[];
}

/// Solicita cargar todos los registros
final class EquipamientoPersonalLoadRequested extends EquipamientoPersonalEvent {
  const EquipamientoPersonalLoadRequested();
}

/// Solicita cargar por personal
final class EquipamientoPersonalLoadByPersonalRequested extends EquipamientoPersonalEvent {
  const EquipamientoPersonalLoadByPersonalRequested(this.personalId);

  final String personalId;

  @override
  List<Object?> get props => <Object?>[personalId];
}

/// Solicita cargar equipamiento asignado
final class EquipamientoPersonalLoadAsignadoRequested extends EquipamientoPersonalEvent {
  const EquipamientoPersonalLoadAsignadoRequested();
}

/// Solicita cargar por tipo
final class EquipamientoPersonalLoadByTipoRequested extends EquipamientoPersonalEvent {
  const EquipamientoPersonalLoadByTipoRequested(this.tipo);

  final String tipo;

  @override
  List<Object?> get props => <Object?>[tipo];
}

/// Solicita crear un registro
final class EquipamientoPersonalCreateRequested extends EquipamientoPersonalEvent {
  const EquipamientoPersonalCreateRequested(this.entity);

  final EquipamientoPersonalEntity entity;

  @override
  List<Object?> get props => <Object?>[entity];
}

/// Solicita actualizar un registro
final class EquipamientoPersonalUpdateRequested extends EquipamientoPersonalEvent {
  const EquipamientoPersonalUpdateRequested(this.entity);

  final EquipamientoPersonalEntity entity;

  @override
  List<Object?> get props => <Object?>[entity];
}

/// Solicita eliminar un registro
final class EquipamientoPersonalDeleteRequested extends EquipamientoPersonalEvent {
  const EquipamientoPersonalDeleteRequested(this.id);

  final String id;

  @override
  List<Object?> get props => <Object?>[id];
}
