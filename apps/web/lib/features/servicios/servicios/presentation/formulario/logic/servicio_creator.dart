import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../models/modalidad_servicio.dart';
import '../models/tipo_ubicacion.dart';
import '../models/trayecto_data.dart';

/// Clase utilitaria para crear servicios
///
/// Encapsula la lógica de mapeo del formulario → entidades de base de datos
/// siguiendo la arquitectura de 3 niveles:
/// - Nivel 1: `servicios` (cabecera/padre)
/// - Nivel 2: `servicios_recurrentes` (configuración de recurrencia)
/// - Nivel 3: `traslados` (generados automáticamente por trigger)
class ServicioCreator {
  const ServicioCreator._();

  /// Crea el servicio padre (nivel 1) y retorna su ID
  ///
  /// Este método inserta en la tabla `servicios` que actúa como cabecera
  /// para toda la jerarquía de servicios/traslados.
  static Future<String> crearServicioPadre({
    required PacienteEntity paciente,
    required ModalidadServicio modalidad,
    required DateTime fechaInicio,
    DateTime? fechaFin,
    required List<TrayectoData> trayectos,
    String? medicoId, // ✅ ID del médico/facultativo asignado
    String? motivoTrasladoId, // ✅ NUEVO: ID del motivo de traslado
    String? tipoAmbulancia,
    String? observaciones,
    String? observacionesMedicas,
    String? movilidad,
    int acompanantes = 0,
    bool requiereAyudante = false,
    List<int> diasSemana = const <int>[],
    int? intervaloSemanas,
    int? intervaloDias,
    List<int> diasMes = const <int>[],
    List<DateTime> fechasEspecificas = const <DateTime>[],
  }) async {
    debugPrint('📦 ServicioCreator.crearServicioPadre: Iniciando...');

    // Obtener hora de recogida del primer trayecto
    final TimeOfDay? primeraHora = trayectos.isNotEmpty ? trayectos.first.hora : null;
    final String horaRecogida = primeraHora != null
        ? '${primeraHora.hour.toString().padLeft(2, '0')}:${primeraHora.minute.toString().padLeft(2, '0')}:00'
        : '08:00:00';

    // Obtener hora de vuelta del segundo trayecto (si existe)
    final TimeOfDay? segundaHora = trayectos.length > 1 ? trayectos[1].hora : null;
    final String? horaVuelta = segundaHora != null
        ? '${segundaHora.hour.toString().padLeft(2, '0')}:${segundaHora.minute.toString().padLeft(2, '0')}:00'
        : null;

    // Mapear modalidad a tipo_recurrencia
    final String tipoRecurrencia = _mapearTipoRecurrencia(modalidad);

    // Determinar si requiere vuelta (basado en número de trayectos)
    final bool requiereVuelta = trayectos.length > 1;

    // ✅ Extraer origen y destino del primer trayecto
    final TrayectoData primerTrayecto = trayectos.first;
    final String tipoOrigen = _mapearTipoUbicacion(primerTrayecto.tipoOrigen);
    final String? origen = _obtenerValorOrigen(primerTrayecto);
    final String tipoDestino = _mapearTipoUbicacion(primerTrayecto.tipoDestino);
    final String? destino = _obtenerValorDestino(primerTrayecto);

    // Construir datos del servicio padre
    final Map<String, dynamic> servicioData = <String, dynamic>{
      'codigo': 'SRV-${const Uuid().v4().substring(0, 8).toUpperCase()}',
      'id_paciente': paciente.id,
      if (medicoId != null && medicoId.isNotEmpty) 'medico_id': medicoId, // ✅ ID del médico (opcional)
      if (motivoTrasladoId != null && motivoTrasladoId.isNotEmpty) 'id_motivo_traslado': motivoTrasladoId, // ✅ ID del motivo de traslado
      'tipo_recurrencia': tipoRecurrencia,
      'fecha_servicio_inicio': fechaInicio.toIso8601String().split('T')[0],
      if (fechaFin != null) 'fecha_servicio_fin': fechaFin.toIso8601String().split('T')[0],
      'hora_recogida': horaRecogida,
      'requiere_vuelta': requiereVuelta, // ✅ Dinámico: true si hay más de 1 trayecto
      if (horaVuelta != null) 'hora_vuelta': horaVuelta, // ✅ Solo si hay segundo trayecto

      // ✅ NUEVO: Campos normalizados de origen/destino
      'tipo_origen': tipoOrigen,
      if (origen != null) 'origen': origen,
      'tipo_destino': tipoDestino,
      if (destino != null) 'destino': destino,

      // ✅ NUEVO: Ubicación en centro (opcional)
      if (primerTrayecto.origenUbicacionEnCentro != null && primerTrayecto.origenUbicacionEnCentro!.isNotEmpty)
        'origen_ubicacion_centro': primerTrayecto.origenUbicacionEnCentro,
      if (primerTrayecto.destinoUbicacionEnCentro != null && primerTrayecto.destinoUbicacionEnCentro!.isNotEmpty)
        'destino_ubicacion_centro': primerTrayecto.destinoUbicacionEnCentro,

      if (tipoAmbulancia != null) 'tipo_ambulancia': tipoAmbulancia,
      'requiere_ayuda': requiereAyudante,
      'requiere_acompanante': acompanantes > 0,
      'requiere_silla_ruedas': movilidad == 'silla_ruedas' || movilidad == 'silla_electrica',
      'requiere_camilla': movilidad == 'camilla' || movilidad == 'camilla_palas',
      'prioridad': 5,
      if (observaciones != null && observaciones.isNotEmpty) 'observaciones': observaciones,
      if (observacionesMedicas != null && observacionesMedicas.isNotEmpty)
        'observaciones_medicas': observacionesMedicas,

      // Parámetros de recurrencia según modalidad
      if (modalidad == ModalidadServicio.semanal || modalidad == ModalidadServicio.semanasAlternas)
        'dias_semana': diasSemana.isNotEmpty ? diasSemana.toList() : <int>[],
      if (modalidad == ModalidadServicio.semanasAlternas)
        'intervalo_semanas': intervaloSemanas ?? 2,
      if (modalidad == ModalidadServicio.diasAlternos)
        'intervalo_dias': intervaloDias ?? 2,
      if (modalidad == ModalidadServicio.mensual)
        'dias_mes': diasMes.isNotEmpty ? diasMes.toList() : <int>[],
      if (modalidad == ModalidadServicio.especifico)
        'fechas_especificas': fechasEspecificas.isNotEmpty
            ? fechasEspecificas.map((DateTime d) => d.toIso8601String().split('T')[0]).toList()
            : <String>[],
    };

    debugPrint('📦 ServicioCreator: Insertando en tabla servicios...');
    debugPrint('📦 ServicioCreator: tipo_recurrencia = $tipoRecurrencia');
    debugPrint('📦 ServicioCreator: requiere_vuelta = $requiereVuelta');
    debugPrint('📦 ServicioCreator: hora_recogida = $horaRecogida');
    if (horaVuelta != null) {
      debugPrint('📦 ServicioCreator: hora_vuelta = $horaVuelta');
    }
    debugPrint('📦 ServicioCreator: Datos completos: ${servicioData.toString()}');

    try {
      final Map<String, dynamic> response = await Supabase.instance.client
          .from('servicios')
          .insert(servicioData)
          .select()
          .single();

      final String servicioId = response['id'] as String;
      debugPrint('📦 ServicioCreator: ✅ Servicio padre creado con ID: $servicioId');

      return servicioId;
    } catch (e) {
      debugPrint('📦 ServicioCreator: ❌ Error al crear servicio padre: $e');
      rethrow;
    }
  }

