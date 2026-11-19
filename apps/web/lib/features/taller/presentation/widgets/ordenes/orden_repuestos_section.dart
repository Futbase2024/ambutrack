import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/widgets/buttons/app_button.dart';
import 'package:ambutrack_web/core/widgets/dialogs/confirmation_dialog.dart';
import 'package:ambutrack_web/core/widgets/loading/app_loading_indicator.dart';
import 'package:ambutrack_web/features/taller/presentation/bloc/repuesto_orden_bloc.dart';
import 'package:ambutrack_web/features/taller/presentation/bloc/repuesto_orden_event.dart';
import 'package:ambutrack_web/features/taller/presentation/bloc/repuesto_orden_state.dart';
import 'package:ambutrack_web/features/taller/presentation/widgets/ordenes/orden_detail_sections.dart';
import 'package:ambutrack_web/features/taller/presentation/widgets/ordenes/orden_ui_helpers.dart';
import 'package:ambutrack_web/features/taller/presentation/widgets/ordenes/repuesto_form_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Sección de repuestos dentro del detalle de una orden
class OrdenRepuestosSection extends StatelessWidget {
  const OrdenRepuestosSection({required this.ordenId, required this.readOnly, super.key});

  final String ordenId;
  final bool readOnly;

  Future<void> _openForm(BuildContext context, {RepuestoOrdenEntity? repuesto}) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext _) => BlocProvider<RepuestoOrdenBloc>.value(
        value: context.read<RepuestoOrdenBloc>(),
        child: RepuestoFormDialog(ordenId: ordenId, repuesto: repuesto),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, RepuestoOrdenEntity repuesto) async {
    final bool? confirmed = await showSimpleConfirmationDialog(
      context: context,
      title: 'Eliminar repuesto',
      message:
          '¿Seguro que deseas eliminar "${repuesto.descripcion}" de la orden?\n\nEsta acción no se puede deshacer.',
      confirmText: 'Eliminar',
      icon: Icons.delete_outline,
    );
    if (confirmed == true && context.mounted) {
      context.read<RepuestoOrdenBloc>().add(RepuestoOrdenDeleteRequested(repuesto: repuesto));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        OrdenSectionTitle(
          title: 'Repuestos',
          trailing: readOnly
              ? null
              : TextButton.icon(
                  onPressed: () => _openForm(context),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Añadir repuesto'),
                ),
        ),
        _RepuestosList(
          readOnly: readOnly,
          onEdit: (RepuestoOrdenEntity r) => _openForm(context, repuesto: r),
          onDelete: (RepuestoOrdenEntity r) => _confirmDelete(context, r),
        ),
      ],
    );
  }
}

class _RepuestoTile extends StatelessWidget {
  const _RepuestoTile({required this.repuesto, required this.readOnly, required this.onEdit, required this.onDelete});

  final RepuestoOrdenEntity repuesto;
  final bool readOnly;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.spacingSmall),
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingMedium, vertical: AppSizes.paddingSmall),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.gray200),
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
      ),
      child: Row(
        children: <Widget>[
          Expanded(child: _RepuestoInfo(repuesto: repuesto)),
          OrdenColorBadge(label: repuesto.estado.displayName, color: estadoRepuestoColor(repuesto.estado)),
          const SizedBox(width: AppSizes.spacingMedium),
          SizedBox(
            width: 90,
            child: Text(
              formatEuros(repuesto.precioTotal),
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.gray900),
            ),
          ),
          if (!readOnly) _RepuestoActions(onEdit: onEdit, onDelete: onDelete),
        ],
      ),
    );
  }
}

/// Lista de repuestos según el estado del bloc
class _RepuestosList extends StatelessWidget {
  const _RepuestosList({required this.readOnly, required this.onEdit, required this.onDelete});

  final bool readOnly;
  final ValueChanged<RepuestoOrdenEntity> onEdit;
  final ValueChanged<RepuestoOrdenEntity> onDelete;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RepuestoOrdenBloc, RepuestoOrdenState>(
      builder: (BuildContext context, RepuestoOrdenState state) {
        if (state is RepuestoOrdenError) {
          return Text(state.message, style: const TextStyle(color: AppColors.error));
        }
        if (state is! RepuestoOrdenLoaded) {
          return const Padding(
            padding: EdgeInsets.all(AppSizes.paddingMedium),
            child: AppLoadingIndicator(message: 'Cargando repuestos...', size: 32),
          );
        }
        if (state.repuestos.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSizes.paddingMedium),
            child: Text('Sin repuestos registrados', style: TextStyle(color: AppColors.gray500)),
          );
        }
        return Column(
          children: state.repuestos
              .map(
                (RepuestoOrdenEntity r) => _RepuestoTile(
                  repuesto: r,
                  readOnly: readOnly,
                  onEdit: () => onEdit(r),
                  onDelete: () => onDelete(r),
                ),
              )
              .toList(growable: false),
        );
      },
    );
  }
}

/// Descripción y detalle (referencia · proveedor · cantidad × precio)
class _RepuestoInfo extends StatelessWidget {
  const _RepuestoInfo({required this.repuesto});

  final RepuestoOrdenEntity repuesto;

  @override
  Widget build(BuildContext context) {
    final String detalle = <String>[
      if (repuesto.referencia != null) repuesto.referencia!,
      if (repuesto.proveedorNombre != null) repuesto.proveedorNombre!,
      '${repuesto.cantidad} × ${formatEuros(repuesto.precioUnitario)}',
    ].join(' · ');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          repuesto.descripcion,
          style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.gray900),
        ),
        Text(detalle, style: const TextStyle(fontSize: 12, color: AppColors.gray500)),
      ],
    );
  }
}

/// Botones editar/eliminar de un repuesto
class _RepuestoActions extends StatelessWidget {
  const _RepuestoActions({required this.onEdit, required this.onDelete});

  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        const SizedBox(width: AppSizes.spacingSmall),
        AppIconButton(
          icon: Icons.edit_outlined,
          onPressed: onEdit,
          tooltip: 'Editar',
          color: AppColors.secondaryLight,
          size: 36,
        ),
        AppIconButton(
          icon: Icons.delete_outline,
          onPressed: onDelete,
          tooltip: 'Eliminar',
          color: AppColors.error,
          size: 36,
        ),
      ],
    );
  }
}
