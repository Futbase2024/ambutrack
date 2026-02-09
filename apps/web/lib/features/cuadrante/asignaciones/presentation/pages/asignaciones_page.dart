import 'package:ambutrack_core/ambutrack_core.dart';
import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/widgets/headers/page_header.dart';
import 'package:ambutrack_web/features/cuadrante/asignaciones/presentation/bloc/asignaciones/asignaciones_bloc.dart';
import 'package:ambutrack_web/features/cuadrante/asignaciones/presentation/bloc/asignaciones/asignaciones_event.dart';
import 'package:ambutrack_web/features/cuadrante/asignaciones/presentation/bloc/asignaciones/asignaciones_state.dart';
import 'package:ambutrack_web/features/cuadrante/asignaciones/presentation/widgets/asignacion_form_dialog.dart';
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
      child: BlocProvider<AsignacionesBloc>(
        create: (BuildContext context) => getIt<AsignacionesBloc>()..add(AsignacionesEvent.loadByFecha(DateTime.now())),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            // PageHeader con estadísticas
            BlocBuilder<AsignacionesBloc, AsignacionesState>(
              builder: (BuildContext context, AsignacionesState state) {
                return PageHeader(
                  config: PageHeaderConfig(
                    icon: Icons.assignment_ind,
                    title: 'Gestión de Asignaciones',
                    subtitle: 'Administra las asignaciones de vehículos a turnos',
                    addButtonLabel: 'Nueva Asignación',
                    stats: _buildHeaderStats(state),
                    onAdd: () => _showCreateDialog(context),
                  ),
                );
              },
            ),
            const SizedBox(height: AppSizes.spacing),

            // Selector de fecha
            _buildDateSelector(context),
            const SizedBox(height: AppSizes.spacingXl),

            // Tabla ocupa el espacio restante
            const Expanded(child: AsignacionesTableStyled()),
          ],
        ),
      ),
    );
  }

  /// Construye las estadísticas del header
  List<HeaderStat> _buildHeaderStats(AsignacionesState state) {
    String total = '-';
    String planificadas = '-';
    String confirmadas = '-';

    if (state is AsignacionesLoaded) {
      total = state.asignaciones.length.toString();
      planificadas = state.asignaciones.where((AsignacionVehiculoTurnoEntity a) => a.estado.toLowerCase() == 'planificada').length.toString();
      confirmadas = state.asignaciones.where((AsignacionVehiculoTurnoEntity a) => a.estado.toLowerCase() == 'confirmada').length.toString();
    } else if (state is AsignacionOperationSuccess) {
      total = state.asignaciones.length.toString();
      planificadas = state.asignaciones.where((AsignacionVehiculoTurnoEntity a) => a.estado.toLowerCase() == 'planificada').length.toString();
      confirmadas = state.asignaciones.where((AsignacionVehiculoTurnoEntity a) => a.estado.toLowerCase() == 'confirmada').length.toString();
    }

    return <HeaderStat>[
      HeaderStat(
        value: total,
        icon: Icons.assignment_ind,
      ),
      HeaderStat(
        value: planificadas,
        icon: Icons.schedule,
      ),
      HeaderStat(
        value: confirmadas,
        icon: Icons.check_circle,
      ),
    ];
  }

  /// Construye el selector de fecha
  Widget _buildDateSelector(BuildContext context) {
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
            onPressed: () => _changeDate(-1),
            tooltip: 'Día anterior',
          ),
          TextButton.icon(
            icon: const Icon(
              Icons.calendar_today,
              size: 18,
              color: AppColors.primary,
            ),
            label: Text(
              _formatDate(_selectedDate),
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimaryLight,
              ),
            ),
            onPressed: () => _selectDate(context),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right, color: AppColors.primary),
            onPressed: () => _changeDate(1),
            tooltip: 'Día siguiente',
          ),
          const SizedBox(width: AppSizes.spacingSmall),
          ElevatedButton(
            onPressed: _goToToday,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Hoy'),
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

  void _changeDate(int days) {
    setState(() {
      _selectedDate = _selectedDate.add(Duration(days: days));
    });
    _loadAsignaciones();
  }

  void _goToToday() {
    setState(() {
      _selectedDate = DateTime.now();
    });
    _loadAsignaciones();
  }

  Future<void> _selectDate(BuildContext pageContext) async {
    final DateTime? picked = await showDatePicker(
      context: pageContext,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked != null && picked != _selectedDate && mounted) {
      setState(() {
        _selectedDate = picked;
      });
      _loadAsignaciones();
    }
  }

  void _loadAsignaciones() {
    context.read<AsignacionesBloc>().add(
          AsignacionesEvent.loadByFecha(_selectedDate),
        );
  }

  Future<void> _showCreateDialog(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) => BlocProvider<AsignacionesBloc>.value(
        value: context.read<AsignacionesBloc>(),
        child: const AsignacionFormDialog(),
      ),
    );
  }
}