  /// Crea la entidad ServicioRecurrenteEntity desde datos del formulario
  ///
  /// Esta entidad representa el nivel 2 de la arquitectura (configuración de recurrencia)
  static ServicioRecurrenteEntity crearEntidadServicioRecurrente({
    required String servicioId,
    required PacienteEntity paciente,
    required ModalidadServicio modalidad,
    required DateTime fechaInicio,
    DateTime? fechaFin,
    required List<TrayectoData> trayectos,
    String? motivoTrasladoId, // ✅ NUEVO: ID del motivo de traslado
    String? tipoAmbulancia,
    String? movilidad,
    int acompanantes = 0,
    String? observaciones,
    String? observacionesInternas,
    String? observacionesMedicas,
    List<int> diasSemana = const <int>[],
    int? intervaloSemanas,
    int? intervaloDias,
    List<int> diasMes = const <int>[],
    List<DateTime> fechasEspecificas = const <DateTime>[],
  }) {
    debugPrint('📦 ServicioCreator.crearEntidadServicioRecurrente: Creando entidad...');

    final DateTime now = DateTime.now();
    final TimeOfDay? primeraHora = trayectos.isNotEmpty ? trayectos.first.hora : null;
    final DateTime horaRecogida = primeraHora != null
        ? DateTime(now.year, now.month, now.day, primeraHora.hour, primeraHora.minute)
        : DateTime(now.year, now.month, now.day, 8);

    // ✅ NUEVO: Hora de vuelta del segundo trayecto
    final TimeOfDay? segundaHora = trayectos.length > 1 ? trayectos[1].hora : null;
    final DateTime? horaVuelta = segundaHora != null
        ? DateTime(now.year, now.month, now.day, segundaHora.hour, segundaHora.minute)
        : null;

    // ✅ NUEVO: Determinar si requiere vuelta
    final bool requiereVuelta = trayectos.length > 1;

    final String tipoRecurrencia = _mapearTipoRecurrencia(modalidad);

    // ✅ Extraer origen y destino del primer trayecto
    final TrayectoData primerTrayecto = trayectos.first;
    final String tipoOrigen = _mapearTipoUbicacion(primerTrayecto.tipoOrigen);
    final String? origen = _obtenerValorOrigen(primerTrayecto);
    final String tipoDestino = _mapearTipoUbicacion(primerTrayecto.tipoDestino);
    final String? destino = _obtenerValorDestino(primerTrayecto);

    return ServicioRecurrenteEntity(
      id: const Uuid().v4(),
      codigo: 'SRV-${const Uuid().v4().substring(0, 8).toUpperCase()}',
      idServicio: servicioId,
      idPaciente: paciente.id,
      idMotivoTraslado: motivoTrasladoId, // ✅ ID del motivo de traslado
      tipoRecurrencia: tipoRecurrencia,
      fechaServicioInicio: fechaInicio,
      fechaServicioFin: fechaFin,
      horaRecogida: horaRecogida,
      horaVuelta: horaVuelta,
      requiereVuelta: requiereVuelta,
      // ✅ UBICACIONES (extraídas del primer trayecto)
      tipoOrigen: tipoOrigen,
      origen: origen,
      origenUbicacionCentro: primerTrayecto.origenUbicacionEnCentro,
      tipoDestino: tipoDestino,
      destino: destino,
      destinoUbicacionCentro: primerTrayecto.destinoUbicacionEnCentro,
      diasSemana: (modalidad == ModalidadServicio.semanal || modalidad == ModalidadServicio.semanasAlternas)
          ? diasSemana.toList()
          : null,
      intervaloSemanas: modalidad == ModalidadServicio.semanasAlternas ? intervaloSemanas : null,
      intervaloDias: modalidad == ModalidadServicio.diasAlternos ? intervaloDias : null,
      diasMes: modalidad == ModalidadServicio.mensual ? diasMes.toList() : null,
      fechasEspecificas: modalidad == ModalidadServicio.especifico ? fechasEspecificas.toList() : null,
      observaciones: observaciones,
      // ⚠️ NOTA: Los campos tipo_ambulancia, requiere_acompanante, requiere_silla_ruedas, requiere_camilla, observaciones_medicas
      // se guardan SOLO en la tabla servicios (padre), NO en servicios_recurrentes.
      // Los traslados los heredarán del servicio padre automáticamente.
      createdAt: DateTime.now(),
    );
  }

