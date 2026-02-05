import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../../domain/entities/configuracion_dia.dart';
import '../../../../../../domain/entities/dia_semana.dart';
import 'tabla_dias_config.dart';

/// Widget de configuración para recurrencia SEMANAL (días fijos de la semana)
/// Muestra una TablaDiasConfig con los 7 días de la semana
class ConfigSemanalTabla extends StatefulWidget {
  const ConfigSemanalTabla({
    required this.tiempoEspera,
    required this.mostrarColumnaVuelta,
    required this.onConfigChanged,
    this.diasIniciales,
    this.horaEnCentro,
    super.key,
  });

  /// Tiempo de espera en minutos (del motivo de traslado)
  final int tiempoEspera;

  /// Si se deben mostrar las columnas de Vuelta (de motivoTraslado.vuelta)
  final bool mostrarColumnaVuelta;

  /// Callback cuando cambia la configuración
  final void Function(List<ConfiguracionDia>) onConfigChanged;

  /// Configuración inicial de días (opcional)
  final List<ConfiguracionDia>? diasIniciales;

  /// Hora en centro del Paso 1 (para autocompletar al marcar Ida)
  final TimeOfDay? horaEnCentro;

  @override
  State<ConfigSemanalTabla> createState() => _ConfigSemanalTablaState();
}

class _ConfigSemanalTablaState extends State<ConfigSemanalTabla> {
  late List<ConfiguracionDia> _dias;

  @override
  void initState() {
    super.initState();
    _initializeDias();
  }

  @override
  void didUpdateWidget(ConfigSemanalTabla oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Si cambia el tiempo de espera, actualizar todos los días
    if (oldWidget.tiempoEspera != widget.tiempoEspera) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _updateTiempoEspera();
        }
      });
    }

    // Si cambia la hora en centro, actualizar hora ida de todos los días activos
    if (oldWidget.horaEnCentro != widget.horaEnCentro && widget.horaEnCentro != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _updateHoraEnCentro();
        }
      });
    }
  }

  void _initializeDias() {
    // SIEMPRE crear los 7 días de la semana
    _dias = DiaSemana.values.map((DiaSemana dia) {
      // Buscar si este día ya existe en diasIniciales
      final ConfiguracionDia? diaExistente = widget.diasIniciales?.firstWhere(
        (ConfiguracionDia d) => d.diaSemana == dia,
        orElse: () => ConfiguracionDia.semanal(
          diaSemana: dia,
          ida: false,
          tiempoEspera: widget.tiempoEspera,
          vuelta: false,
        ),
      );

      // Si encontró el día en diasIniciales, usarlo; sino crear uno nuevo desactivado
      return diaExistente ?? ConfiguracionDia.semanal(
        diaSemana: dia,
        ida: false,
        tiempoEspera: widget.tiempoEspera,
        vuelta: false,
      );
    }).toList();
  }

  void _updateTiempoEspera() {
    setState(() {
      _dias = _dias.map((ConfiguracionDia dia) {
        return ConfiguracionDia(
          diaSemana: dia.diaSemana,
          diaMes: dia.diaMes,
          fecha: dia.fecha,
          ida: dia.ida,
          horaIda: dia.horaIda,
          tiempoEspera: widget.tiempoEspera, // Actualizar tiempo
          vuelta: dia.vuelta,
        );
      }).toList();
    });
    widget.onConfigChanged(_dias);
  }

  /// Actualiza la hora ida de todos los días activos cuando cambia horaEnCentro en Step 1
  void _updateHoraEnCentro() {
    setState(() {
      _dias = _dias.map((ConfiguracionDia dia) {
        // Solo actualizar días que tienen ida=true
        if (dia.ida && widget.horaEnCentro != null) {
          return ConfiguracionDia(
            diaSemana: dia.diaSemana,
            diaMes: dia.diaMes,
            fecha: dia.fecha,
            ida: dia.ida,
            horaIda: widget.horaEnCentro, // Actualizar con nueva hora
            tiempoEspera: dia.tiempoEspera,
            vuelta: dia.vuelta,
          );
        }
        return dia; // Mantener sin cambios si ida=false
      }).toList();
    });

    // Reportar cambios al padre
    final List<ConfiguracionDia> diasActivos = _dias
        .where((ConfiguracionDia d) => d.ida || d.vuelta)
        .toList();
    widget.onConfigChanged(diasActivos);
  }

  void _onDiaChanged(int index, ConfiguracionDia nuevaConfig) {
    setState(() {
      _dias[index] = ConfiguracionDia(
        diaSemana: nuevaConfig.diaSemana,
        diaMes: nuevaConfig.diaMes,
        fecha: nuevaConfig.fecha,
        ida: nuevaConfig.ida,
        horaIda: nuevaConfig.horaIda,
        tiempoEspera: widget.tiempoEspera, // Mantener tiempo de espera global
        vuelta: nuevaConfig.vuelta,
      );
    });

    // ✅ Filtrar: solo reportar días que tienen ida=true O vuelta=true
    final List<ConfiguracionDia> diasActivos = _dias
        .where((ConfiguracionDia d) => d.ida || d.vuelta)
        .toList();

    widget.onConfigChanged(diasActivos);
  }

  @override
  Widget build(BuildContext context) {
    // Validar que haya al menos un día con ida=true
    final bool hayAlgunDiaActivo = _dias.any((ConfiguracionDia d) => d.ida);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // Mensaje informativo
        Container(
          padding: const EdgeInsets.all(AppSizes.paddingSmall),
          decoration: BoxDecoration(
            color: AppColors.info.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
            border: Border.all(
              color: AppColors.info.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: <Widget>[
              const Icon(
                Icons.info_outline,
                size: 16,
                color: AppColors.info,
              ),
              const SizedBox(width: AppSizes.spacingSmall),
              Expanded(
                child: Text(
                  'Selecciona los días de la semana y configura los horarios para cada uno.',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.info,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSizes.spacing),

        // Tabla de días de la semana (L-D)
        TablaDiasConfig(
          dias: _dias,
          mostrarColumnaVuelta: widget.mostrarColumnaVuelta,
          onDiaChanged: _onDiaChanged,
          horaEnCentro: widget.horaEnCentro,
          titulo: 'Configuración Semanal',
        ),

        // Mensaje de advertencia si no hay días activos
        if (!hayAlgunDiaActivo) ...<Widget>[
          const SizedBox(height: AppSizes.spacing),
          Container(
            padding: const EdgeInsets.all(AppSizes.paddingSmall),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
              border: Border.all(
                color: AppColors.warning.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: <Widget>[
                const Icon(
                  Icons.warning_amber,
                  size: 16,
                  color: AppColors.warning,
                ),
                const SizedBox(width: AppSizes.spacingSmall),
                Expanded(
                  child: Text(
                    'Debes seleccionar al menos un día de la semana',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.warning,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
