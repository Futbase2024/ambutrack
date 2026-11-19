import 'package:equatable/equatable.dart';

/// Entidad de dominio para Servicios Recurrentes
/// Representa la configuración de un servicio médico con patrón de recurrencia
class ServicioRecurrenteEntity extends Equatable {
  const ServicioRecurrenteEntity({
    required this.id,
    required this.codigo,
    required this.idServicio,
    required this.idPaciente,
    required this.tipoRecurrencia,
    this.diasSemana,
    this.intervaloSemanas,
    this.intervaloDias,
    this.diasMes,
    this.fechasEspecificas,
    required this.fechaServicioInicio,
    this.fechaServicioFin,
    required this.horaRecogida,
    this.horaVuelta,
    this.requiereVuelta = false,
    this.idMotivoTraslado,
    this.tipoAmbulancia,
    this.requiereAcompanante,
    this.requiereSillaRuedas,
    this.requiereCamilla,
    this.requiereAyuda,
    this.tipoOrigen,
    this.origen,
    this.origenUbicacionCentro,
    this.tipoDestino,
    this.destino,
    this.destinoUbicacionCentro,
    this.observaciones,
    this.observacionesMedicas,
    this.prioridad = 5,
    this.trasladosGeneradosHasta,
    this.activo = true,
    this.createdAt,
    this.updatedAt,
    this.createdBy,
    this.updatedBy,
  });

  // IDENTIFICACIÓN ÚNICA
  final String id;
  final String codigo;

  // SERVICIO PADRE
  final String idServicio; // FK hacia servicios (tabla cabecera/padre)

  // PACIENTE
  final String idPaciente; // FK hacia pacientes

  // CONFIGURACIÓN DE RECURRENCIA
  final String tipoRecurrencia; // 'unico', 'diario', 'semanal', 'semanas_alternas', 'dias_alternos', 'mensual', 'especifico'
  final List<int>? diasSemana; // [1=Lunes, 2=Martes, ..., 7=Domingo] para 'semanal', 'semanas_alternas'
  final int? intervaloSemanas; // para 'semanas_alternas' (ej: cada 2 semanas)
  final int? intervaloDias; // para 'dias_alternos' (ej: cada 3 días)
  final List<int>? diasMes; // [1-31] para 'mensual'
  final List<DateTime>? fechasEspecificas; // Lista de fechas específicas para 'especifico'

  // FECHAS Y HORARIOS
  final DateTime fechaServicioInicio;
  final DateTime? fechaServicioFin; // NULL = servicio indefinido
  final DateTime horaRecogida; // Hora programada de recogida
  final DateTime? horaVuelta; // Hora programada de vuelta (si requiere_vuelta = true)
  final bool requiereVuelta; // Si genera traslados de ida Y vuelta

  // CLASIFICACIÓN DEL SERVICIO
  final String? idMotivoTraslado; // FK hacia tmotivo_traslado

  // ✅ REQUISITOS DE AMBULANCIA
  final String? tipoAmbulancia; // Tipo de ambulancia requerida
  final bool? requiereAcompanante; // Si requiere acompañante
  final bool? requiereSillaRuedas; // Si requiere silla de ruedas
  final bool? requiereCamilla; // Si requiere camilla
  final bool? requiereAyuda; // Si requiere ayuda especial

  // ✅ UBICACIONES (tipo_ubicacion ENUM + valor específico)
  final String? tipoOrigen; // 'domicilio_paciente', 'otro_domicilio', 'centro_hospitalario'
  final String? origen; // ID centro o dirección según tipo_origen
  final String? origenUbicacionCentro; // Nombre ubicación dentro del centro (ej: "Urgencias")
  final String? tipoDestino; // 'domicilio_paciente', 'otro_domicilio', 'centro_hospitalario'
  final String? destino; // ID centro o dirección según tipo_destino
  final String? destinoUbicacionCentro; // Nombre ubicación dentro del centro (ej: "Consultas Externas")

  // OBSERVACIONES
  final String? observaciones; // Visible para conductores
  final String? observacionesMedicas; // Observaciones médicas

  // PRIORIDAD
  final int prioridad; // 1-10 (1 = máxima, 10 = mínima)

  // CONTROL DE GENERACIÓN
  final DateTime? trasladosGeneradosHasta; // Última fecha hasta la que se generaron traslados

  // ESTADO
  final bool activo;

  // AUDITORÍA
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? createdBy;
  final String? updatedBy;

  /// Getter para nombre completo del tipo de recurrencia
  String get tipoRecurrenciaFormateado {
    switch (tipoRecurrencia) {
      case 'unico':
        return 'Servicio Único';
      case 'diario':
        return 'Diario';
      case 'semanal':
        return 'Semanal';
      case 'semanas_alternas':
        return 'Semanas Alternas';
      case 'dias_alternos':
        return 'Días Alternos';
      case 'mensual':
        return 'Mensual';
      case 'especifico':
        return 'Fechas Específicas';
      default:
        return tipoRecurrencia;
    }
  }