  // ============================================================================
  // MÉTODOS PRIVADOS DE MAPEO
  // ============================================================================

  /// Mapea TipoUbicacion a string de base de datos
  static String _mapearTipoUbicacion(TipoUbicacion tipo) {
    switch (tipo) {
      case TipoUbicacion.domicilioPaciente:
        return 'domicilio_paciente';
      case TipoUbicacion.otroDomicilio:
        return 'otro_domicilio';
      case TipoUbicacion.centroHospitalario:
        return 'centro_hospitalario';
    }
  }

  /// Obtiene el valor del origen según el tipo
  static String? _obtenerValorOrigen(TrayectoData trayecto) {
    switch (trayecto.tipoOrigen) {
      case TipoUbicacion.domicilioPaciente:
        return null; // El domicilio se toma del paciente
      case TipoUbicacion.otroDomicilio:
        return trayecto.origenDomicilio; // Dirección del domicilio
      case TipoUbicacion.centroHospitalario:
        return trayecto.origenCentro; // ID del centro hospitalario
    }
  }

  /// Obtiene el valor del destino según el tipo
  static String? _obtenerValorDestino(TrayectoData trayecto) {
    switch (trayecto.tipoDestino) {
      case TipoUbicacion.domicilioPaciente:
        return null; // El domicilio se toma del paciente
      case TipoUbicacion.otroDomicilio:
        return trayecto.destinoDomicilio; // Dirección del domicilio
      case TipoUbicacion.centroHospitalario:
        return trayecto.destinoCentro; // ID del centro hospitalario
    }
  }

  static String _mapearTipoRecurrencia(ModalidadServicio modalidad) {
    switch (modalidad) {
      case ModalidadServicio.unico:
        return 'unico';
      case ModalidadServicio.diario:
        return 'diario';
      case ModalidadServicio.semanasAlternas:
        return 'semanas_alternas';
      case ModalidadServicio.semanal:
        return 'semanal';
      case ModalidadServicio.mensual:
        return 'mensual';
      case ModalidadServicio.diasAlternos:
        return 'dias_alternos';
      case ModalidadServicio.especifico:
        return 'especifico';
    }
  }
}
