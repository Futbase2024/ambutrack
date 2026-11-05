import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:flutter/material.dart';

/// Ficha lateral de la provincia seleccionada
class ProvinciaDetailPanel extends StatelessWidget {
  const ProvinciaDetailPanel({
    required this.item,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  final ProvinciaEntity? item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final ProvinciaEntity? p = item;
    if (p == null) {
      return const GestionDetailEmpty(
        message: 'Selecciona una provincia para ver su ficha',
      );
    }
    return GestionDetailPanel(
      key: ValueKey<String>(p.id),
      title: p.nombre,
      badges: <Widget>[
        if (p.comunidadAutonoma?.trim().isNotEmpty ?? false)
          GestionDotLabel(label: p.comunidadAutonoma!, color: AppColors.info),
      ],
      tabs: <GestionDetailTab>[
        GestionDetailTab(label: 'General', child: _ProvinciaGeneralTab(provincia: p)),
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

class _ProvinciaGeneralTab extends StatelessWidget {
  const _ProvinciaGeneralTab({required this.provincia});

  final ProvinciaEntity provincia;

  @override
  Widget build(BuildContext context) {
    final ProvinciaEntity p = provincia;
    return GestionDetailBody(
      children: <Widget>[
        const GestionDetailSection(title: 'Identificación'),
        GestionDetailField(label: 'Provincia', value: p.nombre),
        GestionDetailField(label: 'Código INE', value: p.codigo),
        const GestionDetailSection(title: 'Ubicación'),
        GestionDetailField(label: 'Comunidad', value: p.comunidadAutonoma),
        const GestionDetailSection(title: 'Registro'),
        GestionDetailField(label: 'Alta', value: GestionFormatters.fecha(p.createdAt)),
        GestionDetailField(label: 'Modificado', value: GestionFormatters.fecha(p.updatedAt)),
      ],
    );
  }
}
