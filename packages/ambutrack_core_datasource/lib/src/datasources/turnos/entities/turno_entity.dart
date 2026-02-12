import 'package:equatable/equatable.dart';

/// Tipos de turno disponibles con sus configuraciones
enum TipoTurno {
  /// Turno de mañana (07:00-15:00)
  manana('Mañana', '07:00', '15:00', '#10B981'),

  /// Turno de tarde (15:00-23:00)
  tarde('Tarde', '15:00', '23:00', '#F59E0B'),

  /// Turno de noche (23:00-07:00)
  noche('Noche', '23:00', '07:00', '#3B82F6'),

  /// Turno personalizado con horarios variables
  personalizado('Personalizado', '', '', '#6B7280');

  const TipoTurno(
    this.nombre,
    this.horaInicio,
    this.horaFin,
    this.colorHex,
  );

  /// Nombre descriptivo del tipo de turno
  final String nombre;

  /// Hora de inicio predeterminada (HH:mm)
  final String horaInicio;

  /// Hora de fin predeterminada (HH:mm)
  final String horaFin;

  /// Color hexadecimal para visualización (#RRGGBB)
  final String colorHex;
}

/// Entidad que representa un turno de trabajo del personal
class TurnoEntity extends Equatable {
  const TurnoEntity({
    required this.id,
    required this.idPersonal,
    required this.nombrePersonal,
    required this.tipoTurno,
    required this.fechaInicio,
    required this.fechaFin,
    required this.horaInicio,
    required this.horaFin,
    this.idContrato,
    this.idBase,
    this.categoriaPersonal,
    this.idVehiculo,
    this.idDotacion,
    this.observaciones,
    this.activo = true,
  });

  /// ID único del turno
  final String id;

  /// ID del personal asignado al turno (FK → personal)
  final String idPersonal;

  /// Nombre del personal (desnormalizado para performance)
  final String nombrePersonal;

  /// Tipo de turno predefinido
  final TipoTurno tipoTurno;

  /// Fecha de inicio del turno
  final DateTime fechaInicio;

  /// Fecha de fin del turno
  final DateTime fechaFin;

  /// Hora de inicio en formato HH:mm
  final String horaInicio;

  /// Hora de fin en formato HH:mm
  final String horaFin;

  /// ID del contrato asociado al turno (FK → contratos)
  final String? idContrato;

  /// ID de la base operativa (opcional, ej: Base Urgencias)
  final String? idBase;

  /// Categoría/Función del personal (TES, Camillero, Conductor, Médico, etc.)
  final String? categoriaPersonal;

  /// ID del vehículo asignado (opcional, solo para técnicos/conductores/TES)
  final String? idVehiculo;

  /// ID de la dotación asociada al turno (FK → dotaciones)
  final String? idDotacion;

  /// Observaciones adicionales del turno
  final String? observaciones;

  /// Si el turno está activo (soft delete)
  final bool activo;

  @override
  List<Object?> get props => [
        id,
        idPersonal,
        nombrePersonal,
        tipoTurno,
        fechaInicio,
        fechaFin,
        horaInicio,
        horaFin,
        idContrato,
        idBase,
        categoriaPersonal,
        idVehiculo,
        idDotacion,
        observaciones,
        activo,
      ];

  /// Copia la entidad con modificaciones
  TurnoEntity copyWith({
    String? id,
    String? idPersonal,
    String? nombrePersonal,
    TipoTurno? tipoTurno,
    DateTime? fechaInicio,
    DateTime? fechaFin,
    String? horaInicio,
    String? horaFin,
    String? idContrato,
    String? idBase,
    String? categoriaPersonal,
    String? idVehiculo,
    String? idDotacion,
    String? observaciones,
    bool? activo,
  }) {
    return TurnoEntity(
      id: id ?? this.id,
      idPersonal: idPersonal ?? this.idPersonal,
      nombrePersonal: nombrePersonal ?? this.nombrePersonal,
      tipoTurno: tipoTurno ?? this.tipoTurno,
      fechaInicio: fechaInicio ?? this.fechaInicio,
      fechaFin: fechaFin ?? this.fechaFin,
      horaInicio: horaInicio ?? this.horaInicio,
      horaFin: horaFin ?? this.horaFin,
      idContrato: idContrato ?? this.idContrato,
      idBase: idBase ?? this.idBase,
      categoriaPersonal: categoriaPersonal ?? this.categoriaPersonal,
      idVehiculo: idVehiculo ?? this.idVehiculo,
      idDotacion: idDotacion ?? this.idDotacion,
      observaciones: observaciones ?? this.observaciones,
      activo: activo ?? this.activo,
    );
  }

  /// Convierte la entidad a JSON (para serialización)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'idPersonal': idPersonal,
      'nombrePersonal': nombrePersonal,
      'tipoTurno': tipoTurno.name,
      'fechaInicio': fechaInicio.toIso8601String(),
      'fechaFin': fechaFin.toIso8601String(),
      'horaInicio': horaInicio,
      'horaFin': horaFin,
      'idContrato': idContrato,
      'idBase': idBase,
      'categoriaPersonal': categoriaPersonal,
      'idVehiculo': idVehiculo,
      'idDotacion': idDotacion,
      'observaciones': observaciones,
      'activo': activo,
    };
  }

  /// Crea una entidad desde JSON
  factory TurnoEntity.fromJson(Map<String, dynamic> json) {
    return TurnoEntity(
      id: json['id'] as String,
      idPersonal: json['idPersonal'] as String,
      nombrePersonal: json['nombrePersonal'] as String,
      tipoTurno: _parseTipoTurno(json['tipoTurno'] as String),
      fechaInicio: DateTime.parse(json['fechaInicio'] as String),
      fechaFin: DateTime.parse(json['fechaFin'] as String),
      horaInicio: json['horaInicio'] as String,
      horaFin: json['horaFin'] as String,
      idContrato: json['idContrato'] as String?,
      idBase: json['idBase'] as String?,
      categoriaPersonal: json['categoriaPersonal'] as String?,
      idVehiculo: json['idVehiculo'] as String?,
      idDotacion: json['idDotacion'] as String?,
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
