import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ambutrack_core/ambutrack_core.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/revisiones_bloc.dart';
import '../bloc/revisiones_event.dart';
import '../bloc/revisiones_state.dart';

/// Página de detalle de revisión con listado de items para verificar.
class RevisionPage extends StatelessWidget {
  const RevisionPage({
    required this.revisionId,
    super.key,
  });

  final String revisionId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<RevisionesBloc>()
        ..add(RevisionLoadByIdRequested(
          id: revisionId,
          incluirAmbulancia: true,
          incluirItems: true,
        )),
      child: const _RevisionView(),
    );
  }
}

class _RevisionView extends StatelessWidget {
  const _RevisionView();

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
        title: BlocBuilder<RevisionesBloc, RevisionesState>(
          builder: (context, state) {
            if (state is RevisionDetailLoaded) {
              return Text(
                'Revisión Día ${state.revision.diaRevision ?? '-'}',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              );
            }
            return const Text(
              'Revisión',
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            );
          },
        ),
        actions: [
          BlocBuilder<RevisionesBloc, RevisionesState>(
            builder: (context, state) {
              if (state is RevisionDetailLoaded) {
                if (state.revision.puedeCompletar) {
                  return IconButton(
                    icon: const Icon(Icons.check_circle_outline),
                    onPressed: () {
                      _mostrarDialogoCompletar(context, state.revision);
                    },
                  );
                }
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: BlocConsumer<RevisionesBloc, RevisionesState>(
          listener: (context, state) {
            if (state is RevisionCompleted) {
              _mostrarDialogoExito(context);
            }
          },
          builder: (context, state) {
            if (state is RevisionesLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                ),
              );
            }

            if (state is RevisionesError) {
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
                        'Error al cargar revisión',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.gray900,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        state.message,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey[600],
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () => context.pop(),
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

            if (state is! RevisionDetailLoaded) {
              return const SizedBox.shrink();
            }

            final revision = state.revision;
            final items = state.items;

            // Agrupar items por categoría
            final itemsPorCategoria = <String, List<ItemRevisionEntity>>{};
            for (final item in items) {
              final categoria = item.categoriaId;
              if (!itemsPorCategoria.containsKey(categoria)) {
                itemsPorCategoria[categoria] = [];
              }
              itemsPorCategoria[categoria]!.add(item);
            }

            return Column(
              children: [
                _RevisionHeader(revision: revision),
                Expanded(
                  child: itemsPorCategoria.isEmpty
                      ? _EmptyItemsView()
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: itemsPorCategoria.length,
                          itemBuilder: (context, index) {
                            final categoria = itemsPorCategoria.keys.elementAt(index);
                            final items = itemsPorCategoria[categoria]!;

                            return _CategoriaSection(
                              categoria: categoria,
                              items: items,
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _mostrarDialogoCompletar(BuildContext context, RevisionEntity revision) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_outline,
                  size: 48,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Completar Revisión',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.gray900,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                '¿Confirmas que todos los items han sido verificados correctamente y deseas completar esta revisión?',
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.gray700,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: AppColors.gray300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Cancelar',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.gray700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                        context.read<RevisionesBloc>().add(
                              RevisionCompletarRequested(
                                revisionId: revision.id,
                              ),
                            );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Completar',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _mostrarDialogoExito(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  size: 48,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Revisión Completada',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.gray900,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'La revisión ha sido marcada como completada exitosamente.',
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.gray700,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    context.pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Entendido',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RevisionHeader extends StatelessWidget {
  const _RevisionHeader({required this.revision});

  final RevisionEntity revision;

  @override
  Widget build(BuildContext context) {
    final estadoColor = _getEstadoColor(revision.estado);
    final estadoNombre = _getEstadoNombre(revision.estado);
    final progreso = revision.progreso;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
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
          Row(
            children: [
              if (revision.ambulancia != null) ...[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        revision.ambulancia!.matricula,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.gray900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        revision.ambulancia!.tipoAmbulancia?.nombre ?? 'Sin tipo',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                const Expanded(
                  child: Text(
                    'Revisión',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.gray900,
                    ),
                  ),
                ),
              ],
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
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _InfoItem(
                  icon: Icons.calendar_today,
                  label: 'Fecha',
                  value: _formatFecha(revision.fechaProgramada),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _InfoItem(
                  icon: Icons.looks_one,
                  label: 'Día',
                  value: '${revision.diaRevision ?? '-'}',
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.checklist_rtl,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Progreso',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${(progreso * 100).toInt()}%',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progreso,
                        backgroundColor: Colors.grey[200],
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.primary,
                        ),
                        minHeight: 8,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${revision.itemsVerificados}/${revision.totalItems}',
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
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

class _InfoItem extends StatelessWidget {
  const _InfoItem({
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
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.gray900,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _EmptyItemsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No hay items',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[700],
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Esta revisión aún no tiene items para verificar',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoriaSection extends StatefulWidget {
  const _CategoriaSection({
    required this.categoria,
    required this.items,
  });

  final String categoria;
  final List<ItemRevisionEntity> items;

  @override
  State<_CategoriaSection> createState() => _CategoriaSectionState();
}

class _CategoriaSectionState extends State<_CategoriaSection> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    final itemsVerificados =
        widget.items.where((i) => i.verificado).length;
    final totalItems = widget.items.length;
    final progreso = totalItems > 0 ? itemsVerificados / totalItems : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    _isExpanded
                        ? Icons.expand_more
                        : Icons.chevron_right,
                    color: AppColors.gray700,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.categoria,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.gray900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$itemsVerificados de $totalItems verificados',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 50,
                    height: 50,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircularProgressIndicator(
                          value: progreso,
                          backgroundColor: Colors.grey[200],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            progreso == 1.0
                                ? AppColors.success
                                : AppColors.primary,
                          ),
                          strokeWidth: 4,
                        ),
                        Text(
                          '${(progreso * 100).toInt()}%',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.gray900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isExpanded) ...[
            const Divider(height: 1),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(12),
              itemCount: widget.items.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final item = widget.items[index];
                return _ItemCard(item: item);
              },
            ),
          ],
        ],
      ),
    );
  }
}

class _ItemCard extends StatelessWidget {
  const _ItemCard({required this.item});

  final ItemRevisionEntity item;

  @override
  Widget build(BuildContext context) {
    final isVerificado = item.verificado;
    final isConforme = item.conforme ?? true;

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: isVerificado
          ? (isConforme
              ? AppColors.success.withValues(alpha: 0.05)
              : AppColors.warning.withValues(alpha: 0.05))
          : Colors.grey[50],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: isVerificado
              ? (isConforme
                  ? AppColors.success.withValues(alpha: 0.2)
                  : AppColors.warning.withValues(alpha: 0.2))
              : Colors.grey.shade300,
        ),
      ),
      child: InkWell(
        onTap: () {
          _mostrarDialogoVerificar(context, item);
        },
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: isVerificado
                      ? (isConforme ? AppColors.success : AppColors.warning)
                      : Colors.transparent,
                  border: Border.all(
                    color: isVerificado
                        ? (isConforme ? AppColors.success : AppColors.warning)
                        : Colors.grey.shade400,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: isVerificado
                    ? const Icon(
                        Icons.check,
                        size: 16,
                        color: Colors.white,
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.nombre,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.gray900,
                        decoration: isVerificado && isConforme
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    if (item.cantidadEsperada != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Cantidad: ${item.cantidadEsperada}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                    if (isVerificado && item.observaciones != null && item.observaciones!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        item.observaciones!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[700],
                          fontStyle: FontStyle.italic,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              if (!isVerificado) ...[
                const SizedBox(width: 8),
                const Icon(
                  Icons.chevron_right,
                  color: AppColors.gray500,
                  size: 20,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _mostrarDialogoVerificar(BuildContext context, ItemRevisionEntity item) {
    final conformeController = ValueNotifier<bool>(true);
    final cantidadController = TextEditingController(
      text: item.cantidadEsperada?.toString() ?? '',
    );
    final observacionesController = TextEditingController(
      text: item.observaciones ?? '',
    );

    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.white,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.inventory_2,
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Verificar Item',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.gray900,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  item.nombre,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.gray900,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Estado',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.gray700,
                  ),
                ),
                const SizedBox(height: 8),
                ValueListenableBuilder<bool>(
                  valueListenable: conformeController,
                  builder: (context, conforme, _) {
                    return Row(
                      children: [
                        Expanded(
                          child: _OpcionVerificacion(
                            label: 'Conforme',
                            icon: Icons.check_circle,
                            color: AppColors.success,
                            isSelected: conforme,
                            onTap: () => conformeController.value = true,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _OpcionVerificacion(
                            label: 'No Conforme',
                            icon: Icons.error,
                            color: AppColors.warning,
                            isSelected: !conforme,
                            onTap: () => conformeController.value = false,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                if (item.cantidadEsperada != null) ...[
                  const SizedBox(height: 20),
                  TextField(
                    controller: cantidadController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Cantidad encontrada',
                      hintText: 'Ej: ${item.cantidadEsperada}',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                TextField(
                  controller: observacionesController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Observaciones (opcional)',
                    hintText: 'Detalles adicionales...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: AppColors.gray300),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Cancelar',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.gray700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          final cantidad = int.tryParse(cantidadController.text);
                          final observaciones = observacionesController.text.trim();

                          context.read<RevisionesBloc>().add(
                                ItemRevisionMarcarVerificadoRequested(
                                  itemId: item.id,
                                  conforme: conformeController.value,
                                  cantidadEncontrada: cantidad,
                                  observaciones: observaciones.isEmpty ? null : observaciones,
                                ),
                              );

                          Navigator.of(dialogContext).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Guardar',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OpcionVerificacion extends StatelessWidget {
  const _OpcionVerificacion({
    required this.label,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? color : Colors.grey.shade400,
              size: 28,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected ? color : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
