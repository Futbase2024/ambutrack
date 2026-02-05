import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../../domain/entities/configuracion_dia.dart';
import '../../../../../../domain/entities/dia_semana.dart';
import 'tabla_dias_config.dart';

/// Widget de configuración para recurrencia DÍAS ALTERNOS
/// Muestra DOS TablaDiasConfig: una para semanas PARES y otra para semanas IMPARES
class ConfigDiasAlternosTabla extends StatefulWidget {
  const ConfigDiasAlternosTabla({
    required this.tiempoEspera,
    required this.mostrarColumnaVuelta,
    required this.onConfigChanged,
    this.diasParesIniciales,
    this.diasImparesIniciales,
    this.horaEnCentro,
    super.key,
  });

  /// Tiempo de espera en minutos (del motivo de traslado)
  final int tiempoEspera;

  /// Si se deben mostrar las columnas de Vuelta
  final bool mostrarColumnaVuelta;

  /// Callback cuando cambia la configuración
  /// Retorna un Map con 'pares' e 'impares'
  final void Function({
    required List<ConfiguracionDia> pares,
    required List<ConfiguracionDia> impares,
  }) onConfigChanged;

  /// Configuración inicial de días pares (opcional)
  final List<ConfiguracionDia>? diasParesIniciales;

  /// Configuración inicial de días impares (opcional)
  final List<ConfiguracionDia>? diasImparesIniciales;

  /// Hora en centro del Paso 1 (para autocompletar al marcar Ida)
  final TimeOfDay? horaEnCentro;

  @override
  State<ConfigDiasAlternosTabla> createState() => _ConfigDiasAlternosTablaState();
}

class _ConfigDiasAlternosTablaState extends State<ConfigDiasAlternosTabla> {
  late List<ConfiguracionDia> _diasPares;
  late List<ConfiguracionDia> _diasImpares;

  @override
  void initState() {
    super.initState();
    _initializeDias();
  }

  @override
  void didUpdateWidget(ConfigDiasAlternosTabla oldWidget) {
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
    // SIEMPRE crear los 7 días para pares, preservando configuración existente
    _diasPares = DiaSemana.values.map((DiaSemana dia) {
      final ConfiguracionDia? diaExistente = widget.diasParesIniciales?.firstWhere(
        (ConfiguracionDia d) => d.diaSemana == dia,
        orElse: () => ConfiguracionDia.semanal(
          diaSemana: dia,
          ida: false,
          tiempoEspera: widget.tiempoEspera,
          vuelta: false,
        ),
      );
      return diaExistente ?? ConfiguracionDia.semanal(
        diaSemana: dia,
        ida: false,
        tiempoEspera: widget.tiempoEspera,
        vuelta: false,
      );
    }).toList();

    // SIEMPRE crear los 7 días para impares, preservando configuración existente
    _diasImpares = DiaSemana.values.map((DiaSemana dia) {
      final ConfiguracionDia? diaExistente = widget.diasImparesIniciales?.firstWhere(
        (ConfiguracionDia d) => d.diaSemana == dia,
        orElse: () => ConfiguracionDia.semanal(
          diaSemana: dia,
          ida: false,
          tiempoEspera: widget.tiempoEspera,
          vuelta: false,
        ),
      );
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
      _diasPares = _diasPares.map((ConfiguracionDia dia) {
        return ConfiguracionDia(
          diaSemana: dia.diaSemana,
          diaMes: dia.diaMes,
          fecha: dia.fecha,
          ida: dia.ida,
          horaIda: dia.horaIda,
          tiempoEspera: widget.tiempoEspera,
          vuelta: dia.vuelta,
        );
      }).toList();

      _diasImpares = _diasImpares.map((ConfiguracionDia dia) {
        return ConfiguracionDia(
          diaSemana: dia.diaSemana,
          diaMes: dia.diaMes,
          fecha: dia.fecha,
          ida: dia.ida,
          horaIda: dia.horaIda,
          tiempoEspera: widget.tiempoEspera,
          vuelta: dia.vuelta,
        );
      }).toList();
    });

    // ✅ Filtrar: solo reportar días activos (ida=true O vuelta=true)
    final List<ConfiguracionDia> paresActivos = _diasPares
        .where((ConfiguracionDia d) => d.ida || d.vuelta)
        .toList();
    final List<ConfiguracionDia> imparesActivos = _diasImpares
        .where((ConfiguracionDia d) => d.ida || d.vuelta)
        .toList();

    widget.onConfigChanged(pares: paresActivos, impares: imparesActivos);
  }

