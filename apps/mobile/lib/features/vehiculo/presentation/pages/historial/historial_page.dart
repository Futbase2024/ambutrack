import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/di/injection.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../bloc/checklist/checklist_bloc.dart';
import '../../bloc/checklist/checklist_event.dart';
import '../../bloc/checklist/checklist_state.dart';
import '../../bloc/vehiculo_asignado/vehiculo_asignado_bloc.dart';
import '../../bloc/vehiculo_asignado/vehiculo_asignado_event.dart';
import '../../bloc/vehiculo_asignado/vehiculo_asignado_state.dart';

/// Página de historial de revisiones del vehículo
class HistorialPage extends StatelessWidget {
  const HistorialPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              getIt<VehiculoAsignadoBloc>()..add(const LoadVehiculoAsignado()),
        ),
        BlocProvider(
          create: (context) => getIt<ChecklistBloc>(),
        ),
      ],
      child: const _HistorialView(),
    );
  }
}

class _HistorialView extends StatefulWidget {
  const _HistorialView();

  @override
  State<_HistorialView> createState() => _HistorialViewState();
}

class _HistorialViewState extends State<_HistorialView> {
  TipoChecklist? _filtroTipo;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray50,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Historial de Revisiones',
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: BlocBuilder<VehiculoAsignadoBloc, VehiculoAsignadoState>(
          builder: (context, vehiculoState) {
            if (vehiculoState is VehiculoAsignadoLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                ),
              );
            }

            if (vehiculoState is VehiculoAsignadoError) {
              return _ErrorView(message: vehiculoState.message);
            }

            if (vehiculoState is! VehiculoAsignadoLoaded) {
              return const _ErrorView(
                message: 'No se pudo cargar información del vehículo',
              );
            }

            final vehiculo = vehiculoState.vehiculo;

            // Cargar historial si aún no está cargado
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (context.mounted) {
                final checklistState = context.read<ChecklistBloc>().state;
                if (checklistState is! ChecklistHistoryLoaded) {
                  context.read<ChecklistBloc>().add(
                        LoadChecklistHistory(vehiculo.id),
                      );
                }
              }
            });

            return BlocBuilder<ChecklistBloc, ChecklistState>(
              builder: (context, checklistState) {
                if (checklistState is ChecklistLoading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                    ),
                  );
                }

                if (checklistState is ChecklistError) {
                  return _ErrorView(message: checklistState.message);
                }

                if (checklistState is! ChecklistHistoryLoaded) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                    ),
                  );
                }

                var checklists = checklistState.checklists;

                // Aplicar filtro si está seleccionado
                if (_filtroTipo != null) {
                  checklists = checklists
                      .where((c) => c.tipo == _filtroTipo)
                      .toList();
                }

                return Column(
                  children: [
                    _VehiculoHeader(vehiculo: vehiculo),
                    _FiltroTipo(
                      filtroSeleccionado: _filtroTipo,
                      onChanged: (tipo) {
                        setState(() {
                          _filtroTipo = tipo;
                        });
                      },
                    ),
                    Expanded(
                      child: checklists.isEmpty
                          ? _EmptyView(tipoFiltrado: _filtroTipo)
                          : _HistorialList(checklists: checklists),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}

/// Header con información del vehículo
class _VehiculoHeader extends StatelessWidget {
  const _VehiculoHeader({required this.vehiculo});

  final VehiculoEntity vehiculo;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            vehiculo.matricula,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${vehiculo.marca} ${vehiculo.modelo}',
            style: const TextStyle(
              fontSize: 15,
              color: AppColors.gray700,
            ),
          ),
        ],
      ),
    );
  }
}

/// Filtro por tipo de checklist
class _FiltroTipo extends StatelessWidget {
  const _FiltroTipo({
    required this.filtroSeleccionado,
    required this.onChanged,
  });

