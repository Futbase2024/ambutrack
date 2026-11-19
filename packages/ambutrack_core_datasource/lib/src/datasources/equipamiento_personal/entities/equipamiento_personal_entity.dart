import 'package:equatable/equatable.dart';

/// Entidad de dominio para el equipamiento asignado al personal
class EquipamientoPersonalEntity extends Equatable {
  const EquipamientoPersonalEntity({
    required this.id,
    required this.personalId,
    required this.tipoEquipamiento,
    required this.nombreEquipamiento,
    required this.fechaAsignacion,
    this.fechaDevolucion,
    this.numeroSerie,
    this.talla,
    this.estado,
    this.observaciones,
    this.documentoUrl,
    required this.activo,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String personalId;
  final String tipoEquipamiento; // 'uniforme', 'epi', 'tecnologico', 'sanitario'
  final String nombreEquipamiento;
  final DateTime fechaAsignacion;
  final DateTime? fechaDevolucion;
  final String? numeroSerie;
  final String? talla;
  final String? estado; // 'nuevo', 'bueno', 'regular', 'malo'
  final String? observaciones;
  final String? documentoUrl;
  final bool activo;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  /// Verifica si el equipamiento está actualmente asignado
  bool get estaAsignado => fechaDevolucion == null && activo;

  /// Verifica si el equipamiento fue devuelto
  bool get fueDevuelto => fechaDevolucion != null;

  @override
  List<Object?> get props => [
        id,
        personalId,
        tipoEquipamiento,
        nombreEquipamiento,
        fechaAsignacion,
        fechaDevolucion,
        numeroSerie,
        talla,
        estado,
        observaciones,
        documentoUrl,
        activo,
        createdAt,
        updatedAt,
      ];
}

/// Constantes para tipos de equipamiento
class TipoEquipamiento {
  const TipoEquipamiento._();

  static const String uniforme = 'uniforme';
  static const String epi = 'epi'; // Equipos de protección individual
  static const String tecnologico = 'tecnologico';
  static const String sanitario = 'sanitario';
}

/// Constantes para estados del equipamiento
class EstadoEquipamiento {
  const EstadoEquipamiento._();

  static const String nuevo = 'nuevo';
  static const String bueno = 'bueno';
  static const String regular = 'regular';
  static const String malo = 'malo';
}
