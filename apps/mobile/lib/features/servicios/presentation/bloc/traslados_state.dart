import 'package:equatable/equatable.dart';

import 'package:ambutrack_core/ambutrack_core.dart';

/// Estados del BLoC de traslados
abstract class TrasladosState extends Equatable {
  const TrasladosState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class TrasladosInitial extends TrasladosState {
  const TrasladosInitial();
}

/// Estado de carga
class TrasladosLoading extends TrasladosState {
  const TrasladosLoading();
}

/// Estado con traslados cargados
class TrasladosLoaded extends TrasladosState {
  const TrasladosLoaded({
    required this.traslados,
    this.trasladoSeleccionado,
    this.pacienteSeleccionado,
    this.historialEstados,
  });

  final List<TrasladoEntity> traslados;
  final TrasladoEntity? trasladoSeleccionado;
  final PacienteEntity? pacienteSeleccionado;
  final List<HistorialEstadoEntity>? historialEstados;

  @override
  List<Object?> get props => [traslados, trasladoSeleccionado, pacienteSeleccionado, historialEstados];

  TrasladosLoaded copyWith({
    List<TrasladoEntity>? traslados,
    TrasladoEntity? trasladoSeleccionado,
    PacienteEntity? pacienteSeleccionado,
    List<HistorialEstadoEntity>? historialEstados,
    bool clearHistorial = false,
    bool clearPaciente = false,
    bool clearTrasladoSeleccionado = false,
  }) {
    return TrasladosLoaded(
      traslados: traslados ?? this.traslados,
      trasladoSeleccionado: clearTrasladoSeleccionado ? null : (trasladoSeleccionado ?? this.trasladoSeleccionado),
      pacienteSeleccionado: clearPaciente ? null : (pacienteSeleccionado ?? this.pacienteSeleccionado),
      historialEstados: clearHistorial ? null : (historialEstados ?? this.historialEstados),
    );
  }

  /// Obtiene un traslado específico de la lista por ID
  TrasladoEntity? getTrasladoById(String id) {
    try {
      return traslados.firstWhere((t) => t.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Filtra traslados por estado
  List<TrasladoEntity> getTrasladosByEstado(EstadoTraslado estado) {
    return traslados.where((t) => t.estado == estado).toList();
  }

  /// Obtiene los traslados de hoy
  List<TrasladoEntity> getTrasladosDeHoy() {
    final hoy = DateTime.now();
    return traslados.where((t) {
      return t.fecha.year == hoy.year &&
          t.fecha.month == hoy.month &&
          t.fecha.day == hoy.day;
    }).toList();
  }
}

/// Estado cuando se está cambiando el estado de un traslado
class CambiandoEstadoTraslado extends TrasladosState {
  const CambiandoEstadoTraslado({
    required this.idTraslado,
    required this.estadoActual,
    required this.estadoNuevo,
  });

  final String idTraslado;
  final EstadoTraslado estadoActual;
  final EstadoTraslado estadoNuevo;

  @override
  List<Object?> get props => [idTraslado, estadoActual, estadoNuevo];
}

/// Estado de éxito al cambiar estado
class EstadoCambiadoSuccess extends TrasladosState {
  const EstadoCambiadoSuccess({
    required this.traslado,
    required this.estadoAnterior,
  });

  final TrasladoEntity traslado;
  final EstadoTraslado estadoAnterior;

  @override
  List<Object?> get props => [traslado, estadoAnterior];
}

/// Estado de error
class TrasladosError extends TrasladosState {
  const TrasladosError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

/// Estado cuando se está actualizando desde el stream
class TrasladosStreamActualizando extends TrasladosState {
  const TrasladosStreamActualizando(this.trasladosActuales);

  final List<TrasladoEntity> trasladosActuales;

  @override
  List<Object?> get props => [trasladosActuales];
}
