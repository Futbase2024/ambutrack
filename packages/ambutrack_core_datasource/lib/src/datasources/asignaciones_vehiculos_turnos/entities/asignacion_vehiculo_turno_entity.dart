import '../../../core/base_entity.dart';

/// Entidad de dominio para Asignación de Vehículo a Turno
///
/// Representa la asignación de un vehículo específico con una dotación
/// a un turno en una fecha determinada
class AsignacionVehiculoTurnoEntity extends BaseEntity {
  /// Fecha de la asignación
  final DateTime fecha;

  /// ID del vehículo asignado
  final String vehiculoId;

  /// ID de la dotación (define personal, turno, hospital/base)
  final String dotacionId;

  /// ID de la plantilla de turno (mañana, tarde, noche)
  final String? plantillaTurnoId;

  /// ID del hospital de destino (opcional)
  final String? hospitalId;

  /// ID de la base de origen (opcional)
  final String? baseId;

  /// Estado de la asignación (planificada, activa, completada, cancelada)
  final String estado;

  /// Usuario que confirmó la asignación
  final String? confirmadaPor;

  /// Fecha de confirmación
  final DateTime? fechaConfirmacion;

  /// Kilómetros iniciales
  final double? kmInicial;

  /// Kilómetros finales
  final double? kmFinal;

  /// Número de servicios realizados
  final int? serviciosRealizados;

  /// Horas efectivas trabajadas
  final double? horasEfectivas;

  /// Observaciones adicionales sobre la asignación
  final String? observaciones;

  /// Metadatos adicionales en formato JSON (opcional)
  final Map<String, dynamic>? metadata;

  /// Usuario que creó el registro
  final String? createdBy;

  /// Usuario que actualizó el registro
  final String? updatedBy;

