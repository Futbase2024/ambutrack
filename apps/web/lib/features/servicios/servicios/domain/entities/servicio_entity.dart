import 'package:ambutrack_core/ambutrack_core.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'motivo_traslado_json_converter.dart';
import 'paciente_json_converter.dart';
import 'utc_datetime_converter.dart';

part 'servicio_entity.freezed.dart';
part 'servicio_entity.g.dart';

/// Entidad de dominio para un Servicio
///
/// Representa la cabecera de un servicio médico (nivel 1 de la arquitectura)
/// que puede generar múltiples traslados automáticamente.
@freezed
class ServicioEntity with _$ServicioEntity {
  const factory ServicioEntity({
    /// ID único del servicio
    String? id,

    /// Código identificador del servicio
    String? codigo,

    /// ID del paciente asociado (opcional)
    @JsonKey(name: 'id_paciente')
    String? idPaciente,

    /// Datos del paciente (join con tabla pacientes)
    /// Se mapea desde el campo 'pacientes' del JSON de Supabase
    @JsonKey(name: 'pacientes')
    @PacienteJsonConverter()
    PacienteEntity? paciente,

    /// ID del médico/facultativo asignado (opcional)
    @JsonKey(name: 'medico_id')
    String? medicoId,

    /// ID del motivo de traslado (tipo de servicio: ALTA, URGENCIAS, REHABILITACIÓN, etc.)
    @JsonKey(name: 'id_motivo_traslado')
    String? idMotivoTraslado,

    /// Datos del motivo de traslado (join con tabla tmotivos_traslado)
    /// Se mapea desde el campo 'tmotivos_traslado' del JSON de Supabase
    @JsonKey(name: 'tmotivos_traslado')
    @MotivoTrasladoJsonConverter()
    MotivoTrasladoEntity? motivoTraslado,

    /// Tipo de recurrencia del servicio
    /// Valores: 'unico', 'diario', 'semanal', 'semanas_alternas', 'dias_alternos', 'mensual', 'especifico'
    @JsonKey(name: 'tipo_recurrencia')
    String? tipoRecurrencia,

    /// Fecha de inicio del servicio
    @JsonKey(name: 'fecha_servicio_inicio')
    DateTime? fechaServicioInicio,

    /// Fecha de fin del servicio (opcional, solo para servicios recurrentes)
    @JsonKey(name: 'fecha_servicio_fin')
    DateTime? fechaServicioFin,

    /// Hora de recogida (HH:MM:SS formato)
    @JsonKey(name: 'hora_recogida')
    String? horaRecogida,

    /// Indica si el servicio requiere vuelta
    @JsonKey(name: 'requiere_vuelta')
    @Default(false) bool requiereVuelta,

    /// Hora de vuelta (solo si requiereVuelta es true)
    @JsonKey(name: 'hora_vuelta')
    String? horaVuelta,

    /// Tipo de origen ('domicilio_paciente' o 'centro_hospitalario')
    @JsonKey(name: 'tipo_origen')
    String? tipoOrigen,

    /// Origen del servicio (dirección del domicilio o nombre del centro)
    String? origen,

    /// Tipo de destino ('domicilio_paciente' o 'centro_hospitalario')
    @JsonKey(name: 'tipo_destino')
    String? tipoDestino,

    /// Destino del servicio (dirección del domicilio o nombre del centro)
    String? destino,

    /// Ubicación específica dentro del centro de origen (ej: Urgencias, Hab-202)
    @JsonKey(name: 'origen_ubicacion_centro')
    String? origenUbicacionCentro,

    /// Ubicación específica dentro del centro de destino (ej: UCI, Sala de Espera)
    @JsonKey(name: 'destino_ubicacion_centro')
    String? destinoUbicacionCentro,

    /// Tipo de ambulancia requerida
    @JsonKey(name: 'tipo_ambulancia')
    String? tipoAmbulancia,

    /// Indica si requiere ayuda (personal adicional)
    @JsonKey(name: 'requiere_ayuda')
    @Default(false) bool requiereAyuda,

    /// Indica si requiere acompañante
    @JsonKey(name: 'requiere_acompanante')
    @Default(false) bool requiereAcompanante,

    /// Indica si requiere silla de ruedas
    @JsonKey(name: 'requiere_silla_ruedas')
    @Default(false) bool requiereSillaRuedas,

    /// Indica si requiere camilla
    @JsonKey(name: 'requiere_camilla')
    @Default(false) bool requiereCamilla,

    /// Prioridad del servicio (1=máxima, 10=mínima)
    @Default(5) int prioridad,

    /// Observaciones generales
    String? observaciones,

    /// Observaciones médicas
    @JsonKey(name: 'observaciones_medicas')
    String? observacionesMedicas,

    /// Estado del servicio
    /// Valores: 'ACTIVO', 'SUSPENDIDO', 'FINALIZADO', 'ELIMINADO'
    @Default('ACTIVO') String estado,

    /// Indica si el servicio está activo (deprecated, usar estado)
    @Default(true) bool activo,

    /// Días de la semana (para recurrencia semanal)
    /// Array de números [1-7] donde 1=Lunes, 7=Domingo
    @JsonKey(name: 'dias_semana')
    List<int>? diasSemana,

    /// Intervalo en semanas (para semanas alternas)
    @JsonKey(name: 'intervalo_semanas')
    int? intervaloSemanas,

    /// Intervalo en días (para días alternos)
    @JsonKey(name: 'intervalo_dias')
    int? intervaloDias,

    /// Días del mes (para recurrencia mensual)
    /// Array de números [1-31]
    @JsonKey(name: 'dias_mes')
    List<int>? diasMes,

    /// Fechas específicas (para modalidad específica)
    /// Array de fechas en formato ISO
    @JsonKey(name: 'fechas_especificas')
    List<String>? fechasEspecificas,

    /// Fecha de creación
    @JsonKey(name: 'created_at')
    @UtcDateTimeConverter()
    DateTime? createdAt,

    /// Fecha de última actualización
    @JsonKey(name: 'updated_at')
    @UtcDateTimeConverter()
    DateTime? updatedAt,

    /// Fecha de eliminación lógica
    @JsonKey(name: 'archived_at')
    @UtcDateTimeConverter()
    DateTime? archivedAt,
  }) = _ServicioEntity;

  factory ServicioEntity.fromJson(Map<String, dynamic> json) =>
      _$ServicioEntityFromJson(json);
}
