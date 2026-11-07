import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/ambulancias_bloc.dart';
import '../bloc/ambulancias_event.dart';
import '../bloc/ambulancias_state.dart';
import '../bloc/revisiones_bloc.dart';
import '../bloc/revisiones_event.dart';
import '../bloc/revisiones_state.dart';

/// Página de detalle de una ambulancia con sus revisiones.
class AmbulanciaDetallePage extends StatelessWidget {
  const AmbulanciaDetallePage({
    required this.ambulanciaId,
    super.key,
  });

  final String ambulanciaId;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => getIt<AmbulanciasBloc>()
            ..add(AmbulanciaLoadByIdRequested(ambulanciaId)),
        ),
        BlocProvider(
          create: (context) => getIt<RevisionesBloc>()
            ..add(RevisionesLoadByAmbulanciaRequested(
              ambulanciaId: ambulanciaId,
              incluirItems: false,
            )),
        ),
      ],
      child: const _AmbulanciaDetalleView(),
    );
  }
}

class _AmbulanciaDetalleView extends StatelessWidget {
  const _AmbulanciaDetalleView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: BlocBuilder<AmbulanciasBloc, AmbulanciasState>(
          builder: (context, state) {
            if (state is AmbulanciaDetailLoaded) {
              return Text(
                state.ambulancia.matricula,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              );
            }
            return const Text(
              'Detalle Ambulancia',
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              final ambulanciaId = (context.read<AmbulanciasBloc>().state
                      as AmbulanciaDetailLoaded?)
                  ?.ambulancia
                  .id;
              if (ambulanciaId != null) {
                context
                    .read<AmbulanciasBloc>()
                    .add(AmbulanciaLoadByIdRequested(ambulanciaId));
                context.read<RevisionesBloc>().add(
                      RevisionesLoadByAmbulanciaRequested(
                        ambulanciaId: ambulanciaId,
                        incluirItems: false,
                      ),
                    );
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: BlocBuilder<AmbulanciasBloc, AmbulanciasState>(
          builder: (context, ambulanciaState) {
            if (ambulanciaState is AmbulanciasLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                ),
              );
            }

            if (ambulanciaState is AmbulanciasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: AppColors.error,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Error al cargar ambulancia',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.gray900,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        ambulanciaState.message,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey[600],
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () {
                          context.pop();
                        },
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('Volver'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (ambulanciaState is! AmbulanciaDetailLoaded) {
              return const SizedBox.shrink();
            }

            final ambulancia = ambulanciaState.ambulancia;

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _AmbulanciaInfoCard(ambulancia: ambulancia),
                  const SizedBox(height: 16),
                  _RevisionesSection(ambulancia: ambulancia),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _AmbulanciaInfoCard extends StatelessWidget {
  const _AmbulanciaInfoCard({required this.ambulancia});

  final AmbulanciaEntity ambulancia;

  @override
  Widget build(BuildContext context) {
    final estadoColor = _getEstadoColor(ambulancia.estado);
    final estadoNombre = _getEstadoNombre(ambulancia.estado);

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.airport_shuttle,
                    color: AppColors.primary,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ambulancia.matricula,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: AppColors.gray900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        ambulancia.tipoAmbulancia?.nombre ?? 'Sin tipo',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: IntrinsicWidth(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: estadoColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: estadoColor.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        estadoNombre,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: estadoColor,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                if (ambulancia.tipoAmbulancia != null) ...[
                  _InfoRow(
                    icon: Icons.medical_services,
                    label: 'Tipo',
                    value: ambulancia.tipoAmbulancia!.codigo,
                  ),
                  const SizedBox(height: 12),
                  _InfoRow(
                    icon: Icons.label_outline,
                    label: 'Descripción',
                    value: ambulancia.tipoAmbulancia!.descripcion ?? '-',
                  ),
                  const SizedBox(height: 12),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getEstadoColor(EstadoAmbulancia? estado) {
    if (estado == null) return AppColors.gray500;
    switch (estado) {
      case EstadoAmbulancia.activa:
        return AppColors.success;
      case EstadoAmbulancia.mantenimiento:
        return AppColors.warning;
      case EstadoAmbulancia.baja:
        return AppColors.error;
    }
  }

  String _getEstadoNombre(EstadoAmbulancia? estado) {
    if (estado == null) return 'DESCONOCIDO';
    switch (estado) {
      case EstadoAmbulancia.activa:
        return 'ACTIVA';
      case EstadoAmbulancia.mantenimiento:
        return 'MANTENIMIENTO';
      case EstadoAmbulancia.baja:
        return 'BAJA';
    }
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: AppColors.gray500,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.gray900,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RevisionesSection extends StatelessWidget {
  const _RevisionesSection({required this.ambulancia});

  final AmbulanciaEntity ambulancia;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                const Icon(
                  Icons.checklist_rtl,
                  color: AppColors.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Revisiones',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.gray900,
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Implementar creación de revisión
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Funcionalidad en desarrollo'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Nueva'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          BlocBuilder<RevisionesBloc, RevisionesState>(
            builder: (context, state) {
              if (state is RevisionesLoading) {
                return const Padding(
                  padding: EdgeInsets.all(40),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                    ),
                  ),
                );
              }

              if (state is RevisionesError) {
                return Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        state.message,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }

              if (state is RevisionesLoaded) {
                if (state.revisiones.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      children: [
                        Icon(
                          Icons.checklist_rtl,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No hay revisiones',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Crea la primera revisión',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  itemCount: state.revisiones.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final revision = state.revisiones[index];
                    final ambulanciaId = (context.read<AmbulanciasBloc>().state
                            as AmbulanciaDetailLoaded)
                        .ambulancia
                        .id;
                    return _RevisionCard(
                      revision: revision,
                      onTap: () {
                        context.push('/ambulancias/$ambulanciaId/revision/${revision.id}');
                      },
                    );
                  },
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }
}

class _RevisionCard extends StatelessWidget {
  const _RevisionCard({
    required this.revision,
    required this.onTap,
  });

  final RevisionEntity revision;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final estadoColor = _getEstadoColor(revision.estado);
    final estadoNombre = _getEstadoNombre(revision.estado);
    final progreso = revision.progreso;

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Colors.grey.shade200,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Día ${revision.diaRevision ?? '-'}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.gray900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatFecha(revision.fechaProgramada),
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: IntrinsicWidth(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: estadoColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          estadoNombre,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: estadoColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Progreso',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${(progreso * 100).toInt()}%',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: progreso,
                            backgroundColor: Colors.grey[200],
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              AppColors.primary,
                            ),
                            minHeight: 6,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${revision.itemsVerificados}/${revision.totalItems}',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              if (revision.observaciones != null &&
                  revision.observaciones!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.notes,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          revision.observaciones!,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[700],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getEstadoColor(EstadoRevision? estado) {
    if (estado == null) return AppColors.gray500;
    switch (estado) {
      case EstadoRevision.pendiente:
        return AppColors.warning;
      case EstadoRevision.enProgreso:
        return AppColors.info;
      case EstadoRevision.completada:
        return AppColors.success;
      case EstadoRevision.conIncidencias:
        return AppColors.error;
    }
  }

  String _getEstadoNombre(EstadoRevision? estado) {
    if (estado == null) return 'DESCONOCIDO';
    switch (estado) {
      case EstadoRevision.pendiente:
        return 'PENDIENTE';
      case EstadoRevision.enProgreso:
        return 'EN PROGRESO';
      case EstadoRevision.completada:
        return 'COMPLETADA';
      case EstadoRevision.conIncidencias:
        return 'CON INCIDENCIAS';
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
    return '${fecha.day} ${meses[fecha.month - 1]} ${fecha.year}';
  }
}
