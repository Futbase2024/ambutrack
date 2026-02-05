import 'package:ambutrack_core/ambutrack_core.dart';
import 'package:ambutrack_web/features/cuadrante/cuadrante_module/domain/entities/cuadrante_filter.dart';
import 'package:ambutrack_web/features/cuadrante/cuadrante_module/domain/entities/cuadrante_view_mode.dart';
import 'package:equatable/equatable.dart';

/// Eventos del cuadrante
abstract class CuadranteEvent extends Equatable {
  const CuadranteEvent();

  @override
  List<Object?> get props => <Object?>[];
}

/// Cargar cuadrante con filtros
class CuadranteLoadRequested extends CuadranteEvent {
  const CuadranteLoadRequested();
}

/// Cambiar semana (siguiente/anterior)
class CuadranteSemanaChanged extends CuadranteEvent {
  const CuadranteSemanaChanged(this.offset);

  /// Offset de semanas: -1 = anterior, +1 = siguiente
  final int offset;

  @override
  List<Object?> get props => <Object?>[offset];
}

/// Cambiar mes (siguiente/anterior)
class CuadranteMesChanged extends CuadranteEvent {
  const CuadranteMesChanged(this.offset);

  /// Offset de meses: -1 = anterior, +1 = siguiente
  final int offset;

  @override
  List<Object?> get props => <Object?>[offset];
}

/// Cambiar modo de vista (tabla/calendario)
class CuadranteViewModeChanged extends CuadranteEvent {
  const CuadranteViewModeChanged(this.mode);

  final CuadranteViewMode mode;

  @override
  List<Object?> get props => <Object?>[mode];
}

/// Actualizar filtros
class CuadranteFilterChanged extends CuadranteEvent {
  const CuadranteFilterChanged(this.filter);

  final CuadranteFilter filter;

  @override
  List<Object?> get props => <Object?>[filter];
}

/// Limpiar filtros
class CuadranteFilterCleared extends CuadranteEvent {
  const CuadranteFilterCleared();
}

/// Refrescar cuadrante
class CuadranteRefreshRequested extends CuadranteEvent {
  const CuadranteRefreshRequested();
}

/// Copiar todos los turnos de una semana a otra
class CuadranteCopiarSemanaRequested extends CuadranteEvent {
  const CuadranteCopiarSemanaRequested({
    required this.semanaOrigen,
    required this.semanaDestino,
    this.idPersonal,
  });

  /// Fecha de inicio de la semana origen
  final DateTime semanaOrigen;

  /// Fecha de inicio de la semana destino
  final DateTime semanaDestino;

  /// IDs del personal a copiar (null = todos, lista con IDs = selección específica)
  final List<String>? idPersonal;

  @override
  List<Object?> get props => <Object?>[semanaOrigen, semanaDestino, idPersonal];
}

/// Actualizar turno específico en cuadrante (sin recargar todo)
class CuadranteTurnoCreated extends CuadranteEvent {
  const CuadranteTurnoCreated(this.turno);

  final TurnoEntity turno;

  @override
  List<Object?> get props => <Object?>[turno];
}

/// Actualizar turno específico en cuadrante (sin recargar todo)
class CuadranteTurnoUpdated extends CuadranteEvent {
  const CuadranteTurnoUpdated(this.turno);

  final TurnoEntity turno;

  @override
  List<Object?> get props => <Object?>[turno];
}

/// Eliminar turno específico del cuadrante (sin recargar todo)
class CuadranteTurnoDeleted extends CuadranteEvent {
  const CuadranteTurnoDeleted(this.turnoId);

  final String turnoId;

  @override
  List<Object?> get props => <Object?>[turnoId];
}
