import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/widgets/loading/app_loading_indicator.dart';
import 'package:ambutrack_web/features/cuadrante/cuadrante_module/presentation/bloc/cuadrante_state.dart';
import 'package:ambutrack_web/features/cuadrante/dotaciones/domain/repositories/dotaciones_repository.dart';
import 'package:ambutrack_web/features/turnos/domain/repositories/turnos_repository.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Vista de calendario mensual con heatmap de disponibilidad
class CuadranteCalendarioView extends StatefulWidget {
  const CuadranteCalendarioView({
    required this.state,
    super.key,
  });

  final CuadranteLoaded state;

  @override
  State<CuadranteCalendarioView> createState() => _CuadranteCalendarioViewState();
}

class _CuadranteCalendarioViewState extends State<CuadranteCalendarioView> {
  DateTime? _diaSeleccionado;
  bool _isLoading = true;
  List<TurnoEntity> _turnos = <TurnoEntity>[];
  List<DotacionEntity> _dotaciones = <DotacionEntity>[];

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  @override
  void didUpdateWidget(CuadranteCalendarioView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Recargar si cambia el mes
    if (widget.state.fechaActual.month != oldWidget.state.fechaActual.month ||
        widget.state.fechaActual.year != oldWidget.state.fechaActual.year) {
      _cargarDatos();
    }
  }

