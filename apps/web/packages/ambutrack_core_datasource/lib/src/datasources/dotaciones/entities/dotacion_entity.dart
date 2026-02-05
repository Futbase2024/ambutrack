import '../../../core/base_entity.dart';

/// Entidad de dominio para Dotación
///
/// Una dotación define la asignación de vehículos, personal y recursos
/// a hospitales, bases o contratos, con horarios y capacidades específicas
class DotacionEntity extends BaseEntity {
  /// Código único de la dotación (generado automáticamente por Supabase)
  final String? codigo;

  /// Nombre de la dotación
  final String nombre;

  /// Descripción detallada de la dotación (opcional)
  final String? descripcion;

  /// ID del contrato al que pertenece (opcional)
  final String? contratoId;

  /// ID del hospital al que pertenece (opcional)
  final String? hospitalId;

  /// ID de la base a la que pertenece (opcional)
  final String? baseId;

  /// ID del tipo de vehículo asignado
  final String tipoVehiculoId;

  /// ID de la plantilla de turno (opcional)
  final String? plantillaTurnoId;

  /// Cantidad de unidades de esta dotación
  final int cantidadUnidades;

  /// Prioridad de la dotación (0 = baja, mayor número = mayor prioridad)
  final int prioridad;

  /// Fecha de inicio de vigencia de la dotación
  final DateTime fechaInicio;

  /// Fecha de fin de vigencia de la dotación (opcional)
  final DateTime? fechaFin;

  /// Si aplica para lunes
  final bool aplicaLunes;

  /// Si aplica para martes
  final bool aplicaMartes;

  /// Si aplica para miércoles
  final bool aplicaMiercoles;

  /// Si aplica para jueves
  final bool aplicaJueves;

  /// Si aplica para viernes
  final bool aplicaViernes;

  /// Si aplica para sábado
  final bool aplicaSabado;

  /// Si aplica para domingo
  final bool aplicaDomingo;

  /// Si la dotación está activa en el sistema
  final bool activo;

  /// Metadatos adicionales en formato JSON (opcional)
  final Map<String, dynamic>? metadata;

