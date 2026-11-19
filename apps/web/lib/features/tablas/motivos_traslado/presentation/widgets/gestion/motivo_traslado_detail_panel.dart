import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/tablas/motivos_traslado/presentation/widgets/gestion/motivo_traslado_gestion_columns.dart';
import 'package:flutter/material.dart';

/// Ficha lateral del motivo de traslado seleccionado
class MotivoTrasladoDetailPanel extends StatelessWidget {
  const MotivoTrasladoDetailPanel({
    required this.item,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  final MotivoTrasladoEntity? item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final MotivoTrasladoEntity? e = item;
    if (e == null) {
      return const GestionDetailEmpty(
        message: 'Selecciona un motivo de traslado para ver su ficha',
      );
    }
    return GestionDetailPanel(
      key: ValueKey<String>(e.id),
      title: e.nombre,
      badges: <Widget>[MotivoTrasladoEstadoDot(activo: e.activo)],
      tabs: <GestionDetailTab>[
        GestionDetailTab(label: 'General', child: _MotivoTrasladoGeneralTab(item: e)),
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

class _MotivoTrasladoGeneralTab extends StatelessWidget {
  const _MotivoTrasladoGeneralTab({required this.item});

  final MotivoTrasladoEntity item;

  @override
  Widget build(BuildContext context) {
    final MotivoTrasladoEntity e = item;
    final bool hasDescripcion = e.descripcion.trim().isNotEmpty;
    return GestionDetailBody(
      children: <Widget>[
        const GestionDetailSection(title: 'Datos generales'),
        GestionDetailField(label: 'Nombre', value: e.nombre),
        GestionDetailField(
          label: 'Estado',
          child: Align(
            alignment: Alignment.centerLeft,
            child: MotivoTrasladoEstadoDot(activo: e.activo),
          ),
        ),
        const GestionDetailSection(title: 'Servicio'),
        GestionDetailField(label: 'Tiempo espera', value: motivoTrasladoTiempo(e.tiempo)),
        GestionDetailField(label: 'Vuelta', value: e.vuelta ? 'Sí' : 'No'),
        const GestionDetailSection(title: 'Descripción'),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(
            GestionFormatters.texto(e.descripcion),
            style: TextStyle(
              fontSize: 12.5,
              height: 1.4,
              color: hasDescripcion ? AppColors.gray800 : AppColors.gray300,
            ),
          ),
        ),
        const GestionDetailSection(title: 'Registro'),
        GestionDetailField(label: 'Alta', value: GestionFormatters.fecha(e.createdAt)),
        GestionDetailField(label: 'Modificado', value: GestionFormatters.fecha(e.updatedAt)),
      ],
    );
  }
}
