import 'package:equatable/equatable.dart';

import 'turno_entity.dart';

/// Entidad de dominio para una plantilla de turno reutilizable
class PlantillaTurnoEntity extends Equatable {
  const PlantillaTurnoEntity({
    required this.id,
    required this.nombre,
    this.descripcion,
    required this.tipoTurno,
    required this.horaInicio,
    required this.horaFin,
    this.color,
    this.duracionDias = 1,
    this.observaciones,
    this.activo = true,
  });

  /// ID único de la plantilla
  final String id;

  /// Nombre descriptivo de la plantilla
  final String nombre;

  /// Descripción opcional de la plantilla
  final String? descripcion;

  /// Tipo de turno (mañana, tarde, noche, personalizado)
  final TipoTurno tipoTurno;

  /// Hora de inicio del turno (formato HH:mm)
  final String horaInicio;

  /// Hora de fin del turno (formato HH:mm)
  final String horaFin;

  /// Color hex personalizado para visualización (#RRGGBB)
  final String? color;

  /// Duración en días (1 = mismo día, 2 = 24h, etc.)
  final int duracionDias;

  /// Observaciones adicionales
  final String? observaciones;

  /// Si la plantilla está activa
  final bool activo;

  @override
  List<Object?> get props => <Object?>[
        id,
        nombre,
        descripcion,
        tipoTurno,
        horaInicio,
        horaFin,
        color,
        duracionDias,
        observaciones,
        activo,
      ];

  /// Copia la entidad con modificaciones
  PlantillaTurnoEntity copyWith({
    String? id,
    String? nombre,
    String? descripcion,
    TipoTurno? tipoTurno,
    String? horaInicio,
    String? horaFin,
    String? color,
    int? duracionDias,
    String? observaciones,
    bool? activo,
  }) {
    return PlantillaTurnoEntity(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      tipoTurno: tipoTurno ?? this.tipoTurno,
      horaInicio: horaInicio ?? this.horaInicio,
      horaFin: horaFin ?? this.horaFin,
      color: color ?? this.color,
      duracionDias: duracionDias ?? this.duracionDias,
      observaciones: observaciones ?? this.observaciones,
      activo: activo ?? this.activo,
    );
  }

  /// Obtiene el color asociado al tipo de turno o el color personalizado
  String getColorHex() {
    if (color != null && color!.isNotEmpty) {
      return color!;
    }
    // Fallback a color del tipo de turno
    return tipoTurno.colorHex;
  }

  /// Convierte la entidad a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'tipoTurno': tipoTurno.name,
      'horaInicio': horaInicio,
      'horaFin': horaFin,
      'color': color,
      'duracionDias': duracionDias,
      'observaciones': observaciones,
      'activo': activo,
    };
  }

  /// Crea una entidad desde JSON
  factory PlantillaTurnoEntity.fromJson(Map<String, dynamic> json) {
    return PlantillaTurnoEntity(
      id: json['id'] as String,
      nombre: json['nombre'] as String,
      descripcion: json['descripcion'] as String?,
      tipoTurno: _parseTipoTurno(json['tipoTurno'] as String),
      horaInicio: json['horaInicio'] as String,
      horaFin: json['horaFin'] as String,
      color: json['color'] as String?,
      duracionDias: json['duracionDias'] as int? ?? 1,
      observaciones: json['observaciones'] as String?,
      activo: json['activo'] as bool? ?? true,
    );
  }

  /// Parsea string a enum TipoTurno
  static TipoTurno _parseTipoTurno(String value) {
    return TipoTurno.values.firstWhere(
      (e) => e.name == value,
      orElse: () => TipoTurno.personalizado,
    );
  }
}
