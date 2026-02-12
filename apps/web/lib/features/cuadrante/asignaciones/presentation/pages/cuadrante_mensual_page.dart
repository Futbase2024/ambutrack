import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/features/cuadrante/asignaciones/presentation/bloc/cuadrante_asignaciones_bloc.dart';
import 'package:ambutrack_web/features/cuadrante/asignaciones/presentation/bloc/cuadrante_asignaciones_event.dart';
import 'package:ambutrack_web/features/cuadrante/asignaciones/presentation/bloc/cuadrante_asignaciones_state.dart';
import 'package:ambutrack_web/features/cuadrante/asignaciones/presentation/widgets/calendario_mensual_widget.dart';
import 'package:ambutrack_web/features/cuadrante/asignaciones/presentation/widgets/cuadrante_asignacion_form_dialog.dart';
import 'package:ambutrack_web/features/cuadrante/asignaciones/presentation/widgets/cuadrante_diario_widget.dart';
import 'package:ambutrack_web/features/cuadrante/asignaciones/presentation/widgets/cuadrante_semanal_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

/// Tipos de vista del cuadrante
enum TipoVistaCuadrante {
  mensual,
  semanal,
  diaria,
}

/// Página del cuadrante visual unificado con múltiples vistas
class CuadranteMensualPage extends StatelessWidget {
  const CuadranteMensualPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocProvider<CuadranteAsignacionesBloc>(
        create: (BuildContext context) => getIt<CuadranteAsignacionesBloc>(),
        child: const _CuadranteMensualView(),
      ),
    );
  }
}

class _CuadranteMensualView extends StatefulWidget {
  const _CuadranteMensualView();

  @override
  State<_CuadranteMensualView> createState() => _CuadranteMensualViewState();
}

