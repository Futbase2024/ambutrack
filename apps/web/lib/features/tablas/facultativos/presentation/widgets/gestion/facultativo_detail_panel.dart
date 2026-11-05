import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/tablas/facultativos/presentation/widgets/gestion/facultativo_gestion_columns.dart';
import 'package:flutter/material.dart';

/// Ficha lateral del facultativo seleccionado
class FacultativoDetailPanel extends StatelessWidget {
  const FacultativoDetailPanel({
    required this.facultativo,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  final FacultativoEntity? facultativo;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final FacultativoEntity? c = facultativo;
    if (c == null) {
      return const GestionDetailEmpty(
        message: 'Selecciona un facultativo para ver su ficha',
      );
    }
    return GestionDetailPanel(
      key: ValueKey<String>(c.id),
      title: c.nombreCompleto,
      badges: <Widget>[FacultativoEstadoDot(activo: c.activo)],
      tabs: <GestionDetailTab>[
        GestionDetailTab(label: 'General', child: _FacultativoGeneralTab(facultativo: c)),
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

class _FacultativoGeneralTab extends StatelessWidget {
  const _FacultativoGeneralTab({required this.facultativo});

  final FacultativoEntity facultativo;

  @override
  Widget build(BuildContext context) {
    final FacultativoEntity c = facultativo;
    return GestionDetailBody(
      children: <Widget>[
        const GestionDetailSection(title: 'Identificación'),
        GestionDetailField(label: 'Nombre', value: c.nombre),
        GestionDetailField(label: 'Apellidos', value: c.apellidos),
        GestionDetailField(label: 'Nº Colegiado', value: c.numColegiado),
        GestionDetailField(label: 'Especialidad', value: c.especialidadNombre),
        GestionDetailField(label: 'Estado', child: FacultativoEstadoDot(activo: c.activo)),
        const GestionDetailSection(title: 'Contacto'),
        GestionDetailField(
          label: 'Teléfono',
          value: c.telefono == null ? null : GestionFormatters.telefono(c.telefono),
        ),
        GestionDetailField(label: 'Email', value: c.email),
        const GestionDetailSection(title: 'Registro'),
        GestionDetailField(label: 'Alta', value: GestionFormatters.fecha(c.createdAt)),
        GestionDetailField(label: 'Modificado', value: GestionFormatters.fecha(c.updatedAt)),
      ],
    );
  }
}
