import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'estado_traslado_enum.dart';
import 'ubicacion_entity.dart';

/// Entidad de dominio que representa un traslado
class TrasladoEntity extends Equatable {
  const TrasladoEntity({
    required this.id,
    required this.codigo,
    required this.idPaciente,
    required this.tipoTraslado,
    required this.fecha,
    required this.horaProgramada,
    required this.estado,
    required this.fechaCreacion,
    this.idServicioRecurrente,
    this.idServicio,
    this.idVehiculo,
    this.matriculaVehiculo,
    this.idConductor,
    this.personalAsignado,
    this.fechaAsignacion,
    this.usuarioAsignacion,
    this.fechaEnviado,
    this.usuarioEnvio,
    this.fechaRecibidoConductor,
    this.fechaEnOrigen,
    this.ubicacionEnOrigen,
    this.fechaSaliendoOrigen,
    this.ubicacionSaliendoOrigen,
    this.fechaEnDestino,
    this.ubicacionEnDestino,
    this.fechaFinalizado,
    this.ubicacionFinalizado,
    this.fechaCancelacion,
    this.motivoCancelacion,
    this.observacionesCancelacion,
    this.usuarioCancelacion,
    this.fechaNoRealizado,
    this.fechaSuspendido,
    this.pacienteConfirmado = false,
    this.fechaConfirmacionPaciente,
    this.metodoConfirmacion,
    this.tipoAmbulancia,
    this.requiereAcompanante = false,
    this.requiereSillaRuedas = false,
    this.requiereCamilla = false,
    this.requiereAyuda = false,
    this.observaciones,
    this.observacionesMedicas,
    this.tipoOrigen,
    this.origen,
    this.origenUbicacionCentro,
    this.tipoDestino,
    this.destino,
    this.destinoUbicacionCentro,
    this.idMotivoTraslado,
    this.facturado = false,
    this.fechaFacturacion,
    this.importeFacturado,
    this.tiempoEsperaOrigenMinutos,
    this.tiempoViajeMinutos,
    this.kilometrosRecorridos,
    this.generadoAutomaticamente = true,
    this.editadoManualmente = false,
    this.prioridad = 5,
    required this.createdAt,
    required this.updatedAt,
    this.createdBy,
    this.updatedBy,
    // Datos desnormalizados para mostrar sin joins
    this.pacienteNombre,
    this.conductorNombre,
    this.vehiculoMatricula,
    this.poblacionPaciente,
    this.poblacionCentroOrigen,
    this.poblacionCentroDestino,
  });

  final String id;
  final String codigo;
  final String idPaciente;
  final String tipoTraslado;
  final DateTime fecha;
  final String horaProgramada; // Formato HH:mm:ss
  final EstadoTraslado estado;
  final DateTime fechaCreacion;

  // Referencias opcionales
  final String? idServicioRecurrente;
  final String? idServicio;
  final String? idVehiculo;
  final String? matriculaVehiculo;
  final String? idConductor;
  final List<String>? personalAsignado; // Array de IDs de personal

  // Fechas de transiciones de estado
  final DateTime? fechaAsignacion;
  final String? usuarioAsignacion;
  final DateTime? fechaEnviado;
  final String? usuarioEnvio;
  final DateTime? fechaRecibidoConductor;
  final DateTime? fechaEnOrigen;
  final UbicacionEntity? ubicacionEnOrigen;
  final DateTime? fechaSaliendoOrigen;
  final UbicacionEntity? ubicacionSaliendoOrigen;
  final DateTime? fechaEnDestino;
  final UbicacionEntity? ubicacionEnDestino;
  final DateTime? fechaFinalizado;
  final UbicacionEntity? ubicacionFinalizado;

  // Cancelación y otros estados finales
  final DateTime? fechaCancelacion;
  final String? motivoCancelacion;
  final String? observacionesCancelacion;
  final String? usuarioCancelacion;
  final DateTime? fechaNoRealizado;
  final DateTime? fechaSuspendido;

  // Confirmación paciente
  final bool pacienteConfirmado;
  final DateTime? fechaConfirmacionPaciente;
  final String? metodoConfirmacion;

