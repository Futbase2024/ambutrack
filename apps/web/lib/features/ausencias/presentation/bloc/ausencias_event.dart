import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:equatable/equatable.dart';

/// Eventos del BLoC de Ausencias
abstract class AusenciasEvent extends Equatable {
  const AusenciasEvent();

  @override
  List<Object?> get props => <Object?>[];
}

/// Evento para cargar todas las ausencias
class AusenciasLoadRequested extends AusenciasEvent {
  const AusenciasLoadRequested();
}

/// Evento para cargar ausencias de un personal específico
class AusenciasLoadByPersonalRequested extends AusenciasEvent {
  const AusenciasLoadByPersonalRequested(this.idPersonal);

  final String idPersonal;

  @override
  List<Object?> get props => <Object?>[idPersonal];
}

/// Evento para cargar ausencias por estado
class AusenciasLoadByEstadoRequested extends AusenciasEvent {
  const AusenciasLoadByEstadoRequested(this.estado);

  final EstadoAusencia estado;

  @override
  List<Object?> get props => <Object?>[estado];
}

/// Evento para cargar ausencias en un rango de fechas
class AusenciasLoadByRangoFechasRequested extends AusenciasEvent {
  const AusenciasLoadByRangoFechasRequested({
    required this.fechaInicio,
    required this.fechaFin,
  });

  final DateTime fechaInicio;
  final DateTime fechaFin;

  @override
  List<Object?> get props => <Object?>[fechaInicio, fechaFin];
}

/// Evento para crear una nueva ausencia
class AusenciaCreateRequested extends AusenciasEvent {
  const AusenciaCreateRequested(this.ausencia);

  final AusenciaEntity ausencia;

  @override
  List<Object?> get props => <Object?>[ausencia];
}

/// Evento para actualizar una ausencia
class AusenciaUpdateRequested extends AusenciasEvent {
  const AusenciaUpdateRequested(this.ausencia);

  final AusenciaEntity ausencia;

  @override
  List<Object?> get props => <Object?>[ausencia];
}

/// Evento para aprobar una ausencia
class AusenciaAprobarRequested extends AusenciasEvent {
  const AusenciaAprobarRequested({
    required this.idAusencia,
    required this.aprobadoPor,
    this.observaciones,
  });

  final String idAusencia;
  final String aprobadoPor;
  final String? observaciones;

  @override
  List<Object?> get props => <Object?>[idAusencia, aprobadoPor, observaciones];
}

/// Evento para rechazar una ausencia
class AusenciaRechazarRequested extends AusenciasEvent {
  const AusenciaRechazarRequested({
    required this.idAusencia,
    required this.aprobadoPor,
    this.observaciones,
  });

  final String idAusencia;
  final String aprobadoPor;
  final String? observaciones;

  @override
  List<Object?> get props => <Object?>[idAusencia, aprobadoPor, observaciones];
}

/// Evento para eliminar una ausencia
class AusenciaDeleteRequested extends AusenciasEvent {
  const AusenciaDeleteRequested(this.id);

  final String id;

  @override
  List<Object?> get props => <Object?>[id];
}

/// Evento para cargar tipos de ausencia
class TiposAusenciaLoadRequested extends AusenciasEvent {
  const TiposAusenciaLoadRequested();
}

/// Evento para eliminar días parciales de una ausencia
///
/// Permite eliminar un rango de días específico dentro de una ausencia existente.
/// - Si el rango está al inicio: modifica fechaInicio
/// - Si el rango está al final: modifica fechaFin
/// - Si el rango está en medio: divide la ausencia en dos
class AusenciaEliminarDiasParcialRequested extends AusenciasEvent {
  const AusenciaEliminarDiasParcialRequested({
    required this.ausencia,
    required this.fechaInicioEliminar,
    required this.fechaFinEliminar,
  });

  /// La ausencia original a modificar
  final AusenciaEntity ausencia;

  /// Fecha inicio del rango a eliminar
  final DateTime fechaInicioEliminar;

  /// Fecha fin del rango a eliminar
  final DateTime fechaFinEliminar;

  @override
  List<Object?> get props => <Object?>[ausencia, fechaInicioEliminar, fechaFinEliminar];
}
