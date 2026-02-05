import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../../domain/entities/configuracion_dia.dart';
import 'selector_dias_mes.dart';
import 'tabla_dias_config.dart';

/// Widget de configuración para recurrencia MENSUAL
/// Combina SelectorDiasMes + TablaDiasConfig para los días seleccionados
class ConfigMensualTabla extends StatefulWidget {
  const ConfigMensualTabla({
    required this.tiempoEspera,
    required this.mostrarColumnaVuelta,
    required this.onConfigChanged,
    this.diasIniciales,
    this.horaEnCentro,
    super.key,
  });

  /// Tiempo de espera en minutos (del motivo de traslado)
  final int tiempoEspera;

  /// Si se deben mostrar las columnas de Vuelta
  final bool mostrarColumnaVuelta;

  /// Callback cuando cambia la configuración
  final void Function(List<ConfiguracionDia>) onConfigChanged;

  /// Configuración inicial de días (opcional)
  final List<ConfiguracionDia>? diasIniciales;

  /// Hora en centro del Paso 1 (para autocompletar al marcar Ida)
  final TimeOfDay? horaEnCentro;

  @override
  State<ConfigMensualTabla> createState() => _ConfigMensualTablaState();
}

class _ConfigMensualTablaState extends State<ConfigMensualTabla> {
  late List<int> _diasSeleccionados;
  late Map<int, ConfiguracionDia> _configuracionPorDia;

  @override
  void initState() {
    super.initState();
    _initializeDias();
  }

