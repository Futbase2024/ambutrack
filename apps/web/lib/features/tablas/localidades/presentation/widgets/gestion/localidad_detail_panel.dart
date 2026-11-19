import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:flutter/material.dart';

/// Ficha lateral de la localidad seleccionada
class LocalidadDetailPanel extends StatelessWidget {
  const LocalidadDetailPanel({
    required this.localidad,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  final LocalidadEntity? localidad;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final LocalidadEntity? c = localidad;
    if (c == null) {
      return const GestionDetailEmpty(
        message: 'Selecciona una localidad para ver su ficha',
      );
    }
    return GestionDetailPanel(
      key: ValueKey<String>(c.id),
      title: c.nombre,
      tabs: <GestionDetailTab>[
        GestionDetailTab(label: 'General', child: _LocalidadGeneralTab(localidad: c)),
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

class _LocalidadGeneralTab extends StatelessWidget {
  const _LocalidadGeneralTab({required this.localidad});

  final LocalidadEntity localidad;

  @override
  Widget build(BuildContext context) {
    final LocalidadEntity c = localidad;
    return GestionDetailBody(
      children: <Widget>[
        const GestionDetailSection(title: 'Identificación'),
        GestionDetailField(label: 'Localidad', value: c.nombre),
        GestionDetailField(label: 'Código', value: c.codigo),
        GestionDetailField(label: 'C. Postal', value: c.codigoPostal),
        const GestionDetailSection(title: 'Ubicación'),
        GestionDetailField(label: 'Provincia', value: c.provinciaNombre),
        const GestionDetailSection(title: 'Registro'),
        GestionDetailField(label: 'Alta', value: GestionFormatters.fecha(c.createdAt)),
        GestionDetailField(label: 'Modificado', value: GestionFormatters.fecha(c.updatedAt)),
      ],
    );
  }
}
