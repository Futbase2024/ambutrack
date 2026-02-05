import '../entities/estado_traslado_enum.dart';
import '../entities/traslado_entity.dart';
import '../entities/ubicacion_entity.dart';

/// Modelo DTO para serialización JSON desde/hacia Supabase
class TrasladoSupabaseModel {
  const TrasladoSupabaseModel({
    required this.id,
    required this.codigo,
    required this.idPaciente,
    required this.tipoTraslado,
    required this.fecha,
    required this.horaProgramada,
    required this.estado,
    required this.fechaCreacion,
    required this.createdAt,
    required this.updatedAt,
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
    this.pacienteConfirmado,
    this.fechaConfirmacionPaciente,
    this.metodoConfirmacion,
    this.tipoAmbulancia,
    this.requiereAcompanante,
    this.requiereSillaRuedas,
    this.requiereCamilla,
    this.requiereAyuda,
    this.observaciones,
    this.observacionesMedicas,
    this.tipoOrigen,
    this.origen,
    this.origenUbicacionCentro,
    this.tipoDestino,
    this.destino,
    this.destinoUbicacionCentro,
    this.idMotivoTraslado,
    this.facturado,
    this.fechaFacturacion,
    this.importeFacturado,
    this.tiempoEsperaOrigenMinutos,
    this.tiempoViajeMinutos,
    this.kilometrosRecorridos,
    this.generadoAutomaticamente,
    this.editadoManualmente,
    this.prioridad,
    this.createdBy,
    this.updatedBy,
  });

  final String id;
  final String codigo;
  final String idPaciente;
  final String tipoTraslado;
  final DateTime fecha;
  final String horaProgramada;
  final String estado;
  final DateTime fechaCreacion;
  final String? idServicioRecurrente;
  final String? idServicio;
  final String? idVehiculo;
  final String? matriculaVehiculo;
  final String? idConductor;
  final List<dynamic>? personalAsignado;
  final DateTime? fechaAsignacion;
  final String? usuarioAsignacion;
  final DateTime? fechaEnviado;
  final String? usuarioEnvio;
  final DateTime? fechaRecibidoConductor;
  final DateTime? fechaEnOrigen;
  final Map<String, dynamic>? ubicacionEnOrigen;
  final DateTime? fechaSaliendoOrigen;
  final Map<String, dynamic>? ubicacionSaliendoOrigen;
  final DateTime? fechaEnDestino;
  final Map<String, dynamic>? ubicacionEnDestino;
  final DateTime? fechaFinalizado;
  final Map<String, dynamic>? ubicacionFinalizado;
  final DateTime? fechaCancelacion;
  final String? motivoCancelacion;
  final String? observacionesCancelacion;
  final String? usuarioCancelacion;
  final DateTime? fechaNoRealizado;
  final DateTime? fechaSuspendido;
  final bool? pacienteConfirmado;
  final DateTime? fechaConfirmacionPaciente;
  final String? metodoConfirmacion;
  final String? tipoAmbulancia;
  final bool? requiereAcompanante;
  final bool? requiereSillaRuedas;
  final bool? requiereCamilla;
  final bool? requiereAyuda;
  final String? observaciones;
  final String? observacionesMedicas;
  final String? tipoOrigen;
  final String? origen;
  final String? origenUbicacionCentro;
  final String? tipoDestino;
  final String? destino;
  final String? destinoUbicacionCentro;
  final String? idMotivoTraslado;
  final bool? facturado;
  final DateTime? fechaFacturacion;
  final double? importeFacturado;
  final int? tiempoEsperaOrigenMinutos;
  final int? tiempoViajeMinutos;
  final double? kilometrosRecorridos;
  final bool? generadoAutomaticamente;
  final bool? editadoManualmente;
  final int? prioridad;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? createdBy;
  final String? updatedBy;