  @override
  void didUpdateWidget(ConfigMensualTabla oldWidget) {
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
    debugPrint('🔧 ConfigMensualTabla: Inicializando días...');
    _configuracionPorDia = <int, ConfiguracionDia>{};

    if (widget.diasIniciales != null && widget.diasIniciales!.isNotEmpty) {
      debugPrint('🔧 ConfigMensualTabla: Días iniciales: ${widget.diasIniciales!.length}');
      _diasSeleccionados = <int>[];
      for (final ConfiguracionDia dia in widget.diasIniciales!) {
        if (dia.diaMes != null) {
          _diasSeleccionados.add(dia.diaMes!);
          _configuracionPorDia[dia.diaMes!] = dia;
        }
      }
      debugPrint('🔧 ConfigMensualTabla: Días cargados: $_diasSeleccionados');
      // ✅ Notificar configuración inicial
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _notifyChanges();
      });
    } else {
      debugPrint('🔧 ConfigMensualTabla: Sin días iniciales (nuevo servicio)');
      _diasSeleccionados = <int>[];
    }
  }

  void _updateTiempoEspera() {
    final Map<int, ConfiguracionDia> nuevaConfig = <int, ConfiguracionDia>{};

    for (final MapEntry<int, ConfiguracionDia> entry in _configuracionPorDia.entries) {
      nuevaConfig[entry.key] = ConfiguracionDia(
        diaSemana: entry.value.diaSemana,
        diaMes: entry.value.diaMes,
        fecha: entry.value.fecha,
        ida: entry.value.ida,
        horaIda: entry.value.horaIda,
        tiempoEspera: widget.tiempoEspera,
        vuelta: entry.value.vuelta,
      );
    }

    setState(() {
      _configuracionPorDia = nuevaConfig;
    });

    _notifyChanges();
  }

  /// Actualiza la hora ida de todos los días activos cuando cambia horaEnCentro en Step 1
  void _updateHoraEnCentro() {
    final Map<int, ConfiguracionDia> nuevaConfig = <int, ConfiguracionDia>{};

    for (final MapEntry<int, ConfiguracionDia> entry in _configuracionPorDia.entries) {
      // Solo actualizar si el día tiene ida=true
      if (entry.value.ida && widget.horaEnCentro != null) {
        nuevaConfig[entry.key] = ConfiguracionDia(
          diaSemana: entry.value.diaSemana,
          diaMes: entry.value.diaMes,
          fecha: entry.value.fecha,
          ida: entry.value.ida,
          horaIda: widget.horaEnCentro, // Actualizar con nueva hora
          tiempoEspera: entry.value.tiempoEspera,
          vuelta: entry.value.vuelta,
        );
      } else {
        nuevaConfig[entry.key] = entry.value; // Mantener sin cambios
      }
    }

    setState(() {
      _configuracionPorDia = nuevaConfig;
    });

    _notifyChanges();
  }

  void _onDiasSeleccionChanged(List<int> nuevosDias) {
    debugPrint('📅 ConfigMensualTabla: Días seleccionados cambiados: $nuevosDias');
    setState(() {
      // Eliminar días que ya no están seleccionados
      _configuracionPorDia.removeWhere(
        (int dia, ConfiguracionDia config) => !nuevosDias.contains(dia),
      );

      // Agregar configuración por defecto para días nuevos
      for (final int dia in nuevosDias) {
        if (!_configuracionPorDia.containsKey(dia)) {
          debugPrint('📅 ConfigMensualTabla: Agregando día $dia con hora ${widget.horaEnCentro}');
          _configuracionPorDia[dia] = ConfiguracionDia.mensual(
            diaMes: dia,
            ida: true, // Por defecto activado
            horaIda: widget.horaEnCentro ?? const TimeOfDay(hour: 10, minute: 0), // ✅ Usar hora del paso 1
            tiempoEspera: widget.tiempoEspera,
            vuelta: false,
          );
        }
      }

      _diasSeleccionados = nuevosDias;
    });

    debugPrint('📅 ConfigMensualTabla: Llamando _notifyChanges...');
    _notifyChanges();
  }

  void _onDiaChanged(int index, ConfiguracionDia nuevaConfig) {
    final List<ConfiguracionDia> diasOrdenados = _getDiasOrdenados();
    final ConfiguracionDia diaActual = diasOrdenados[index];

    if (diaActual.diaMes != null) {
      setState(() {
        _configuracionPorDia[diaActual.diaMes!] = ConfiguracionDia(
          diaSemana: nuevaConfig.diaSemana,
          diaMes: diaActual.diaMes,
          fecha: nuevaConfig.fecha,
          ida: nuevaConfig.ida,
          horaIda: nuevaConfig.horaIda,
          tiempoEspera: widget.tiempoEspera,
          vuelta: nuevaConfig.vuelta,
        );
      });

      _notifyChanges();
    }
  }

  List<ConfiguracionDia> _getDiasOrdenados() {
    final List<int> diasOrdenados = List<int>.from(_diasSeleccionados)
    ..sort((int a, int b) {
      if (a == 0) {
        return 1;
      }
      if (b == 0) {
        return -1;
      }
      return a.compareTo(b);
    });

    return diasOrdenados
        .where((int dia) => _configuracionPorDia.containsKey(dia))
        .map((int dia) => _configuracionPorDia[dia]!)
        .toList();
  }

  void _notifyChanges() {
    final List<ConfiguracionDia> dias = _getDiasOrdenados();
    debugPrint('🔔 ConfigMensualTabla: Notificando cambios con ${dias.length} días');
    debugPrint('🔔 ConfigMensualTabla: Días: ${dias.map((ConfiguracionDia d) => d.diaMes).toList()}');
    widget.onConfigChanged(dias);
  }

  @override
  Widget build(BuildContext context) {
    final List<ConfiguracionDia> diasOrdenados = _getDiasOrdenados();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // Selector de días del mes
        SelectorDiasMes(
          diasSeleccionados: _diasSeleccionados,
          onDiasChanged: _onDiasSeleccionChanged,
        ),

        // Mostrar tabla solo si hay días seleccionados
        if (diasOrdenados.isNotEmpty) ...<Widget>[
          const SizedBox(height: AppSizes.spacingLarge),
          TablaDiasConfig(
            dias: diasOrdenados,
            mostrarColumnaVuelta: widget.mostrarColumnaVuelta,
            onDiaChanged: _onDiaChanged,
            titulo: 'Configuración de Días Seleccionados (${diasOrdenados.length})',
            horaEnCentro: widget.horaEnCentro,
          ),
        ],

        // Mensaje de advertencia si no hay días seleccionados
        if (_diasSeleccionados.isEmpty) ...<Widget>[
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
                    'Debes seleccionar al menos un día del mes',
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
