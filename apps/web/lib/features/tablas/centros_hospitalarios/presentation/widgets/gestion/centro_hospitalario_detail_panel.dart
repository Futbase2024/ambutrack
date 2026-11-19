import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/tablas/centros_hospitalarios/presentation/widgets/gestion/centro_hospitalario_gestion_columns.dart';
import 'package:flutter/material.dart';

/// Ficha lateral del centro seleccionado
class CentroHospitalarioDetailPanel extends StatelessWidget {
  const CentroHospitalarioDetailPanel({
    required this.centro,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  final CentroHospitalarioEntity? centro;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final CentroHospitalarioEntity? c = centro;
    if (c == null) {
      return const GestionDetailEmpty(
        message: 'Selecciona un centro para ver su ficha',
      );
    }
    return GestionDetailPanel(
      key: ValueKey<String>(c.id),
      title: c.nombre,
      badges: <Widget>[
        if (c.tipoCentro?.trim().isNotEmpty ?? false) CentroTipoDot(tipo: c.tipoCentro),
        CentroEstadoDot(activo: c.activo),
      ],
      tabs: <GestionDetailTab>[
        GestionDetailTab(label: 'General', child: _CentroGeneralTab(centro: c)),
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

class _CentroGeneralTab extends StatelessWidget {
  const _CentroGeneralTab({required this.centro});

  final CentroHospitalarioEntity centro;

  @override
  Widget build(BuildContext context) {
    final CentroHospitalarioEntity c = centro;
    final List<String> especialidades = c.especialidades ?? const <String>[];
    return GestionDetailBody(
      children: <Widget>[
        const GestionDetailSection(title: 'Identificación'),
        GestionDetailField(label: 'Nombre', value: c.nombre),
        GestionDetailField(label: 'Tipo', child: CentroTipoDot(tipo: c.tipoCentro)),
        GestionDetailField(label: 'Estado', child: CentroEstadoDot(activo: c.activo)),
        const GestionDetailSection(title: 'Ubicación'),
        GestionDetailField(label: 'Dirección', value: c.direccion),
        GestionDetailField(label: 'Localidad', value: c.localidadNombre),
        GestionDetailField(label: 'Provincia', value: c.provinciaNombre),
        GestionDetailField(label: 'Coord. GPS', value: c.coordenadasGps),
        const GestionDetailSection(title: 'Contacto'),
        GestionDetailField(
          label: 'Teléfono',
          value: c.telefono == null ? null : GestionFormatters.telefono(c.telefono),
        ),
        GestionDetailField(label: 'Email', value: c.email),
        const GestionDetailSection(title: 'Especialidades'),
        if (especialidades.isEmpty)
          const GestionDetailField(label: 'Especialidades')
        else
          for (final String e in especialidades) GestionDetailField(label: '•', value: e, labelWidth: 16),
        const GestionDetailSection(title: 'Registro'),
        GestionDetailField(label: 'Alta', value: GestionFormatters.fecha(c.createdAt)),
        GestionDetailField(label: 'Modificado', value: GestionFormatters.fecha(c.updatedAt)),
      ],
    );
  }
}