  /// Actualiza la hora ida de todos los días activos cuando cambia horaEnCentro en Step 1
  void _updateHoraEnCentro() {
    setState(() {
      _diasPares = _diasPares.map((ConfiguracionDia dia) {
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
        return dia;
      }).toList();

      _diasImpares = _diasImpares.map((ConfiguracionDia dia) {
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
        return dia;
      }).toList();
    });

    // Reportar cambios al padre
    final List<ConfiguracionDia> paresActivos = _diasPares
        .where((ConfiguracionDia d) => d.ida || d.vuelta)
        .toList();
    final List<ConfiguracionDia> imparesActivos = _diasImpares
        .where((ConfiguracionDia d) => d.ida || d.vuelta)
        .toList();

    widget.onConfigChanged(pares: paresActivos, impares: imparesActivos);
  }

  void _onDiaParChanged(int index, ConfiguracionDia nuevaConfig) {
    setState(() {
      _diasPares[index] = ConfiguracionDia(
        diaSemana: nuevaConfig.diaSemana,
        diaMes: nuevaConfig.diaMes,
        fecha: nuevaConfig.fecha,
        ida: nuevaConfig.ida,
        horaIda: nuevaConfig.horaIda,
        tiempoEspera: widget.tiempoEspera,
        vuelta: nuevaConfig.vuelta,
      );
    });

    // ✅ Filtrar: solo reportar días activos (ida=true O vuelta=true)
    final List<ConfiguracionDia> paresActivos = _diasPares
        .where((ConfiguracionDia d) => d.ida || d.vuelta)
        .toList();
    final List<ConfiguracionDia> imparesActivos = _diasImpares
        .where((ConfiguracionDia d) => d.ida || d.vuelta)
        .toList();

    widget.onConfigChanged(pares: paresActivos, impares: imparesActivos);
  }

  void _onDiaImparChanged(int index, ConfiguracionDia nuevaConfig) {
    setState(() {
      _diasImpares[index] = ConfiguracionDia(
        diaSemana: nuevaConfig.diaSemana,
        diaMes: nuevaConfig.diaMes,
        fecha: nuevaConfig.fecha,
        ida: nuevaConfig.ida,
        horaIda: nuevaConfig.horaIda,
        tiempoEspera: widget.tiempoEspera,
        vuelta: nuevaConfig.vuelta,
      );
    });

    // ✅ Filtrar: solo reportar días activos (ida=true O vuelta=true)
    final List<ConfiguracionDia> paresActivos = _diasPares
        .where((ConfiguracionDia d) => d.ida || d.vuelta)
        .toList();
    final List<ConfiguracionDia> imparesActivos = _diasImpares
        .where((ConfiguracionDia d) => d.ida || d.vuelta)
        .toList();

    widget.onConfigChanged(pares: paresActivos, impares: imparesActivos);
  }

  @override
  Widget build(BuildContext context) {
    // Validar que haya al menos un día activo en alguna de las dos semanas
    final bool hayAlgunDiaActivo =
        _diasPares.any((ConfiguracionDia d) => d.ida) ||
        _diasImpares.any((ConfiguracionDia d) => d.ida);

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
                  'Configura los horarios para las semanas pares e impares. '
                  'Las semanas se alternarán automáticamente.',
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

        // Tabla de semanas PARES
        TablaDiasConfig(
          dias: _diasPares,
          mostrarColumnaVuelta: widget.mostrarColumnaVuelta,
          onDiaChanged: _onDiaParChanged,
          titulo: 'Semanas Pares (2, 4, 6, ...)',
          horaEnCentro: widget.horaEnCentro,
          mostrarBotonCopiar: false,
        ),
        const SizedBox(height: AppSizes.spacingLarge),

        // Tabla de semanas IMPARES
        TablaDiasConfig(
          dias: _diasImpares,
          mostrarColumnaVuelta: widget.mostrarColumnaVuelta,
          onDiaChanged: _onDiaImparChanged,
          titulo: 'Semanas Impares (1, 3, 5, ...)',
          horaEnCentro: widget.horaEnCentro,
          mostrarBotonCopiar: false,
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
                    'Debes seleccionar al menos un día en alguna de las dos semanas',
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
