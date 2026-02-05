import 'package:equatable/equatable.dart';

/// Nivel de ocupación para visualización de heat map
enum NivelOcupacion {
  /// Sin cobertura (0 trabajadores)
  sinCobertura,

  /// Bajo (1 trabajador)
  bajo,

  /// Adecuado (2-3 trabajadores)
  adecuado,

  /// Alto (4-5 trabajadores)
  alto,

  /// Sobrecarga (6+ trabajadores)
  sobrecarga,
}

/// Extensión para obtener color y texto del nivel de ocupación
extension NivelOcupacionExtension on NivelOcupacion {
  /// Color para el heat map
  String get colorHex {
    switch (this) {
      case NivelOcupacion.sinCobertura:
        return '#DC2626'; // Rojo crítico
      case NivelOcupacion.bajo:
        return '#F59E0B'; // Naranja advertencia
      case NivelOcupacion.adecuado:
        return '#10B981'; // Verde OK
      case NivelOcupacion.alto:
        return '#3B82F6'; // Azul información
      case NivelOcupacion.sobrecarga:
        return '#8B5CF6'; // Morado sobrecarga
    }
  }

  /// Texto descriptivo
  String get displayText {
    switch (this) {
      case NivelOcupacion.sinCobertura:
        return 'Sin Cobertura';
      case NivelOcupacion.bajo:
        return 'Bajo';
      case NivelOcupacion.adecuado:
        return 'Adecuado';
      case NivelOcupacion.alto:
        return 'Alto';
      case NivelOcupacion.sobrecarga:
        return 'Sobrecarga';
    }
  }

  /// Icono representativo
  String get icon {
    switch (this) {
      case NivelOcupacion.sinCobertura:
        return '❌';
      case NivelOcupacion.bajo:
        return '⚠️';
      case NivelOcupacion.adecuado:
        return '✅';
      case NivelOcupacion.alto:
        return 'ℹ️';
      case NivelOcupacion.sobrecarga:
        return '⚡';
    }
  }
}

/// Entidad que representa la disponibilidad de personal en una franja horaria
class DisponibilidadEntity extends Equatable {
  const DisponibilidadEntity({
    required this.fecha,
    required this.horaInicio,
    required this.horaFin,
    required this.cantidadPersonal,
    required this.nivelOcupacion,
    this.personalAsignado = const <String>[],
    this.categoriaServicio,
    this.tipoTurno,
  });

  /// Crea una instancia desde un cálculo de turnos
  factory DisponibilidadEntity.fromTurnos({
    required DateTime fecha,
    required DateTime horaInicio,
    required DateTime horaFin,
    required int cantidadPersonal,
    List<String>? personalAsignado,
    String? categoriaServicio,
    String? tipoTurno,
  }) {
    // Calcular nivel de ocupación basado en cantidad
    final NivelOcupacion nivel = _calcularNivel(cantidadPersonal);

    return DisponibilidadEntity(
      fecha: fecha,
      horaInicio: horaInicio,
      horaFin: horaFin,
      cantidadPersonal: cantidadPersonal,
      nivelOcupacion: nivel,
      personalAsignado: personalAsignado ?? <String>[],
      categoriaServicio: categoriaServicio,
      tipoTurno: tipoTurno,
    );
  }

  /// Fecha de la franja
  final DateTime fecha;

  /// Hora de inicio de la franja
  final DateTime horaInicio;

  /// Hora de fin de la franja
  final DateTime horaFin;

  /// Cantidad de personal asignado en esta franja
  final int cantidadPersonal;

  /// Nivel de ocupación calculado
  final NivelOcupacion nivelOcupacion;

  /// IDs del personal asignado
  final List<String> personalAsignado;

  /// Categoría de servicio (opcional, para filtrado)
  final String? categoriaServicio;

  /// Tipo de turno (opcional, para filtrado)
  final String? tipoTurno;

  @override
  List<Object?> get props => <Object?>[
        fecha,
        horaInicio,
        horaFin,
        cantidadPersonal,
        nivelOcupacion,
        personalAsignado,
        categoriaServicio,
        tipoTurno,
      ];

  /// CopyWith para inmutabilidad
  DisponibilidadEntity copyWith({
    DateTime? fecha,
    DateTime? horaInicio,
    DateTime? horaFin,
    int? cantidadPersonal,
    NivelOcupacion? nivelOcupacion,
    List<String>? personalAsignado,
    String? categoriaServicio,
    String? tipoTurno,
  }) {
    return DisponibilidadEntity(
      fecha: fecha ?? this.fecha,
      horaInicio: horaInicio ?? this.horaInicio,
      horaFin: horaFin ?? this.horaFin,
      cantidadPersonal: cantidadPersonal ?? this.cantidadPersonal,
      nivelOcupacion: nivelOcupacion ?? this.nivelOcupacion,
      personalAsignado: personalAsignado ?? this.personalAsignado,
      categoriaServicio: categoriaServicio ?? this.categoriaServicio,
      tipoTurno: tipoTurno ?? this.tipoTurno,
    );
  }

  /// Calcula el nivel de ocupación según la cantidad de personal
  static NivelOcupacion _calcularNivel(int cantidad) {
    if (cantidad == 0) {
      return NivelOcupacion.sinCobertura;
    } else if (cantidad == 1) {
      return NivelOcupacion.bajo;
    } else if (cantidad >= 2 && cantidad <= 3) {
      return NivelOcupacion.adecuado;
    } else if (cantidad >= 4 && cantidad <= 5) {
      return NivelOcupacion.alto;
    } else {
      return NivelOcupacion.sobrecarga;
    }
  }
}

/// Filtros para la vista de disponibilidad
class DisponibilidadFilter extends Equatable {
  const DisponibilidadFilter({
    this.categoriaServicio,
    this.tipoTurno,
    this.soloGaps = false,
    this.soloSobrecarga = false,
  });

  /// Filtrar por categoría de servicio
  final String? categoriaServicio;

  /// Filtrar por tipo de turno
  final String? tipoTurno;

  /// Mostrar solo gaps (sin cobertura)
  final bool soloGaps;

  /// Mostrar solo sobrecargas
  final bool soloSobrecarga;

  @override
  List<Object?> get props => <Object?>[
        categoriaServicio,
        tipoTurno,
        soloGaps,
        soloSobrecarga,
      ];

  DisponibilidadFilter copyWith({
    String? categoriaServicio,
    String? tipoTurno,
    bool? soloGaps,
    bool? soloSobrecarga,
  }) {
    return DisponibilidadFilter(
      categoriaServicio: categoriaServicio ?? this.categoriaServicio,
      tipoTurno: tipoTurno ?? this.tipoTurno,
      soloGaps: soloGaps ?? this.soloGaps,
      soloSobrecarga: soloSobrecarga ?? this.soloSobrecarga,
    );
  }

  /// Filtro vacío (sin filtros aplicados)
  static const DisponibilidadFilter empty = DisponibilidadFilter();
}
