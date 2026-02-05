import 'package:ambutrack_web/features/cuadrante/cuadrante_visual/domain/entities/personal_drag_data.dart';
import 'package:ambutrack_web/features/cuadrante/cuadrante_visual/domain/entities/vehiculo_drag_data.dart';
import 'package:equatable/equatable.dart';

/// Eventos del CuadranteVisualBloc
abstract class CuadranteVisualEvent extends Equatable {
  const CuadranteVisualEvent();

  @override
  List<Object?> get props => <Object?>[];
}

/// Cargar cuadrante para una fecha específica
class CuadranteLoadRequested extends CuadranteVisualEvent {
  const CuadranteLoadRequested(this.fecha);

  final DateTime fecha;

  @override
  List<Object?> get props => <Object?>[fecha];
}

/// Asignar personal a un slot
class CuadrantePersonalAssigned extends CuadranteVisualEvent {
  const CuadrantePersonalAssigned({
    required this.dotacionId,
    required this.numeroUnidad,
    required this.personalData,
  });

  final String dotacionId;
  final int numeroUnidad;
  final PersonalDragData personalData;

  @override
  List<Object?> get props => <Object?>[dotacionId, numeroUnidad, personalData];
}

/// Asignar vehículo a un slot
class CuadranteVehiculoAssigned extends CuadranteVisualEvent {
  const CuadranteVehiculoAssigned({
    required this.dotacionId,
    required this.numeroUnidad,
    required this.vehiculoData,
  });

  final String dotacionId;
  final int numeroUnidad;
  final VehiculoDragData vehiculoData;

  @override
  List<Object?> get props => <Object?>[dotacionId, numeroUnidad, vehiculoData];
}

/// Remover personal de un slot
class CuadrantePersonalRemoved extends CuadranteVisualEvent {
  const CuadrantePersonalRemoved({
    required this.dotacionId,
    required this.numeroUnidad,
  });

  final String dotacionId;
  final int numeroUnidad;

  @override
  List<Object?> get props => <Object?>[dotacionId, numeroUnidad];
}

/// Remover vehículo de un slot
class CuadranteVehiculoRemoved extends CuadranteVisualEvent {
  const CuadranteVehiculoRemoved({
    required this.dotacionId,
    required this.numeroUnidad,
  });

  final String dotacionId;
  final int numeroUnidad;

  @override
  List<Object?> get props => <Object?>[dotacionId, numeroUnidad];
}

/// Guardar cuadrante (persistir a BD)
class CuadranteSaveRequested extends CuadranteVisualEvent {
  const CuadranteSaveRequested();
}

/// Limpiar cuadrante
class CuadranteClearRequested extends CuadranteVisualEvent {
  const CuadranteClearRequested();
}