  /// Convierte desde JSON de Supabase
  factory TrasladoSupabaseModel.fromJson(Map<String, dynamic> json) {
    return TrasladoSupabaseModel(
      id: json['id'] as String,
      codigo: json['codigo'] as String,
      idPaciente: json['id_paciente'] as String,
      tipoTraslado: json['tipo_traslado'] as String,
      fecha: DateTime.parse(json['fecha'] as String),
      horaProgramada: json['hora_programada'] as String,
      estado: json['estado'] as String,
      fechaCreacion: DateTime.parse(json['fecha_creacion'] as String),
      idServicioRecurrente: json['id_servicio_recurrente'] as String?,
      idServicio: json['id_servicio'] as String?,
      idVehiculo: json['id_vehiculo'] as String?,
      matriculaVehiculo: json['matricula_vehiculo'] as String?,
      idConductor: json['id_conductor'] as String?,
      personalAsignado: json['personal_asignado'] as List<dynamic>?,
      fechaAsignacion: json['fecha_asignacion'] != null
          ? DateTime.parse(json['fecha_asignacion'] as String)
          : null,
      usuarioAsignacion: json['usuario_asignacion'] as String?,
      fechaEnviado: json['fecha_enviado'] != null
          ? DateTime.parse(json['fecha_enviado'] as String)
          : null,
      usuarioEnvio: json['usuario_envio'] as String?,
      fechaRecibidoConductor: json['fecha_recibido_conductor'] != null
          ? DateTime.parse(json['fecha_recibido_conductor'] as String)
          : null,
      fechaEnOrigen: json['fecha_en_origen'] != null
          ? DateTime.parse(json['fecha_en_origen'] as String)
          : null,
      ubicacionEnOrigen:
          json['ubicacion_en_origen'] as Map<String, dynamic>?,
      fechaSaliendoOrigen: json['fecha_saliendo_origen'] != null
          ? DateTime.parse(json['fecha_saliendo_origen'] as String)
          : null,
      ubicacionSaliendoOrigen:
          json['ubicacion_saliendo_origen'] as Map<String, dynamic>?,
      fechaEnDestino: json['fecha_en_destino'] != null
          ? DateTime.parse(json['fecha_en_destino'] as String)
          : null,
      ubicacionEnDestino:
          json['ubicacion_en_destino'] as Map<String, dynamic>?,
      fechaFinalizado: json['fecha_finalizado'] != null
          ? DateTime.parse(json['fecha_finalizado'] as String)
          : null,
      ubicacionFinalizado:
          json['ubicacion_finalizado'] as Map<String, dynamic>?,
      fechaCancelacion: json['fecha_cancelacion'] != null
          ? DateTime.parse(json['fecha_cancelacion'] as String)
          : null,
      motivoCancelacion: json['motivo_cancelacion'] as String?,
      observacionesCancelacion: json['observaciones_cancelacion'] as String?,
      usuarioCancelacion: json['usuario_cancelacion'] as String?,
      fechaNoRealizado: json['fecha_no_realizado'] != null
          ? DateTime.parse(json['fecha_no_realizado'] as String)
          : null,
      fechaSuspendido: json['fecha_suspendido'] != null
          ? DateTime.parse(json['fecha_suspendido'] as String)
          : null,
      pacienteConfirmado: json['paciente_confirmado'] as bool?,
      fechaConfirmacionPaciente: json['fecha_confirmacion_paciente'] != null
          ? DateTime.parse(json['fecha_confirmacion_paciente'] as String)
          : null,
      metodoConfirmacion: json['metodo_confirmacion'] as String?,
      tipoAmbulancia: json['tipo_ambulancia'] as String?,
      requiereAcompanante: json['requiere_acompanante'] as bool?,
      requiereSillaRuedas: json['requiere_silla_ruedas'] as bool?,
      requiereCamilla: json['requiere_camilla'] as bool?,
      requiereAyuda: json['requiere_ayuda'] as bool?,
      observaciones: json['observaciones'] as String?,
      observacionesMedicas: json['observaciones_medicas'] as String?,
      tipoOrigen: json['tipo_origen'] as String?,
      origen: json['origen'] as String?,
      origenUbicacionCentro: json['origen_ubicacion_centro'] as String?,
      tipoDestino: json['tipo_destino'] as String?,
      destino: json['destino'] as String?,
      destinoUbicacionCentro: json['destino_ubicacion_centro'] as String?,
      idMotivoTraslado: json['id_motivo_traslado'] as String?,
      facturado: json['facturado'] as bool?,
      fechaFacturacion: json['fecha_facturacion'] != null
          ? DateTime.parse(json['fecha_facturacion'] as String)
          : null,
      importeFacturado: json['importe_facturado'] != null
          ? (json['importe_facturado'] as num).toDouble()
          : null,
      tiempoEsperaOrigenMinutos:
          json['tiempo_espera_origen_minutos'] as int?,
      tiempoViajeMinutos: json['tiempo_viaje_minutos'] as int?,
      kilometrosRecorridos: json['kilometros_recorridos'] != null
          ? (json['kilometros_recorridos'] as num).toDouble()
          : null,
      generadoAutomaticamente: json['generado_automaticamente'] as bool?,
      editadoManualmente: json['editado_manualmente'] as bool?,
      prioridad: json['prioridad'] as int?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      createdBy: json['created_by'] as String?,
      updatedBy: json['updated_by'] as String?,
    );
  }