  // Requisitos del traslado
  final String? tipoAmbulancia;
  final bool requiereAcompanante;
  final bool requiereSillaRuedas;
  final bool requiereCamilla;
  final bool requiereAyuda;

  // Observaciones
  final String? observaciones;
  final String? observacionesMedicas;

  // Origen y destino
  final String? tipoOrigen; // 'domicilio', 'hospital', etc.
  final String? origen; // Dirección completa
  final String? origenUbicacionCentro; // Ej: "Urgencias", "Hab-202"
  final String? tipoDestino;
  final String? destino;
  final String? destinoUbicacionCentro;
  final String? idMotivoTraslado;

  // Facturación
  final bool facturado;
  final DateTime? fechaFacturacion;
  final double? importeFacturado;

  // Métricas
  final int? tiempoEsperaOrigenMinutos;
  final int? tiempoViajeMinutos;
  final double? kilometrosRecorridos;

  // Metadata
  final bool generadoAutomaticamente;
  final bool editadoManualmente;
  final int prioridad; // 1-10 (1=máxima prioridad)

  // Auditoría
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? createdBy;
  final String? updatedBy;

  // Datos desnormalizados (para mostrar en UI sin joins)
  final String? pacienteNombre;
  final String? conductorNombre;
  final String? vehiculoMatricula;
  final String? poblacionPaciente; // Población del domicilio del paciente
  final String? poblacionCentroOrigen; // Población del centro hospitalario de origen
  final String? poblacionCentroDestino; // Población del centro hospitalario de destino

  @override
  List<Object?> get props => [
        id,
        codigo,
        estado,
        fecha,
        horaProgramada,
        idPaciente,
        idConductor,
        idVehiculo,
        fechaRecibidoConductor,
        fechaEnOrigen,
        fechaSaliendoOrigen,
        fechaEnDestino,
        fechaFinalizado,
        updatedAt,
      ];

