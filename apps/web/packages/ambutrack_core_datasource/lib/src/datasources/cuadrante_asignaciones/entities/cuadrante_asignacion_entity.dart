import 'package:equatable/equatable.dart';

/// Estados posibles de una asignación de cuadrante
enum EstadoAsignacion {
  /// Asignación planificada pero no confirmada
  planificada('planificada'),

  /// Asignación confirmada
  confirmada('confirmada'),

  /// Asignación activa en curso
  activa('activa'),

  /// Asignación completada
  completada('completada'),

  /// Asignación cancelada
  cancelada('cancelada');

  const EstadoAsignacion(this.value);

  /// Valor string del estado
  final String value;
}

/// Tipos de turno disponibles
enum TipoTurnoAsignacion {
  /// Turno de mañana
  manana('manana'),

  /// Turno de tarde
  tarde('tarde'),

  /// Turno de noche
  noche('noche'),

  /// Turno personalizado con horarios variables
  personalizado('personalizado');

  const TipoTurnoAsignacion(this.value);

  /// Valor string del tipo de turno
  final String value;
}

/// Entidad unificada de cuadrante (personal + vehículo + dotación)
///
/// Representa una asignación completa en el cuadrante que incluye:
/// - Personal asignado con su turno
/// - Vehículo asignado (opcional según categoría)
/// - Dotación y número de unidad
/// - Métricas operacionales
class CuadranteAsignacionEntity extends Equatable {
  const CuadranteAsignacionEntity({
    required this.id,
    required this.fecha,
    required this.horaInicio,
    required this.horaFin,
    this.cruzaMedianoche = false,
    required this.idPersonal,
    required this.nombrePersonal,
    this.categoriaPersonal,
    required this.tipoTurno,
    this.plantillaTurnoId,
    this.idVehiculo,
    this.matriculaVehiculo,
    required this.idDotacion,
    required this.nombreDotacion,
    this.numeroUnidad = 1,
    this.idHospital,
    this.idBase,
    this.estado = EstadoAsignacion.planificada,
    this.confirmadaPor,
    this.fechaConfirmacion,
    this.kmInicial,
    this.kmFinal,
    this.serviciosRealizados = 0,
    this.horasEfectivas,
    this.observaciones,
    this.metadata,
    this.activo = true,
    required this.createdAt,
    required this.updatedAt,
    this.createdBy,
    this.updatedBy,
  });

  // Identificación
  /// ID único de la asignación
  final String id;

  // Fecha y horarios
  /// Fecha del día de la asignación
  final DateTime fecha;

  /// Hora de inicio del turno en formato HH:mm
  final String horaInicio;

  /// Hora de fin del turno en formato HH:mm
  final String horaFin;

  /// Indica si el turno cruza medianoche (termina al día siguiente)
  final bool cruzaMedianoche;

  // Personal (obligatorio)
  /// ID del personal asignado (FK → personal)
  final String idPersonal;

  /// Nombre completo del personal (desnormalizado para performance)
  final String nombrePersonal;

  /// Categoría del personal (Médico, Enfermero, TES, Conductor, etc.)
  final String? categoriaPersonal;

  // Tipo de turno
  /// Tipo de turno (mañana, tarde, noche, personalizado)
  final TipoTurnoAsignacion tipoTurno;

  /// ID de plantilla de turno (opcional, si se usa plantilla predefinida)
  final String? plantillaTurnoId;

  // Vehículo (opcional)
  /// ID del vehículo asignado (FK → vehiculos, opcional según categoría)
  final String? idVehiculo;

  /// Matrícula del vehículo (desnormalizado para performance)
  final String? matriculaVehiculo;

  // Dotación (obligatorio)
  /// ID de la dotación/contrato (FK → dotaciones)
  final String idDotacion;

  /// Nombre de la dotación (desnormalizado para performance)
  final String nombreDotacion;

  /// Número de unidad dentro de la dotación (1, 2, 3...)
  final int numeroUnidad;

  // Destino (opcional)
  /// ID del hospital de destino (FK → centros_hospitalarios, opcional)
  final String? idHospital;

  /// ID de la base de origen (FK → bases, opcional)
  final String? idBase;

  // Estado
  /// Estado de la asignación
  final EstadoAsignacion estado;

  /// Usuario que confirmó la asignación (FK → users)
  final String? confirmadaPor;

  /// Fecha y hora de confirmación
  final DateTime? fechaConfirmacion;

  // Métricas operacionales
  /// Kilómetros iniciales del vehículo
  final double? kmInicial;

  /// Kilómetros finales del vehículo
  final double? kmFinal;

  /// Número de servicios realizados durante el turno
  final int serviciosRealizados;

  /// Horas efectivas trabajadas
  final double? horasEfectivas;

  // Observaciones
  /// Observaciones o notas adicionales
  final String? observaciones;

  /// Metadata adicional en formato JSON
  final Map<String, dynamic>? metadata;

  // Auditoría
  /// Si la asignación está activa (soft delete)
  final bool activo;

  /// Fecha de creación del registro
  final DateTime createdAt;

  /// Fecha de última actualización del registro
  final DateTime updatedAt;

  /// Usuario que creó el registro (FK → users)
  final String? createdBy;

  /// Usuario que actualizó el registro (FK → users)
  final String? updatedBy;