  /// Crea una nueva instancia de [AsignacionVehiculoTurnoEntity]
  const AsignacionVehiculoTurnoEntity({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    required this.fecha,
    required this.vehiculoId,
    required this.dotacionId,
    this.plantillaTurnoId,
    this.hospitalId,
    this.baseId,
    this.estado = 'planificada',
    this.confirmadaPor,
    this.fechaConfirmacion,
    this.kmInicial,
    this.kmFinal,
    this.serviciosRealizados = 0,
    this.horasEfectivas,
    this.observaciones,
    this.metadata,
    this.createdBy,
    this.updatedBy,
  });

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'fecha': fecha.toIso8601String(),
      'vehiculo_id': vehiculoId,
      'dotacion_id': dotacionId,
      if (plantillaTurnoId != null) 'plantilla_turno_id': plantillaTurnoId,
      if (hospitalId != null) 'hospital_id': hospitalId,
      if (baseId != null) 'base_id': baseId,
      'estado': estado,
      if (confirmadaPor != null) 'confirmada_por': confirmadaPor,
      if (fechaConfirmacion != null)
        'fecha_confirmacion': fechaConfirmacion!.toIso8601String(),
      if (kmInicial != null) 'km_inicial': kmInicial,
      if (kmFinal != null) 'km_final': kmFinal,
      if (serviciosRealizados != null)
        'servicios_realizados': serviciosRealizados,
      if (horasEfectivas != null) 'horas_efectivas': horasEfectivas,
      if (observaciones != null) 'observaciones': observaciones,
      if (metadata != null) 'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      if (createdBy != null) 'created_by': createdBy,
      if (updatedBy != null) 'updated_by': updatedBy,
    };
  }

  /// Crea un [AsignacionVehiculoTurnoEntity] desde datos JSON
  factory AsignacionVehiculoTurnoEntity.fromJson(Map<String, dynamic> json) {
    return AsignacionVehiculoTurnoEntity(
      id: json['id'] as String,
      fecha: _parseDateTime(json['fecha'])!,
      vehiculoId: json['vehiculo_id'] as String,
      dotacionId: json['dotacion_id'] as String,
      plantillaTurnoId: json['plantilla_turno_id'] as String?,
      hospitalId: json['hospital_id'] as String?,
      baseId: json['base_id'] as String?,
      estado: json['estado'] as String? ?? 'planificada',
      confirmadaPor: json['confirmada_por'] as String?,
      fechaConfirmacion: _parseDateTime(json['fecha_confirmacion']),
      kmInicial: _parseDouble(json['km_inicial']),
      kmFinal: _parseDouble(json['km_final']),
      serviciosRealizados: json['servicios_realizados'] as int?,
      horasEfectivas: _parseDouble(json['horas_efectivas']),
      observaciones: json['observaciones'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: _parseDateTime(json['created_at']) ?? DateTime.now(),
      updatedAt: _parseDateTime(json['updated_at']) ?? DateTime.now(),
      createdBy: json['created_by'] as String?,
      updatedBy: json['updated_by'] as String?,
    );
  }

  /// Parsea un DateTime desde JSON, manejando String y DateTime
  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is String) {
      return DateTime.parse(value);
    }
    if (value is DateTime) {
      return value;
    }
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    throw FormatException(
        'Valor de fecha inválido: $value (tipo: ${value.runtimeType})');
  }

  /// Parsea un double desde JSON, manejando int, double y String
  static double? _parseDouble(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is double) {
      return value;
    }
    if (value is int) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value);
    }
    return null;
  }

  @override
  AsignacionVehiculoTurnoEntity copyWith({
    String? id,
    DateTime? fecha,
    String? vehiculoId,
    String? dotacionId,
    String? plantillaTurnoId,
    String? hospitalId,
    String? baseId,
    String? estado,
    String? confirmadaPor,
    DateTime? fechaConfirmacion,
    double? kmInicial,
    double? kmFinal,
    int? serviciosRealizados,
    double? horasEfectivas,
    String? observaciones,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
  }) {
    return AsignacionVehiculoTurnoEntity(
      id: id ?? this.id,
      fecha: fecha ?? this.fecha,
      vehiculoId: vehiculoId ?? this.vehiculoId,
      dotacionId: dotacionId ?? this.dotacionId,
      plantillaTurnoId: plantillaTurnoId ?? this.plantillaTurnoId,
      hospitalId: hospitalId ?? this.hospitalId,
      baseId: baseId ?? this.baseId,
      estado: estado ?? this.estado,
      confirmadaPor: confirmadaPor ?? this.confirmadaPor,
      fechaConfirmacion: fechaConfirmacion ?? this.fechaConfirmacion,
      kmInicial: kmInicial ?? this.kmInicial,
      kmFinal: kmFinal ?? this.kmFinal,
      serviciosRealizados: serviciosRealizados ?? this.serviciosRealizados,
      horasEfectivas: horasEfectivas ?? this.horasEfectivas,
      observaciones: observaciones ?? this.observaciones,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
    );
  }

  @override
  List<Object?> get props => <Object?>[
        ...super.props,
        fecha,
        vehiculoId,
        dotacionId,
        plantillaTurnoId,
        hospitalId,
        baseId,
        estado,
        confirmadaPor,
        fechaConfirmacion,
        kmInicial,
        kmFinal,
        serviciosRealizados,
        horasEfectivas,
        observaciones,
        metadata,
        createdBy,
        updatedBy,
      ];

  @override
  String toString() {
    return 'AsignacionVehiculoTurnoEntity('
        'id: $id, '
        'fecha: $fecha, '
        'vehiculoId: $vehiculoId, '
        'dotacionId: $dotacionId, '
        'plantillaTurnoId: $plantillaTurnoId, '
        'estado: $estado'
        ')';
  }

  /// Retorna el destino de la asignación (Hospital o Base)
  String get tipoDestino {
    if (hospitalId != null) return 'Hospital';
    if (baseId != null) return 'Base';
    return 'Sin asignar';
  }

  /// Retorna el ID del destino según el tipo
  String? get destinoId {
    if (hospitalId != null) return hospitalId;
    if (baseId != null) return baseId;
    return null;
  }

  /// Verifica si la asignación está activa (planificada o activa)
  bool get esActiva {
    return estado == 'planificada' || estado == 'activa';
  }

  /// Verifica si la asignación está completada
  bool get esCompletada {
    return estado == 'completada';
  }

  /// Verifica si la asignación está cancelada
  bool get esCancelada {
    return estado == 'cancelada';
  }
}
