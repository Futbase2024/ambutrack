import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/taller/presentation/widgets/gestion/taller_gestion_columns.dart';
import 'package:ambutrack_web/features/taller/presentation/widgets/gestion/taller_ordenes_tab.dart';
import 'package:flutter/material.dart';

/// Ficha lateral del taller seleccionado
class TallerDetailPanel extends StatelessWidget {
  const TallerDetailPanel({
    required this.taller,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  final TallerEntity? taller;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final TallerEntity? t = taller;
    if (t == null) {
      return const GestionDetailEmpty(
        message: 'Selecciona un taller para ver su ficha',
      );
    }
    return GestionDetailPanel(
      key: ValueKey<String>(t.id),
      title: t.nombre,
      badges: <Widget>[
        GestionDotLabel(label: t.tipo.displayName, color: tallerTipoColor(t.tipo)),
        TallerEstadoDot(activo: t.activo),
      ],
      tabs: <GestionDetailTab>[
        GestionDetailTab(label: 'General', child: _TallerGeneralTab(taller: t)),
        GestionDetailTab(label: 'Órdenes', child: TallerOrdenesTab(tallerId: t.id)),
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

class _TallerGeneralTab extends StatelessWidget {
  const _TallerGeneralTab({required this.taller});

  final TallerEntity taller;

  @override
  Widget build(BuildContext context) {
    final TallerEntity t = taller;
    return GestionDetailBody(
      children: <Widget>[
        const GestionDetailSection(title: 'Identificación'),
        GestionDetailField(label: 'NIF', value: t.nif),
        GestionDetailField(label: 'Especialidad', value: t.especialidad),
        const GestionDetailSection(title: 'Contacto'),
        GestionDetailField(label: 'Persona', value: t.contactoNombre),
        GestionDetailField(
          label: 'Teléfono',
          value: t.telefono == null ? null : GestionFormatters.telefono(t.telefono),
        ),
        GestionDetailField(label: 'Email', value: t.email),
        const GestionDetailSection(title: 'Dirección'),
        GestionDetailField(label: 'Dirección', value: t.direccion),
        GestionDetailField(label: 'C. Postal', value: t.codigoPostal),
        GestionDetailField(label: 'Ciudad', value: t.ciudad),
        GestionDetailField(label: 'Provincia', value: t.provincia),
        const GestionDetailSection(title: 'Observaciones'),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(
            GestionFormatters.texto(t.observaciones),
            style: TextStyle(
              fontSize: 12.5,
              height: 1.4,
              color: t.observaciones?.trim().isNotEmpty ?? false
                  ? AppColors.gray800
                  : AppColors.gray300,
            ),
          ),
        ),
        const GestionDetailSection(title: 'Registro'),
        GestionDetailField(label: 'Alta', value: GestionFormatters.fecha(t.createdAt)),
        GestionDetailField(
          label: 'Modificado',
          value: t.updatedAt == null ? null : GestionFormatters.fecha(t.updatedAt),
        ),
      ],
    );
  }
}
