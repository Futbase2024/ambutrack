import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:equatable/equatable.dart';

/// Acción de gestión realizada sobre una solicitud
enum AccionSolicitudVestuario { aprobar, rechazar, entregar }

/// Resultado de la última acción de gestión (evento puntual para la UI)
class SolicitudVestuarioResultado extends Equatable {
  const SolicitudVestuarioResultado({
    required this.secuencia,
    required this.accion,
    required this.tipo,
    this.error,
  });

  /// Contador para distinguir resultados consecutivos iguales
  final int secuencia;
  final AccionSolicitudVestuario accion;
  final TipoSolicitudVestuario tipo;

  /// null = operación correcta
  final String? error;

  bool get ok => error == null;

  @override
  List<Object?> get props => <Object?>[secuencia, accion, tipo, error];
}

/// Estado de la pantalla de solicitudes de vestuario
class SolicitudesVestuarioState extends Equatable {
  const SolicitudesVestuarioState({
    this.solicitudes,
    this.stock = const <StockVestuarioEntity>[],
    this.cargando = false,
    this.procesando = false,
    this.error,
    this.resultado,
  });

  /// null = aún no se ha cargado nada
  final List<SolicitudVestuarioEntity>? solicitudes;

  /// Artículos de almacén (para elegir de dónde se entrega)
  final List<StockVestuarioEntity> stock;
  final bool cargando;

  /// Hay una aprobación / rechazo / entrega en curso
  final bool procesando;

  /// Error de la última carga
  final String? error;
  final SolicitudVestuarioResultado? resultado;

  int get abiertas => (solicitudes ?? const <SolicitudVestuarioEntity>[])
      .where((SolicitudVestuarioEntity s) => s.estado.abierta)
      .length;

  SolicitudesVestuarioState copyWith({
    List<SolicitudVestuarioEntity>? solicitudes,
    List<StockVestuarioEntity>? stock,
    bool? cargando,
    bool? procesando,
    String? error,
    bool clearError = false,
    SolicitudVestuarioResultado? resultado,
  }) {
    return SolicitudesVestuarioState(
      solicitudes: solicitudes ?? this.solicitudes,
      stock: stock ?? this.stock,
      cargando: cargando ?? this.cargando,
      procesando: procesando ?? this.procesando,
      error: clearError ? null : (error ?? this.error),
      resultado: resultado ?? this.resultado,
    );
  }

  @override
  List<Object?> get props => <Object?>[solicitudes, stock, cargando, procesando, error, resultado];
}