  @override
  List<Object?> get props => [
        id,
        fecha,
        horaInicio,
        horaFin,
        cruzaMedianoche,
        idPersonal,
        nombrePersonal,
        categoriaPersonal,
        tipoTurno,
        plantillaTurnoId,
        idVehiculo,
        matriculaVehiculo,
        idDotacion,
        nombreDotacion,
        numeroUnidad,
        idHospital,
        idBase,
        estado,
        confirmadaPor,
        fechaConfirmacion,
        kmInicial,
        kmFinal,
        serviciosRealizados,
        horasEfectivas,
        observaciones,
        metadata,
        activo,
        createdAt,
        updatedAt,
        createdBy,
        updatedBy,
      ];

  /// Retorna DateTime completo de inicio (fecha + hora)
  DateTime get fechaHoraInicio {
    final List<String> parts = horaInicio.split(':');
    return DateTime(
      fecha.year,
      fecha.month,
      fecha.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
  }

  /// Retorna DateTime completo de fin (fecha + hora, ajustando si cruza medianoche)
  DateTime get fechaHoraFin {
    final List<String> parts = horaFin.split(':');
    final DateTime fechaBase = cruzaMedianoche
        ? fecha.add(const Duration(days: 1))
        : fecha;

    return DateTime(
      fechaBase.year,
      fechaBase.month,
      fechaBase.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
  }

  /// Verifica si la asignación está activa (planificada, confirmada o activa)
  bool get esActiva =>
      estado == EstadoAsignacion.planificada ||
      estado == EstadoAsignacion.confirmada ||
      estado == EstadoAsignacion.activa;

  /// Verifica si tiene vehículo asignado
  bool get tieneVehiculo => idVehiculo != null;

  /// Verifica si está asignado a hospital
  bool get esHospital => idHospital != null;

  /// Verifica si está asignado a base
  bool get esBase => idBase != null;

  /// Retorna el destino de la asignación
  String get tipoDestino {
    if (idHospital != null) return 'Hospital';
    if (idBase != null) return 'Base';
    return 'Sin asignar';
  }

  /// Retorna el ID del destino según el tipo
  String? get destinoId {
    if (idHospital != null) return idHospital;
    if (idBase != null) return idBase;
    return null;
  }

  /// Retorna kilómetros recorridos (si están disponibles)
  double? get kilometrosRecorridos {
    if (kmInicial != null && kmFinal != null) {
      return kmFinal! - kmInicial!;
    }
    return null;
  }

  /// Copia la entidad con modificaciones
  CuadranteAsignacionEntity copyWith({
    String? id,
    DateTime? fecha,
    String? horaInicio,
    String? horaFin,
    bool? cruzaMedianoche,
    String? idPersonal,
    String? nombrePersonal,
    String? categoriaPersonal,
    TipoTurnoAsignacion? tipoTurno,
    String? plantillaTurnoId,
    String? idVehiculo,
    String? matriculaVehiculo,
    String? idDotacion,
    String? nombreDotacion,
    int? numeroUnidad,
    String? idHospital,
    String? idBase,
    EstadoAsignacion? estado,
    String? confirmadaPor,
    DateTime? fechaConfirmacion,
    double? kmInicial,
    double? kmFinal,
    int? serviciosRealizados,
    double? horasEfectivas,
    String? observaciones,
    Map<String, dynamic>? metadata,
    bool? activo,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
  }) {
    return CuadranteAsignacionEntity(
      id: id ?? this.id,
      fecha: fecha ?? this.fecha,
      horaInicio: horaInicio ?? this.horaInicio,
      horaFin: horaFin ?? this.horaFin,
      cruzaMedianoche: cruzaMedianoche ?? this.cruzaMedianoche,
      idPersonal: idPersonal ?? this.idPersonal,
      nombrePersonal: nombrePersonal ?? this.nombrePersonal,
      categoriaPersonal: categoriaPersonal ?? this.categoriaPersonal,
      tipoTurno: tipoTurno ?? this.tipoTurno,
      plantillaTurnoId: plantillaTurnoId ?? this.plantillaTurnoId,
      idVehiculo: idVehiculo ?? this.idVehiculo,
      matriculaVehiculo: matriculaVehiculo ?? this.matriculaVehiculo,
      idDotacion: idDotacion ?? this.idDotacion,
      nombreDotacion: nombreDotacion ?? this.nombreDotacion,
      numeroUnidad: numeroUnidad ?? this.numeroUnidad,
      idHospital: idHospital ?? this.idHospital,
      idBase: idBase ?? this.idBase,
      estado: estado ?? this.estado,
      confirmadaPor: confirmadaPor ?? this.confirmadaPor,
      fechaConfirmacion: fechaConfirmacion ?? this.fechaConfirmacion,
      kmInicial: kmInicial ?? this.kmInicial,
      kmFinal: kmFinal ?? this.kmFinal,
      serviciosRealizados: serviciosRealizados ?? this.serviciosRealizados,
      horasEfectivas: horasEfectivas ?? this.horasEfectivas,
      observaciones: observaciones ?? this.observaciones,
      metadata: metadata ?? this.metadata,
      activo: activo ?? this.activo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
    );
  }

  @override
  String toString() {
    return 'CuadranteAsignacionEntity('
        'id: $id, '
        'fecha: $fecha, '
        'personal: $nombrePersonal, '
        'dotacion: $nombreDotacion, '
        'unidad: $numeroUnidad, '
        'horario: $horaInicio-$horaFin, '
        'estado: ${estado.value}'
        ')';
  }
}
