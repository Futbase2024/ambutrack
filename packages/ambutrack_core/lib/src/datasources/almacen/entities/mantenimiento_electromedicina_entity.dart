import 'package:equatable/equatable.dart';

/// Tipos de mantenimiento de electromedicina
enum TipoMantenimientoElectromedicina {
  /// Mantenimiento programado
  preventivo('PREVENTIVO', 'Preventivo'),

  /// Reparación por avería
  correctivo('CORRECTIVO', 'Correctivo'),

  /// Ajuste técnico de precisión
  calibracion('CALIBRACION', 'Calibración'),

  /// Revisión técnica reglamentaria
  revisionTecnica('REVISION_TECNICA', 'Revisión Técnica'),

  /// Sustitución de componentes
  sustitucionPiezas('SUSTITUCION_PIEZAS', 'Sustitución de Piezas');

  const TipoMantenimientoElectromedicina(this.code, this.label);

  final String code;
  final String label;

  static TipoMantenimientoElectromedicina fromCode(String code) {
    return TipoMantenimientoElectromedicina.values.firstWhere(
      (tipo) => tipo.code == code,
      orElse: () => TipoMantenimientoElectromedicina.preventivo,
    );
  }
}

/// Resultado del mantenimiento
enum ResultadoMantenimiento {
  /// Equipo apto para uso
  apto('APTO', 'Apto'),

  /// Equipo no apto, requiere reparación
  noApto('NO_APTO', 'No Apto'),

  /// Equipo reparado exitosamente
  reparado('REPARADO', 'Reparado'),

  /// En proceso de reparación
  enReparacion('EN_REPARACION', 'En Reparación'),

  /// Equipo dado de baja definitiva
  bajaDefinitiva('BAJA_DEFINITIVA', 'Baja Definitiva');

  const ResultadoMantenimiento(this.code, this.label);

  final String code;
  final String label;

  static ResultadoMantenimiento fromCode(String code) {
    return ResultadoMantenimiento.values.firstWhere(
      (resultado) => resultado.code == code,
      orElse: () => ResultadoMantenimiento.apto,
    );
  }

  /// Retorna true si el equipo está operativo
  bool get esOperativo =>
      this == ResultadoMantenimiento.apto ||
      this == ResultadoMantenimiento.reparado;

  /// Retorna true si el equipo NO está operativo
  bool get noOperativo =>
      this == ResultadoMantenimiento.noApto ||
      this == ResultadoMantenimiento.enReparacion ||
      this == ResultadoMantenimiento.bajaDefinitiva;
}

/// Entidad de Mantenimiento de Electromedicina
///
/// Registra los mantenimientos, calibraciones y reparaciones
/// de equipos médicos (desfibriladores, monitores, etc.).
class MantenimientoElectromedicinaEntity extends Equatable {
  const MantenimientoElectromedicinaEntity({
    required this.id,
    required this.idProducto,
    required this.numeroSerie,
    required this.fechaMantenimiento,
    required this.tipoMantenimiento,
    this.idVehiculo,
    this.proximoMantenimiento,
    this.tecnicoResponsable,
    this.empresaExterna,
    this.resultado,
    this.observaciones,
    this.coste,
    this.numeroFactura,
    this.certificadoUrl,
    this.informeUrl,
    this.createdAt,
    this.createdBy,
  });

  /// ID único del mantenimiento
  final String id;

  /// ID del producto (equipo médico)
  final String idProducto;

  /// Número de serie del equipo
  final String numeroSerie;

  /// ID del vehículo al que está asignado (puede cambiar)
  final String? idVehiculo;

  /// Fecha de realización del mantenimiento
  final DateTime fechaMantenimiento;

  /// Fecha calculada del próximo mantenimiento
  final DateTime? proximoMantenimiento;

  /// Tipo de mantenimiento realizado
  final TipoMantenimientoElectromedicina tipoMantenimiento;

  /// Nombre del técnico responsable
  final String? tecnicoResponsable;

  /// Empresa externa que realizó el mantenimiento
  final String? empresaExterna;

  /// Resultado del mantenimiento
  final ResultadoMantenimiento? resultado;

  /// Observaciones del mantenimiento
  final String? observaciones;

  /// Coste del mantenimiento
  final double? coste;

  /// Número de factura
  final String? numeroFactura;

  /// URL del certificado de mantenimiento
  final String? certificadoUrl;

  /// URL del informe técnico
  final String? informeUrl;

  /// Fecha de creación del registro
  final DateTime? createdAt;

  /// ID del usuario que creó el registro
  final String? createdBy;

  /// Retorna true si está próximo a vencer (30 días)
  bool get proximoAVencer {
    if (proximoMantenimiento == null) return false;
    final diasRestantes = proximoMantenimiento!.difference(DateTime.now()).inDays;
    return diasRestantes <= 30 && diasRestantes >= 0;
  }

  /// Retorna true si el mantenimiento está vencido
  bool get vencido {
    if (proximoMantenimiento == null) return false;
    return proximoMantenimiento!.isBefore(DateTime.now());
  }

  @override
  List<Object?> get props => [
        id,
        idProducto,
        numeroSerie,
        idVehiculo,
        fechaMantenimiento,
        proximoMantenimiento,
        tipoMantenimiento,
        tecnicoResponsable,
        empresaExterna,
        resultado,
        observaciones,
        coste,
        numeroFactura,
        certificadoUrl,
        informeUrl,
        createdAt,
        createdBy,
      ];

  MantenimientoElectromedicinaEntity copyWith({
    String? id,
    String? idProducto,
    String? numeroSerie,
    String? idVehiculo,
    DateTime? fechaMantenimiento,
    DateTime? proximoMantenimiento,
    TipoMantenimientoElectromedicina? tipoMantenimiento,
    String? tecnicoResponsable,
    String? empresaExterna,
    ResultadoMantenimiento? resultado,
    String? observaciones,
    double? coste,
    String? numeroFactura,
    String? certificadoUrl,
    String? informeUrl,
    DateTime? createdAt,
    String? createdBy,
  }) {
    return MantenimientoElectromedicinaEntity(
      id: id ?? this.id,
      idProducto: idProducto ?? this.idProducto,
      numeroSerie: numeroSerie ?? this.numeroSerie,
      idVehiculo: idVehiculo ?? this.idVehiculo,
      fechaMantenimiento: fechaMantenimiento ?? this.fechaMantenimiento,
      proximoMantenimiento: proximoMantenimiento ?? this.proximoMantenimiento,
      tipoMantenimiento: tipoMantenimiento ?? this.tipoMantenimiento,
      tecnicoResponsable: tecnicoResponsable ?? this.tecnicoResponsable,
      empresaExterna: empresaExterna ?? this.empresaExterna,
      resultado: resultado ?? this.resultado,
      observaciones: observaciones ?? this.observaciones,
      coste: coste ?? this.coste,
      numeroFactura: numeroFactura ?? this.numeroFactura,
      certificadoUrl: certificadoUrl ?? this.certificadoUrl,
      informeUrl: informeUrl ?? this.informeUrl,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
    );
  }
}
