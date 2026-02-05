import 'package:equatable/equatable.dart';

import '../../motivos_traslado/entities/motivo_traslado_entity.dart';
import '../../pacientes/entities/paciente_entity.dart';

/// Entidad de dominio para Traslados
/// Representa una instancia concreta de transporte generada desde un servicio recurrente
class TrasladoEntity extends Equatable {
  const TrasladoEntity({
    required this.id,
    this.codigo,
    this.idServicioRecurrente,
    this.idServicio,
    this.idMotivoTraslado,
    this.motivoTraslado,
    this.idPaciente,
    this.paciente,
    this.tipoTraslado,
    this.fecha,
    this.horaProgramada,
    this.estado,
    this.idPersonalConductor,
    this.idPersonalEnfermero,
    this.idPersonalMedico,
    this.idVehiculo,
    this.matriculaVehiculo,
    this.tipoOrigen,
    this.origen,
    this.tipoDestino,
    this.destino,
    this.kmInicio,
    this.kmFin,
    this.kmTotales,
    this.observaciones,
    this.observacionesInternas,
    this.motivoCancelacion,
    this.motivoNoRealizacion,
    this.duracionEstimadaMinutos,
    this.duracionRealMinutos,
    this.prioridad = 5,
    this.fechaEnviado,
    this.fechaRecibidoConductor,
    this.fechaEnOrigen,
    this.ubicacionEnOrigen,
    this.fechaSaliendoOrigen,
    this.ubicacionSaliendoOrigen,
    this.fechaEnTransito,
    this.ubicacionEnTransito,
    this.fechaEnDestino,
    this.ubicacionEnDestino,
    this.fechaFinalizado,
    this.ubicacionFinalizado,
    this.fechaCancelado,
    this.fechaSuspendido,
    this.fechaNoRealizado,
    this.idUsuarioAsignacion,
    this.fechaAsignacion,
    this.idUsuarioEnvio,
    this.fechaEnvio,
    this.idUsuarioCancelacion,
    this.createdAt,
    this.updatedAt,
    this.createdBy,
    this.updatedBy,
  });

  // IDENTIFICACIÓN ÚNICA
  final String id;
  final String? codigo; // Nullable - puede no tener código generado

  // RELACIÓN CON SERVICIO
  final String? idServicioRecurrente; // FK hacia servicios_recurrentes (nullable para servicios únicos)
  final String? idServicio; // FK hacia servicios (cabecera del servicio)

  // MOTIVO DE TRASLADO
  final String? idMotivoTraslado; // FK hacia tmotivos_traslado
  final MotivoTrasladoEntity? motivoTraslado; // Motivo embebido (cargado opcionalmente)

  // RELACIÓN CON PACIENTE
  final String? idPaciente; // FK hacia pacientes
  final PacienteEntity? paciente; // Paciente embebido (cargado opcionalmente)

  // TIPO Y FECHA
  final String? tipoTraslado; // 'ida' o 'vuelta' (nullable)
  final DateTime? fecha; // Fecha programada del traslado (nullable)
  final DateTime? horaProgramada; // Hora programada de inicio (nullable)

  // ESTADO DEL TRASLADO
  final String? estado; // 'pendiente', 'asignado', 'enviado', etc. (nullable)

  // ASIGNACIÓN DE RECURSOS
  final String? idPersonalConductor; // FK hacia personal
  final String? idPersonalEnfermero; // FK hacia personal
  final String? idPersonalMedico; // FK hacia personal
  final String? idVehiculo; // FK hacia vehiculos
  final String? matriculaVehiculo; // Matrícula del vehículo (desnormalizada para historial)

  // ORIGEN Y DESTINO (Normalizados)
  final String? tipoOrigen; // 'domicilio_paciente', 'otro_domicilio', 'centro_hospitalario'
  final String? origen; // Dirección o ID del centro hospitalario de origen
  final String? tipoDestino; // 'domicilio_paciente', 'otro_domicilio', 'centro_hospitalario'
  final String? destino; // Dirección o ID del centro hospitalario de destino

