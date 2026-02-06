import 'package:ambutrack_core/ambutrack_core.dart' hide PersonalEntity;
import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/widgets/loading/app_loading_indicator.dart';
import 'package:ambutrack_web/features/personal/domain/entities/personal_entity.dart';
import 'package:ambutrack_web/features/personal/domain/repositories/personal_repository.dart';
import 'package:ambutrack_web/features/vacaciones/presentation/bloc/vacaciones_bloc.dart';
import 'package:ambutrack_web/features/vacaciones/presentation/bloc/vacaciones_event.dart';
import 'package:ambutrack_web/features/vacaciones/presentation/bloc/vacaciones_state.dart';
import 'package:ambutrack_web/features/vacaciones/presentation/widgets/gestionar_vacacion_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

/// Widget que muestra el calendario de vacaciones en formato matriz/grid
///
/// **Estructura**:
/// - **Primera fila (header)**: Días del mes (1, 2, 3, ..., 31)
/// - **Primera columna**: Nombre y apellidos del personal
/// - **Celdas**: Marcadores visuales de vacaciones por persona/día
///
/// **Ejemplo visual**:
/// ```
/// ┌──────────────┬───┬───┬───┬───┬───┬───┬───┬
/// │ Personal     │ 1 │ 2 │ 3 │ 4 │ 5 │ 6 │ 7 │ ...
/// ├──────────────┼───┼───┼───┼───┼───┼───┼───┼
/// │ Juan Pérez   │   │ 🏖️│ 🏖️│ 🏖️│   │   │   │
/// │ Ana García   │   │   │   │   │ 🏖️│ 🏖️│   │
/// │ Luis Martín  │ 🏖️│ 🏖️│   │   │   │   │   │
/// └──────────────┴───┴───┴───┴───┴───┴───┴───┴
/// ```
class CalendarioVacacionesWidget extends StatefulWidget {
  const CalendarioVacacionesWidget({super.key});

  @override
  State<CalendarioVacacionesWidget> createState() =>
      _CalendarioVacacionesWidgetState();
}

