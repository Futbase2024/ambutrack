import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../../domain/entities/configuracion_dia.dart';
import 'tabla_dias_config.dart';

/// Widget de configuración para recurrencia FECHAS ESPECÍFICAS
/// Permite agregar fechas manualmente y mostrarlas en tabla con opción de eliminar
class ConfigFechasEspecificasTabla extends StatefulWidget {
  const ConfigFechasEspecificasTabla({
    required this.tiempoEspera,
    required this.mostrarColumnaVuelta,
    required this.onConfigChanged,
    this.fechasIniciales,
    this.horaEnCentro,
    super.key,
  });

  /// Tiempo de espera en minutos (del motivo de traslado)
  final int tiempoEspera;

  /// Si se deben mostrar las columnas de Vuelta
  final bool mostrarColumnaVuelta;

  /// Callback cuando cambia la configuración
  final void Function(List<ConfiguracionDia>) onConfigChanged;

  /// Configuración inicial de fechas (opcional)
  final List<ConfiguracionDia>? fechasIniciales;

  /// Hora en centro del Paso 1 (para autocompletar al marcar Ida)
  final TimeOfDay? horaEnCentro;

  @override
  State<ConfigFechasEspecificasTabla> createState() => _ConfigFechasEspecificasTablaState();
}

class _ConfigFechasEspecificasTablaState extends State<ConfigFechasEspecificasTabla> {
  late List<ConfiguracionDia> _fechas;

  @override
  void initState() {
    super.initState();
    _initializeFechas();
  }

