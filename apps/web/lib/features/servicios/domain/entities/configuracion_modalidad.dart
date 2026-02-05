/// Tipos de recurrencia disponibles para servicios
library;

import 'dia_programado.dart';
import 'plantilla_horario.dart';

export 'dia_programado.dart';
export 'plantilla_horario.dart';

enum TipoRecurrencia {
  unico,
  diario,
  semanal,
  diasAlternos,
  fechasEspecificas,
  mensual,
}

/// Extensión para TipoRecurrencia
extension TipoRecurrenciaExtension on TipoRecurrencia {
  /// Convierte el enum a string para la base de datos
  String toDbString() {
    switch (this) {
      case TipoRecurrencia.unico:
        return 'unico';
      case TipoRecurrencia.diario:
        return 'diario';
      case TipoRecurrencia.semanal:
        return 'semanal';
      case TipoRecurrencia.diasAlternos:
        return 'dias_alternos';
      case TipoRecurrencia.fechasEspecificas:
        return 'fechas_especificas';
      case TipoRecurrencia.mensual:
        return 'mensual';
    }
  }

  /// Obtiene el nombre legible del tipo de recurrencia
  String get displayName {
    switch (this) {
      case TipoRecurrencia.unico:
        return 'Serv. Único';
      case TipoRecurrencia.diario:
        return 'Diario';
      case TipoRecurrencia.semanal:
        return 'Semanal';
      case TipoRecurrencia.diasAlternos:
        return 'Días Alternos';
      case TipoRecurrencia.fechasEspecificas:
        return 'Fechas Específicas';
      case TipoRecurrencia.mensual:
        return 'Mensual';
    }
  }

  /// Obtiene la descripción del tipo de recurrencia
  String get description {
    switch (this) {
      case TipoRecurrencia.unico:
        return 'Una sola fecha';
      case TipoRecurrencia.diario:
        return 'Todos los días';
      case TipoRecurrencia.semanal:
        return 'Días fijos';
      case TipoRecurrencia.diasAlternos:
        return 'Cada N días';
      case TipoRecurrencia.fechasEspecificas:
        return 'Fechas concretas';
      case TipoRecurrencia.mensual:
        return 'Días del mes';
    }
  }

  /// Mensaje informativo según el tipo seleccionado
  String getInfoMessage({required bool sinFechaFin}) {
    switch (this) {
      case TipoRecurrencia.unico:
        return 'El servicio se realizará en la fecha seleccionada';
      case TipoRecurrencia.diario:
        return sinFechaFin
            ? 'El servicio se repetirá todos los días hasta que se defina fecha de finalización'
            : 'El servicio se repetirá todos los días durante el periodo de tratamiento';
      case TipoRecurrencia.semanal:
        return sinFechaFin
            ? 'El servicio se repetirá los días seleccionados cada semana'
            : 'El servicio se repetirá los días seleccionados durante el periodo de tratamiento';
      case TipoRecurrencia.diasAlternos:
        return sinFechaFin
            ? 'El servicio se repetirá cada N días de forma indefinida'
            : 'El servicio se repetirá cada N días durante el periodo de tratamiento';
      case TipoRecurrencia.fechasEspecificas:
        return 'El servicio se realizará solo en las fechas seleccionadas';
      case TipoRecurrencia.mensual:
        return sinFechaFin
            ? 'El servicio se repetirá los días del mes seleccionados'
            : 'El servicio se repetirá los días del mes seleccionados durante el periodo de tratamiento';
    }
  }
}

/// Configuración completa de la modalidad del servicio
class ConfiguracionModalidad {

  ConfiguracionModalidad({
    required this.tipoRecurrencia,
    required this.fechaInicio,
    this.fechaFin,
    this.sinFechaFin = false,
    this.diasSemana,
    this.intervaloDias,
    this.fechasEspecificas,
    this.diasMes,
    this.plantillaHorarios,
    this.diasProgramados,
  });
  /// Tipo de recurrencia seleccionado
  final TipoRecurrencia tipoRecurrencia;

  /// Fecha de inicio del servicio (obligatoria)
  final DateTime fechaInicio;