  /// Getter para verificar si requiere generación de traslados
  bool get requiereGeneracion {
    if (!activo) {
      return false;
    }

    final ahora = DateTime.now();

    // Si no hay fecha de fin, siempre requiere generación
    if (fechaServicioFin == null) {
      return trasladosGeneradosHasta == null ||
             trasladosGeneradosHasta!.isBefore(ahora.add(const Duration(days: 14)));
    }

    // Si hay fecha de fin, verificar que no haya pasado
    if (fechaServicioFin!.isBefore(ahora)) {
      return false;
    }

    return trasladosGeneradosHasta == null ||
           trasladosGeneradosHasta!.isBefore(fechaServicioFin!);
  }

  /// Método copyWith para crear copias inmutables
  ServicioRecurrenteEntity copyWith({
    String? id,
    String? codigo,
    String? idServicio,
    String? idPaciente,
    String? tipoRecurrencia,
    List<int>? diasSemana,
    int? intervaloSemanas,
    int? intervaloDias,
    List<int>? diasMes,
    List<DateTime>? fechasEspecificas,
    DateTime? fechaServicioInicio,
    DateTime? fechaServicioFin,
    DateTime? horaRecogida,
    DateTime? horaVuelta,
    bool? requiereVuelta,
    String? idMotivoTraslado,
    String? tipoAmbulancia,
    bool? requiereAcompanante,
    bool? requiereSillaRuedas,
    bool? requiereCamilla,
    bool? requiereAyuda,
    String? tipoOrigen,
    String? origen,
    String? origenUbicacionCentro,
    String? tipoDestino,
    String? destino,
    String? destinoUbicacionCentro,
    String? observaciones,
    String? observacionesMedicas,
    int? prioridad,
    DateTime? trasladosGeneradosHasta,
    bool? activo,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
  }) {
    return ServicioRecurrenteEntity(
      id: id ?? this.id,
      codigo: codigo ?? this.codigo,
      idServicio: idServicio ?? this.idServicio,
      idPaciente: idPaciente ?? this.idPaciente,
      tipoRecurrencia: tipoRecurrencia ?? this.tipoRecurrencia,
      diasSemana: diasSemana ?? this.diasSemana,
      intervaloSemanas: intervaloSemanas ?? this.intervaloSemanas,
      intervaloDias: intervaloDias ?? this.intervaloDias,
      diasMes: diasMes ?? this.diasMes,
      fechasEspecificas: fechasEspecificas ?? this.fechasEspecificas,
      fechaServicioInicio: fechaServicioInicio ?? this.fechaServicioInicio,
      fechaServicioFin: fechaServicioFin ?? this.fechaServicioFin,
      horaRecogida: horaRecogida ?? this.horaRecogida,
      horaVuelta: horaVuelta ?? this.horaVuelta,
      requiereVuelta: requiereVuelta ?? this.requiereVuelta,
      idMotivoTraslado: idMotivoTraslado ?? this.idMotivoTraslado,
      tipoAmbulancia: tipoAmbulancia ?? this.tipoAmbulancia,
      requiereAcompanante: requiereAcompanante ?? this.requiereAcompanante,
      requiereSillaRuedas: requiereSillaRuedas ?? this.requiereSillaRuedas,
      requiereCamilla: requiereCamilla ?? this.requiereCamilla,
      requiereAyuda: requiereAyuda ?? this.requiereAyuda,
      tipoOrigen: tipoOrigen ?? this.tipoOrigen,
      origen: origen ?? this.origen,
      origenUbicacionCentro: origenUbicacionCentro ?? this.origenUbicacionCentro,
      tipoDestino: tipoDestino ?? this.tipoDestino,
      destino: destino ?? this.destino,
      destinoUbicacionCentro: destinoUbicacionCentro ?? this.destinoUbicacionCentro,
      observaciones: observaciones ?? this.observaciones,
      observacionesMedicas: observacionesMedicas ?? this.observacionesMedicas,
      prioridad: prioridad ?? this.prioridad,
      trasladosGeneradosHasta: trasladosGeneradosHasta ?? this.trasladosGeneradosHasta,
      activo: activo ?? this.activo,
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
        idServicio,
        idPaciente,
        tipoRecurrencia,
        diasSemana,
        intervaloSemanas,
        intervaloDias,
        diasMes,
        fechasEspecificas,
        fechaServicioInicio,
        fechaServicioFin,
        horaRecogida,
        horaVuelta,
        requiereVuelta,
        idMotivoTraslado,
        tipoAmbulancia,
        requiereAcompanante,
        requiereSillaRuedas,
        requiereCamilla,
        requiereAyuda,
        tipoOrigen,
        origen,
        origenUbicacionCentro,
        tipoDestino,
        destino,
        destinoUbicacionCentro,
        observaciones,
        observacionesMedicas,
        prioridad,
        trasladosGeneradosHasta,
        activo,
        createdAt,
        updatedAt,
        createdBy,
        updatedBy,
      ];
}
