import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/widgets/gestion_frame/gestion_frame.dart';
import 'package:ambutrack_web/features/cuadrante/asignaciones/presentation/bloc/cuadrante_asignaciones_bloc.dart';
import 'package:ambutrack_web/features/cuadrante/asignaciones/presentation/bloc/cuadrante_asignaciones_event.dart';
import 'package:ambutrack_web/features/cuadrante/asignaciones/presentation/bloc/cuadrante_asignaciones_state.dart';
import 'package:ambutrack_web/features/cuadrante/asignaciones/presentation/widgets/calendario_mensual_widget.dart';
import 'package:ambutrack_web/features/cuadrante/asignaciones/presentation/widgets/cuadrante_asignacion_form_dialog.dart';
import 'package:ambutrack_web/features/cuadrante/asignaciones/presentation/widgets/cuadrante_diario_widget.dart';
import 'package:ambutrack_web/features/cuadrante/asignaciones/presentation/widgets/cuadrante_mensual_toolbar.dart';
import 'package:ambutrack_web/features/cuadrante/asignaciones/presentation/widgets/cuadrante_semanal_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

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
      barrierDismissible: false,
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
      barrierDismissible: false,
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
      body: GestionFrame(
        toolbar: CuadranteMensualToolbar(
          tipoVista: _tipoVista,
          selectedDate: _selectedDate,
          onTipoVistaChanged: _onTipoVistaChanged,
          onPrevious: _onPreviousPeriod,
          onNext: _onNextPeriod,
        ),
        statusBar: CuadranteMensualStatusBar(
          tipoVista: _tipoVista,
          selectedDate: _selectedDate,
        ),
        content: BlocBuilder<CuadranteAsignacionesBloc, CuadranteAsignacionesState>(
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
