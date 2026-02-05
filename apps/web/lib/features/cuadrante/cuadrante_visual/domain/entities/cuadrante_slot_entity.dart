import 'package:equatable/equatable.dart';

/// Entidad que representa un slot (posición) en el cuadrante
///
/// Un slot es una posición donde se puede asignar:
/// - Personal (con su rol: conductor, TES, técnico)
/// - Vehículo (ambulancia)
///
/// Ejemplo: "Turno de Noche HUPR - Unidad #1 - Lunes 22"
class CuadranteSlotEntity extends Equatable {
  const CuadranteSlotEntity({
    required this.dotacionId,
    required this.fecha,
    required this.numeroUnidad,
    this.personalId,
    this.personalNombre,
    this.rolPersonal,
    this.vehiculoId,
    this.vehiculoMatricula,
    this.asignacionId,
    this.notas,
  });

  /// ID de la dotación a la que pertenece este slot
  final String dotacionId;

  /// Fecha del slot (día específico)
  final DateTime fecha;

  /// Número de unidad dentro de la dotación (1, 2, 3... N)
  /// Si la dotación requiere 10 vehículos, habrá slots 1-10
  final int numeroUnidad;

  /// ID del personal asignado (nullable)
  final String? personalId;

  /// Nombre del personal asignado (para mostrar)
  final String? personalNombre;

  /// Rol del personal en este slot ('conductor', 'tes', 'tecnico')
  final String? rolPersonal;

  /// ID del vehículo asignado (nullable)
  final String? vehiculoId;

  /// Matrícula del vehículo (para mostrar)
  final String? vehiculoMatricula;

  /// ID de la asignación en BD (si ya está guardada)
  final String? asignacionId;

  /// Notas u observaciones
  final String? notas;

  /// Identificador único del slot (dotacion + fecha + unidad)
  String get slotId => '${dotacionId}_${fecha.toIso8601String()}_$numeroUnidad';

  /// Verifica si el slot está vacío (sin personal ni vehículo)
  bool get estaVacio => personalId == null && vehiculoId == null;

  /// Verifica si el slot está completo (tiene personal Y vehículo)
  bool get estaCompleto => personalId != null && vehiculoId != null;

  /// Verifica si el slot está parcialmente asignado
  bool get estaParcial => !estaVacio && !estaCompleto;

  /// Verifica si tiene personal asignado
  bool get tienePersonal => personalId != null;

  /// Verifica si tiene vehículo asignado
  bool get tieneVehiculo => vehiculoId != null;

  /// Verifica si el personal asignado es conductor
  bool get esRolConductor => rolPersonal?.toLowerCase() == 'conductor';

  /// Verifica si el personal asignado es TES
  bool get esRolTES => rolPersonal?.toLowerCase() == 'tes';

  /// Verifica si el personal asignado es técnico
  bool get esRolTecnico => rolPersonal?.toLowerCase() == 'tecnico';

  /// Color según estado del slot
  /// - Verde: Completo
  /// - Amarillo: Parcial
  /// - Gris: Vacío
  String get estadoColor {
    if (estaCompleto) {
      return 'success';
    }
    if (estaParcial) {
      return 'warning';
    }
    return 'empty';
  }

  @override
  List<Object?> get props => <Object?>[
        dotacionId,
        fecha,
        numeroUnidad,
        personalId,
        personalNombre,
        rolPersonal,
        vehiculoId,
        vehiculoMatricula,
        asignacionId,
        notas,
      ];

  /// Crea una copia con modificaciones
  CuadranteSlotEntity copyWith({
    String? dotacionId,
    DateTime? fecha,
    int? numeroUnidad,
    String? personalId,
    String? personalNombre,
    String? rolPersonal,
    String? vehiculoId,
    String? vehiculoMatricula,
    String? asignacionId,
    String? notas,
  }) {
    return CuadranteSlotEntity(
      dotacionId: dotacionId ?? this.dotacionId,
      fecha: fecha ?? this.fecha,
      numeroUnidad: numeroUnidad ?? this.numeroUnidad,
      personalId: personalId ?? this.personalId,
      personalNombre: personalNombre ?? this.personalNombre,
      rolPersonal: rolPersonal ?? this.rolPersonal,
      vehiculoId: vehiculoId ?? this.vehiculoId,
      vehiculoMatricula: vehiculoMatricula ?? this.vehiculoMatricula,
      asignacionId: asignacionId ?? this.asignacionId,
      notas: notas ?? this.notas,
    );
  }

  /// Limpia el personal del slot
  CuadranteSlotEntity limpiarPersonal() {
    return copyWith(
      personalId: '',
      personalNombre: '',
      rolPersonal: '',
    );
  }

  /// Limpia el vehículo del slot
  CuadranteSlotEntity limpiarVehiculo() {
    return copyWith(
      vehiculoId: '',
      vehiculoMatricula: '',
    );
  }

  /// Limpia completamente el slot
  CuadranteSlotEntity limpiar() {
    return copyWith(
      personalId: '',
      personalNombre: '',
      rolPersonal: '',
      vehiculoId: '',
      vehiculoMatricula: '',
      asignacionId: '',
      notas: '',
    );
  }

  @override
  String toString() {
    return 'CuadranteSlot('
        'dotacion: $dotacionId, '
        'fecha: ${fecha.toIso8601String().substring(0, 10)}, '
        'unidad: $numeroUnidad, '
        'personal: ${personalNombre ?? "vacío"}, '
        'rol: ${rolPersonal ?? "N/A"}, '
        'vehiculo: ${vehiculoMatricula ?? "vacío"}'
        ')';
  }
}
