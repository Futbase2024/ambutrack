import 'package:ambutrack_core/ambutrack_core.dart';
import 'package:equatable/equatable.dart';

/// Eventos del BLoC de Vestuario
abstract class VestuarioEvent extends Equatable {
  const VestuarioEvent();

  @override
  List<Object?> get props => <Object?>[];
}

/// Evento para cargar todos los registros
class VestuarioLoadRequested extends VestuarioEvent {
  const VestuarioLoadRequested();
}

/// Evento para cargar vestuario de un personal
class VestuarioLoadByPersonalRequested extends VestuarioEvent {
  const VestuarioLoadByPersonalRequested(this.personalId);

  final String personalId;

  @override
  List<Object?> get props => <Object?>[personalId];
}

/// Evento para cargar vestuario asignado
class VestuarioLoadAsignadoRequested extends VestuarioEvent {
  const VestuarioLoadAsignadoRequested();
}

/// Evento para cargar vestuario por prenda
class VestuarioLoadByPrendaRequested extends VestuarioEvent {
  const VestuarioLoadByPrendaRequested(this.prenda);

  final String prenda;

  @override
  List<Object?> get props => <Object?>[prenda];
}

/// Evento para crear un registro
class VestuarioCreateRequested extends VestuarioEvent {
  const VestuarioCreateRequested(this.item);

  final VestuarioEntity item;

  @override
  List<Object?> get props => <Object?>[item];
}

/// Evento para actualizar un registro
class VestuarioUpdateRequested extends VestuarioEvent {
  const VestuarioUpdateRequested(this.item);

  final VestuarioEntity item;

  @override
  List<Object?> get props => <Object?>[item];
}

/// Evento para eliminar un registro
class VestuarioDeleteRequested extends VestuarioEvent {
  const VestuarioDeleteRequested(this.id);

  final String id;

  @override
  List<Object?> get props => <Object?>[id];
}