  // KILOMETRAJE
  final double? kmInicio;
  final double? kmFin;
  final double? kmTotales;

  // OBSERVACIONES
  final String? observaciones;
  final String? observacionesInternas;

  // MOTIVOS DE FINALIZACIÓN ANORMAL
  final String? motivoCancelacion;
  final String? motivoNoRealizacion;

  // DURACIÓN
  final int? duracionEstimadaMinutos;
  final int? duracionRealMinutos;

  // PRIORIDAD
  final int prioridad; // 1-10 (1 = máxima urgencia)

  // ========== CRONAS (Timestamps cronológicos) ==========

  // 1. ENVIADO (desde sistema a conductor)
  final DateTime? fechaEnviado;

  // 2. RECIBIDO POR CONDUCTOR (conductor acepta)
  final DateTime? fechaRecibidoConductor;

  // 3. EN ORIGEN (conductor llega al punto de recogida)
  final DateTime? fechaEnOrigen;
  final Map<String, dynamic>? ubicacionEnOrigen; // {lat, lng, timestamp}

  // 4. SALIENDO DE ORIGEN (conductor inicia traslado con paciente)
  final DateTime? fechaSaliendoOrigen;
  final Map<String, dynamic>? ubicacionSaliendoOrigen; // {lat, lng, timestamp}

  // 5. EN TRÁNSITO (actualizaciones de GPS durante el viaje)
  final DateTime? fechaEnTransito;
  final Map<String, dynamic>? ubicacionEnTransito; // {lat, lng, timestamp}

  // 6. EN DESTINO (conductor llega al destino)
  final DateTime? fechaEnDestino;
  final Map<String, dynamic>? ubicacionEnDestino; // {lat, lng, timestamp}

  // 7. FINALIZADO (conductor completa el traslado)
  final DateTime? fechaFinalizado;
  final Map<String, dynamic>? ubicacionFinalizado; // {lat, lng, timestamp}

  // 8. CANCELADO (traslado cancelado antes de completar)
  final DateTime? fechaCancelado;

  // 9. SUSPENDIDO (traslado suspendido temporalmente)
  final DateTime? fechaSuspendido;

  // 10. NO REALIZADO (traslado no se pudo realizar)
  final DateTime? fechaNoRealizado;

  // ========== AUDITORÍA DE ASIGNACIÓN ==========
  final String? idUsuarioAsignacion;
  final DateTime? fechaAsignacion;
  final String? idUsuarioEnvio;
  final DateTime? fechaEnvio;
  final String? idUsuarioCancelacion;

  // AUDITORÍA GENERAL
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? createdBy;
  final String? updatedBy;

  /// Getter para verificar si el traslado está en curso
  bool get estaEnCurso {
    if (estado == null) return false;
    return estado != 'finalizado' &&
           estado != 'cancelado' &&
           estado != 'anulado' &&
           estado != 'suspendido' &&
           estado != 'no_realizado';
  }

  /// Getter para verificar si requiere asignación
  bool get requiereAsignacion {
    if (estado == null) return false;
    return estado == 'pendiente' &&
           (idPersonalConductor == null || idVehiculo == null);
  }

  /// Getter para calcular tiempo transcurrido (si está en curso)
  Duration? get tiempoTranscurrido {
    if (!estaEnCurso || fechaRecibidoConductor == null) {
      return null;
    }

    return DateTime.now().difference(fechaRecibidoConductor!);
  }

  /// Getter para nombre formateado del tipo
  String get tipoTrasladoFormateado {
    if (tipoTraslado == null) return 'Sin tipo';
    return tipoTraslado == 'ida' ? 'Ida' : 'Vuelta';
  }

