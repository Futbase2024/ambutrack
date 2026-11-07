import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:equatable/equatable.dart';

/// Estado de carga del resumen de generación
enum GeneracionStatus { initial, loading, loaded, error }

/// Resumen del estado de generación de traslados
class GeneracionResumen extends Equatable {
  const GeneracionResumen({
    required this.serviciosVigentes,
    required this.requierenGeneracion,
    required this.sinGenerar,
    this.generadosHastaMin,
    this.generadosHastaMax,
  });

  /// Calcula el resumen a partir de los servicios recurrentes vigentes
  factory GeneracionResumen.desde(List<ServicioRecurrenteEntity> vigentes) {
    DateTime? min;
    DateTime? max;
    int sinGenerar = 0;
    for (final ServicioRecurrenteEntity s in vigentes) {
      final DateTime? hasta = s.trasladosGeneradosHasta;
      if (hasta == null) {
        sinGenerar++;
        continue;
      }
      if (min == null || hasta.isBefore(min)) {
        min = hasta;
      }
      if (max == null || hasta.isAfter(max)) {
        max = hasta;
      }
    }
    return GeneracionResumen(
      serviciosVigentes: vigentes.length,
      requierenGeneracion:
          vigentes.where((ServicioRecurrenteEntity s) => s.requiereGeneracion).length,
      sinGenerar: sinGenerar,
      generadosHastaMin: min,
      generadosHastaMax: max,
    );
  }

  final int serviciosVigentes;

  /// Servicios cuya ventana generada no cubre los próximos 14 días
  final int requierenGeneracion;

  /// Servicios sin ninguna generación registrada
  final int sinGenerar;
  final DateTime? generadosHastaMin;
  final DateTime? generadosHastaMax;

  @override
  List<Object?> get props => <Object?>[
        serviciosVigentes,
        requierenGeneracion,
        sinGenerar,
        generadosHastaMin,
        generadosHastaMax,
      ];
}

/// Estado del GeneracionTrasladosBloc
class GeneracionTrasladosState extends Equatable {
  const GeneracionTrasladosState({
    this.status = GeneracionStatus.initial,
    this.resumen,
    this.generando = false,
    this.ultimoResultado,
    this.errorMessage,
    this.errorGeneracion,
  });

  final GeneracionStatus status;
  final GeneracionResumen? resumen;

  /// Generación en curso
  final bool generando;

  /// Resultado de la última generación lanzada desde esta pantalla
  final ResultadoGeneracionTrasladosEntity? ultimoResultado;

  /// Error al cargar el resumen
  final String? errorMessage;

  /// Error de la última generación (se limpia en la siguiente)
  final String? errorGeneracion;

  GeneracionTrasladosState copyWith({
    GeneracionStatus? status,
    GeneracionResumen? resumen,
    bool? generando,
    ResultadoGeneracionTrasladosEntity? ultimoResultado,
    String? errorMessage,
    String? errorGeneracion,
    bool clearErrorGeneracion = false,
  }) {
    return GeneracionTrasladosState(
      status: status ?? this.status,
      resumen: resumen ?? this.resumen,
      generando: generando ?? this.generando,
      ultimoResultado: ultimoResultado ?? this.ultimoResultado,
      errorMessage: errorMessage ?? this.errorMessage,
      errorGeneracion:
          clearErrorGeneracion ? null : (errorGeneracion ?? this.errorGeneracion),
    );
  }

  @override
  List<Object?> get props => <Object?>[
        status,
        resumen,
        generando,
        ultimoResultado,
        errorMessage,
        errorGeneracion,
      ];
}
