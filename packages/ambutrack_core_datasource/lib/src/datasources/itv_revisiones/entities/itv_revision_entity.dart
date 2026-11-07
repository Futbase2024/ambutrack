import '../../../core/base_entity.dart';

/// Entidad de ITV o Revisión
class ItvRevisionEntity extends BaseEntity {
  const ItvRevisionEntity({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    required this.vehiculoId,
    required this.fecha,
    required this.tipo,
    required this.resultado,
    required this.kmVehiculo,
    this.fechaVencimiento,
    this.observaciones,
    this.taller,
    this.numeroDocumento,
    this.costoTotal = 0.0,
    this.estado = EstadoItvRevision.pendiente,
    this.empresaId,
    this.createdBy,
    this.updatedBy,
  });

  final String vehiculoId;
  final DateTime fecha;
  final TipoItvRevision tipo;
  final ResultadoItvRevision resultado;
  final double kmVehiculo;
  final DateTime? fechaVencimiento;
  final String? observaciones;
  final String? taller;
  final String? numeroDocumento;
  final double costoTotal;
  final EstadoItvRevision estado;
  final String? empresaId;
  final String? createdBy;
  final String? updatedBy;

  @override
  List<Object?> get props => <Object?>[
        id,
        vehiculoId,
        fecha,
        tipo,
        resultado,
        kmVehiculo,
        fechaVencimiento,
        observaciones,
        taller,
        numeroDocumento,
        costoTotal,
        estado,
        empresaId,
        createdAt,
        createdBy,
        updatedAt,
        updatedBy,
      ];

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      if (id.isNotEmpty) 'id': id,  // ✅ Solo incluir id si no está vacío
      'vehiculo_id': vehiculoId,
      'fecha': fecha.toIso8601String(),
      'tipo': tipo.toSnakeCase(),
      'resultado': resultado.toSnakeCase(),
      'km_vehiculo': kmVehiculo,
      'fecha_vencimiento': fechaVencimiento?.toIso8601String(),
      'observaciones': observaciones,
      'taller': taller,
      'numero_documento': numeroDocumento,
      'costo_total': costoTotal,
      'estado': estado.toSnakeCase(),
      'empresa_id': empresaId,
      'created_at': createdAt.toIso8601String(),
      'created_by': createdBy,
      'updated_at': updatedAt.toIso8601String(),
      'updated_by': updatedBy,
    };
  }

  /// Copia la entidad con los campos modificados
  @override
  ItvRevisionEntity copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? vehiculoId,
    DateTime? fecha,
    TipoItvRevision? tipo,
    ResultadoItvRevision? resultado,
    double? kmVehiculo,
    DateTime? fechaVencimiento,
    String? observaciones,
    String? taller,
    String? numeroDocumento,
    double? costoTotal,
    EstadoItvRevision? estado,
    String? empresaId,
    String? createdBy,
    String? updatedBy,
  }) {
    return ItvRevisionEntity(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      vehiculoId: vehiculoId ?? this.vehiculoId,
      fecha: fecha ?? this.fecha,
      tipo: tipo ?? this.tipo,
      resultado: resultado ?? this.resultado,
      kmVehiculo: kmVehiculo ?? this.kmVehiculo,
      fechaVencimiento: fechaVencimiento ?? this.fechaVencimiento,
      observaciones: observaciones ?? this.observaciones,
      taller: taller ?? this.taller,
      numeroDocumento: numeroDocumento ?? this.numeroDocumento,
      costoTotal: costoTotal ?? this.costoTotal,
      estado: estado ?? this.estado,
      empresaId: empresaId ?? this.empresaId,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
    );
  }
}

/// Tipos de ITV o Revisión
enum TipoItvRevision {
  itv,
  revisionTecnica,
  inspeccionAnual,
  inspeccionEspecial;