  /// Getter para estado formateado
  String get estadoFormateado {
    if (estado == null) return 'Sin estado';
    switch (estado) {
      case 'pendiente':
        return 'Pendiente';
      case 'asignado':
        return 'Asignado';
      case 'enviado':
        return 'Enviado';
      case 'recibido_conductor':
        return 'Recibido por Conductor';
      case 'en_origen':
        return 'En Origen';
      case 'saliendo_origen':
        return 'Saliendo de Origen';
      case 'en_transito':
        return 'En Tránsito';
      case 'en_destino':
        return 'En Destino';
      case 'finalizado':
        return 'Finalizado';
      case 'cancelado':
        return 'Cancelado';
      case 'anulado':
        return 'Anulado';
      case 'no_realizado':
        return 'No Realizado';
      default:
        return estado!;
    }
  }

  /// Método copyWith para crear copias inmutables
  TrasladoEntity copyWith({
    String? id,
    String? codigo,
    String? idServicioRecurrente,
    String? idServicio,
    String? idMotivoTraslado,
    MotivoTrasladoEntity? motivoTraslado,
    String? idPaciente,
    PacienteEntity? paciente,
    String? tipoTraslado,
    DateTime? fecha,
    DateTime? horaProgramada,
    String? estado,
    String? idPersonalConductor,
    String? idPersonalEnfermero,
    String? idPersonalMedico,
    String? idVehiculo,
    String? matriculaVehiculo,
    String? tipoOrigen,
    String? origen,
    String? tipoDestino,
    String? destino,
    double? kmInicio,
    double? kmFin,
    double? kmTotales,
    String? observaciones,
    String? observacionesInternas,
    String? motivoCancelacion,
    String? motivoNoRealizacion,
    int? duracionEstimadaMinutos,
    int? duracionRealMinutos,
    int? prioridad,
    DateTime? fechaEnviado,
    DateTime? fechaRecibidoConductor,
    DateTime? fechaEnOrigen,
    Map<String, dynamic>? ubicacionEnOrigen,
    DateTime? fechaSaliendoOrigen,
    Map<String, dynamic>? ubicacionSaliendoOrigen,
    DateTime? fechaEnTransito,
    Map<String, dynamic>? ubicacionEnTransito,
    DateTime? fechaEnDestino,
    Map<String, dynamic>? ubicacionEnDestino,
    DateTime? fechaFinalizado,
    Map<String, dynamic>? ubicacionFinalizado,
    DateTime? fechaCancelado,
    DateTime? fechaSuspendido,
    DateTime? fechaNoRealizado,
    String? idUsuarioAsignacion,
    DateTime? fechaAsignacion,
    String? idUsuarioEnvio,
    DateTime? fechaEnvio,
    String? idUsuarioCancelacion,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
  }) {
    return TrasladoEntity(
      id: id ?? this.id,
      codigo: codigo ?? this.codigo,
      idServicioRecurrente: idServicioRecurrente ?? this.idServicioRecurrente,
      idServicio: idServicio ?? this.idServicio,
      idMotivoTraslado: idMotivoTraslado ?? this.idMotivoTraslado,
      motivoTraslado: motivoTraslado ?? this.motivoTraslado,
      idPaciente: idPaciente ?? this.idPaciente,
      paciente: paciente ?? this.paciente,
      tipoTraslado: tipoTraslado ?? this.tipoTraslado,
      fecha: fecha ?? this.fecha,
      horaProgramada: horaProgramada ?? this.horaProgramada,
      estado: estado ?? this.estado,
      idPersonalConductor: idPersonalConductor ?? this.idPersonalConductor,
      idPersonalEnfermero: idPersonalEnfermero ?? this.idPersonalEnfermero,
      idPersonalMedico: idPersonalMedico ?? this.idPersonalMedico,
      idVehiculo: idVehiculo ?? this.idVehiculo,
      matriculaVehiculo: matriculaVehiculo ?? this.matriculaVehiculo,
      tipoOrigen: tipoOrigen ?? this.tipoOrigen,
      origen: origen ?? this.origen,
      tipoDestino: tipoDestino ?? this.tipoDestino,
      destino: destino ?? this.destino,
      kmInicio: kmInicio ?? this.kmInicio,
      kmFin: kmFin ?? this.kmFin,
      kmTotales: kmTotales ?? this.kmTotales,
      observaciones: observaciones ?? this.observaciones,
      observacionesInternas: observacionesInternas ?? this.observacionesInternas,
      motivoCancelacion: motivoCancelacion ?? this.motivoCancelacion,
      motivoNoRealizacion: motivoNoRealizacion ?? this.motivoNoRealizacion,
      duracionEstimadaMinutos: duracionEstimadaMinutos ?? this.duracionEstimadaMinutos,
      duracionRealMinutos: duracionRealMinutos ?? this.duracionRealMinutos,
      prioridad: prioridad ?? this.prioridad,
      fechaEnviado: fechaEnviado ?? this.fechaEnviado,
      fechaRecibidoConductor: fechaRecibidoConductor ?? this.fechaRecibidoConductor,
      fechaEnOrigen: fechaEnOrigen ?? this.fechaEnOrigen,
      ubicacionEnOrigen: ubicacionEnOrigen ?? this.ubicacionEnOrigen,
      fechaSaliendoOrigen: fechaSaliendoOrigen ?? this.fechaSaliendoOrigen,
      ubicacionSaliendoOrigen: ubicacionSaliendoOrigen ?? this.ubicacionSaliendoOrigen,
      fechaEnTransito: fechaEnTransito ?? this.fechaEnTransito,
      ubicacionEnTransito: ubicacionEnTransito ?? this.ubicacionEnTransito,
      fechaEnDestino: fechaEnDestino ?? this.fechaEnDestino,
      ubicacionEnDestino: ubicacionEnDestino ?? this.ubicacionEnDestino,
      fechaFinalizado: fechaFinalizado ?? this.fechaFinalizado,
      ubicacionFinalizado: ubicacionFinalizado ?? this.ubicacionFinalizado,
      fechaCancelado: fechaCancelado ?? this.fechaCancelado,
      fechaSuspendido: fechaSuspendido ?? this.fechaSuspendido,
      fechaNoRealizado: fechaNoRealizado ?? this.fechaNoRealizado,
      idUsuarioAsignacion: idUsuarioAsignacion ?? this.idUsuarioAsignacion,
      fechaAsignacion: fechaAsignacion ?? this.fechaAsignacion,
      idUsuarioEnvio: idUsuarioEnvio ?? this.idUsuarioEnvio,
      fechaEnvio: fechaEnvio ?? this.fechaEnvio,
      idUsuarioCancelacion: idUsuarioCancelacion ?? this.idUsuarioCancelacion,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
    );
  }