class _CalendarioVacacionesWidgetState
    extends State<CalendarioVacacionesWidget> {
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

    return BlocBuilder<VacacionesBloc, VacacionesState>(
      buildWhen: (VacacionesState previous, VacacionesState current) {
        // Siempre reconstruir si cambia el tipo de estado
        if (previous.runtimeType != current.runtimeType) {
          return true;
        }

        // Si ambos son VacacionesLoaded, verificar cambios en fechas
        if (previous is VacacionesLoaded && current is VacacionesLoaded) {
          // Reconstruir si cambia la cantidad de vacaciones
          if (previous.vacaciones.length != current.vacaciones.length) {
            return true;
          }

          // Reconstruir si cambian las fechas de alguna vacación
          if (_vacacionesDatesChanged(previous.vacaciones, current.vacaciones)) {
            debugPrint('📅 Calendario: Detectado cambio en fechas de vacaciones');
            return true;
          }
        }

        return true; // Por defecto, reconstruir
      },
      builder: (BuildContext context, VacacionesState state) {
        if (state is VacacionesLoading) {
          return const _LoadingView();
        }

        if (state is VacacionesError) {
          return _ErrorView(message: state.message);
        }

        if (state is VacacionesLoaded) {
          return _buildCalendar(context, state.vacaciones);
        }

        return const SizedBox.shrink();
      },
    );
  }

  /// Verifica si las fechas de las vacaciones han cambiado
  bool _vacacionesDatesChanged(
    List<VacacionesEntity> previous,
    List<VacacionesEntity> current,
  ) {
    for (final VacacionesEntity currentVacacion in current) {
      try {
        final VacacionesEntity previousVacacion = previous.firstWhere(
          (VacacionesEntity v) => v.id == currentVacacion.id,
        );

        // Verificar si las fechas cambiaron
        if (!_isSameDay(previousVacacion.fechaInicio, currentVacacion.fechaInicio) ||
            !_isSameDay(previousVacacion.fechaFin, currentVacacion.fechaFin)) {
          return true;
        }
      } catch (_) {
        // Si no se encuentra la vacación anterior, es nueva
        return true;
      }
    }
    return false;
  }

  /// Compara si dos fechas son el mismo día
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  /// Construye el calendario completo
  Widget _buildCalendar(
    BuildContext context,
    List<VacacionesEntity> vacaciones,
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
            child: _buildCalendarMatrix(vacaciones),
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
  Widget _buildCalendarMatrix(List<VacacionesEntity> vacaciones) {
    debugPrint('📅 Calendario: Total vacaciones: ${vacaciones.length}');
    debugPrint('📅 Calendario: Mes/Año seleccionado: $_selectedMonth/$_selectedYear');

    // Filtrar vacaciones del mes/año seleccionado
    final List<VacacionesEntity> vacacionesMes = vacaciones.where((VacacionesEntity v) {
      final bool sameYear = v.fechaInicio.year == _selectedYear || v.fechaFin.year == _selectedYear;
      final bool enRango = (v.fechaInicio.month == _selectedMonth ||
              v.fechaFin.month == _selectedMonth) ||
          (v.fechaInicio.isBefore(
                  DateTime(_selectedYear, _selectedMonth)) &&
              v.fechaFin.isAfter(DateTime(
                _selectedYear,
                _selectedMonth + 1,
                0,
              )));

      if (sameYear && enRango) {
        debugPrint('📅 Vacación encontrada: ${v.idPersonal} del ${v.fechaInicio} al ${v.fechaFin}');
      }

      return sameYear && enRango;
    }).toList();

    debugPrint('📅 Calendario: Vacaciones filtradas para el mes: ${vacacionesMes.length}');

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
              vacacionesMes,
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
    List<VacacionesEntity> vacaciones,
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
            final List<VacacionesEntity> vacacionesPersonal =
                vacaciones.where((VacacionesEntity v) => v.idPersonal == personal.id).toList();

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

                  return _buildGridDayCell(date, vacacionesPersonal, dayWidth, cellHeight);
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
    List<VacacionesEntity> vacaciones,
    double dayWidth,
    double cellHeight,
  ) {
    final VacacionesEntity? vacacion = _getVacacionForDay(date, vacaciones);

    if (vacacion == null) {
      return Container(
        width: dayWidth,
        height: cellHeight,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.gray200, width: 0.5),
        ),
      );
    }

    // Color según estado
    late Color color;
    late IconData icon;
    late String tooltip;

    switch (vacacion.estado) {
      case 'aprobada':
        color = AppColors.success;
        icon = Icons.check_circle;
        tooltip = 'Aprobada';
      case 'pendiente':
        color = AppColors.warning;
        icon = Icons.schedule;
        tooltip = 'Pendiente';
      case 'rechazada':
        color = AppColors.error;
        icon = Icons.cancel;
        tooltip = 'Rechazada';
      default:
        color = AppColors.gray400;
        icon = Icons.help_outline;
        tooltip = vacacion.estado;
    }

    return Tooltip(
      message: '$tooltip\n${vacacion.fechaInicio.day}/${vacacion.fechaInicio.month} - ${vacacion.fechaFin.day}/${vacacion.fechaFin.month}',
      child: InkWell(
        onTap: () => _showGestionarDialog(vacacion),
        child: Container(
          width: dayWidth,
          height: cellHeight,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            border: Border.all(color: color, width: 2),
          ),
          child: Icon(icon, size: 18, color: color),
        ),
      ),
    );
  }

  /// Muestra el diálogo de gestión de vacaciones
  Future<void> _showGestionarDialog(VacacionesEntity vacacion) async {
    // Buscar la vacación actualizada en el estado del BLoC
    final VacacionesState state = context.read<VacacionesBloc>().state;
    VacacionesEntity vacacionActualizada = vacacion;

    if (state is VacacionesLoaded) {
      try {
        vacacionActualizada = state.vacaciones.firstWhere(
          (VacacionesEntity v) => v.id == vacacion.id,
        );
      } catch (_) {
        // Si no se encuentra, usar la vacación original
        vacacionActualizada = vacacion;
      }
    }

    // Buscar el nombre del personal
    PersonalEntity personal;
    try {
      personal = _listadoPersonal.firstWhere(
        (PersonalEntity p) => p.id == vacacionActualizada.idPersonal,
      );
    } catch (_) {
      // Si no se encuentra, usar valores por defecto
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
      builder: (BuildContext dialogContext) {
        return BlocProvider<VacacionesBloc>.value(
          value: context.read<VacacionesBloc>(),
          child: GestionarVacacionDialog(
            vacacion: vacacionActualizada,
            nombrePersonal: nombreCompleto,
          ),
        );
      },
    );
  }

  /// Obtiene la vacación para un día específico
  VacacionesEntity? _getVacacionForDay(
    DateTime date,
    List<VacacionesEntity> vacaciones,
  ) {
    for (final VacacionesEntity vacacion in vacaciones) {
      // Normalizar fechas a medianoche para comparación
      final DateTime dateNormalized = DateTime(date.year, date.month, date.day);
      final DateTime inicioNormalized = DateTime(
        vacacion.fechaInicio.year,
        vacacion.fechaInicio.month,
        vacacion.fechaInicio.day,
      );
      final DateTime finNormalized = DateTime(
        vacacion.fechaFin.year,
        vacacion.fechaFin.month,
        vacacion.fechaFin.day,
      );

      // Verificar si la fecha está en el rango (inclusivo)
      if ((dateNormalized.isAtSameMomentAs(inicioNormalized) ||
              dateNormalized.isAfter(inicioNormalized)) &&
          (dateNormalized.isAtSameMomentAs(finNormalized) ||
              dateNormalized.isBefore(finNormalized))) {
        return vacacion;
      }
    }
    return null;
  }

  /// Construye la leyenda
  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      child: Wrap(
        spacing: AppSizes.spacing,
        runSpacing: AppSizes.spacingSmall,
        children: <Widget>[
          _buildLegendItem(
            'Aprobada',
            AppColors.success,
            Icons.check_circle,
          ),
          _buildLegendItem(
            'Pendiente',
            AppColors.warning,
            Icons.schedule,
          ),
          _buildLegendItem(
            'Rechazada',
            AppColors.error,
            Icons.cancel,
          ),
          _buildLegendItem(
            'Cancelada',
            AppColors.gray400,
            Icons.block,
          ),
        ],
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
          .read<VacacionesBloc>()
          .add(VacacionesLoadByYearRequested(_selectedYear));
    }
  }

  void _nextMonth() {
    final bool cambiaAnio = _selectedMonth == 12;

    setState(() {
      if (_selectedMonth == 12) {
        _selectedMonth = 1;
        _selectedYear++;
      } else {
        _selectedMonth++;
      }
    });

    if (cambiaAnio) {
      context
          .read<VacacionesBloc>()
          .add(VacacionesLoadByYearRequested(_selectedYear));
    }
  }

  void _previousYear() {
    setState(() {
      _selectedYear--;
    });
    // Cargar vacaciones del nuevo año
    context
        .read<VacacionesBloc>()
        .add(VacacionesLoadByYearRequested(_selectedYear));
  }

  void _nextYear() {
    setState(() {
      _selectedYear++;
    });
    // Cargar vacaciones del nuevo año
    context
        .read<VacacionesBloc>()
        .add(VacacionesLoadByYearRequested(_selectedYear));
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
          message: 'Cargando calendario de vacaciones...',
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