  Future<void> _cargarDatos() async {
    if (!mounted) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final TurnosRepository turnosRepository = getIt<TurnosRepository>();
      final DotacionesRepository dotacionesRepository = getIt<DotacionesRepository>();

      final DateTime primerDiaMes = DateTime(widget.state.fechaActual.year, widget.state.fechaActual.month);
      final DateTime ultimoDiaMes = DateTime(widget.state.fechaActual.year, widget.state.fechaActual.month + 1, 0);

      // Cargar turnos del mes y dotaciones en paralelo
      final List<dynamic> results = await Future.wait(<Future<dynamic>>[
        turnosRepository.getByDateRange(
          startDate: primerDiaMes,
          endDate: ultimoDiaMes.add(const Duration(days: 1)),
        ),
        dotacionesRepository.getAll(),
      ]);

      final List<TurnoEntity> turnos = results[0] as List<TurnoEntity>;
      final List<DotacionEntity> todasDotaciones = results[1] as List<DotacionEntity>;

      // Filtrar solo dotaciones activas
      final List<DotacionEntity> dotaciones = todasDotaciones
          .where((DotacionEntity d) => d.activo)
          .toList();

      if (mounted) {
        setState(() {
          _turnos = turnos;
          _dotaciones = dotaciones;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Error al cargar datos del calendario: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        padding: const EdgeInsets.all(AppSizes.paddingXl),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.radius),
          border: Border.all(color: AppColors.gray200),
        ),
        constraints: const BoxConstraints(minHeight: 400),
        child: const Center(
          child: AppLoadingIndicator(
            message: 'Cargando calendario...',
          ),
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // Header con título del mes
          _buildHeader(),
          const SizedBox(height: AppSizes.spacing),

          // Row con estadísticas y calendario
          LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // Estadísticas del mes (izquierda)
                  SizedBox(
                    width: 350,
                    child: Column(
                      children: <Widget>[
                        _buildEstadisticasMes(),
                        if (_diaSeleccionado != null) ...<Widget>[
                          const SizedBox(height: AppSizes.spacing),
                          _buildDetallesDia(),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSizes.spacing),

                  // Calendario (derecha - ocupa el resto del espacio)
                  SizedBox(
                    width: constraints.maxWidth - 350 - AppSizes.spacing,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        _buildLeyenda(),
                        const SizedBox(height: AppSizes.paddingSmall),
                        _buildCalendario(),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final String mesNombre = _getNombreMes(widget.state.fechaActual.month);
    final int anio = widget.state.fechaActual.year;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingMedium,
        vertical: AppSizes.paddingLarge,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: <Color>[AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSizes.radius),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          '$mesNombre $anio',
          style: GoogleFonts.inter(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 0.5,
            height: 1.2,
          ),
        ),
      ),
    );
  }

  Widget _buildEstadisticasMes() {
    // Calcular estadísticas del mes completo
    final DateTime ultimoDia = DateTime(widget.state.fechaActual.year, widget.state.fechaActual.month + 1, 0);

    int totalRequerido = 0;
    int totalProgramado = 0;
    final Map<String, int> porNivel = <String, int>{
      'muy_bajo': 0,
      'bajo': 0,
      'adecuado': 0,
      'sobrecarga': 0,
      'sin_datos': 0,
    };

    // Recorrer todos los días del mes
    for (int dia = 1; dia <= ultimoDia.day; dia++) {
      final DateTime fecha = DateTime(widget.state.fechaActual.year, widget.state.fechaActual.month, dia);
      final Map<String, dynamic> stats = _calcularEstadisticasDia(fecha);

      final int requerido = stats['requerido'] as int;
      final int programado = stats['programado'] as int;
      final double porcentaje = stats['porcentaje'] as double;

      totalRequerido += requerido;
      totalProgramado += programado;

      // Clasificar día según nivel de disponibilidad
      if (requerido == 0) {
        porNivel['sin_datos'] = porNivel['sin_datos']! + 1;
      } else if (porcentaje < 25) {
        porNivel['muy_bajo'] = porNivel['muy_bajo']! + 1;
      } else if (porcentaje < 85) {
        porNivel['bajo'] = porNivel['bajo']! + 1;
      } else if (porcentaje <= 100) {
        porNivel['adecuado'] = porNivel['adecuado']! + 1;
      } else {
        porNivel['sobrecarga'] = porNivel['sobrecarga']! + 1;
      }
    }

    final double porcentajeTotal = totalRequerido > 0 ? (totalProgramado / totalRequerido) * 100 : 0;

    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radius),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Resumen del Mes',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: AppSizes.spacing),

          // Total programado vs requerido
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  'Total:',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.textSecondaryLight,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingSmall,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _getColorFromPorcentaje(porcentajeTotal, totalRequerido).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                  border: Border.all(
                    color: _getColorFromPorcentaje(porcentajeTotal, totalRequerido),
                  ),
                ),
                child: Text(
                  '$totalProgramado / $totalRequerido (${porcentajeTotal.toStringAsFixed(1)}%)',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: _getColorFromPorcentaje(porcentajeTotal, totalRequerido),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spacing),

          // Distribución por niveles
          Text(
            'Días por Nivel de Disponibilidad:',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: AppSizes.paddingSmall),

          _buildNivelRow('Muy Bajo (<25%)', porNivel['muy_bajo']!, AppColors.error),
          _buildNivelRow('Bajo (25-84%)', porNivel['bajo']!, AppColors.warning),
          _buildNivelRow('Adecuado (≥85%)', porNivel['adecuado']!, AppColors.success),
          _buildNivelRow('Sobrecarga (>100%)', porNivel['sobrecarga']!, AppColors.secondary),
          if (porNivel['sin_datos']! > 0)
            _buildNivelRow('Sin Datos', porNivel['sin_datos']!, AppColors.gray200),
        ],
      ),
    );
  }

  Widget _buildNivelRow(String label, int dias, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.paddingSmall),
      child: Row(
        children: <Widget>[
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: AppColors.gray300),
            ),
          ),
          const SizedBox(width: AppSizes.paddingSmall),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppColors.textSecondaryLight,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
            ),
            child: Text(
              dias.toString(),
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: color == AppColors.gray200 ? AppColors.textPrimaryLight : color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeyenda() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radius),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          _buildLeyendaItem('Sin datos', AppColors.gray200),
          const SizedBox(width: AppSizes.spacing),
          _buildLeyendaItem('Muy Bajo (<25%)', AppColors.error),
          const SizedBox(width: AppSizes.spacing),
          _buildLeyendaItem('Bajo (25-84%)', AppColors.warning),
          const SizedBox(width: AppSizes.spacing),
          _buildLeyendaItem('Adecuado (≥85%)', AppColors.success),
          const SizedBox(width: AppSizes.spacing),
          _buildLeyendaItem('Sobrecarga (>100%)', AppColors.secondary),
        ],
      ),
    );
  }

  Widget _buildLeyendaItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: AppColors.gray300),
          ),
        ),
        const SizedBox(width: AppSizes.paddingSmall),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            color: AppColors.textSecondaryLight,
          ),
        ),
      ],
    );
  }

  Widget _buildCalendario() {
    final int diasEnMes = DateTime(widget.state.fechaActual.year, widget.state.fechaActual.month + 1, 0).day;
    final DateTime primerDia = DateTime(widget.state.fechaActual.year, widget.state.fechaActual.month);
    final int primerDiaSemana = primerDia.weekday; // 1 = Lunes, 7 = Domingo

    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radius),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Column(
        children: <Widget>[
          // Cabecera con días de la semana
          Container(
            padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingSmall),
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
            ),
            child: Row(
              children: <Widget>[
                for (final String dia in <String>['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'])
                  Expanded(
                    child: Center(
                      child: Text(
                        dia,
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.paddingSmall),
          // Grid de días
          _buildGridDias(diasEnMes, primerDiaSemana),
        ],
      ),
    );
  }

  Widget _buildGridDias(int diasEnMes, int primerDiaSemana) {
    final List<Widget> semanas = <Widget>[];
    int diaActual = 1;

    // Primera semana (puede tener espacios vacíos)
    final List<Widget> primeraSemana = <Widget>[];
    for (int i = 1; i < primerDiaSemana; i++) {
      primeraSemana.add(const Expanded(child: SizedBox()));
    }
    for (int i = primerDiaSemana; i <= 7 && diaActual <= diasEnMes; i++) {
      primeraSemana.add(_buildDiaCell(diaActual));
      diaActual++;
    }
    semanas.add(Row(children: primeraSemana));

    // Semanas completas
    while (diaActual <= diasEnMes) {
      final List<Widget> semana = <Widget>[];
      for (int i = 1; i <= 7 && diaActual <= diasEnMes; i++) {
        semana.add(_buildDiaCell(diaActual));
        diaActual++;
      }
      // Rellenar con espacios vacíos si es la última semana
      while (semana.length < 7) {
        semana.add(const Expanded(child: SizedBox()));
      }
      semanas.add(Row(children: semana));
    }

    return Column(
      children: semanas.map((Widget semana) {
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSizes.paddingSmall),
          child: semana,
        );
      }).toList(),
    );
  }

  Widget _buildDiaCell(int dia) {
    final DateTime fecha = DateTime(widget.state.fechaActual.year, widget.state.fechaActual.month, dia);
    final Map<String, dynamic> stats = _calcularEstadisticasDia(fecha);

    final int requerido = stats['requerido'] as int;
    final int programado = stats['programado'] as int;
    final double porcentaje = stats['porcentaje'] as double;
    final Color backgroundColor = _getColorFromPorcentaje(porcentaje, requerido);

    // Determinar color de texto según el fondo
    final Color textColor = _getTextColorForBackground(backgroundColor);

    final bool esHoy = _esHoy(fecha);
    final bool estaSeleccionado = _diaSeleccionado != null &&
        _diaSeleccionado!.year == fecha.year &&
        _diaSeleccionado!.month == fecha.month &&
        _diaSeleccionado!.day == fecha.day;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _diaSeleccionado = fecha;
          });
        },
        child: Container(
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
            border: Border.all(
              color: estaSeleccionado
                  ? AppColors.primary
                  : esHoy
                      ? AppColors.secondary
                      : Colors.transparent,
              width: estaSeleccionado ? 3 : 2,
            ),
            boxShadow: estaSeleccionado
                ? <BoxShadow>[
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.4),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: AspectRatio(
            aspectRatio: 1,
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    dia.toString(),
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: esHoy ? FontWeight.bold : FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  if (requerido > 0) ...<Widget>[
                    const SizedBox(height: 4),
                    Text(
                      '$programado/$requerido',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: textColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${porcentaje.toStringAsFixed(0)}%',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetallesDia() {
    if (_diaSeleccionado == null) {
      return const SizedBox.shrink();
    }

    final Map<String, dynamic> stats = _calcularEstadisticasDia(_diaSeleccionado!);
    final int requerido = stats['requerido'] as int;
    final int programado = stats['programado'] as int;
    final double porcentaje = stats['porcentaje'] as double;
    final Map<String, Map<String, int>> porDotacion = stats['porDotacion'] as Map<String, Map<String, int>>;

    final String diaNombre = _getNombreDiaCompleto(_diaSeleccionado!.weekday);
    final String fecha = '${_diaSeleccionado!.day}/${_diaSeleccionado!.month}/${_diaSeleccionado!.year}';

    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radius),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  '$diaNombre, $fecha',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimaryLight,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingSmall,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _getColorFromPorcentaje(porcentaje, requerido).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                  border: Border.all(
                    color: _getColorFromPorcentaje(porcentaje, requerido),
                  ),
                ),
                child: Text(
                  '$programado / $requerido (${porcentaje.toStringAsFixed(0)}%)',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: _getColorFromPorcentaje(porcentaje, requerido),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spacing),
          // Detalle por dotación
          ...porDotacion.entries.map((MapEntry<String, Map<String, int>> entry) {
            final String nombreDotacion = entry.key;
            final int req = entry.value['requerido'] ?? 0;
            final int prog = entry.value['programado'] ?? 0;
            final double pct = req > 0 ? (prog / req) * 100 : 0;

            return Padding(
              padding: const EdgeInsets.only(bottom: AppSizes.paddingSmall),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      nombreDotacion,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppColors.textPrimaryLight,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.paddingSmall,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: _getColorFromPorcentaje(pct, req).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                    ),
                    child: Text(
                      '$prog / $req (${pct.toStringAsFixed(0)}%)',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: _getColorFromPorcentaje(pct, req),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  /// Calcula estadísticas de disponibilidad para un día específico
  Map<String, dynamic> _calcularEstadisticasDia(DateTime fecha) {
    int totalRequerido = 0;
    int totalProgramado = 0;
    final Map<String, Map<String, int>> porDotacion = <String, Map<String, int>>{};

    // Filtrar dotaciones vigentes en esta fecha
    final List<DotacionEntity> dotacionesVigentes = _dotaciones
        .where((DotacionEntity d) => d.esVigenteEn(fecha))
        .toList();

    for (final DotacionEntity dotacion in dotacionesVigentes) {
      // Verificar si aplica en este día de la semana
      if (!dotacion.aplicaEnDia(fecha.weekday)) {
        continue;
      }

      final int requerido = dotacion.cantidadUnidades;
      totalRequerido += requerido;

      // Contar turnos programados para este día y dotación
      // IMPORTANTE: Usar fechas UTC para comparación consistente
      final int programado = _turnos.where((TurnoEntity turno) {
        if (turno.idDotacion != dotacion.id || !turno.activo) {
          return false;
        }

        // Normalizar fecha de inicio del turno a medianoche UTC
        final DateTime fechaInicioTurno = DateTime.utc(
          turno.fechaInicio.year,
          turno.fechaInicio.month,
          turno.fechaInicio.day,
        );

        // Normalizar fecha del día actual a medianoche UTC
        final DateTime fechaDiaUtc = DateTime.utc(
          fecha.year,
          fecha.month,
          fecha.day,
        );

        // El turno pertenece a este día si su fechaInicio (UTC, normalizado)
        // coincide con el día actual
        return fechaInicioTurno.isAtSameMomentAs(fechaDiaUtc);
      }).length;

      totalProgramado += programado;

      porDotacion[dotacion.nombre] = <String, int>{
        'requerido': requerido,
        'programado': programado,
      };
    }

    final double porcentaje = totalRequerido > 0 ? (totalProgramado / totalRequerido) * 100 : 0;

    return <String, dynamic>{
      'requerido': totalRequerido,
      'programado': totalProgramado,
      'porcentaje': porcentaje,
      'porDotacion': porDotacion,
    };
  }

  Color _getColorFromPorcentaje(double porcentaje, int requerido) {
    if (requerido == 0) {
      return AppColors.gray200; // Sin datos
    }
    if (porcentaje < 25) {
      return AppColors.error; // Muy bajo
    }
    if (porcentaje < 85) {
      return AppColors.warning; // Bajo
    }
    if (porcentaje <= 100) {
      return AppColors.success; // Adecuado
    }
    return AppColors.secondary; // Sobrecarga
  }

  /// Determina el color de texto adecuado según el color de fondo
  Color _getTextColorForBackground(Color backgroundColor) {
    // Usar blanco para colores de estado (error, warning, success, secondary)
    if (backgroundColor == AppColors.error ||
        backgroundColor == AppColors.warning ||
        backgroundColor == AppColors.success ||
        backgroundColor == AppColors.secondary) {
      return Colors.white;
    }
    // Usar gris oscuro para fondos claros (gray200)
    return AppColors.textPrimaryLight;
  }

  bool _esHoy(DateTime fecha) {
    final DateTime hoy = DateTime.now();
    return fecha.year == hoy.year && fecha.month == hoy.month && fecha.day == hoy.day;
  }

  String _getNombreMes(int mes) {
    switch (mes) {
      case 1:
        return 'Enero';
      case 2:
        return 'Febrero';
      case 3:
        return 'Marzo';
      case 4:
        return 'Abril';
      case 5:
        return 'Mayo';
      case 6:
        return 'Junio';
      case 7:
        return 'Julio';
      case 8:
        return 'Agosto';
      case 9:
        return 'Septiembre';
      case 10:
        return 'Octubre';
      case 11:
        return 'Noviembre';
      case 12:
        return 'Diciembre';
      default:
        return '';
    }
  }

  String _getNombreDiaCompleto(int dia) {
    switch (dia) {
      case 1:
        return 'Lunes';
      case 2:
        return 'Martes';
      case 3:
        return 'Miércoles';
      case 4:
        return 'Jueves';
      case 5:
        return 'Viernes';
      case 6:
        return 'Sábado';
      case 7:
        return 'Domingo';
      default:
        return '';
    }
  }
}