  @override
  void didUpdateWidget(ConfigFechasEspecificasTabla oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Si cambia el tiempo de espera, actualizar todas las fechas
    if (oldWidget.tiempoEspera != widget.tiempoEspera) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _updateTiempoEspera();
        }
      });
    }

    // Si cambia la hora en centro, actualizar hora ida de todas las fechas activas
    if (oldWidget.horaEnCentro != widget.horaEnCentro && widget.horaEnCentro != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _updateHoraEnCentro();
        }
      });
    }
  }

  void _initializeFechas() {
    if (widget.fechasIniciales != null && widget.fechasIniciales!.isNotEmpty) {
      _fechas = widget.fechasIniciales!;
    } else {
      _fechas = <ConfiguracionDia>[];
    }
  }

  void _updateTiempoEspera() {
    setState(() {
      _fechas = _fechas.map((ConfiguracionDia dia) {
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

    // ✅ Filtrar: solo reportar fechas activas (ida=true O vuelta=true)
    final List<ConfiguracionDia> fechasActivas = _fechas
        .where((ConfiguracionDia d) => d.ida || d.vuelta)
        .toList();

    widget.onConfigChanged(fechasActivas);
  }

  /// Actualiza la hora ida de todas las fechas activas cuando cambia horaEnCentro en Step 1
  void _updateHoraEnCentro() {
    setState(() {
      _fechas = _fechas.map((ConfiguracionDia dia) {
        // Solo actualizar si la fecha tiene ida=true
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
    final List<ConfiguracionDia> fechasActivas = _fechas
        .where((ConfiguracionDia d) => d.ida || d.vuelta)
        .toList();

    widget.onConfigChanged(fechasActivas);
  }

  void _onFechaChanged(int index, ConfiguracionDia nuevaConfig) {
    setState(() {
      _fechas[index] = ConfiguracionDia(
        diaSemana: nuevaConfig.diaSemana,
        diaMes: nuevaConfig.diaMes,
        fecha: nuevaConfig.fecha,
        ida: nuevaConfig.ida,
        horaIda: nuevaConfig.horaIda,
        tiempoEspera: widget.tiempoEspera,
        vuelta: nuevaConfig.vuelta,
      );
    });

    // ✅ Filtrar: solo reportar fechas activas (ida=true O vuelta=true)
    final List<ConfiguracionDia> fechasActivas = _fechas
        .where((ConfiguracionDia d) => d.ida || d.vuelta)
        .toList();

    debugPrint('📅 ConfigFechasEspecificas._onFechaChanged: Reportando ${fechasActivas.length} fechas activas');
    debugPrint('📅 Fechas activas: ${fechasActivas.map((ConfiguracionDia d) => '${d.fecha} - ida:${d.ida}, vuelta:${d.vuelta}').toList()}');

    widget.onConfigChanged(fechasActivas);
  }

  void _onEliminarFecha(int index) {
    setState(() {
      _fechas.removeAt(index);
    });

    // ✅ Filtrar: solo reportar fechas activas (ida=true O vuelta=true)
    final List<ConfiguracionDia> fechasActivas = _fechas
        .where((ConfiguracionDia d) => d.ida || d.vuelta)
        .toList();

    widget.onConfigChanged(fechasActivas);
  }

  Future<void> _agregarFecha() async {
    final DateTime? fechaSeleccionada = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('es', 'ES'),
      helpText: 'Seleccionar Fecha',
      cancelText: 'Cancelar',
      confirmText: 'Agregar',
    );

    if (fechaSeleccionada != null) {
      // Verificar que la fecha no esté duplicada
      final bool fechaDuplicada = _fechas.any(
        (ConfiguracionDia d) =>
            d.fecha != null &&
            d.fecha!.year == fechaSeleccionada.year &&
            d.fecha!.month == fechaSeleccionada.month &&
            d.fecha!.day == fechaSeleccionada.day,
      );

      if (fechaDuplicada) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Esta fecha ya ha sido agregada'),
              backgroundColor: AppColors.warning,
            ),
          );
        }
        return;
      }

      setState(() {
        _fechas..add(
          ConfiguracionDia.fechaEspecifica(
            fecha: fechaSeleccionada,
            ida: true, // Por defecto activado
            horaIda: widget.horaEnCentro ?? const TimeOfDay(hour: 10, minute: 0), // ✅ Usar hora del paso 1
            tiempoEspera: widget.tiempoEspera,
            vuelta: false, // Por defecto sin vuelta
          ),
        )

        // Ordenar fechas por orden cronológico
        ..sort((ConfiguracionDia a, ConfiguracionDia b) {
          if (a.fecha == null || b.fecha == null) {
            return 0;
          }
          return a.fecha!.compareTo(b.fecha!);
        });
      });

      // ✅ Filtrar: solo reportar fechas activas (ida=true O vuelta=true)
      // Nota: Al agregar, siempre viene con ida=true por defecto, pero por consistencia aplicamos filtro
      final List<ConfiguracionDia> fechasActivas = _fechas
          .where((ConfiguracionDia d) => d.ida || d.vuelta)
          .toList();

      widget.onConfigChanged(fechasActivas);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  'Agrega fechas específicas en las que se realizará el servicio. '
                  'Puedes configurar el horario de cada fecha individualmente.',
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

        // Botón para agregar fecha
        Row(
          children: <Widget>[
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _agregarFecha,
                icon: const Icon(Icons.add, size: 18),
                label: Text(
                  'Agregar Fecha',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.paddingMedium,
                    vertical: AppSizes.paddingSmall,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.spacing),

        // Tabla de fechas (solo si hay fechas agregadas)
        if (_fechas.isNotEmpty) ...<Widget>[
          TablaDiasConfig(
            dias: _fechas,
            mostrarColumnaVuelta: widget.mostrarColumnaVuelta,
            onDiaChanged: _onFechaChanged,
            onEliminar: _onEliminarFecha,
            titulo: 'Fechas Seleccionadas (${_fechas.length})',
            horaEnCentro: widget.horaEnCentro,
          ),
        ] else ...<Widget>[
          // Mensaje cuando no hay fechas
          Container(
            padding: const EdgeInsets.all(AppSizes.paddingLarge),
            decoration: BoxDecoration(
              color: AppColors.gray100,
              borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
              border: Border.all(color: AppColors.gray300),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Icon(
                    Icons.event_busy,
                    size: 48,
                    color: AppColors.textSecondaryLight,
                  ),
                  const SizedBox(height: AppSizes.spacingSmall),
                  Text(
                    'No hay fechas agregadas',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Haz clic en "Agregar Fecha" para empezar',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],

        // Mensaje de advertencia si no hay fechas
        if (_fechas.isEmpty) ...<Widget>[
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
                    'Debes agregar al menos una fecha específica',
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
