import 'package:ambutrack_web/features/servicios/domain/entities/configuracion_modalidad.dart';
import 'package:ambutrack_web/features/servicios/servicios/presentation/formulario/models/modalidad_servicio.dart';
import 'package:flutter/foundation.dart';

// Helpers puros del asistente de servicios (extraídos sin cambios de lógica).

/// Mapea ModalidadServicio (sistema viejo) a TipoRecurrencia (sistema nuevo)
TipoRecurrencia modalidadToTipoRecurrencia(ModalidadServicio modalidad) {
  switch (modalidad) {
    case ModalidadServicio.unico:
      return TipoRecurrencia.unico;
    case ModalidadServicio.semanal:
    case ModalidadServicio.semanasAlternas:
      return TipoRecurrencia.semanal;
    case ModalidadServicio.diasAlternos:
      return TipoRecurrencia.diasAlternos;
    case ModalidadServicio.mensual:
      return TipoRecurrencia.mensual;
    case ModalidadServicio.especifico:
      return TipoRecurrencia.fechasEspecificas;
    case ModalidadServicio.diario:
      return TipoRecurrencia.diario;
  }
}

/// Mapea TipoRecurrencia (sistema nuevo) a ModalidadServicio (sistema viejo)
ModalidadServicio tipoRecurrenciaToModalidad(TipoRecurrencia tipo) {
  switch (tipo) {
    case TipoRecurrencia.unico:
      return ModalidadServicio.unico;
    case TipoRecurrencia.semanal:
      return ModalidadServicio.semanal;
    case TipoRecurrencia.diasAlternos:
      return ModalidadServicio.diasAlternos;
    case TipoRecurrencia.mensual:
      return ModalidadServicio.mensual;
    case TipoRecurrencia.fechasEspecificas:
      return ModalidadServicio.especifico;
    case TipoRecurrencia.diario:
      return ModalidadServicio.diario;
  }
}

/// Extrae de la configuración del paso 2 los días de semana, días del mes y
/// fechas específicas seleccionados (estructuras legacy usadas en la revisión).
void extraerSeleccionesDeConfiguracion({
  required Map<String, dynamic> configuracion,
  required ModalidadServicio modalidad,
  required Set<int> diasSemana,
  required Set<int> diasMes,
  required Set<DateTime> fechasEspecificas,
}) {
  // ✅ Extraer días de semana de la configuración para modalidades semanales
  if (modalidad == ModalidadServicio.semanal || modalidad == ModalidadServicio.semanasAlternas) {
    diasSemana.clear();
    final List<dynamic>? dias = configuracion['dias'] as List<dynamic>?;
    if (dias != null) {
      for (final dynamic diaData in dias) {
        if (diaData is Map<String, dynamic>) {
          final int? diaSemanaIndex = diaData['dia_semana'] as int?;
          if (diaSemanaIndex != null) {
            diasSemana.add(diaSemanaIndex);
          }
        }
      }
      debugPrint('📅 Días de semana extraídos: $diasSemana');
    }
  }

  // ✅ Extraer días del mes de la configuración para modalidad mensual
  if (modalidad == ModalidadServicio.mensual) {
    diasMes.clear();
    final List<dynamic>? dias = configuracion['dias'] as List<dynamic>?;
    if (dias != null) {
      for (final dynamic diaData in dias) {
        if (diaData is Map<String, dynamic>) {
          final int? diaMesNum = diaData['dia_mes'] as int?;
          if (diaMesNum != null) {
            diasMes.add(diaMesNum);
          }
        }
      }
      debugPrint('📅 Días del mes extraídos: $diasMes');
    }
  }

  // ✅ Extraer fechas específicas de la configuración
  if (modalidad == ModalidadServicio.especifico) {
    fechasEspecificas.clear();
    final List<dynamic>? fechas = configuracion['fechas'] as List<dynamic>?;
    if (fechas != null) {
      for (final dynamic fechaData in fechas) {
        if (fechaData is Map<String, dynamic>) {
          final String? fechaStr = fechaData['fecha'] as String?;
          if (fechaStr != null) {
            try {
              fechasEspecificas.add(DateTime.parse(fechaStr));
            } catch (e) {
              debugPrint('⚠️ Error parseando fecha: $fechaStr - $e');
            }
          }
        }
      }
      debugPrint('📅 Fechas específicas extraídas: $fechasEspecificas');
    }
  }
}