class _CuadranteMensualViewState extends State<_CuadranteMensualView> {
  TipoVistaCuadrante _tipoVista = TipoVistaCuadrante.mensual;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadAsignaciones();
  }

  void _loadAsignaciones() {
    DateTime firstDay;
    DateTime lastDay;

    switch (_tipoVista) {
      case TipoVistaCuadrante.mensual:
        firstDay = DateTime(_selectedDate.year, _selectedDate.month);
        lastDay = DateTime(_selectedDate.year, _selectedDate.month + 1, 0);
      case TipoVistaCuadrante.semanal:
        // Calcular inicio de semana (lunes)
        final int weekday = _selectedDate.weekday; // 1 = lunes
        firstDay = _selectedDate.subtract(Duration(days: weekday - 1));
        lastDay = firstDay.add(const Duration(days: 6));
      case TipoVistaCuadrante.diaria:
        firstDay = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
        lastDay = firstDay;
    }

    context.read<CuadranteAsignacionesBloc>().add(
          CuadranteAsignacionesLoadByRangoRequested(
            fechaInicio: firstDay,
            fechaFin: lastDay,
          ),
        );
  }

  void _onDateChanged(DateTime newDate) {
    setState(() {
      _selectedDate = newDate;
    });
    _loadAsignaciones();
  }

  void _onTipoVistaChanged(TipoVistaCuadrante newTipo) {
    setState(() {
      _tipoVista = newTipo;
    });
    _loadAsignaciones();
  }

  /// Abre el diálogo para crear una nueva asignación
  Future<void> _onCrearAsignacion(DateTime fecha) async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return BlocProvider<CuadranteAsignacionesBloc>.value(
          value: context.read<CuadranteAsignacionesBloc>(),
          child: CuadranteAsignacionFormDialog(
            fechaInicial: fecha,
          ),
        );
      },
    );
    // Recargar asignaciones después de cerrar el diálogo
    _loadAsignaciones();
  }

  /// Abre el diálogo para editar una asignación existente
  Future<void> _onEditarAsignacion(CuadranteAsignacionEntity asignacion) async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return BlocProvider<CuadranteAsignacionesBloc>.value(
          value: context.read<CuadranteAsignacionesBloc>(),
          child: CuadranteAsignacionFormDialog(
            asignacion: asignacion,
          ),
        );
      },
    );
    // Recargar asignaciones después de cerrar el diálogo
    _loadAsignaciones();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _buildHeader(),
          const SizedBox(height: AppSizes.spacing),
          Expanded(
            child: BlocBuilder<CuadranteAsignacionesBloc, CuadranteAsignacionesState>(
              builder: (BuildContext context, CuadranteAsignacionesState state) {
                if (state is CuadranteAsignacionesLoading) {
                  return const _LoadingView();
                }

                if (state is CuadranteAsignacionesError) {
                  return _ErrorView(message: state.message);
                }

                if (state is CuadranteAsignacionesLoaded) {
                  switch (_tipoVista) {
                    case TipoVistaCuadrante.mensual:
                      return CalendarioMensualWidget(
                        selectedMonth: _selectedDate,
                        asignaciones: state.asignaciones,
                        onMonthChanged: _onDateChanged,
                        onDayTap: _onCrearAsignacion,
                        onAsignacionTap: _onEditarAsignacion,
                      );
                    case TipoVistaCuadrante.semanal:
                      return CuadranteSemanalWidget(
                        selectedWeek: _selectedDate,
                        asignaciones: state.asignaciones,
                        onWeekChanged: _onDateChanged,
                      );
                    case TipoVistaCuadrante.diaria:
                      return CuadranteDiarioWidget(
                        selectedDate: _selectedDate,
                        asignaciones: state.asignaciones,
                        onDateChanged: _onDateChanged,
                      );
                  }
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.padding),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: AppColors.gray200),
        ),
      ),
      child: Row(
        children: <Widget>[
          const Icon(
            Icons.calendar_month,
            size: 32,
            color: AppColors.primary,
          ),
          const SizedBox(width: AppSizes.spacing),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Cuadrante Mensual Unificado',
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Gestión visual de asignaciones de personal y vehículos',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
          _buildVistaSelector(),
          const SizedBox(width: AppSizes.spacing),
          _buildDateNavigator(),
        ],
      ),
    );
  }

  Widget _buildVistaSelector() {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.gray300),
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _buildVistaButton(
            label: 'Diaria',
            icon: Icons.calendar_today,
            tipo: TipoVistaCuadrante.diaria,
          ),
          _buildVistaButton(
            label: 'Semanal',
            icon: Icons.calendar_view_week,
            tipo: TipoVistaCuadrante.semanal,
          ),
          _buildVistaButton(
            label: 'Mensual',
            icon: Icons.calendar_month,
            tipo: TipoVistaCuadrante.mensual,
          ),
        ],
      ),
    );
  }

  Widget _buildVistaButton({
    required String label,
    required IconData icon,
    required TipoVistaCuadrante tipo,
  }) {
    final bool isSelected = _tipoVista == tipo;

    return InkWell(
      onTap: () => _onTipoVistaChanged(tipo),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingMedium,
          vertical: AppSizes.paddingSmall,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : AppColors.textSecondaryLight,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? Colors.white : AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateNavigator() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingMedium,
        vertical: AppSizes.paddingSmall,
      ),
      decoration: BoxDecoration(
        color: AppColors.primarySurface,
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        border: Border.all(color: AppColors.primary),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          IconButton(
            icon: const Icon(Icons.chevron_left, color: AppColors.primary),
            onPressed: _onPreviousPeriod,
            tooltip: _getPreviousTooltip(),
          ),
          const SizedBox(width: AppSizes.spacingSmall),
          Text(
            _getDateRangeText(),
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: AppSizes.spacingSmall),
          IconButton(
            icon: const Icon(Icons.chevron_right, color: AppColors.primary),
            onPressed: _onNextPeriod,
            tooltip: _getNextTooltip(),
          ),
        ],
      ),
    );
  }

  void _onPreviousPeriod() {
    DateTime newDate;
    switch (_tipoVista) {
      case TipoVistaCuadrante.mensual:
        newDate = DateTime(_selectedDate.year, _selectedDate.month - 1);
      case TipoVistaCuadrante.semanal:
        newDate = _selectedDate.subtract(const Duration(days: 7));
      case TipoVistaCuadrante.diaria:
        newDate = _selectedDate.subtract(const Duration(days: 1));
    }
    _onDateChanged(newDate);
  }

  void _onNextPeriod() {
    DateTime newDate;
    switch (_tipoVista) {
      case TipoVistaCuadrante.mensual:
        newDate = DateTime(_selectedDate.year, _selectedDate.month + 1);
      case TipoVistaCuadrante.semanal:
        newDate = _selectedDate.add(const Duration(days: 7));
      case TipoVistaCuadrante.diaria:
        newDate = _selectedDate.add(const Duration(days: 1));
    }
    _onDateChanged(newDate);
  }

  String _getPreviousTooltip() {
    switch (_tipoVista) {
      case TipoVistaCuadrante.mensual:
        return 'Mes anterior';
      case TipoVistaCuadrante.semanal:
        return 'Semana anterior';
      case TipoVistaCuadrante.diaria:
        return 'Día anterior';
    }
  }

  String _getNextTooltip() {
    switch (_tipoVista) {
      case TipoVistaCuadrante.mensual:
        return 'Mes siguiente';
      case TipoVistaCuadrante.semanal:
        return 'Semana siguiente';
      case TipoVistaCuadrante.diaria:
        return 'Día siguiente';
    }
  }

  String _getDateRangeText() {
    const List<String> meses = <String>[
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

    switch (_tipoVista) {
      case TipoVistaCuadrante.mensual:
        return '${meses[_selectedDate.month - 1]} ${_selectedDate.year}';
      case TipoVistaCuadrante.semanal:
        final int weekday = _selectedDate.weekday;
        final DateTime firstDay = _selectedDate.subtract(Duration(days: weekday - 1));
        final DateTime lastDay = firstDay.add(const Duration(days: 6));

        if (firstDay.month == lastDay.month) {
          return '${firstDay.day}-${lastDay.day} ${meses[firstDay.month - 1]} ${firstDay.year}';
        } else if (firstDay.year == lastDay.year) {
          return '${firstDay.day} ${meses[firstDay.month - 1]} - ${lastDay.day} ${meses[lastDay.month - 1]} ${firstDay.year}';
        } else {
          return '${firstDay.day} ${meses[firstDay.month - 1]} ${firstDay.year} - ${lastDay.day} ${meses[lastDay.month - 1]} ${lastDay.year}';
        }
      case TipoVistaCuadrante.diaria:
        final List<String> diasSemana = <String>['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
        return '${diasSemana[_selectedDate.weekday - 1]}, ${_selectedDate.day} ${meses[_selectedDate.month - 1]} ${_selectedDate.year}';
    }
  }
}

/// Vista de carga
class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const CircularProgressIndicator(color: AppColors.primary),
          const SizedBox(height: AppSizes.spacing),
          Text(
            'Cargando cuadrante...',
            style: GoogleFonts.inter(
              fontSize: 16,
              color: AppColors.textSecondaryLight,
            ),
          ),
        ],
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
    return Center(
      child: Container(
        padding: const EdgeInsets.all(AppSizes.paddingXl),
        margin: const EdgeInsets.all(AppSizes.spacing),
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
              'Error al cargar el cuadrante',
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
      ),
    );
  }
}
