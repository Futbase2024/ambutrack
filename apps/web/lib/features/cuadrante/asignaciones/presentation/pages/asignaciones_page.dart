import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/widgets/headers/page_header.dart';
import 'package:ambutrack_web/features/cuadrante/asignaciones/presentation/bloc/asignaciones/asignaciones_bloc.dart';
import 'package:ambutrack_web/features/cuadrante/asignaciones/presentation/bloc/asignaciones/asignaciones_event.dart';
import 'package:ambutrack_web/features/cuadrante/asignaciones/presentation/bloc/asignaciones/asignaciones_state.dart';
import 'package:ambutrack_web/features/cuadrante/asignaciones/presentation/widgets/asignacion_form_dialog.dart';
import 'package:ambutrack_web/features/cuadrante/asignaciones/presentation/widgets/asignaciones_filters.dart';
import 'package:ambutrack_web/features/cuadrante/asignaciones/presentation/widgets/asignaciones_table_styled.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

/// Página principal de gestión de Asignaciones
class AsignacionesPage extends StatelessWidget {
  const AsignacionesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocProvider<AsignacionesBloc>.value(
        value: getIt<AsignacionesBloc>(),
        child: const _AsignacionesView(),
      ),
    );
  }
}

class _AsignacionesView extends StatefulWidget {
  const _AsignacionesView();

  @override
  State<_AsignacionesView> createState() => _AsignacionesViewState();
}

class _AsignacionesViewState extends State<_AsignacionesView> {
  DateTime _selectedDate = DateTime.now();
  DateTime? _pageStartTime;
  AsignacionesFilterData _filterData = const AsignacionesFilterData();

  @override
  void initState() {
    super.initState();
    _pageStartTime = DateTime.now();

    final AsignacionesBloc bloc = context.read<AsignacionesBloc>();
    if (bloc.state is AsignacionesInitial) {
      bloc.add(AsignacionesLoadByFechaRequested(_selectedDate));
    } else if (bloc.state is AsignacionesLoaded) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_pageStartTime != null) {
          final Duration elapsed =
              DateTime.now().difference(_pageStartTime!);
          debugPrint(
            '⏱️ AsignacionesPage: Carga caché ${elapsed.inMilliseconds}ms',
          );
          _pageStartTime = null;
        }
      });
    }
  }

  void _onFilterChanged(AsignacionesFilterData filterData) {
    setState(() => _filterData = filterData);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AsignacionesBloc, AsignacionesState>(
      listener: (BuildContext context, AsignacionesState state) {
        if (state is AsignacionesLoaded && _pageStartTime != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_pageStartTime != null) {
              final Duration elapsed =
                  DateTime.now().difference(_pageStartTime!);
              debugPrint(
                '⏱️ AsignacionesPage: Carga ${elapsed.inMilliseconds}ms',
              );
              _pageStartTime = null;
            }
          });
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundLight,
        body: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSizes.paddingXl,
            AppSizes.paddingXl,
            AppSizes.paddingXl,
            AppSizes.paddingLarge,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              BlocBuilder<AsignacionesBloc, AsignacionesState>(
                builder: (BuildContext context, AsignacionesState state) {
                  return PageHeader(
                    config: PageHeaderConfig(
                      icon: Icons.assignment_ind,
                      title: 'Gestión de Asignaciones',
                      subtitle:
                          'Administra las asignaciones de vehículos a turnos',
                      addButtonLabel: 'Nueva Asignación',
                      stats: _buildHeaderStats(state),
                      onAdd: _showCreateDialog,
                      extra: AsignacionesFilters(
                        onFilterChanged: _onFilterChanged,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: AppSizes.spacing),

              _DateSelector(
                selectedDate: _selectedDate,
                onDateChanged: _changeDate,
                onToday: _goToToday,
                onPickDate: _selectDate,
              ),
              const SizedBox(height: AppSizes.spacing),

              Expanded(
                child: AsignacionesTableStyled(filterData: _filterData),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<HeaderStat> _buildHeaderStats(AsignacionesState state) {
    String total = '-';
    String planificadas = '-';
    String confirmadas = '-';

    if (state is AsignacionesLoaded) {
      total = state.asignaciones.length.toString();
      planificadas = state.asignaciones
          .where((AsignacionVehiculoTurnoEntity a) =>
              a.estado.toLowerCase() == 'planificada')
          .length
          .toString();
      confirmadas = state.asignaciones
          .where((AsignacionVehiculoTurnoEntity a) =>
              a.estado.toLowerCase() == 'confirmada')
          .length
          .toString();
    }

    return <HeaderStat>[
      HeaderStat(value: total, icon: Icons.assignment_ind),
      HeaderStat(value: planificadas, icon: Icons.schedule),
      HeaderStat(value: confirmadas, icon: Icons.check_circle),
    ];
  }

  void _changeDate(int days) {
    setState(() => _selectedDate = _selectedDate.add(Duration(days: days)));
    context
        .read<AsignacionesBloc>()
        .add(AsignacionesLoadByFechaRequested(_selectedDate));
  }

  void _goToToday() {
    setState(() => _selectedDate = DateTime.now());
    context
        .read<AsignacionesBloc>()
        .add(AsignacionesLoadByFechaRequested(_selectedDate));
  }

  Future<void> _selectDate(BuildContext pageContext) async {
    final DateTime? picked = await showDatePicker(
      context: pageContext,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked != null && picked != _selectedDate && mounted) {
      setState(() => _selectedDate = picked);
      context
          .read<AsignacionesBloc>()
          .add(AsignacionesLoadByFechaRequested(_selectedDate));
    }
  }

  Future<void> _showCreateDialog() async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) =>
          BlocProvider<AsignacionesBloc>.value(
            value: context.read<AsignacionesBloc>(),
            child: const AsignacionFormDialog(),
          ),
    );
  }
}

/// Selector de fecha compacto
class _DateSelector extends StatelessWidget {
  const _DateSelector({
    required this.selectedDate,
    required this.onDateChanged,
    required this.onToday,
    required this.onPickDate,
  });

  final DateTime selectedDate;
  final void Function(int) onDateChanged;
  final VoidCallback onToday;
  final Future<void> Function(BuildContext) onPickDate;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingMedium,
        vertical: AppSizes.paddingSmall,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.gray300),
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          IconButton(
            icon: const Icon(Icons.chevron_left, color: AppColors.primary),
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            onPressed: () => onDateChanged(-1),
            tooltip: 'Día anterior',
          ),
          TextButton.icon(
            icon: const Icon(
              Icons.calendar_today,
              size: 18,
              color: AppColors.primary,
            ),
            label: Text(
              _formatDate(selectedDate),
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimaryLight,
              ),
            ),
            onPressed: () => onPickDate(context),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right, color: AppColors.primary),
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            onPressed: () => onDateChanged(1),
            tooltip: 'Día siguiente',
          ),
          const SizedBox(width: AppSizes.spacingSmall),
          ElevatedButton(
            onPressed: onToday,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text('Hoy', style: TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}