  TrasladoEntity copyWith({
    String? id,
    String? codigo,
    String? idPaciente,
    String? tipoTraslado,
    DateTime? fecha,
    String? horaProgramada,
    EstadoTraslado? estado,
    DateTime? fechaCreacion,
    String? idServicioRecurrente,
    String? idServicio,
    String? idVehiculo,
    String? matriculaVehiculo,
    String? idConductor,
    List<String>? personalAsignado,
    DateTime? fechaAsignacion,
    String? usuarioAsignacion,
    DateTime? fechaEnviado,
    String? usuarioEnvio,
    DateTime? fechaRecibidoConductor,
    DateTime? fechaEnOrigen,
    UbicacionEntity? ubicacionEnOrigen,
    DateTime? fechaSaliendoOrigen,
    UbicacionEntity? ubicacionSaliendoOrigen,
    DateTime? fechaEnDestino,
    UbicacionEntity? ubicacionEnDestino,
    DateTime? fechaFinalizado,
    UbicacionEntity? ubicacionFinalizado,
    DateTime? fechaCancelacion,
    String? motivoCancelacion,
    String? observacionesCancelacion,
    String? usuarioCancelacion,
    DateTime? fechaNoRealizado,
    DateTime? fechaSuspendido,
    bool? pacienteConfirmado,
    DateTime? fechaConfirmacionPaciente,
    String? metodoConfirmacion,
    String? tipoAmbulancia,
    bool? requiereAcompanante,
    bool? requiereSillaRuedas,
    bool? requiereCamilla,
    bool? requiereAyuda,
    String? observaciones,
    String? observacionesMedicas,
    String? tipoOrigen,
    String? origen,
    String? origenUbicacionCentro,
    String? tipoDestino,
    String? destino,
    String? destinoUbicacionCentro,
    String? idMotivoTraslado,
    bool? facturado,
    DateTime? fechaFacturacion,
    double? importeFacturado,
    int? tiempoEsperaOrigenMinutos,
    int? tiempoViajeMinutos,
    double? kilometrosRecorridos,
    bool? generadoAutomaticamente,
    bool? editadoManualmente,
    int? prioridad,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
    String? pacienteNombre,
    String? conductorNombre,
    String? vehiculoMatricula,
    String? poblacionPaciente,
    String? poblacionCentroOrigen,
    String? poblacionCentroDestino,
  }) {
    return TrasladoEntity(
      id: id ?? this.id,
      codigo: codigo ?? this.codigo,
      idPaciente: idPaciente ?? this.idPaciente,
      tipoTraslado: tipoTraslado ?? this.tipoTraslado,
      fecha: fecha ?? this.fecha,
      horaProgramada: horaProgramada ?? this.horaProgramada,
      estado: estado ?? this.estado,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      idServicioRecurrente: idServicioRecurrente ?? this.idServicioRecurrente,
      idServicio: idServicio ?? this.idServicio,
      idVehiculo: idVehiculo ?? this.idVehiculo,
      matriculaVehiculo: matriculaVehiculo ?? this.matriculaVehiculo,
      idConductor: idConductor ?? this.idConductor,
      personalAsignado: personalAsignado ?? this.personalAsignado,
      fechaAsignacion: fechaAsignacion ?? this.fechaAsignacion,
      usuarioAsignacion: usuarioAsignacion ?? this.usuarioAsignacion,
      fechaEnviado: fechaEnviado ?? this.fechaEnviado,
      usuarioEnvio: usuarioEnvio ?? this.usuarioEnvio,
      fechaRecibidoConductor:
          fechaRecibidoConductor ?? this.fechaRecibidoConductor,
      fechaEnOrigen: fechaEnOrigen ?? this.fechaEnOrigen,
      ubicacionEnOrigen: ubicacionEnOrigen ?? this.ubicacionEnOrigen,
      fechaSaliendoOrigen: fechaSaliendoOrigen ?? this.fechaSaliendoOrigen,
      ubicacionSaliendoOrigen:
          ubicacionSaliendoOrigen ?? this.ubicacionSaliendoOrigen,
      fechaEnDestino: fechaEnDestino ?? this.fechaEnDestino,
      ubicacionEnDestino: ubicacionEnDestino ?? this.ubicacionEnDestino,
      fechaFinalizado: fechaFinalizado ?? this.fechaFinalizado,
      ubicacionFinalizado: ubicacionFinalizado ?? this.ubicacionFinalizado,
      fechaCancelacion: fechaCancelacion ?? this.fechaCancelacion,
      motivoCancelacion: motivoCancelacion ?? this.motivoCancelacion,
      observacionesCancelacion:
          observacionesCancelacion ?? this.observacionesCancelacion,
      usuarioCancelacion: usuarioCancelacion ?? this.usuarioCancelacion,
      fechaNoRealizado: fechaNoRealizado ?? this.fechaNoRealizado,
      fechaSuspendido: fechaSuspendido ?? this.fechaSuspendido,
      pacienteConfirmado: pacienteConfirmado ?? this.pacienteConfirmado,
      fechaConfirmacionPaciente:
          fechaConfirmacionPaciente ?? this.fechaConfirmacionPaciente,
      metodoConfirmacion: metodoConfirmacion ?? this.metodoConfirmacion,
      tipoAmbulancia: tipoAmbulancia ?? this.tipoAmbulancia,
      requiereAcompanante: requiereAcompanante ?? this.requiereAcompanante,
      requiereSillaRuedas: requiereSillaRuedas ?? this.requiereSillaRuedas,
      requiereCamilla: requiereCamilla ?? this.requiereCamilla,
      requiereAyuda: requiereAyuda ?? this.requiereAyuda,
      observaciones: observaciones ?? this.observaciones,
      observacionesMedicas: observacionesMedicas ?? this.observacionesMedicas,
      tipoOrigen: tipoOrigen ?? this.tipoOrigen,
      origen: origen ?? this.origen,
      origenUbicacionCentro:
          origenUbicacionCentro ?? this.origenUbicacionCentro,
      tipoDestino: tipoDestino ?? this.tipoDestino,
      destino: destino ?? this.destino,
      destinoUbicacionCentro:
          destinoUbicacionCentro ?? this.destinoUbicacionCentro,
      idMotivoTraslado: idMotivoTraslado ?? this.idMotivoTraslado,
      facturado: facturado ?? this.facturado,
      fechaFacturacion: fechaFacturacion ?? this.fechaFacturacion,
      importeFacturado: importeFacturado ?? this.importeFacturado,
      tiempoEsperaOrigenMinutos:
          tiempoEsperaOrigenMinutos ?? this.tiempoEsperaOrigenMinutos,
      tiempoViajeMinutos: tiempoViajeMinutos ?? this.tiempoViajeMinutos,
      kilometrosRecorridos: kilometrosRecorridos ?? this.kilometrosRecorridos,
      generadoAutomaticamente:
          generadoAutomaticamente ?? this.generadoAutomaticamente,
      editadoManualmente: editadoManualmente ?? this.editadoManualmente,
      prioridad: prioridad ?? this.prioridad,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
      pacienteNombre: pacienteNombre ?? this.pacienteNombre,
      conductorNombre: conductorNombre ?? this.conductorNombre,
      vehiculoMatricula: vehiculoMatricula ?? this.vehiculoMatricula,
      poblacionPaciente: poblacionPaciente ?? this.poblacionPaciente,
      poblacionCentroOrigen: poblacionCentroOrigen ?? this.poblacionCentroOrigen,
      poblacionCentroDestino: poblacionCentroDestino ?? this.poblacionCentroDestino,
    );
  }