  /// Crea una nueva instancia de [DotacionEntity]
  const DotacionEntity({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    this.codigo,
    required this.nombre,
    this.descripcion,
    this.contratoId,
    this.hospitalId,
    this.baseId,
    required this.tipoVehiculoId,
    this.plantillaTurnoId,
    this.cantidadUnidades = 1,
    this.prioridad = 0,
    required this.fechaInicio,
    this.fechaFin,
    this.aplicaLunes = true,
    this.aplicaMartes = true,
    this.aplicaMiercoles = true,
    this.aplicaJueves = true,
    this.aplicaViernes = true,
    this.aplicaSabado = true,
    this.aplicaDomingo = true,
    this.activo = true,
    this.metadata,
  }) : assert(
          (hospitalId != null && baseId == null) ||
              (baseId != null && hospitalId == null) ||
              (contratoId != null),
          'La dotación debe pertenecer a hospital XOR base XOR contrato',
        );

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      if (codigo != null) 'codigo': codigo,
      'nombre': nombre,
      'descripcion': descripcion,
      'contrato_id': contratoId,
      'hospital_id': hospitalId,
      'base_id': baseId,
      'tipo_vehiculo_id': tipoVehiculoId,
      'plantilla_turno_id': plantillaTurnoId,
      'cantidad_unidades': cantidadUnidades,
      'prioridad': prioridad,
      'fecha_inicio': fechaInicio.toIso8601String(),
      if (fechaFin != null) 'fecha_fin': fechaFin!.toIso8601String(),
      'aplica_lunes': aplicaLunes,
      'aplica_martes': aplicaMartes,
      'aplica_miercoles': aplicaMiercoles,
      'aplica_jueves': aplicaJueves,
      'aplica_viernes': aplicaViernes,
      'aplica_sabado': aplicaSabado,
      'aplica_domingo': aplicaDomingo,
      'activo': activo,
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Crea un [DotacionEntity] desde datos JSON
  factory DotacionEntity.fromJson(Map<String, dynamic> json) {
    return DotacionEntity(
      id: json['id'] as String,
      codigo: json['codigo'] as String?,
      nombre: json['nombre'] as String,
      descripcion: json['descripcion'] as String?,
      contratoId: json['contrato_id'] as String?,
      hospitalId: json['hospital_id'] as String?,
      baseId: json['base_id'] as String?,
      tipoVehiculoId: json['tipo_vehiculo_id'] as String,
      plantillaTurnoId: json['plantilla_turno_id'] as String?,
      cantidadUnidades: json['cantidad_unidades'] as int? ?? 1,
      prioridad: json['prioridad'] as int? ?? 0,
      fechaInicio: _parseDateTime(json['fecha_inicio'])!,
      fechaFin: _parseDateTime(json['fecha_fin']),
      aplicaLunes: json['aplica_lunes'] as bool? ?? true,
      aplicaMartes: json['aplica_martes'] as bool? ?? true,
      aplicaMiercoles: json['aplica_miercoles'] as bool? ?? true,
      aplicaJueves: json['aplica_jueves'] as bool? ?? true,
      aplicaViernes: json['aplica_viernes'] as bool? ?? true,
      aplicaSabado: json['aplica_sabado'] as bool? ?? true,
      aplicaDomingo: json['aplica_domingo'] as bool? ?? true,
      activo: json['activo'] as bool? ?? true,
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: _parseDateTime(json['created_at']) ?? DateTime.now(),
      updatedAt: _parseDateTime(json['updated_at']) ?? DateTime.now(),
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
    throw FormatException('Valor de fecha inválido: $value (tipo: ${value.runtimeType})');
  }

  @override
  DotacionEntity copyWith({
    String? id,
    String? codigo,
    String? nombre,
    String? descripcion,
    String? contratoId,
    String? hospitalId,
    String? baseId,
    String? tipoVehiculoId,
    String? plantillaTurnoId,
    int? cantidadUnidades,
    int? prioridad,
    DateTime? fechaInicio,
    DateTime? fechaFin,
    bool? aplicaLunes,
    bool? aplicaMartes,
    bool? aplicaMiercoles,
    bool? aplicaJueves,
    bool? aplicaViernes,
    bool? aplicaSabado,
    bool? aplicaDomingo,
    bool? activo,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DotacionEntity(
      id: id ?? this.id,
      codigo: codigo ?? this.codigo,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      contratoId: contratoId ?? this.contratoId,
      hospitalId: hospitalId ?? this.hospitalId,
      baseId: baseId ?? this.baseId,
      tipoVehiculoId: tipoVehiculoId ?? this.tipoVehiculoId,
      plantillaTurnoId: plantillaTurnoId ?? this.plantillaTurnoId,
      cantidadUnidades: cantidadUnidades ?? this.cantidadUnidades,
      prioridad: prioridad ?? this.prioridad,
      fechaInicio: fechaInicio ?? this.fechaInicio,
      fechaFin: fechaFin ?? this.fechaFin,
      aplicaLunes: aplicaLunes ?? this.aplicaLunes,
      aplicaMartes: aplicaMartes ?? this.aplicaMartes,
      aplicaMiercoles: aplicaMiercoles ?? this.aplicaMiercoles,
      aplicaJueves: aplicaJueves ?? this.aplicaJueves,
      aplicaViernes: aplicaViernes ?? this.aplicaViernes,
      aplicaSabado: aplicaSabado ?? this.aplicaSabado,
      aplicaDomingo: aplicaDomingo ?? this.aplicaDomingo,
      activo: activo ?? this.activo,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => <Object?>[
        ...super.props,
        codigo,
        nombre,
        descripcion,
        contratoId,
        hospitalId,
        baseId,
        tipoVehiculoId,
        plantillaTurnoId,
        cantidadUnidades,
        prioridad,
        fechaInicio,
        fechaFin,
        aplicaLunes,
        aplicaMartes,
        aplicaMiercoles,
        aplicaJueves,
        aplicaViernes,
        aplicaSabado,
        aplicaDomingo,
        activo,
        metadata,
      ];

  @override
  String toString() {
    return 'DotacionEntity('
        'id: $id, '
        'codigo: $codigo, '
        'nombre: $nombre, '
        'tipoVehiculoId: $tipoVehiculoId, '
        'cantidadUnidades: $cantidadUnidades, '
        'prioridad: $prioridad, '
        'activo: $activo'
        ')';
  }

  /// Determina el destino de la dotación (Hospital, Base o Contrato)
  String get tipoDestino {
    if (hospitalId != null) return 'Hospital';
    if (baseId != null) return 'Base';
    if (contratoId != null) return 'Contrato';
    return 'Sin asignar';
  }

  /// Retorna el ID del destino según el tipo
  String? get destinoId {
    if (hospitalId != null) return hospitalId;
    if (baseId != null) return baseId;
    if (contratoId != null) return contratoId;
    return null;
  }

  /// Retorna los días de la semana en que aplica esta dotación
  List<String> get diasAplicables {
    final List<String> dias = <String>[];
    if (aplicaLunes) dias.add('Lunes');
    if (aplicaMartes) dias.add('Martes');
    if (aplicaMiercoles) dias.add('Miércoles');
    if (aplicaJueves) dias.add('Jueves');
    if (aplicaViernes) dias.add('Viernes');
    if (aplicaSabado) dias.add('Sábado');
    if (aplicaDomingo) dias.add('Domingo');
    return dias;
  }

  /// Verifica si la dotación está vigente en una fecha específica
  bool esVigenteEn(DateTime fecha) {
    // Normalizar a solo fecha (ignorar hora/zona horaria)
    final DateTime fechaSoloFecha = DateTime(fecha.year, fecha.month, fecha.day);
    final DateTime inicioSoloFecha = DateTime(fechaInicio.year, fechaInicio.month, fechaInicio.day);
    final DateTime? finSoloFecha = fechaFin != null
        ? DateTime(fechaFin!.year, fechaFin!.month, fechaFin!.day)
        : null;

    final bool despuesDeInicio = fechaSoloFecha.isAfter(inicioSoloFecha) ||
                                  fechaSoloFecha.isAtSameMomentAs(inicioSoloFecha);
    final bool antesDeFin = finSoloFecha == null ||
                             fechaSoloFecha.isBefore(finSoloFecha) ||
                             fechaSoloFecha.isAtSameMomentAs(finSoloFecha);
    return despuesDeInicio && antesDeFin && activo;
  }

  /// Verifica si la dotación aplica en un día de la semana específico
  /// [diaNumero]: 1 = Lunes, 7 = Domingo
  bool aplicaEnDia(int diaNumero) {
    switch (diaNumero) {
      case 1:
        return aplicaLunes;
      case 2:
        return aplicaMartes;
      case 3:
        return aplicaMiercoles;
      case 4:
        return aplicaJueves;
      case 5:
        return aplicaViernes;
      case 6:
        return aplicaSabado;
      case 7:
        return aplicaDomingo;
      default:
        return false;
    }
  }
}