  final TipoChecklist? filtroSeleccionado;
  final ValueChanged<TipoChecklist?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filtrar por tipo:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.gray900,
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _FiltroChip(
                  label: 'Todos',
                  isSelected: filtroSeleccionado == null,
                  onTap: () => onChanged(null),
                ),
                const SizedBox(width: 8),
                _FiltroChip(
                  label: 'Mensual',
                  isSelected: filtroSeleccionado == TipoChecklist.mensual,
                  onTap: () => onChanged(TipoChecklist.mensual),
                ),
                const SizedBox(width: 8),
                _FiltroChip(
                  label: 'Pre-Servicio',
                  isSelected: filtroSeleccionado == TipoChecklist.preServicio,
                  onTap: () => onChanged(TipoChecklist.preServicio),
                ),
                const SizedBox(width: 8),
                _FiltroChip(
                  label: 'Post-Servicio',
                  isSelected: filtroSeleccionado == TipoChecklist.postServicio,
                  onTap: () => onChanged(TipoChecklist.postServicio),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Chip de filtro
class _FiltroChip extends StatelessWidget {
  const _FiltroChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.gray100,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.gray700,
          ),
        ),
      ),
    );
  }
}

/// Lista de historial de checklists
class _HistorialList extends StatelessWidget {
  const _HistorialList({required this.checklists});

  final List<ChecklistVehiculoEntity> checklists;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: checklists.length,
      itemBuilder: (context, index) {
        final checklist = checklists[index];
        return _ChecklistCard(checklist: checklist);
      },
    );
  }
}

/// Card de checklist individual
class _ChecklistCard extends StatelessWidget {
  const _ChecklistCard({required this.checklist});

  final ChecklistVehiculoEntity checklist;

  @override
  Widget build(BuildContext context) {
    final color = _getTipoColor(checklist.tipo);
    final porcentajeCompleto = checklist.porcentajeCompleto;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          // TODO: Navegar a detalle del checklist
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      checklist.tipo.nombre,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (checklist.checklistCompleto)
                    const Icon(
                      Icons.check_circle,
                      color: AppColors.success,
                      size: 20,
                    )
                  else
                    const Icon(
                      Icons.warning_amber,
                      color: AppColors.warning,
                      size: 20,
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: AppColors.gray600,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _formatFecha(checklist.fechaRealizacion),
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.gray700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.person,
                    size: 16,
                    color: AppColors.gray600,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      checklist.realizadoPorNombre,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.gray700,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _StatItem(
                    icon: Icons.check_circle_outline,
                    label: 'Presentes',
                    value: '${checklist.itemsPresentes}',
                    color: AppColors.success,
                  ),
                  _StatItem(
                    icon: Icons.cancel_outlined,
                    label: 'Ausentes',
                    value: '${checklist.itemsAusentes}',
                    color: AppColors.error,
                  ),
                  _StatItem(
                    icon: Icons.percent,
                    label: 'Completado',
                    value: '${porcentajeCompleto.toStringAsFixed(0)}%',
                    color: porcentajeCompleto == 100
                        ? AppColors.success
                        : AppColors.warning,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getTipoColor(TipoChecklist tipo) {
    switch (tipo) {
      case TipoChecklist.mensual:
        return AppColors.primary;
      case TipoChecklist.preServicio:
        return AppColors.success;
      case TipoChecklist.postServicio:
        return AppColors.warning;
    }
  }

  String _formatFecha(DateTime fecha) {
    final meses = [
      'Ene',
      'Feb',
      'Mar',
      'Abr',
      'May',
      'Jun',
      'Jul',
      'Ago',
      'Sep',
      'Oct',
      'Nov',
      'Dic'
    ];
    return '${fecha.day} ${meses[fecha.month - 1]} ${fecha.year} - ${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')}';
  }
}

/// Item de estadística
class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icon,
          size: 20,
          color: color,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.gray600,
          ),
        ),
      ],
    );
  }
}

/// Vista vacía cuando no hay historial
class _EmptyView extends StatelessWidget {
  const _EmptyView({this.tipoFiltrado});

  final TipoChecklist? tipoFiltrado;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.gray200,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.history,
                size: 40,
                color: AppColors.gray500,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              tipoFiltrado == null
                  ? 'Sin historial'
                  : 'Sin historial de ${tipoFiltrado!.nombre.toLowerCase()}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.gray900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              tipoFiltrado == null
                  ? 'Aún no se han realizado checklists en este vehículo'
                  : 'No hay checklists del tipo seleccionado',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.gray600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.gray700,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
