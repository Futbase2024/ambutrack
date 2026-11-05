import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/widgets/loading/app_loading_indicator.dart';
import 'package:ambutrack_web/features/ausencias/presentation/bloc/ausencias_bloc.dart';
import 'package:ambutrack_web/features/ausencias/presentation/bloc/ausencias_event.dart';
import 'package:ambutrack_web/features/ausencias/presentation/bloc/ausencias_state.dart';
import 'package:ambutrack_web/features/ausencias/presentation/widgets/gestionar_ausencia_dialog.dart';
import 'package:ambutrack_web/features/personal/domain/entities/personal_entity.dart';
import 'package:ambutrack_web/features/personal/domain/repositories/personal_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

/// Widget que muestra el calendario de ausencias en formato matriz/grid
///
/// **Estructura**:
/// - **Primera fila (header)**: Días del mes (1, 2, 3, ..., 31)
/// - **Primera columna**: Nombre y apellidos del personal
/// - **Celdas**: Marcadores visuales de ausencias por persona/día
class CalendarioAusenciasWidget extends StatefulWidget {
  const CalendarioAusenciasWidget({super.key});

  @override
  State<CalendarioAusenciasWidget> createState() =>
      _CalendarioAusenciasWidgetState();
}

class _CalendarioAusenciasWidgetState
    extends State<CalendarioAusenciasWidget> {
  final PersonalRepository _personalRepository = getIt<PersonalRepository>();

  int _selectedYear = DateTime.now().year;
  int _selectedMonth = DateTime.now().month;
  List<PersonalEntity> _listadoPersonal = <PersonalEntity>[];
  bool _isLoadingPersonal = true;

  @override
  void initState() {
    super.initState();
    _loadPersonal();
  }

  /// Carga la lista de personal desde el repositorio
  Future<void> _loadPersonal() async {
    try {
      final List<PersonalEntity> personal = await _personalRepository.getAll();

      if (mounted) {
        setState(() {
          _listadoPersonal = personal.where((PersonalEntity p) => p.activo).toList();
          _isLoadingPersonal = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingPersonal = false;
        });
        debugPrint('❌ Error al cargar personal: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingPersonal) {
      return const _LoadingView();
    }

    return BlocBuilder<AusenciasBloc, AusenciasState>(
      buildWhen: (AusenciasState previous, AusenciasState current) {
        // ✅ ESTRATEGIA OPTIMIZADA:
        // 1. SI pasa de Loaded → Loading: Mostrar spinner (carga inicial)
        // 2. SI pasa de Loaded → Error: Mostrar error
        // 3. SI cambia cantidad de ausencias: Reconstruir (create/delete)
        // 4. SI cambian fechas de ausencias: Reconstruir (eliminación parcial)
        // 5. SI solo cambia estado de ausencia existente: NO reconstruir (optimistic update)

        // Caso 1: Error siempre se muestra
        if (current is AusenciasError) {
          debugPrint('🔄 Calendario: Reconstruyendo por error');
          return true;
        }

        // Caso 2: Loading solo en carga inicial (NO en refetch silencioso)
        if (current is AusenciasLoading && previous is! AusenciasLoaded) {
          debugPrint('🔄 Calendario: Reconstruyendo por carga inicial');
          return true;
        }

        // Caso 3: Evitar loading durante refetch silencioso
        if (current is AusenciasLoading && previous is AusenciasLoaded) {
          debugPrint('⏭️ Calendario: NO mostrar loading (refetch silencioso)');
          return false; // ✅ NO reconstruir, mantener UI actual
        }

        // Caso 4: Cambios en ausencias
        if (previous is AusenciasLoaded && current is AusenciasLoaded) {
          final bool lengthChanged = previous.ausencias.length != current.ausencias.length;

          if (lengthChanged) {
            debugPrint('🔄 Calendario: Reconstruyendo por cambio en cantidad (${previous.ausencias.length} -> ${current.ausencias.length})');
            return true;
          }

          // Verificar si cambiaron las fechas de alguna ausencia (eliminación parcial)
          final bool datesChanged = _ausenciasDatesChanged(previous.ausencias, current.ausencias);
          if (datesChanged) {
            debugPrint('🔄 Calendario: Reconstruyendo por cambio en fechas de ausencias');
            return true;
          }

          debugPrint('⏭️ Calendario: NO reconstruyendo (solo cambió estado de ausencias existentes)');
          return false; // ✅ NO reconstruir, las celdas se actualizan individualmente
        }

        return true;
      },
      builder: (BuildContext context, AusenciasState state) {
        if (state is AusenciasLoading) {
          return const _LoadingView();
        }

        if (state is AusenciasError) {
          return _ErrorView(message: state.message);
        }

        if (state is AusenciasLoaded) {
          return _buildCalendar(context, state.ausencias);
        }

        return const SizedBox.shrink();
      },
    );
  }

  /// Construye el calendario completo
  Widget _buildCalendar(
    BuildContext context,
    List<AusenciaEntity> ausencias,
  ) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radius),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Column(
        children: <Widget>[
          _buildHeader(),
          const Divider(height: 1, color: AppColors.gray300),
          Expanded(
            child: _buildCalendarMatrix(ausencias),
          ),
          const Divider(height: 1, color: AppColors.gray300),
          _buildLegend(),
        ],
      ),
    );
  }

  /// Construye la cabecera con navegación de mes/año
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          // Selector de mes
          Row(
            children: <Widget>[
              IconButton(
                icon: const Icon(Icons.chevron_left, size: 20),
                onPressed: _previousMonth,
                tooltip: 'Mes anterior',
                color: AppColors.primary,
              ),
              const SizedBox(width: AppSizes.spacingSmall),
              Text(
                _getMonthName(_selectedMonth),
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(width: AppSizes.spacingSmall),
              IconButton(
                icon: const Icon(Icons.chevron_right, size: 20),
                onPressed: _nextMonth,
                tooltip: 'Mes siguiente',
                color: AppColors.primary,
              ),
            ],
          ),
          // Leyenda de estados (centro)
          Expanded(
            child: Center(
              child: Wrap(
                spacing: AppSizes.spacing,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: <Widget>[
                  Text(
                    'Estados:',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimaryLight,
                    ),
                  ),
                  _buildLegendItem('Aprobada', AppColors.success, Icons.check_circle),
                  _buildLegendItem('Pendiente', AppColors.warning, Icons.schedule),
                  _buildLegendItem('Rechazada', AppColors.error, Icons.cancel),
                  _buildLegendItem('Cancelada', AppColors.gray400, Icons.block),
                ],
              ),
            ),
          ),
          // Selector de año
          Row(
            children: <Widget>[
              IconButton(
                icon: const Icon(Icons.chevron_left, size: 20),
                onPressed: _previousYear,
                tooltip: 'Año anterior',
                color: AppColors.secondary,
              ),
              const SizedBox(width: AppSizes.spacingSmall),
              Text(
                _selectedYear.toString(),
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(width: AppSizes.spacingSmall),
              IconButton(
                icon: const Icon(Icons.chevron_right, size: 20),
                onPressed: _nextYear,
                tooltip: 'Año siguiente',
                color: AppColors.secondary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Construye la matriz del calendario
  Widget _buildCalendarMatrix(List<AusenciaEntity> ausencias) {
    debugPrint('📅 Calendario Ausencias: Total ausencias: ${ausencias.length}');
    debugPrint('📅 Calendario Ausencias: Mes/Año seleccionado: $_selectedMonth/$_selectedYear');

    // Debug: Mostrar todas las ausencias
    for (final AusenciaEntity a in ausencias) {
      debugPrint('📅 Ausencia: ${a.id} | Personal: ${a.idPersonal} | ${a.fechaInicio} - ${a.fechaFin}');
    }

    // Filtrar ausencias del mes/año seleccionado
    final List<AusenciaEntity> ausenciasMes = ausencias.where((AusenciaEntity a) {
      final bool sameYear = a.fechaInicio.year == _selectedYear || a.fechaFin.year == _selectedYear;
      final bool enRango = (a.fechaInicio.month == _selectedMonth ||
              a.fechaFin.month == _selectedMonth) ||
          (a.fechaInicio.isBefore(
                  DateTime(_selectedYear, _selectedMonth)) &&
              a.fechaFin.isAfter(DateTime(
                _selectedYear,
                _selectedMonth + 1,
                0,
              )));

      debugPrint('📅 Filtro para ${a.id}: sameYear=$sameYear, enRango=$enRango');
      return sameYear && enRango;
    }).toList();

    debugPrint('📅 Calendario Ausencias: Ausencias filtradas para el mes: ${ausenciasMes.length}');

    // Obtener número de días del mes
    final int daysInMonth =
        DateTime(_selectedYear, _selectedMonth + 1, 0).day;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        // Calcular anchos responsivos
        final double availableWidth = constraints.maxWidth - 24;
        const double personalColumnWidth = 200;
        final double remainingWidth = availableWidth - personalColumnWidth;
        final double dayColumnWidth = remainingWidth / daysInMonth;
        const double cellHeight = 40;

        return SingleChildScrollView(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: _buildGridCalendar(
              ausenciasMes,
              daysInMonth,
              dayColumnWidth,
              personalColumnWidth,
              cellHeight,
            ),
          ),
        );
      },
    );
  }

  /// Construye el calendario en formato grid/cuadrícula
  Widget _buildGridCalendar(
    List<AusenciaEntity> ausencias,
    int daysInMonth,
    double dayWidth,
    double personalWidth,
    double cellHeight,
  ) {
    // Ordenar personal alfabéticamente
    final List<PersonalEntity> personalOrdenado = List<PersonalEntity>.from(_listadoPersonal)
      ..sort((PersonalEntity a, PersonalEntity b) {
        final String nombreCompletoA = '${a.nombre} ${a.apellidos}'.toLowerCase();
        final String nombreCompletoB = '${b.nombre} ${b.apellidos}'.toLowerCase();
        return nombreCompletoA.compareTo(nombreCompletoB);
      });

    // Calcular ancho total de la tabla
    final double totalWidth = personalWidth + (dayWidth * daysInMonth);

    return SizedBox(
      width: totalWidth,
      child: Table(
        border: TableBorder.all(
          color: AppColors.gray300,
        ),
        columnWidths: <int, TableColumnWidth>{
          0: FixedColumnWidth(personalWidth), // Columna de personal
          // Las demás columnas usan el ancho calculado responsivamente
          for (int i = 1; i <= daysInMonth; i++)
            i: FixedColumnWidth(dayWidth),
        },
        children: <TableRow>[
          // Fila de encabezado con días
          TableRow(
            decoration: const BoxDecoration(color: AppColors.gray50),
            children: <Widget>[
              // Primera celda: "Personal"
              Container(
                height: cellHeight,
                padding: const EdgeInsets.all(8),
                alignment: Alignment.centerLeft,
                child: Text(
                  'Personal',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimaryLight,
                  ),
                ),
              ),
              // Celdas de días (1, 2, 3, ...)
              ...List<Widget>.generate(daysInMonth, (int index) {
                final int day = index + 1;
                final DateTime date = DateTime(_selectedYear, _selectedMonth, day);
                final bool isWeekend =
                    date.weekday == DateTime.saturday ||
                    date.weekday == DateTime.sunday;

                return Container(
                  height: cellHeight,
                  decoration: BoxDecoration(
                    color: isWeekend ? AppColors.error.withValues(alpha: 0.05) : AppColors.gray50,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    day.toString(),
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: isWeekend ? AppColors.error : AppColors.textPrimaryLight,
                    ),
                  ),
                );
              }),
            ],
          ),
          // Filas de personal
          ...personalOrdenado.map((PersonalEntity personal) {
            final List<AusenciaEntity> ausenciasPersonal =
                ausencias.where((AusenciaEntity a) => a.idPersonal == personal.id).toList();

            return TableRow(
              children: <Widget>[
                // Primera celda: Nombre del personal
                Container(
                  height: cellHeight,
                  padding: const EdgeInsets.all(8),
                  alignment: Alignment.centerLeft,
                  child: Tooltip(
                    message: '${personal.nombre} ${personal.apellidos}',
                    child: Text(
                      '${personal.nombre} ${personal.apellidos}',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimaryLight,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ),
                // Celdas de días
                ...List<Widget>.generate(daysInMonth, (int index) {
                  final int day = index + 1;
                  final DateTime date = DateTime(_selectedYear, _selectedMonth, day);

                  return _buildGridDayCell(
                    date,
                    ausenciasPersonal,
                    dayWidth,
                    cellHeight,
                    personal.id,
                  );
                }),
              ],
            );
          }),
        ],
      ),
    );
  }

  /// Construye la celda de un día en formato grid
  Widget _buildGridDayCell(
    DateTime date,
    List<AusenciaEntity> ausencias,
    double dayWidth,
    double cellHeight,
    String personalId,
  ) {
    final AusenciaEntity? ausencia = _getAusenciaForDay(date, ausencias);

    // Usar RepaintBoundary para aislar la celda y evitar repintados innecesarios
    // Key única: personalId + fecha + ausenciaId
    return RepaintBoundary(
      key: ValueKey<String>('${personalId}_${date.toIso8601String()}_${ausencia?.id ?? "empty"}'),
      child: _DayCell(
        ausenciaId: ausencia?.id,
        date: date,
        dayWidth: dayWidth,
        cellHeight: cellHeight,
        onTap: ausencia != null ? () => _showGestionarDialog(ausencia) : null,
      ),
    );
  }

  /// Obtiene el icono según el tipo de ausencia
  IconData _getIconForTipoAusencia(String nombreTipo) {
    final String nombreLower = nombreTipo.toLowerCase();

    if (nombreLower.contains('vacacion')) {
      return Icons.beach_access;
    } else if (nombreLower.contains('baja médica') || nombreLower.contains('medica')) {
      return Icons.local_hospital;
    } else if (nombreLower.contains('maternidad') || nombreLower.contains('paternidad')) {
      return Icons.child_care;
    } else if (nombreLower.contains('formación') || nombreLower.contains('formacion')) {
      return Icons.school;
    } else if (nombreLower.contains('compensatorio')) {
      return Icons.event_available;
    } else if (nombreLower.contains('asuntos propios')) {
      return Icons.person;
    } else if (nombreLower.contains('permiso personal')) {
      return Icons.badge;
    } else if (nombreLower.contains('permiso no remunerado')) {
      return Icons.money_off;
    } else {
      return Icons.event_busy;
    }
  }

  /// Muestra el diálogo de gestión de ausencias
  Future<void> _showGestionarDialog(AusenciaEntity ausencia) async {
    // Buscar la ausencia actualizada en el estado del BLoC
    final AusenciasState state = context.read<AusenciasBloc>().state;
    AusenciaEntity ausenciaActualizada = ausencia;

    if (state is AusenciasLoaded) {
      try {
        ausenciaActualizada = state.ausencias.firstWhere(
          (AusenciaEntity a) => a.id == ausencia.id,
        );
      } catch (_) {
        // Si no se encuentra, usar la ausencia original
        ausenciaActualizada = ausencia;
      }
    }

    PersonalEntity personal;
    try {
      personal = _listadoPersonal.firstWhere(
        (PersonalEntity p) => p.id == ausenciaActualizada.idPersonal,
      );
    } catch (_) {
      personal = PersonalEntity(
        id: '',
        nombre: 'Desconocido',
        apellidos: '',
        dni: '',
        createdAt: DateTime.now(),
      );
    }

    final String nombreCompleto = '${personal.nombre} ${personal.apellidos}';

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return BlocProvider<AusenciasBloc>.value(
          value: context.read<AusenciasBloc>(),
          child: GestionarAusenciaDialog(
            ausencia: ausenciaActualizada,
            nombrePersonal: nombreCompleto,
          ),
        );
      },
    );
  }

  /// Obtiene la ausencia para un día específico
  AusenciaEntity? _getAusenciaForDay(
    DateTime date,
    List<AusenciaEntity> ausencias,
  ) {
    for (final AusenciaEntity ausencia in ausencias) {
      final DateTime dateNormalized = DateTime(date.year, date.month, date.day);
      final DateTime inicioNormalized = DateTime(
        ausencia.fechaInicio.year,
        ausencia.fechaInicio.month,
        ausencia.fechaInicio.day,
      );
      final DateTime finNormalized = DateTime(
        ausencia.fechaFin.year,
        ausencia.fechaFin.month,
        ausencia.fechaFin.day,
      );

      if ((dateNormalized.isAtSameMomentAs(inicioNormalized) ||
              dateNormalized.isAfter(inicioNormalized)) &&
          (dateNormalized.isAtSameMomentAs(finNormalized) ||
              dateNormalized.isBefore(finNormalized))) {
        return ausencia;
      }
    }
    return null;
  }

  /// Construye la leyenda
  Widget _buildLegend() {
    // Obtener tipos de ausencia del estado del BLoC
    final AusenciasState state = context.read<AusenciasBloc>().state;
    final List<TipoAusenciaEntity> tiposAusencia = state is AusenciasLoaded
        ? state.tiposAusencia
        : <TipoAusenciaEntity>[];

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingMedium,
        vertical: AppSizes.paddingSmall,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: <Widget>[
            // Tipos de Ausencia
            Text(
              'Tipos:',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(width: AppSizes.spacing),
            ...tiposAusencia.expand(
              (TipoAusenciaEntity tipo) => <Widget>[
                _buildLegendItem(
                  tipo.nombre,
                  Color(int.parse(tipo.color.replaceFirst('#', '0xFF'))),
                  _getIconForTipoAusencia(tipo.nombre),
                ),
                const SizedBox(width: AppSizes.spacing),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Construye un item de la leyenda
  Widget _buildLegendItem(String label, Color color, IconData icon) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Icon(icon, size: 14, color: color),
        ),
        const SizedBox(width: AppSizes.spacingSmall),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: AppColors.textSecondaryLight,
          ),
        ),
      ],
    );
  }

  // Navegación

  void _previousMonth() {
    final bool cambiaAnio = _selectedMonth == 1;

    setState(() {
      if (_selectedMonth == 1) {
        _selectedMonth = 12;
        _selectedYear--;
      } else {
        _selectedMonth--;
      }
    });

    if (cambiaAnio) {
      context
          .read<AusenciasBloc>()
          .add(const AusenciasLoadRequested());
    }
  }

  void _nextMonth() {
    setState(() {
      if (_selectedMonth == 12) {
        _selectedMonth = 1;
        _selectedYear++;
        debugPrint('📅 Calendario: Cambiando a año $_selectedYear, mes $_selectedMonth');
      } else {
        _selectedMonth++;
        debugPrint('📅 Calendario: Cambiando a mes $_selectedMonth, año $_selectedYear');
      }
    });

    // Recargar ausencias cuando cambia de año
    if (_selectedMonth == 1) {
      debugPrint('🔄 Calendario: Recargando ausencias por cambio de año');
      context
          .read<AusenciasBloc>()
          .add(const AusenciasLoadRequested());
    }
  }

  void _previousYear() {
    setState(() {
      _selectedYear--;
    });
    context.read<AusenciasBloc>().add(const AusenciasLoadRequested());
  }

  void _nextYear() {
    setState(() {
      _selectedYear++;
    });
    context.read<AusenciasBloc>().add(const AusenciasLoadRequested());
  }

  String _getMonthName(int month) {
    const List<String> months = <String>[
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre',
    ];
    return months[month - 1];
  }

  /// Verifica si las fechas de las ausencias cambiaron (para detectar eliminación parcial)
  bool _ausenciasDatesChanged(
    List<AusenciaEntity> previous,
    List<AusenciaEntity> current,
  ) {
    // Si la cantidad es diferente, ya se maneja arriba
    if (previous.length != current.length) {
      return false;
    }

    // Crear mapa de ausencias anteriores por ID
    final Map<String, AusenciaEntity> previousMap = <String, AusenciaEntity>{
      for (final AusenciaEntity a in previous) a.id: a,
    };

    // Verificar si alguna ausencia cambió sus fechas
    for (final AusenciaEntity currentAusencia in current) {
      final AusenciaEntity? previousAusencia = previousMap[currentAusencia.id];

      if (previousAusencia == null) {
        // ID nuevo, algo cambió
        return true;
      }

      // Comparar fechas (normalizar sin hora)
      final bool inicioChanged = !_isSameDay(
        previousAusencia.fechaInicio,
        currentAusencia.fechaInicio,
      );
      final bool finChanged = !_isSameDay(
        previousAusencia.fechaFin,
        currentAusencia.fechaFin,
      );

      if (inicioChanged || finChanged) {
        debugPrint(
          '📅 Ausencia ${currentAusencia.id} cambió fechas: '
          '${previousAusencia.fechaInicio} -> ${currentAusencia.fechaInicio}, '
          '${previousAusencia.fechaFin} -> ${currentAusencia.fechaFin}',
        );
        return true;
      }
    }

    return false;
  }

  /// Compara si dos fechas son el mismo día (ignora hora)
  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
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
          message: 'Cargando calendario de ausencias...',
        ),
      ),
    );
  }
}

