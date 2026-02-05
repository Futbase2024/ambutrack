import 'package:ambutrack_core/ambutrack_core.dart';
import 'package:equatable/equatable.dart';

/// Eventos del BLoC de contratos
abstract class ContratoEvent extends Equatable {
  const ContratoEvent();

  @override
  List<Object?> get props => <Object?>[];
}

/// Evento para cargar todos los contratos
class ContratoLoadRequested extends ContratoEvent {
  const ContratoLoadRequested();
}

/// Evento para cargar solo contratos activos
class ContratoLoadActivosRequested extends ContratoEvent {
  const ContratoLoadActivosRequested();
}

/// Evento para cargar solo contratos vigentes
class ContratoLoadVigentesRequested extends ContratoEvent {
  const ContratoLoadVigentesRequested();
}

/// Evento para cargar contratos por hospital
class ContratoLoadByHospitalRequested extends ContratoEvent {

  const ContratoLoadByHospitalRequested(this.hospitalId);
  final String hospitalId;

  @override
  List<Object?> get props => <Object?>[hospitalId];
}

/// Evento para crear un contrato
class ContratoCreateRequested extends ContratoEvent {

  const ContratoCreateRequested(this.contrato);
  final ContratoEntity contrato;

  @override
  List<Object?> get props => <Object?>[contrato];
}

/// Evento para actualizar un contrato
class ContratoUpdateRequested extends ContratoEvent {

  const ContratoUpdateRequested(this.contrato);
  final ContratoEntity contrato;

  @override
  List<Object?> get props => <Object?>[contrato];
}

/// Evento para eliminar un contrato
class ContratoDeleteRequested extends ContratoEvent {

  const ContratoDeleteRequested(this.id);
  final String id;

  @override
  List<Object?> get props => <Object?>[id];
}

/// Evento para activar/desactivar un contrato
class ContratoToggleActivoRequested extends ContratoEvent {

  const ContratoToggleActivoRequested(this.id, {required this.activo});
  final String id;
  final bool activo;

  @override
  List<Object?> get props => <Object?>[id, activo];
}
