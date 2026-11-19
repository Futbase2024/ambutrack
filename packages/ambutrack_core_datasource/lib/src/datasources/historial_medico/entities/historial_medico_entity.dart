import 'package:equatable/equatable.dart';

/// Entidad de dominio para reconocimientos médicos del personal
class HistorialMedicoEntity extends Equatable {
  const HistorialMedicoEntity({
    required this.id,
    required this.personalId,
    required this.fechaReconocimiento,
    required this.fechaCaducidad,
    required this.aptitud,
    this.observaciones,
    this.restricciones,
    this.centroMedico,
    this.nombreMedico,
    this.documentoUrl,
    required this.activo,
    this.createdAt,
    this.updatedAt,
  });

  /// ID del reconocimiento médico
  final String id;

  /// ID del personal (FK)
  final String personalId;

  /// Fecha del reconocimiento médico
  final DateTime fechaReconocimiento;

  /// Fecha de caducidad del reconocimiento
  final DateTime fechaCaducidad;

  /// Aptitud: 'apto', 'apto_con_restricciones', 'no_apto'
  final String aptitud;

  /// Observaciones generales
  final String? observaciones;

  /// Restricciones médicas si aplican
  final String? restricciones;

  /// Centro médico donde se realizó
  final String? centroMedico;

  /// Nombre del médico que realizó el reconocimiento
  final String? nombreMedico;

  /// URL del documento (PDF escaneado)
  final String? documentoUrl;

  /// Estado activo/inactivo
  final bool activo;

  /// Fecha de creación
  final DateTime? createdAt;

  /// Fecha de última actualización
  final DateTime? updatedAt;

  /// Copia la entidad con valores actualizados
  HistorialMedicoEntity copyWith({
    String? id,
    String? personalId,
    DateTime? fechaReconocimiento,
    DateTime? fechaCaducidad,
    String? aptitud,
    String? observaciones,
    String? restricciones,
    String? centroMedico,
    String? nombreMedico,
    String? documentoUrl,
    bool? activo,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return HistorialMedicoEntity(
      id: id ?? this.id,
      personalId: personalId ?? this.personalId,
      fechaReconocimiento: fechaReconocimiento ?? this.fechaReconocimiento,
      fechaCaducidad: fechaCaducidad ?? this.fechaCaducidad,
      aptitud: aptitud ?? this.aptitud,
      observaciones: observaciones ?? this.observaciones,
      restricciones: restricciones ?? this.restricciones,
      centroMedico: centroMedico ?? this.centroMedico,
      nombreMedico: nombreMedico ?? this.nombreMedico,
      documentoUrl: documentoUrl ?? this.documentoUrl,
      activo: activo ?? this.activo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Verifica si el reconocimiento está próximo a caducar (30 días)
  bool get estaProximoCaducar {
    final DateTime ahora = DateTime.now();
    final Duration diferencia = fechaCaducidad.difference(ahora);
    return diferencia.inDays <= 30 && diferencia.inDays >= 0;
  }

  /// Verifica si el reconocimiento está caducado
  bool get estaCaducado {
    return DateTime.now().isAfter(fechaCaducidad);
  }

  @override
  List<Object?> get props => <Object?>[
        id,
        personalId,
        fechaReconocimiento,
        fechaCaducidad,
        aptitud,
        observaciones,
        restricciones,
        centroMedico,
        nombreMedico,
        documentoUrl,
        activo,
        createdAt,
        updatedAt,
      ];
}

/// Tipos de aptitud médica
class AptitudMedica {
  static const String apto = 'apto';
  static const String aptoConRestricciones = 'apto_con_restricciones';
  static const String noApto = 'no_apto';

  static const List<String> valores = <String>[
    apto,
    aptoConRestricciones,
    noApto,
  ];

  static String getLabel(String aptitud) {
    switch (aptitud) {
      case apto:
        return 'Apto';
      case aptoConRestricciones:
        return 'Apto con Restricciones';
      case noApto:
        return 'No Apto';
      default:
        return aptitud;
    }
  }
}
