import 'package:ambutrack_core/ambutrack_core.dart';
import 'package:equatable/equatable.dart';

/// Resultado de la generación automática de cuadrante
class ResultadoGeneracionEntity extends Equatable {
  const ResultadoGeneracionEntity({
    required this.turnosGenerados,
    required this.conflictos,
    required this.advertencias,
    required this.estadisticas,
  });

  final List<TurnoEntity> turnosGenerados;
  final List<ConflictoGeneracion> conflictos;
  final List<AdvertenciaGeneracion> advertencias;
  final EstadisticasGeneracion estadisticas;

  @override
  List<Object?> get props => <Object?>[
        turnosGenerados,
        conflictos,
        advertencias,
        estadisticas,
      ];

  bool get tieneConflictos => conflictos.isNotEmpty;
  bool get tieneAdvertencias => advertencias.isNotEmpty;
}

/// Conflicto detectado durante la generación
class ConflictoGeneracion extends Equatable {
  const ConflictoGeneracion({
    required this.tipo,
    required this.mensaje,
    required this.idPersonal,
    required this.fecha,
  });

  final TipoConflicto tipo;
  final String mensaje;
  final String? idPersonal;
  final DateTime fecha;

  @override
  List<Object?> get props => <Object?>[tipo, mensaje, idPersonal, fecha];
}

/// Tipos de conflicto
enum TipoConflicto {
  excesoCargaHoraria,
  faltaDescanso,
  solapamientoTurnos,
  personalNoDisponible,
  restriccionLegalViolada,
}

/// Advertencia no crítica
class AdvertenciaGeneracion extends Equatable {
  const AdvertenciaGeneracion({
    required this.mensaje,
    required this.idPersonal,
    this.fecha,
  });

  final String mensaje;
  final String? idPersonal;
  final DateTime? fecha;

  @override
  List<Object?> get props => <Object?>[mensaje, idPersonal, fecha];
}

/// Estadísticas de la generación
class EstadisticasGeneracion extends Equatable {
  const EstadisticasGeneracion({
    required this.totalTurnosGenerados,
    required this.totalPersonalAsignado,
    required this.horasPromedioPorPersona,
    required this.distribucionPorTipoTurno,
    required this.coberturaCompletada,
  });

  final int totalTurnosGenerados;
  final int totalPersonalAsignado;
  final double horasPromedioPorPersona;
  final Map<TipoTurno, int> distribucionPorTipoTurno;
  final double coberturaCompletada; // Porcentaje (0-100)

  @override
  List<Object?> get props => <Object?>[
        totalTurnosGenerados,
        totalPersonalAsignado,
        horasPromedioPorPersona,
        distribucionPorTipoTurno,
        coberturaCompletada,
      ];
}