  /// Convierte a JSON para Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'codigo': codigo,
      'id_paciente': idPaciente,
      'tipo_traslado': tipoTraslado,
      'fecha': fecha.toIso8601String().split('T')[0],
      'hora_programada': horaProgramada,
      'estado': estado,
      'fecha_creacion': fechaCreacion.toIso8601String(),
      if (idServicioRecurrente != null)
        'id_servicio_recurrente': idServicioRecurrente,
      if (idServicio != null) 'id_servicio': idServicio,
      if (idVehiculo != null) 'id_vehiculo': idVehiculo,
      if (matriculaVehiculo != null) 'matricula_vehiculo': matriculaVehiculo,
      if (idConductor != null) 'id_conductor': idConductor,
      if (personalAsignado != null) 'personal_asignado': personalAsignado,
      if (fechaAsignacion != null)
        'fecha_asignacion': fechaAsignacion!.toIso8601String(),
      if (usuarioAsignacion != null) 'usuario_asignacion': usuarioAsignacion,
      if (fechaEnviado != null)
        'fecha_enviado': fechaEnviado!.toIso8601String(),
      if (usuarioEnvio != null) 'usuario_envio': usuarioEnvio,
      if (fechaRecibidoConductor != null)
        'fecha_recibido_conductor': fechaRecibidoConductor!.toIso8601String(),
      if (fechaEnOrigen != null)
        'fecha_en_origen': fechaEnOrigen!.toIso8601String(),
      if (ubicacionEnOrigen != null) 'ubicacion_en_origen': ubicacionEnOrigen,
      if (fechaSaliendoOrigen != null)
        'fecha_saliendo_origen': fechaSaliendoOrigen!.toIso8601String(),
      if (ubicacionSaliendoOrigen != null)
        'ubicacion_saliendo_origen': ubicacionSaliendoOrigen,
      if (fechaEnDestino != null)
        'fecha_en_destino': fechaEnDestino!.toIso8601String(),
      if (ubicacionEnDestino != null)
        'ubicacion_en_destino': ubicacionEnDestino,
      if (fechaFinalizado != null)
        'fecha_finalizado': fechaFinalizado!.toIso8601String(),
      if (ubicacionFinalizado != null)
        'ubicacion_finalizado': ubicacionFinalizado,
      if (fechaCancelacion != null)
        'fecha_cancelacion': fechaCancelacion!.toIso8601String(),
      if (motivoCancelacion != null) 'motivo_cancelacion': motivoCancelacion,
      if (observacionesCancelacion != null)
        'observaciones_cancelacion': observacionesCancelacion,
      if (usuarioCancelacion != null)
        'usuario_cancelacion': usuarioCancelacion,
      if (fechaNoRealizado != null)
        'fecha_no_realizado': fechaNoRealizado!.toIso8601String(),
      if (fechaSuspendido != null)
        'fecha_suspendido': fechaSuspendido!.toIso8601String(),
      if (pacienteConfirmado != null)
        'paciente_confirmado': pacienteConfirmado,
      if (fechaConfirmacionPaciente != null)
        'fecha_confirmacion_paciente':
            fechaConfirmacionPaciente!.toIso8601String(),
      if (metodoConfirmacion != null)
        'metodo_confirmacion': metodoConfirmacion,
      if (tipoAmbulancia != null) 'tipo_ambulancia': tipoAmbulancia,
      if (requiereAcompanante != null)
        'requiere_acompanante': requiereAcompanante,
      if (requiereSillaRuedas != null)
        'requiere_silla_ruedas': requiereSillaRuedas,
      if (requiereCamilla != null) 'requiere_camilla': requiereCamilla,
      if (requiereAyuda != null) 'requiere_ayuda': requiereAyuda,
      if (observaciones != null) 'observaciones': observaciones,
      if (observacionesMedicas != null)
        'observaciones_medicas': observacionesMedicas,
      if (tipoOrigen != null) 'tipo_origen': tipoOrigen,
      if (origen != null) 'origen': origen,
      if (origenUbicacionCentro != null)
        'origen_ubicacion_centro': origenUbicacionCentro,
      if (tipoDestino != null) 'tipo_destino': tipoDestino,
      if (destino != null) 'destino': destino,
      if (destinoUbicacionCentro != null)
        'destino_ubicacion_centro': destinoUbicacionCentro,
      if (idMotivoTraslado != null) 'id_motivo_traslado': idMotivoTraslado,
      if (facturado != null) 'facturado': facturado,
      if (fechaFacturacion != null)
        'fecha_facturacion': fechaFacturacion!.toIso8601String(),
      if (importeFacturado != null) 'importe_facturado': importeFacturado,
      if (tiempoEsperaOrigenMinutos != null)
        'tiempo_espera_origen_minutos': tiempoEsperaOrigenMinutos,
      if (tiempoViajeMinutos != null) 'tiempo_viaje_minutos': tiempoViajeMinutos,
      if (kilometrosRecorridos != null)
        'kilometros_recorridos': kilometrosRecorridos,
      if (generadoAutomaticamente != null)
        'generado_automaticamente': generadoAutomaticamente,
      if (editadoManualmente != null) 'editado_manualmente': editadoManualmente,
      if (prioridad != null) 'prioridad': prioridad,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      if (createdBy != null) 'created_by': createdBy,
      if (updatedBy != null) 'updated_by': updatedBy,
    };
  }

  /// Convierte a Entity de dominio
  TrasladoEntity toEntity() {
    return TrasladoEntity(
      id: id,
      codigo: codigo,
      idPaciente: idPaciente,
      tipoTraslado: tipoTraslado,
      fecha: fecha,
      horaProgramada: horaProgramada,
      estado: EstadoTraslado.fromString(estado),
      fechaCreacion: fechaCreacion,
      idServicioRecurrente: idServicioRecurrente,
      idServicio: idServicio,
      idVehiculo: idVehiculo,
      matriculaVehiculo: matriculaVehiculo,
      idConductor: idConductor,
      personalAsignado: personalAsignado?.cast<String>(),
      fechaAsignacion: fechaAsignacion,
      usuarioAsignacion: usuarioAsignacion,
      fechaEnviado: fechaEnviado,
      usuarioEnvio: usuarioEnvio,
      fechaRecibidoConductor: fechaRecibidoConductor,
      fechaEnOrigen: fechaEnOrigen,
      ubicacionEnOrigen: ubicacionEnOrigen != null
          ? UbicacionEntity.fromJson(ubicacionEnOrigen!)
          : null,
      fechaSaliendoOrigen: fechaSaliendoOrigen,
      ubicacionSaliendoOrigen: ubicacionSaliendoOrigen != null
          ? UbicacionEntity.fromJson(ubicacionSaliendoOrigen!)
          : null,
      fechaEnDestino: fechaEnDestino,
      ubicacionEnDestino: ubicacionEnDestino != null
          ? UbicacionEntity.fromJson(ubicacionEnDestino!)
          : null,
      fechaFinalizado: fechaFinalizado,
      ubicacionFinalizado: ubicacionFinalizado != null
          ? UbicacionEntity.fromJson(ubicacionFinalizado!)
          : null,
      fechaCancelacion: fechaCancelacion,
      motivoCancelacion: motivoCancelacion,
      observacionesCancelacion: observacionesCancelacion,
      usuarioCancelacion: usuarioCancelacion,
      fechaNoRealizado: fechaNoRealizado,
      fechaSuspendido: fechaSuspendido,
      pacienteConfirmado: pacienteConfirmado ?? false,
      fechaConfirmacionPaciente: fechaConfirmacionPaciente,
      metodoConfirmacion: metodoConfirmacion,
      tipoAmbulancia: tipoAmbulancia,
      requiereAcompanante: requiereAcompanante ?? false,
      requiereSillaRuedas: requiereSillaRuedas ?? false,
      requiereCamilla: requiereCamilla ?? false,
      requiereAyuda: requiereAyuda ?? false,
      observaciones: observaciones,
      observacionesMedicas: observacionesMedicas,
      tipoOrigen: tipoOrigen,
      origen: origen,
      origenUbicacionCentro: origenUbicacionCentro,
      tipoDestino: tipoDestino,
      destino: destino,
      destinoUbicacionCentro: destinoUbicacionCentro,
      idMotivoTraslado: idMotivoTraslado,
      facturado: facturado ?? false,
      fechaFacturacion: fechaFacturacion,
      importeFacturado: importeFacturado,
      tiempoEsperaOrigenMinutos: tiempoEsperaOrigenMinutos,
      tiempoViajeMinutos: tiempoViajeMinutos,
      kilometrosRecorridos: kilometrosRecorridos,
      generadoAutomaticamente: generadoAutomaticamente ?? true,
      editadoManualmente: editadoManualmente ?? false,
      prioridad: prioridad ?? 5,
      createdAt: createdAt,
      updatedAt: updatedAt,
      createdBy: createdBy,
      updatedBy: updatedBy,
    );
  }

  /// Crea desde Entity de dominio
  factory TrasladoSupabaseModel.fromEntity(TrasladoEntity entity) {
    return TrasladoSupabaseModel(
      id: entity.id,
      codigo: entity.codigo,
      idPaciente: entity.idPaciente,
      tipoTraslado: entity.tipoTraslado,
      fecha: entity.fecha,
      horaProgramada: entity.horaProgramada,
      estado: entity.estado.value,
      fechaCreacion: entity.fechaCreacion,
      idServicioRecurrente: entity.idServicioRecurrente,
      idServicio: entity.idServicio,
      idVehiculo: entity.idVehiculo,
      matriculaVehiculo: entity.matriculaVehiculo,
      idConductor: entity.idConductor,
      personalAsignado: entity.personalAsignado,
      fechaAsignacion: entity.fechaAsignacion,
      usuarioAsignacion: entity.usuarioAsignacion,
      fechaEnviado: entity.fechaEnviado,
      usuarioEnvio: entity.usuarioEnvio,
      fechaRecibidoConductor: entity.fechaRecibidoConductor,
      fechaEnOrigen: entity.fechaEnOrigen,
      ubicacionEnOrigen: entity.ubicacionEnOrigen?.toJson(),
      fechaSaliendoOrigen: entity.fechaSaliendoOrigen,
      ubicacionSaliendoOrigen: entity.ubicacionSaliendoOrigen?.toJson(),
      fechaEnDestino: entity.fechaEnDestino,
      ubicacionEnDestino: entity.ubicacionEnDestino?.toJson(),
      fechaFinalizado: entity.fechaFinalizado,
      ubicacionFinalizado: entity.ubicacionFinalizado?.toJson(),
      fechaCancelacion: entity.fechaCancelacion,
      motivoCancelacion: entity.motivoCancelacion,
      observacionesCancelacion: entity.observacionesCancelacion,
      usuarioCancelacion: entity.usuarioCancelacion,
      fechaNoRealizado: entity.fechaNoRealizado,
      fechaSuspendido: entity.fechaSuspendido,
      pacienteConfirmado: entity.pacienteConfirmado,
      fechaConfirmacionPaciente: entity.fechaConfirmacionPaciente,
      metodoConfirmacion: entity.metodoConfirmacion,
      tipoAmbulancia: entity.tipoAmbulancia,
      requiereAcompanante: entity.requiereAcompanante,
      requiereSillaRuedas: entity.requiereSillaRuedas,
      requiereCamilla: entity.requiereCamilla,
      requiereAyuda: entity.requiereAyuda,
      observaciones: entity.observaciones,
      observacionesMedicas: entity.observacionesMedicas,
      tipoOrigen: entity.tipoOrigen,
      origen: entity.origen,
      origenUbicacionCentro: entity.origenUbicacionCentro,
      tipoDestino: entity.tipoDestino,
      destino: entity.destino,
      destinoUbicacionCentro: entity.destinoUbicacionCentro,
      idMotivoTraslado: entity.idMotivoTraslado,
      facturado: entity.facturado,
      fechaFacturacion: entity.fechaFacturacion,
      importeFacturado: entity.importeFacturado,
      tiempoEsperaOrigenMinutos: entity.tiempoEsperaOrigenMinutos,
      tiempoViajeMinutos: entity.tiempoViajeMinutos,
      kilometrosRecorridos: entity.kilometrosRecorridos,
      generadoAutomaticamente: entity.generadoAutomaticamente,
      editadoManualmente: entity.editadoManualmente,
      prioridad: entity.prioridad,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      createdBy: entity.createdBy,
      updatedBy: entity.updatedBy,
    );
  }
}
