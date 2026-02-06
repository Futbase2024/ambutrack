import 'package:ambutrack_core/src/core/base_entity.dart';

/// Entidad de dominio que representa un contrato
class ContratoEntity extends BaseEntity {

  const ContratoEntity({
    required super.id,
    required this.codigo,
    required this.hospitalId,
    required this.fechaInicio,
    this.fechaFin,
    this.descripcion,
    this.tipoContrato,
    this.importeMensual,
    this.condicionesEspeciales,
    required this.activo,
    this.metadata,
    required super.createdAt,
    required super.updatedAt,
    this.createdBy,
    this.updatedBy,
  });

  /// Código único del contrato
  final String codigo;

  /// ID del centro hospitalario asociado
  final String hospitalId;

  /// Fecha de inicio del contrato
  final DateTime fechaInicio;

  /// Fecha de fin del contrato (null = indefinido)
  final DateTime? fechaFin;

  /// Descripción del contrato
  final String? descripcion;

  /// Tipo de contrato (ej: "URGENCIAS", "PROGRAMADO", "MIXTO")
  final String? tipoContrato;

  /// Importe mensual del contrato
  final double? importeMensual;

  /// Condiciones especiales del contrato (JSON)
  final Map<String, dynamic>? condicionesEspeciales;

  /// Estado activo/inactivo
  final bool activo;

  /// Metadata adicional (JSON)
  final Map<String, dynamic>? metadata;

  /// ID del usuario que creó el contrato
  final String? createdBy;

  /// ID del usuario que actualizó el contrato
  final String? updatedBy;

  /// Verifica si el contrato está vigente en la fecha actual
  bool get esVigente {
    final DateTime ahora = DateTime.now();
    final bool iniciado = ahora.isAfter(fechaInicio) ||
        ahora.isAtSameMomentAs(fechaInicio);
    final bool noFinalizado = fechaFin == null || ahora.isBefore(fechaFin!);
    return activo && iniciado && noFinalizado;
  }

  /// Verifica si el contrato ha finalizado
  bool get haFinalizado {
    if (fechaFin == null) {
      return false;
    }
    return DateTime.now().isAfter(fechaFin!);
  }

  /// Obtiene el período de vigencia en formato legible
  String get periodoVigencia {
    final String inicio = '${fechaInicio.day.toString().padLeft(2, '0')}/'
        '${fechaInicio.month.toString().padLeft(2, '0')}/'
        '${fechaInicio.year}';

    if (fechaFin == null) {
      return '$inicio - Indefinido';
    }

    final String fin = '${fechaFin!.day.toString().padLeft(2, '0')}/'
        '${fechaFin!.month.toString().padLeft(2, '0')}/'
        '${fechaFin!.year}';

    return '$inicio - $fin';
  }

  @override
  List<Object?> get props => <Object?>[
        id,
        codigo,
        hospitalId,
        fechaInicio,
        fechaFin,
        descripcion,
        tipoContrato,
        importeMensual,
        condicionesEspeciales,
        activo,
        metadata,
        createdAt,
        updatedAt,
        createdBy,
        updatedBy,
      ];

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'codigo': codigo,
      'hospital_id': hospitalId,
      'fecha_inicio': fechaInicio.toIso8601String(),
      'fecha_fin': fechaFin?.toIso8601String(),
      'descripcion': descripcion,
      'tipo_contrato': tipoContrato,
      'importe_mensual': importeMensual,
      'condiciones_especiales': condicionesEspeciales,
      'activo': activo,
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'created_by': createdBy,
      'updated_by': updatedBy,
    };
  }

  @override
  ContratoEntity copyWith({
    String? id,
    String? codigo,
    String? hospitalId,
    DateTime? fechaInicio,
    DateTime? fechaFin,
    String? descripcion,
    String? tipoContrato,
    double? importeMensual,
    Map<String, dynamic>? condicionesEspeciales,
    bool? activo,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
  }) {
    return ContratoEntity(
      id: id ?? this.id,
      codigo: codigo ?? this.codigo,
      hospitalId: hospitalId ?? this.hospitalId,
      fechaInicio: fechaInicio ?? this.fechaInicio,
      fechaFin: fechaFin ?? this.fechaFin,
      descripcion: descripcion ?? this.descripcion,
      tipoContrato: tipoContrato ?? this.tipoContrato,
      importeMensual: importeMensual ?? this.importeMensual,
      condicionesEspeciales: condicionesEspeciales ?? this.condicionesEspeciales,
      activo: activo ?? this.activo,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
    );
  }
}
