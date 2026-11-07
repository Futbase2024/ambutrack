import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/tablas/tipos_paciente/presentation/widgets/gestion/tipo_paciente_gestion_columns.dart';
import 'package:flutter/material.dart';

/// Ficha lateral del tipo de paciente seleccionado
class TipoPacienteDetailPanel extends StatelessWidget {
  const TipoPacienteDetailPanel({
    required this.item,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  final TipoPacienteEntity? item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final TipoPacienteEntity? e = item;
    if (e == null) {
      return const GestionDetailEmpty(
        message: 'Selecciona un tipo de paciente para ver su ficha',
      );
    }
    return GestionDetailPanel(
      key: ValueKey<String>(e.id),
      title: e.nombre,
      badges: <Widget>[TipoPacienteEstadoDot(activo: e.activo)],
      tabs: <GestionDetailTab>[
        GestionDetailTab(label: 'General', child: _TipoPacienteGeneralTab(item: e)),
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

class _TipoPacienteGeneralTab extends StatelessWidget {
  const _TipoPacienteGeneralTab({required this.item});

  final TipoPacienteEntity item;

  @override
  Widget build(BuildContext context) {
    final TipoPacienteEntity e = item;
    final bool hasDescripcion = e.descripcion?.trim().isNotEmpty ?? false;
    return GestionDetailBody(
      children: <Widget>[
        const GestionDetailSection(title: 'Datos generales'),
        GestionDetailField(label: 'Nombre', value: e.nombre),
        GestionDetailField(
          label: 'Estado',
          child: Align(
            alignment: Alignment.centerLeft,
            child: TipoPacienteEstadoDot(activo: e.activo),
          ),
        ),
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