  /// Fecha de fin del servicio (opcional)
  final DateTime? fechaFin;

  /// Indica si el servicio no tiene fecha de finalización
  final bool sinFechaFin;

  /// Días de la semana seleccionados (0=Domingo, 1=Lunes...6=Sábado)
  /// Solo aplica para recurrencia semanal
  final List<int>? diasSemana;

  /// Intervalo de días para recurrencia de días alternos
  /// Ejemplo: 2 = cada 2 días, 3 = cada 3 días
  final int? intervaloDias;

  /// Fechas específicas seleccionadas manualmente
  /// Solo aplica para recurrencia de fechas específicas
  final List<DateTime>? fechasEspecificas;

  /// Días del mes seleccionados (1-31)
  /// Solo aplica para recurrencia mensual
  final List<int>? diasMes;

  /// Plantilla de horarios (modo sin fecha fin)
  final List<PlantillaHorario>? plantillaHorarios;

  /// Días programados con horarios específicos (modo con fecha fin)
  final List<DiaProgramado>? diasProgramados;

  /// Determina si la configuración usa modo plantilla (sin fecha fin)
  bool get esModoPlantilla => sinFechaFin || fechaFin == null;

  /// Valida que la configuración sea correcta
  String? validar() {
    // Validar fecha fin >= fecha inicio
    if (fechaFin != null && fechaFin!.isBefore(fechaInicio)) {
      return 'La fecha de finalización debe ser posterior a la fecha de inicio';
    }

    // Validaciones específicas por tipo de recurrencia
    switch (tipoRecurrencia) {
      case TipoRecurrencia.semanal:
        if (diasSemana == null || diasSemana!.isEmpty) {
          return 'Debe seleccionar al menos un día de la semana';
        }
        break;

      case TipoRecurrencia.diasAlternos:
        if (intervaloDias == null || intervaloDias! < 2) {
          return 'El intervalo de días debe ser al menos 2';
        }
        break;

      case TipoRecurrencia.fechasEspecificas:
        if (fechasEspecificas == null || fechasEspecificas!.isEmpty) {
          return 'Debe seleccionar al menos una fecha específica';
        }
        break;

      case TipoRecurrencia.mensual:
        if (diasMes == null || diasMes!.isEmpty) {
          return 'Debe seleccionar al menos un día del mes';
        }
        break;

      case TipoRecurrencia.unico:
      case TipoRecurrencia.diario:
        // No requieren validación adicional
        break;
    }

    // Validar que haya horarios configurados
    if (esModoPlantilla) {
      if (plantillaHorarios == null || plantillaHorarios!.isEmpty) {
        return 'Debe configurar al menos un horario';
      }
    } else {
      if (diasProgramados == null || diasProgramados!.isEmpty) {
        return 'Debe configurar al menos un día programado';
      }
    }

    return null; // Sin errores
  }

  /// Crea una copia con campos modificados
  ConfiguracionModalidad copyWith({
    TipoRecurrencia? tipoRecurrencia,
    DateTime? fechaInicio,
    DateTime? fechaFin,
    bool? sinFechaFin,
    List<int>? diasSemana,
    int? intervaloDias,
    List<DateTime>? fechasEspecificas,
    List<int>? diasMes,
    List<PlantillaHorario>? plantillaHorarios,
    List<DiaProgramado>? diasProgramados,
  }) {
    return ConfiguracionModalidad(
      tipoRecurrencia: tipoRecurrencia ?? this.tipoRecurrencia,
      fechaInicio: fechaInicio ?? this.fechaInicio,
      fechaFin: fechaFin ?? this.fechaFin,
      sinFechaFin: sinFechaFin ?? this.sinFechaFin,
      diasSemana: diasSemana ?? this.diasSemana,
      intervaloDias: intervaloDias ?? this.intervaloDias,
      fechasEspecificas: fechasEspecificas ?? this.fechasEspecificas,
      diasMes: diasMes ?? this.diasMes,
      plantillaHorarios: plantillaHorarios ?? this.plantillaHorarios,
      diasProgramados: diasProgramados ?? this.diasProgramados,
    );
  }
}