  String get displayName {
    switch (this) {
      case TipoItvRevision.itv:
        return 'ITV';
      case TipoItvRevision.revisionTecnica:
        return 'Revisión Técnica';
      case TipoItvRevision.inspeccionAnual:
        return 'Inspección Anual';
      case TipoItvRevision.inspeccionEspecial:
        return 'Inspección Especial';
    }
  }

  static TipoItvRevision fromString(String? value) {
    if (value == null) return TipoItvRevision.itv;

    switch (value.toLowerCase()) {
      case 'itv':
        return TipoItvRevision.itv;
      case 'revision_tecnica':
      case 'revisiontecnica':
        return TipoItvRevision.revisionTecnica;
      case 'inspeccion_anual':
      case 'inspeccionanual':
        return TipoItvRevision.inspeccionAnual;
      case 'inspeccion_especial':
      case 'inspeccionespecial':
        return TipoItvRevision.inspeccionEspecial;
      default:
        return TipoItvRevision.itv;
    }
  }

  String toSnakeCase() {
    switch (this) {
      case TipoItvRevision.itv:
        return 'itv';
      case TipoItvRevision.revisionTecnica:
        return 'revision_tecnica';
      case TipoItvRevision.inspeccionAnual:
        return 'inspeccion_anual';
      case TipoItvRevision.inspeccionEspecial:
        return 'inspeccion_especial';
    }
  }
}

/// Resultado de la ITV o Revisión
enum ResultadoItvRevision {
  favorable,
  desfavorable,
  negativo,
  pendiente;

  String get displayName {
    switch (this) {
      case ResultadoItvRevision.favorable:
        return 'Favorable';
      case ResultadoItvRevision.desfavorable:
        return 'Desfavorable';
      case ResultadoItvRevision.negativo:
        return 'Negativo';
      case ResultadoItvRevision.pendiente:
        return 'Pendiente';
    }
  }

  static ResultadoItvRevision fromString(String? value) {
    if (value == null) return ResultadoItvRevision.pendiente;

    switch (value.toLowerCase()) {
      case 'favorable':
        return ResultadoItvRevision.favorable;
      case 'desfavorable':
        return ResultadoItvRevision.desfavorable;
      case 'negativo':
        return ResultadoItvRevision.negativo;
      case 'pendiente':
        return ResultadoItvRevision.pendiente;
      default:
        return ResultadoItvRevision.pendiente;
    }
  }

  String toSnakeCase() {
    switch (this) {
      case ResultadoItvRevision.favorable:
        return 'favorable';
      case ResultadoItvRevision.desfavorable:
        return 'desfavorable';
      case ResultadoItvRevision.negativo:
        return 'negativo';
      case ResultadoItvRevision.pendiente:
        return 'pendiente';
    }
  }
}

/// Estado de la ITV o Revisión
enum EstadoItvRevision {
  pendiente,
  realizada,
  vencida,
  cancelada;

  String get displayName {
    switch (this) {
      case EstadoItvRevision.pendiente:
        return 'Pendiente';
      case EstadoItvRevision.realizada:
        return 'Realizada';
      case EstadoItvRevision.vencida:
        return 'Vencida';
      case EstadoItvRevision.cancelada:
        return 'Cancelada';
    }
  }

  static EstadoItvRevision fromString(String? value) {
    if (value == null) return EstadoItvRevision.pendiente;

    switch (value.toLowerCase()) {
      case 'pendiente':
        return EstadoItvRevision.pendiente;
      case 'realizada':
        return EstadoItvRevision.realizada;
      case 'vencida':
        return EstadoItvRevision.vencida;
      case 'cancelada':
        return EstadoItvRevision.cancelada;
      default:
        return EstadoItvRevision.pendiente;
    }
  }

  String toSnakeCase() {
    switch (this) {
      case EstadoItvRevision.pendiente:
        return 'pendiente';
      case EstadoItvRevision.realizada:
        return 'realizada';
      case EstadoItvRevision.vencida:
        return 'vencida';
      case EstadoItvRevision.cancelada:
        return 'cancelada';
    }
  }
}
