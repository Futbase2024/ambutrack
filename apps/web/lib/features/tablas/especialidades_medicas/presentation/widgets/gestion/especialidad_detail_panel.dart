import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/tablas/especialidades_medicas/presentation/widgets/gestion/especialidad_gestion_columns.dart';
import 'package:flutter/material.dart';

/// Ficha lateral de la especialidad médica seleccionada
class EspecialidadDetailPanel extends StatelessWidget {
  const EspecialidadDetailPanel({
    required this.especialidad,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  final EspecialidadEntity? especialidad;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final EspecialidadEntity? c = especialidad;
    if (c == null) {
      return const GestionDetailEmpty(
        message: 'Selecciona una especialidad para ver su ficha',
      );
    }
    return GestionDetailPanel(
      key: ValueKey<String>(c.id),
      title: c.nombre,
      badges: <Widget>[
        EspecialidadTipoDot(tipo: c.tipoEspecialidad),
        EspecialidadEstadoDot(activo: c.activo),
      ],
      tabs: <GestionDetailTab>[
        GestionDetailTab(label: 'General', child: _EspecialidadGeneralTab(especialidad: c)),
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

class _EspecialidadGeneralTab extends StatelessWidget {
  const _EspecialidadGeneralTab({required this.especialidad});

  final EspecialidadEntity especialidad;

  @override
  Widget build(BuildContext context) {
    final EspecialidadEntity c = especialidad;
    final bool hasDescripcion = c.descripcion?.trim().isNotEmpty ?? false;
    return GestionDetailBody(
      children: <Widget>[
        const GestionDetailSection(title: 'Identificación'),
        GestionDetailField(label: 'Nombre', value: c.nombre),
        GestionDetailField(label: 'Tipo', child: EspecialidadTipoDot(tipo: c.tipoEspecialidad)),
        GestionDetailField(
          label: 'Certificación',
          value: c.requiereCertificacion ? 'Requiere certificación' : 'No requiere',
        ),
        GestionDetailField(label: 'Estado', child: EspecialidadEstadoDot(activo: c.activo)),
        const GestionDetailSection(title: 'Descripción'),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(
            GestionFormatters.texto(c.descripcion),
            style: TextStyle(
              fontSize: 12.5,
              height: 1.4,
              color: hasDescripcion ? AppColors.gray800 : AppColors.gray300,
            ),
          ),
        ),
        const GestionDetailSection(title: 'Registro'),
        GestionDetailField(label: 'Alta', value: GestionFormatters.fecha(c.createdAt)),
        GestionDetailField(label: 'Modificado', value: GestionFormatters.fecha(c.updatedAt)),
      ],
    );
  }
}
