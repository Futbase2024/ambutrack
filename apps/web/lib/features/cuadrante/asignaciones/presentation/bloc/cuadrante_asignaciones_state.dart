import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:equatable/equatable.dart';

/// Estados para el BLoC de asignaciones de cuadrante
abstract class CuadranteAsignacionesState extends Equatable {
  const CuadranteAsignacionesState();

  @override
  List<Object?> get props => <Object?>[];
}

/// Estado inicial
class CuadranteAsignacionesInitial extends CuadranteAsignacionesState {
  const CuadranteAsignacionesInitial();
}

/// Estado de carga
class CuadranteAsignacionesLoading extends CuadranteAsignacionesState {
  const CuadranteAsignacionesLoading();
}

/// Estado de éxito con lista de asignaciones
class CuadranteAsignacionesLoaded extends CuadranteAsignacionesState {
  const CuadranteAsignacionesLoaded(this.asignaciones);

  final List<CuadranteAsignacionEntity> asignaciones;

  @override
  List<Object?> get props => <Object?>[asignaciones];
}

/// Estado de operación exitosa (create, update, delete)
class CuadranteAsignacionesOperationSuccess extends CuadranteAsignacionesState {
  const CuadranteAsignacionesOperationSuccess({
    required this.message,
    this.asignacion,
  });

  final String message;
  final CuadranteAsignacionEntity? asignacion;

  @override
  List<Object?> get props => <Object?>[message, asignacion];
}

/// Estado de error
class CuadranteAsignacionesError extends CuadranteAsignacionesState {
  const CuadranteAsignacionesError(this.message);

  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}

/// Estado de validación de conflictos
class CuadranteAsignacionesConflictChecked extends CuadranteAsignacionesState {
  const CuadranteAsignacionesConflictChecked({
    required this.hasConflict,
    this.conflictMessage,
  });

  final bool hasConflict;
  final String? conflictMessage;

  @override
  List<Object?> get props => <Object?>[hasConflict, conflictMessage];
}

/// Estado de conflicto detectado en tiempo real
class CuadranteAsignacionesConflictDetected extends CuadranteAsignacionesState {
  const CuadranteAsignacionesConflictDetected({
    required this.tipoConflicto,
    required this.tieneConflicto,
    required this.mensaje,
  });

  /// Tipo de conflicto: 'personal' o 'vehiculo'
  final String tipoConflicto;

  /// Si tiene conflicto
  final bool tieneConflicto;

  /// Mensaje descriptivo del conflicto
  final String mensaje;

  @override
  List<Object?> get props => <Object?>[tipoConflicto, tieneConflicto, mensaje];
}