  @override
  List<Object?> get props => [
        id,
        codigo,
        idServicioRecurrente,
        idServicio,
        idMotivoTraslado,
        motivoTraslado,
        idPaciente,
        paciente,
        tipoTraslado,
        fecha,
        horaProgramada,
        estado,
        idPersonalConductor,
        idPersonalEnfermero,
        idPersonalMedico,
        idVehiculo,
        matriculaVehiculo,
        tipoOrigen,
        origen,
        tipoDestino,
        destino,
        kmInicio,
        kmFin,
        kmTotales,
        observaciones,
        observacionesInternas,
        motivoCancelacion,
        motivoNoRealizacion,
        duracionEstimadaMinutos,
        duracionRealMinutos,
        prioridad,
        fechaEnviado,
        fechaRecibidoConductor,
        fechaEnOrigen,
        ubicacionEnOrigen,
        fechaSaliendoOrigen,
        ubicacionSaliendoOrigen,
        fechaEnTransito,
        ubicacionEnTransito,
        fechaEnDestino,
        ubicacionEnDestino,
        fechaFinalizado,
        ubicacionFinalizado,
        fechaCancelado,
        fechaSuspendido,
        fechaNoRealizado,
        idUsuarioAsignacion,
        fechaAsignacion,
        idUsuarioEnvio,
        fechaEnvio,
        idUsuarioCancelacion,
        createdAt,
        updatedAt,
        createdBy,
        updatedBy,
      ];
}
