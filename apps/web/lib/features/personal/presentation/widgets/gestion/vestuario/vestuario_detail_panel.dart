import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/personal/presentation/widgets/gestion/vestuario/vestuario_gestion_columns.dart';
import 'package:ambutrack_web/features/personal/presentation/widgets/gestion/vestuario/vestuario_related_tabs.dart';
import 'package:flutter/material.dart';

/// Ficha lateral de la asignación de vestuario seleccionada
class VestuarioDetailPanel extends StatelessWidget {
  const VestuarioDetailPanel({
    required this.item,
    required this.todos,
    required this.nombre,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  final VestuarioEntity? item;

  /// Todas las asignaciones cargadas (para la pestaña "Trabajador")
  final List<VestuarioEntity> todos;
  final String Function(String personalId) nombre;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final VestuarioEntity? v = item;
    if (v == null) {
      return const GestionDetailEmpty(
        message: 'Selecciona una asignación para ver su ficha',
      );
    }
    final List<VestuarioEntity> delTrabajador = todos
        .where((VestuarioEntity o) => o.personalId == v.personalId)
        .toList()
      ..sort((VestuarioEntity a, VestuarioEntity b) => b.fechaEntrega.compareTo(a.fechaEntrega));
    return GestionDetailPanel(
      key: ValueKey<String>(v.id),
      title: '${v.prenda} · ${v.talla}',
      badges: <Widget>[VestuarioEstadoDot(item: v)],
      tabs: <GestionDetailTab>[
        GestionDetailTab(
          label: 'General',
          child: _VestuarioGeneralTab(item: v, trabajador: nombre(v.personalId)),
        ),
        GestionDetailTab(label: 'Stock', child: VestuarioStockTab(item: v)),
        GestionDetailTab(
          label: 'Trabajador',
          child: VestuarioTrabajadorTab(items: delTrabajador, selectedId: v.id),
        ),
      ],
      actions: <Widget>[
        OutlinedButton.icon(
          onPressed: onEdit,
          icon: const Icon(Icons.edit_outlined, size: 16),
          label: const Text('Editar'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            minimumSize: const Size(0, 34),
            textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ),
        OutlinedButton.icon(
          onPressed: onDelete,
          icon: const Icon(Icons.delete_outline, size: 16),
          label: const Text('Eliminar'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.error,
            side: BorderSide(color: AppColors.error.withValues(alpha: 0.4)),
            minimumSize: const Size(0, 34),
            textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

class _VestuarioGeneralTab extends StatelessWidget {
  const _VestuarioGeneralTab({required this.item, required this.trabajador});

  final VestuarioEntity item;
  final String trabajador;

  @override
  Widget build(BuildContext context) {
    final VestuarioEntity v = item;
    return GestionDetailBody(
      children: <Widget>[
        const GestionDetailSection(title: 'Trabajador'),
        GestionDetailField(label: 'Nombre', value: trabajador),
        const GestionDetailSection(title: 'Prenda'),
        GestionDetailField(label: 'Prenda', value: v.prenda),
        GestionDetailField(label: 'Talla', value: v.talla),
        GestionDetailField(label: 'Cantidad', value: '${v.cantidad ?? 1}'),
        GestionDetailField(label: 'Marca', value: v.marca),
        GestionDetailField(label: 'Color', value: v.color),
        GestionDetailField(label: 'Condición', value: v.estado),
        const GestionDetailSection(title: 'Entrega'),
        GestionDetailField(label: 'Fecha entrega', value: GestionFormatters.fecha(v.fechaEntrega)),
        GestionDetailField(
          label: 'Devolución',
          value: v.fechaDevolucion == null ? null : GestionFormatters.fecha(v.fechaDevolucion),
        ),
        GestionDetailField(label: 'Situación', child: VestuarioEstadoDot(item: v)),
        GestionDetailField(label: 'Registro', value: v.activo ? 'Activo' : 'Inactivo'),
        const GestionDetailSection(title: 'Observaciones'),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(
            GestionFormatters.texto(v.observaciones),
            style: TextStyle(
              fontSize: 12.5,
              height: 1.4,
              color: v.observaciones?.trim().isNotEmpty ?? false
                  ? AppColors.gray800
                  : AppColors.gray300,
            ),
          ),
        ),
        const GestionDetailSection(title: 'Registro'),
        GestionDetailField(label: 'Alta', value: GestionFormatters.fecha(v.createdAt)),
        GestionDetailField(
          label: 'Modificado',
          value: v.updatedAt == null ? null : GestionFormatters.fecha(v.updatedAt),
        ),
      ],
    );
  }
}
