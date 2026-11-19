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

/// Vista de disponibilidad/ocupación del cuadrante
class CuadranteDisponibilidadView extends StatefulWidget {
  const CuadranteDisponibilidadView({required this.state, super.key});

  final CuadranteLoaded state;

  @override
  State<CuadranteDisponibilidadView> createState() =>
      _CuadranteDisponibilidadViewState();
}

class _CuadranteDisponibilidadViewState
    extends State<CuadranteDisponibilidadView> {
  bool _isLoading = true;
  List<DotacionEntity> _dotaciones = <DotacionEntity>[];
  Map<String, Map<String, int>> _disponibilidadPorDotacion = <String, Map<String, int>>{};

  @override
  void initState() {
    super.initState();
    _cargarDisponibilidad();
  }

  @override
  void didUpdateWidget(CuadranteDisponibilidadView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Recargar si cambia la semana o si hay cambios en los turnos
    if (oldWidget.state.primerDiaSemana != widget.state.primerDiaSemana ||
        oldWidget.state.personalConTurnos.length != widget.state.personalConTurnos.length) {
      debugPrint('🔄 Recargando disponibilidad: semana o turnos cambiaron');
      _cargarDisponibilidad();
    }
  }

  Future<void> _cargarDisponibilidad() async {
    setState(() => _isLoading = true);

    try {
      final TurnosRepository turnosRepository = getIt<TurnosRepository>();
      final DotacionesRepository dotacionesRepository = getIt<DotacionesRepository>();

      // Calcular rango de la semana
      // IMPORTANTE: Normalizar a medianoche para evitar problemas con horas
      final DateTime primerDia = widget.state.primerDiaSemana;
      final DateTime inicioSemana = DateTime(primerDia.year, primerDia.month, primerDia.day);
      final DateTime finSemana = inicioSemana.add(const Duration(days: 7));

      // Cargar turnos de la semana y dotaciones en paralelo
      final List<dynamic> results = await Future.wait(<Future<dynamic>>[
        turnosRepository.getByDateRange(
          startDate: inicioSemana,
          endDate: finSemana,
        ),
        dotacionesRepository.getAll(),
      ]);

      final List<TurnoEntity> turnos = results[0] as List<TurnoEntity>;
      final List<DotacionEntity> todasDotaciones = results[1] as List<DotacionEntity>;

      // Filtrar solo dotaciones vigentes y activas
      final List<DotacionEntity> dotaciones = todasDotaciones
          .where((DotacionEntity d) => d.activo && d.esVigenteEn(inicioSemana))
          .toList();

      debugPrint('📊 Calculando disponibilidad para ${turnos.length} turnos y ${dotaciones.length} dotaciones');

      // Calcular disponibilidad por dotación
      final Map<String, Map<String, int>> disponibilidadPorDotacion = _calcularDisponibilidadPorDotacion(
        turnos: turnos,
        dotaciones: dotaciones,
        inicioSemana: inicioSemana,
      );

      if (mounted) {
        setState(() {
          _dotaciones = dotaciones;
          _disponibilidadPorDotacion = disponibilidadPorDotacion;
          _isLoading = false;
        });
      }

      debugPrint('✅ Dotaciones procesadas: ${disponibilidadPorDotacion.length}');
    } catch (e) {
      debugPrint('❌ Error al calcular disponibilidad: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Calcula la disponibilidad agrupada por dotación
  Map<String, Map<String, int>> _calcularDisponibilidadPorDotacion({
    required List<TurnoEntity> turnos,
    required List<DotacionEntity> dotaciones,
    required DateTime inicioSemana,
  }) {
    final Map<String, Map<String, int>> resultado = <String, Map<String, int>>{};

    for (final DotacionEntity dotacion in dotaciones) {
      final Map<String, int> stats = <String, int>{};
      int totalRequerido = 0;
      int totalProgramado = 0;

      // Filtrar turnos de esta dotación específica
      final List<TurnoEntity> turnosDotacion = turnos
          .where((TurnoEntity t) => t.idDotacion == dotacion.id)
          .toList();

      debugPrint('📊 ${dotacion.nombre}: ${turnosDotacion.length} turnos asignados');

      // Calcular por día
      for (int dia = 1; dia <= 7; dia++) {
        final String diaNombre = _getNombreDia(dia);
        final DateTime diaActual = inicioSemana.add(Duration(days: dia - 1));

        // Unidades requeridas según configuración de dotación
        int requerido = 0;
        if (dotacion.aplicaEnDia(dia)) {
          requerido = dotacion.cantidadUnidades;
          totalRequerido += requerido;
        }
        stats['${diaNombre}_requerido'] = requerido;

        // Contar turnos programados para este día
        // IMPORTANTE: Los turnos nocturnos (ej: 23:00 a 08:00) se contabilizan
        // en el día en que COMIENZAN, no en el día en que terminan
        final DateTime inicioDia = DateTime(diaActual.year, diaActual.month, diaActual.day);

        final List<TurnoEntity> turnosDelDia = turnosDotacion.where((TurnoEntity turno) {
          // IMPORTANTE: Usar la fecha UTC original normalizada a medianoche
          // No convertir a local, porque los turnos se guardan con la fecha del día
          // en que COMIENZAN, sin importar la zona horaria
          final DateTime fechaInicioTurno = DateTime.utc(
            turno.fechaInicio.year,
            turno.fechaInicio.month,
            turno.fechaInicio.day,
          );

          // Convertir inicioDia a UTC para comparación consistente
          final DateTime inicioDiaUtc = DateTime.utc(
            inicioDia.year,
            inicioDia.month,
            inicioDia.day,
          );

          // El turno pertenece a este día si su fechaInicio (UTC, normalizado)
          // coincide con el día actual (también en UTC)
          return fechaInicioTurno.isAtSameMomentAs(inicioDiaUtc);
        }).toList();

        final int programado = turnosDelDia.length;

        // Log solo si hay turnos programados
        if (programado > 0) {
          debugPrint('   📅 $diaNombre: $programado/$requerido (${turnosDelDia.map((TurnoEntity t) => t.nombrePersonal).join(', ')})');
        }

        stats['${diaNombre}_programado'] = programado;
        totalProgramado += programado;
      }

      stats['total_requerido'] = totalRequerido;
      stats['total_programado'] = totalProgramado;

      resultado[dotacion.nombre] = stats;
    }

    return resultado;
  }

  String _getNombreDia(int diaNumero) {
    switch (diaNumero) {
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
        return 'Desconocido';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const _LoadingView();
    }

    // Obtener altura disponible
    final double availableHeight = MediaQuery.of(context).size.height - 200;

    return Padding(
      padding: const EdgeInsets.only(top: AppSizes.paddingSmall),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // Título con botón de refresh
          Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Mapa de Disponibilidad por Dotaciones',
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimaryLight,
                      ),
                    ),
                  const SizedBox(height: 4),
                  Text(
                    'Turnos programados vs unidades requeridas. Verde (≥100%), Azul (75-99%), Amarillo (50-74%), Rojo (<50%)',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.textSecondaryLight,
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSizes.spacingSmall),
            // Botón de refresh
            DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
              ),
              child: IconButton(
                onPressed: _cargarDisponibilidad,
                icon: const Icon(Icons.refresh, color: AppColors.primary, size: 20),
                tooltip: 'Recargar disponibilidad',
                padding: const EdgeInsets.all(8),
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.spacing),

        // Layout responsivo: Tabla a la izquierda, Stats a la derecha
        Expanded(
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              // Si el ancho es mayor a 900px, mostrar en row
              if (constraints.maxWidth > 900) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // Tabla de dotaciones (70% del ancho)
                    Expanded(
                      flex: 7,
                      child: SizedBox(
                        height: availableHeight,
                        child: _buildDotacionesTable(),
                      ),
                    ),
                    const SizedBox(width: AppSizes.spacing),
                    // Stats summary (30% del ancho)
                    Expanded(
                      flex: 3,
                      child: SizedBox(
                        height: availableHeight,
                        child: SingleChildScrollView(
                          child: _buildStatsCard(),
                        ),
                      ),
                    ),
                  ],
                );
              } else {
                // En pantallas pequeñas, mostrar en columna
                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      SizedBox(
                        height: availableHeight * 0.6,
                        child: _buildDotacionesTable(),
                      ),
                      const SizedBox(height: AppSizes.spacing),
                      _buildStatsCard(),
                    ],
                  ),
                );
              }
            },
          ),
        ),
        ],
      ),
    );
  }

  Widget _buildDotacionesTable() {
    if (_dotaciones.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(AppSizes.paddingLarge),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.radius),
          border: Border.all(color: AppColors.gray200),
        ),
        child: Center(
          child: Text(
            'No hay dotaciones configuradas para esta semana',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.textSecondaryLight,
            ),
          ),
        ),
      );
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radius),
        border: Border.all(color: AppColors.gray200),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSizes.radius),
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return SingleChildScrollView(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: constraints.maxWidth,
                  ),
                  child: DataTable(
          headingRowColor: WidgetStateProperty.all(AppColors.primarySurface),
          headingRowHeight: 56,
          dataRowMinHeight: 48,
          dataRowMaxHeight: 64,
          columnSpacing: 16,
          horizontalMargin: 12,
          dividerThickness: 0.5,
          columns: <DataColumn>[
            DataColumn(
              label: Text(
                'Dotación',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
            ...<String>['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'].map(
              (String dia) => DataColumn(
                label: Text(
                  dia,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'Total',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
          rows: _dotaciones.map((DotacionEntity dotacion) {
            final Map<String, int> stats = _disponibilidadPorDotacion[dotacion.nombre] ?? <String, int>{};

            return DataRow(
              cells: <DataCell>[
                // Nombre de la dotación
                DataCell(
                  Text(
                    dotacion.nombre,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimaryLight,
                    ),
                  ),
                ),
                // Días de la semana
                ...<String>['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'].map(
                  (String dia) {
                    final int requerido = stats['${dia}_requerido'] ?? 0;
                    final int programado = stats['${dia}_programado'] ?? 0;

                    return DataCell(
                      _buildDisponibilidadCell(programado, requerido),
                    );
                  },
                ),
                // Total
                DataCell(
                  _buildDisponibilidadCell(
                    stats['total_programado'] ?? 0,
                    stats['total_requerido'] ?? 0,
                  ),
                ),
              ],
            );
          }).toList(),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDisponibilidadCell(int programado, int requerido) {
    if (requerido == 0) {
      return Text(
        '-',
        style: GoogleFonts.inter(
          fontSize: 13,
          color: AppColors.textSecondaryLight,
        ),
        textAlign: TextAlign.center,
      );
    }

    // Calcular porcentaje de cobertura
    final double porcentaje = (programado / requerido) * 100;

    // Color según porcentaje de cobertura
    final Color color;
    if (porcentaje >= 100) {
      color = AppColors.success; // Verde: Cobertura completa (≥100%)
    } else if (porcentaje >= 75) {
      color = AppColors.info; // Azul: Cobertura aceptable (75-99%)
    } else if (porcentaje >= 50) {
      color = AppColors.warning; // Amarillo: Cobertura baja (50-74%)
    } else {
      color = AppColors.error; // Rojo: Cobertura crítica (<50%)
    }

    final Color bgColor = color.withValues(alpha: 0.1);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        '$programado/$requerido (${porcentaje.toStringAsFixed(0)}%)',
        style: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: color,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildStatsCard() {
    // Calcular totales basándose en porcentajes (programado/requerido * 100)
    int totalFranjas = 0;
    int muyBajo = 0;  // < 25%
    int bajo = 0;     // 25% - 84%
    int adecuado = 0; // 85% - 100%
    int sobrecarga = 0; // > 100%

    // Contar franjas por dotación/día
    for (final DotacionEntity dotacion in _dotaciones) {
      final Map<String, int> stats = _disponibilidadPorDotacion[dotacion.nombre] ?? <String, int>{};

      // Procesar días de la semana
      for (final String dia in <String>['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo']) {
        final int requerido = stats['${dia}_requerido'] ?? 0;
        final int programado = stats['${dia}_programado'] ?? 0;

        // Solo contar si hay unidades requeridas
        if (requerido > 0) {
          totalFranjas++;
          final double porcentaje = (programado / requerido) * 100;

          if (porcentaje < 25) {
            muyBajo++;
          } else if (porcentaje < 85) {
            bajo++;
          } else if (porcentaje <= 100) {
            adecuado++;
          } else {
            sobrecarga++;
          }
        }
      }
    }

    return Column(
      children: <Widget>[
        // Resumen por franjas
        Container(
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
                'Resumen por Franjas',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: AppSizes.spacing),
              _buildStatRow('Total franjas', totalFranjas.toString(), AppColors.gray400),
              _buildStatRow('❌ Muy Bajo (<25%)', muyBajo.toString(), AppColors.error),
              _buildStatRow('⚠️ Bajo (25-84%)', bajo.toString(), AppColors.warning),
              _buildStatRow('✅ Adecuado (≥85%)', adecuado.toString(), AppColors.success),
              _buildStatRow('⚡ Sobrecarga (>100%)', sobrecarga.toString(), AppColors.secondary),
            ],
          ),
        ),
        const SizedBox(height: AppSizes.spacing),
        // Resumen por recursos (vehículos y personal)
        _buildRecursosStatsCard(),
      ],
    );
  }

  Widget _buildRecursosStatsCard() {
    // Totales acumulados de toda la semana
    int totalVehiculosRequeridos = 0;
    int totalVehiculosProgramados = 0;
    int totalPersonalRequerido = 0;
    int totalPersonalProgramado = 0;

    // Sumar todos los días de todas las dotaciones
    for (final DotacionEntity dotacion in _dotaciones) {
      final Map<String, int> stats = _disponibilidadPorDotacion[dotacion.nombre] ?? <String, int>{};

      for (final String dia in <String>['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo']) {
        final int requerido = stats['${dia}_requerido'] ?? 0;
        final int programado = stats['${dia}_programado'] ?? 0;

        // Los stats ya contienen el número de turnos (= personal)
        // Para vehículos: usamos el mismo número (cada dotación requiere vehículos)
        totalVehiculosRequeridos += requerido;
        totalVehiculosProgramados += programado;

        // Personal: cada turno = 1 persona asignada
        totalPersonalRequerido += requerido;
        totalPersonalProgramado += programado;
      }
    }

    // Calcular porcentajes
    final double porcentajeVehiculos = totalVehiculosRequeridos > 0
        ? (totalVehiculosProgramados / totalVehiculosRequeridos) * 100
        : 0;
    final double porcentajePersonal = totalPersonalRequerido > 0
        ? (totalPersonalProgramado / totalPersonalRequerido) * 100
        : 0;

    // Determinar color según porcentaje
    Color getColorFromPercentage(double porcentaje) {
      if (porcentaje < 25) {
        return AppColors.error;
      }
      if (porcentaje < 85) {
        return AppColors.warning;
      }
      if (porcentaje <= 100) {
        return AppColors.success;
      }
      return AppColors.secondary;
    }

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
            'Resumen por Recursos (Semana Completa)',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: AppSizes.spacing),
          _buildRecursoRow(
            icon: Icons.directions_car,
            label: 'Vehículos',
            programado: totalVehiculosProgramados,
            requerido: totalVehiculosRequeridos,
            porcentaje: porcentajeVehiculos,
            color: getColorFromPercentage(porcentajeVehiculos),
          ),
          const SizedBox(height: AppSizes.paddingSmall),
          _buildRecursoRow(
            icon: Icons.people,
            label: 'Personal',
            programado: totalPersonalProgramado,
            requerido: totalPersonalRequerido,
            porcentaje: porcentajePersonal,
            color: getColorFromPercentage(porcentajePersonal),
          ),
        ],
      ),
    );
  }

  Widget _buildRecursoRow({
    required IconData icon,
    required String label,
    required int programado,
    required int requerido,
    required double porcentaje,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingSmall),
      decoration: BoxDecoration(
        color: AppColors.gray50,
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
      ),
      child: Row(
        children: <Widget>[
          Icon(icon, color: color, size: 20),
          const SizedBox(width: AppSizes.paddingSmall),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimaryLight,
              ),
            ),
          ),
          Text(
            '$programado / $requerido',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(width: AppSizes.paddingSmall),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.paddingSmall,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: color.withValues(alpha:  0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
              border: Border.all(color: color),
            ),
            child: Text(
              '${porcentaje.toStringAsFixed(0)}%',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.paddingSmall),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.textSecondaryLight,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

}

/// Vista de carga
class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.spacingMassive),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radius),
        border: Border.all(color: AppColors.gray200),
      ),
      constraints: const BoxConstraints(minHeight: 400),
      child: const Center(
        child: AppLoadingIndicator(
          message: 'Calculando disponibilidad...',
        ),
      ),
    );
  }
}
