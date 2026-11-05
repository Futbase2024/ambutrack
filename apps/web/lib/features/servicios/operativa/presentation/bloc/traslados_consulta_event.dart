import 'package:equatable/equatable.dart';

/// Tipo de consulta de traslados
enum TrasladosConsultaModo {
  /// Traslados de un día concreto
  dia,

  /// Traslados de un rango de fechas
  rango,

  /// Traslados en curso (estados no finales)
  enCurso,
}

/// Parámetros de la consulta de traslados
class TrasladosConsulta extends Equatable {
  const TrasladosConsulta._({required this.modo, this.desde, this.hasta});

  /// Traslados del día [fecha]
  factory TrasladosConsulta.dia(DateTime fecha) =>
      TrasladosConsulta._(modo: TrasladosConsultaModo.dia, desde: fecha, hasta: fecha);

  /// Traslados entre [desde] y [hasta] (inclusive)
  factory TrasladosConsulta.rango(DateTime desde, DateTime hasta) =>
      TrasladosConsulta._(modo: TrasladosConsultaModo.rango, desde: desde, hasta: hasta);

  /// Traslados en curso
  factory TrasladosConsulta.enCurso() =>
      const TrasladosConsulta._(modo: TrasladosConsultaModo.enCurso);

  final TrasladosConsultaModo modo;
  final DateTime? desde;
  final DateTime? hasta;

  @override
  List<Object?> get props => <Object?>[modo, desde, hasta];
}

/// Eventos del TrasladosConsultaBloc
abstract class TrasladosConsultaEvent extends Equatable {
  const TrasladosConsultaEvent();

  @override
  List<Object?> get props => <Object?>[];
}

/// Lanza una consulta de traslados
class TrasladosConsultaRequested extends TrasladosConsultaEvent {
  const TrasladosConsultaRequested({required this.consulta, this.silent = false});

  final TrasladosConsulta consulta;

  /// Si es true no se emite estado de carga (refresco en segundo plano)
  final bool silent;

  @override
  List<Object?> get props => <Object?>[consulta, silent];
}

/// Repite la última consulta
class TrasladosConsultaRefreshRequested extends TrasladosConsultaEvent {
  const TrasladosConsultaRefreshRequested({this.silent = false});

  final bool silent;

  @override
  List<Object?> get props => <Object?>[silent];
}
