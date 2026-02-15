import 'package:equatable/equatable.dart';

/// Tipo de alerta de caducidad
enum AlertaTipo {
  /// Seguro del vehículo
  seguro,

  /// ITV del vehículo
  itv,

  /// Homologación sanitaria
  homologacion,

  /// Revisión técnica del vehículo
  revisionTecnica,

  /// Mantenimiento programado
  mantenimiento,

  /// Otras revisiones (inspección anual, especial, etc.)
  revision,
}

/// Severidad de la alerta basada en días restantes
enum AlertaSeveridad {
  /// Crítica: menos de 7 días
  critica,

  /// Alta: 7-30 días
  alta,

  /// Media: 31-60 días
  media,

  /// Baja: 61-90 días
  baja,
}

/// Entidad de dominio para Alertas de Caducidad
///
/// Representa una alerta de caducidad generada desde la vista materializada
/// `vw_alertas_caducidad_activas` en Supabase
class AlertaCaducidadEntity extends Equatable {
  const AlertaCaducidadEntity({
    required this.id,
    required this.tipo,
    required this.entidadId,
    required this.entidadKey,
    required this.entidadNombre,
    required this.fechaCaducidad,
    required this.diasRestantes,
    required this.severidad,
    required this.tablaOrigen,
    required this.esCritica,
    required this.prioridad,
  });

  /// Identificador único de la alerta (UUID)
  final String id;

  /// Tipo de alerta
  final AlertaTipo tipo;

  /// ID de la entidad asociada (vehículo, documento, etc.)
  final String entidadId;

  /// Clave única de la entidad (ej: "VEHICULO:uuid" o "DOCUMENTO:uuid")
  final String entidadKey;

  /// Nombre descriptivo de la entidad (ej: "1234 ABC - Toyota HiMed")
  final String entidadNombre;

  /// Fecha de caducidad
  final DateTime fechaCaducidad;

  /// Días restantes hasta la caducidad
  final int diasRestantes;

  /// Severidad de la alerta
  final AlertaSeveridad severidad;

  /// Tabla de origen en la base de datos
  final String tablaOrigen;

  /// Indica si la alerta es crítica (< 7 días)
  final bool esCritica;

  /// Prioridad para ordenamiento (1-4, siendo 1 la más alta)
  final int prioridad;

  /// Método copyWith para crear copias inmutables
  AlertaCaducidadEntity copyWith({
    String? id,
    AlertaTipo? tipo,
    String? entidadId,
    String? entidadKey,
    String? entidadNombre,
    DateTime? fechaCaducidad,
    int? diasRestantes,
    AlertaSeveridad? severidad,
    String? tablaOrigen,
    bool? esCritica,
    int? prioridad,
  }) {
    return AlertaCaducidadEntity(
      id: id ?? this.id,
      tipo: tipo ?? this.tipo,
      entidadId: entidadId ?? this.entidadId,
      entidadKey: entidadKey ?? this.entidadKey,
      entidadNombre: entidadNombre ?? this.entidadNombre,
      fechaCaducidad: fechaCaducidad ?? this.fechaCaducidad,
      diasRestantes: diasRestantes ?? this.diasRestantes,
      severidad: severidad ?? this.severidad,
      tablaOrigen: tablaOrigen ?? this.tablaOrigen,
      esCritica: esCritica ?? this.esCritica,
      prioridad: prioridad ?? this.prioridad,
    );
  }

  @override
  List<Object?> get props => [
        id,
        tipo,
        entidadId,
        entidadKey,
        entidadNombre,
        fechaCaducidad,
        diasRestantes,
        severidad,
        tablaOrigen,
        esCritica,
        prioridad,
      ];
}

/// Entidad de resumen de alertas
///
/// Representa un resumen agregado de las alertas por severidad
class AlertasResumenEntity extends Equatable {
  const AlertasResumenEntity({
    required this.criticas,
    required this.altas,
    required this.medias,
    required this.bajas,
    required this.total,
  });

  /// Número de alertas críticas (< 7 días)
  final int criticas;

  /// Número de alertas altas (7-30 días)
  final int altas;

  /// Número de alertas medias (31-60 días)
  final int medias;

  /// Número de alertas bajas (61-90 días)
  final int bajas;

  /// Total de alertas
  final int total;

  @override
  List<Object?> get props => [criticas, altas, medias, bajas, total];
}