/// Vista de error
class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingXl),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radius),
        border: Border.all(color: AppColors.error),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(Icons.error_outline, color: AppColors.error, size: 48),
          const SizedBox(height: AppSizes.spacing),
          Text(
            'Error al cargar calendario',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.error,
            ),
          ),
          const SizedBox(height: AppSizes.spacingSmall),
          Text(
            message,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.textSecondaryLight,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Widget de celda de día optimizado con BlocSelector
class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.ausenciaId,
    required this.date,
    required this.dayWidth,
    required this.cellHeight,
    this.onTap,
  });

  final String? ausenciaId; // ✅ Ahora solo guardamos el ID
  final DateTime date;
  final double dayWidth;
  final double cellHeight;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    // ✅ BlocSelector: Retorna la ausencia completa para comparación completa de Equatable
    return BlocSelector<AusenciasBloc, AusenciasState, AusenciaEntity?>(
      selector: (AusenciasState state) {
        if (state is! AusenciasLoaded || ausenciaId == null) {
          return null;
        }

        // Buscar la ausencia por ID
        try {
          final AusenciaEntity ausencia = state.ausencias.firstWhere(
            (AusenciaEntity a) => a.id == ausenciaId,
          );
          return ausencia;
        } catch (_) {
          return null;
        }
      },
      builder: (BuildContext context, AusenciaEntity? ausencia) {
        // Si no hay ausencia, mostrar celda vacía
        if (ausencia == null) {
          return Container(
            width: dayWidth,
            height: cellHeight,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.gray200, width: 0.5),
            ),
          );
        }

        // Color según estado
        late Color borderColor;
        late String estadoTooltip;

        switch (ausencia.estado) {
          case EstadoAusencia.aprobada:
            borderColor = AppColors.success;
            estadoTooltip = 'Aprobada';
          case EstadoAusencia.pendiente:
            borderColor = AppColors.warning;
            estadoTooltip = 'Pendiente';
          case EstadoAusencia.rechazada:
            borderColor = AppColors.error;
            estadoTooltip = 'Rechazada';
          case EstadoAusencia.cancelada:
            borderColor = AppColors.gray400;
            estadoTooltip = 'Cancelada';
        }

        // Obtener tipo de ausencia del estado del BLoC
        final AusenciasState state = context.read<AusenciasBloc>().state;
        TipoAusenciaEntity? tipoAusencia;
        if (state is AusenciasLoaded) {
          try {
            tipoAusencia = state.tiposAusencia.firstWhere(
              (TipoAusenciaEntity t) => t.id == ausencia.idTipoAusencia,
            );
          } catch (_) {
            // Si no se encuentra el tipo, usar valores por defecto
          }
        }

        // Icono según tipo de ausencia
        final IconData tipoIcon = _getIconForTipoAusencia(tipoAusencia?.nombre ?? 'Otro');
        final Color tipoColor = tipoAusencia != null
            ? Color(int.parse(tipoAusencia.color.replaceFirst('#', '0xFF')))
            : AppColors.gray400;

        return Tooltip(
          message: '$estadoTooltip\n${tipoAusencia?.nombre ?? "Tipo desconocido"}\n${ausencia.fechaInicio.day}/${ausencia.fechaInicio.month} - ${ausencia.fechaFin.day}/${ausencia.fechaFin.month}',
          child: InkWell(
            onTap: onTap,
            child: Container(
              width: dayWidth,
              height: cellHeight,
              decoration: BoxDecoration(
                color: borderColor.withValues(alpha: 0.15),
                border: Border.all(color: borderColor, width: 2),
              ),
              child: Icon(tipoIcon, size: 18, color: tipoColor),
            ),
          ),
        );
      },
    );
  }

  /// Obtiene el icono según el tipo de ausencia
  IconData _getIconForTipoAusencia(String nombreTipo) {
    final String nombreLower = nombreTipo.toLowerCase();

    if (nombreLower.contains('vacacion')) {
      return Icons.beach_access;
    } else if (nombreLower.contains('baja médica') || nombreLower.contains('medica')) {
      return Icons.local_hospital;
    } else if (nombreLower.contains('maternidad') || nombreLower.contains('paternidad')) {
      return Icons.child_care;
    } else if (nombreLower.contains('formación') || nombreLower.contains('formacion')) {
      return Icons.school;
    } else if (nombreLower.contains('compensatorio')) {
      return Icons.event_available;
    } else if (nombreLower.contains('asuntos propios')) {
      return Icons.person;
    } else if (nombreLower.contains('permiso personal')) {
      return Icons.badge;
    } else if (nombreLower.contains('permiso no remunerado')) {
      return Icons.money_off;
    } else {
      return Icons.event_busy;
    }
  }
}