  /// Obtiene la fecha/hora del último cambio de estado
  DateTime? get ultimaActualizacionEstado {
    switch (estado) {
      case EstadoTraslado.pendiente:
        return fechaCreacion;
      case EstadoTraslado.asignado:
        return fechaAsignacion;
      case EstadoTraslado.enviado:
        return fechaAsignacion; // Usa fecha de asignación como referencia
      case EstadoTraslado.recibido:
        return fechaRecibidoConductor;
      case EstadoTraslado.enOrigen:
        return fechaEnOrigen;
      case EstadoTraslado.saliendoOrigen:
        return fechaSaliendoOrigen;
      case EstadoTraslado.enTransito:
        return fechaSaliendoOrigen; // Usa fecha de saliendo origen como referencia
      case EstadoTraslado.enDestino:
        return fechaEnDestino;
      case EstadoTraslado.finalizado:
        return fechaFinalizado;
      case EstadoTraslado.cancelado:
        return fechaCancelacion;
      case EstadoTraslado.noRealizado:
        return fechaNoRealizado;
    }
  }

  /// Verifica si el traslado requiere equipamiento especial
  bool get requiereEquipamientoEspecial {
    return requiereSillaRuedas || requiereCamilla || requiereAyuda;
  }

  /// Texto descriptivo del origen
  String get origenCompleto {
    if (origen == null) return 'Sin especificar';
    if (origenUbicacionCentro != null) {
      return '$origen - $origenUbicacionCentro';
    }
    return origen!;
  }

  /// Texto descriptivo del destino
  String get destinoCompleto {
    if (destino == null) return 'Sin especificar';
    if (destinoUbicacionCentro != null) {
      return '$destino - $destinoUbicacionCentro';
    }
    return destino!;
  }

  /// Obtiene la población del origen del traslado
  /// Devuelve la población del centro hospitalario o del domicilio del paciente
  String? get poblacionOrigen {
    // Si el origen es un centro hospitalario, usar su población
    if (tipoOrigen == 'centro_hospitalario') {
      return poblacionCentroOrigen;
    }

    // Si el origen es el domicilio del paciente, usar la población del paciente
    if (tipoOrigen == 'domicilio' || tipoOrigen == 'domicilio_paciente') {
      return poblacionPaciente;
    }

    return null;
  }

  /// Obtiene la población del destino del traslado
  /// Devuelve la población del centro hospitalario o del domicilio del paciente
  String? get poblacionDestino {
    // Si el destino es un centro hospitalario, usar su población
    if (tipoDestino == 'centro_hospitalario') {
      return poblacionCentroDestino;
    }

    // Si el destino es el domicilio del paciente, usar la población del paciente
    if (tipoDestino == 'domicilio' || tipoDestino == 'domicilio_paciente') {
      return poblacionPaciente;
    }

    return null;
  }
}
