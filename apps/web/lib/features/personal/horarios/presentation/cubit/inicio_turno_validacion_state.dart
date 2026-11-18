import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:equatable/equatable.dart';

/// Resultado de la última aprobación / rechazo (evento puntual para la UI)
class InicioTurnoValidacionResultado extends Equatable {
  const InicioTurnoValidacionResultado({required this.secuencia, required this.aprobado, this.error});

  /// Contador para distinguir resultados consecutivos iguales
  final int secuencia;
  final bool aprobado;

  /// null = operación correcta
  final String? error;

  bool get ok => error == null;

  @override
  List<Object?> get props => <Object?>[secuencia, aprobado, error];
}

/// Estado de la pantalla de validación de inicios de turno
class InicioTurnoValidacionState extends Equatable {
  const InicioTurnoValidacionState({
    this.inicios,
    this.cargando = false,
    this.validando = false,
    this.error,
    this.resultado,
  });

  /// null = aún no se ha cargado nada
  final List<InicioTurnoEntity>? inicios;
  final bool cargando;
  final bool validando;

  /// Error de la última carga
  final String? error;
  final InicioTurnoValidacionResultado? resultado;

  int get pendientes => (inicios ?? const <InicioTurnoEntity>[])
      .where((InicioTurnoEntity i) => i.estadoValidacion == EstadoValidacionInicio.pendiente)
      .length;

  InicioTurnoValidacionState copyWith({
    List<InicioTurnoEntity>? inicios,
    bool? cargando,
    bool? validando,
    String? error,
    bool clearError = false,
    InicioTurnoValidacionResultado? resultado,
  }) {
    return InicioTurnoValidacionState(
      inicios: inicios ?? this.inicios,
      cargando: cargando ?? this.cargando,
      validando: validando ?? this.validando,
      error: clearError ? null : (error ?? this.error),
      resultado: resultado ?? this.resultado,
    );
  }

  @override
  List<Object?> get props => <Object?>[inicios, cargando, validando, error, resultado];
}
