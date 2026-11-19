import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/cuadrante/excepciones_festivos/presentation/widgets/gestion/excepciones_gestion_columns.dart';
import 'package:flutter/material.dart';

/// Ficha lateral de la excepción/festivo seleccionado
class ExcepcionesDetailPanel extends StatelessWidget {
  const ExcepcionesDetailPanel({
    required this.item,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  final ExcepcionFestivoEntity? item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final ExcepcionFestivoEntity? e = item;
    if (e == null) {
      return const GestionDetailEmpty(message: 'Selecciona un festivo o excepción para ver su ficha');
    }
    return GestionDetailPanel(
      key: ValueKey<String>(e.id),
      title: e.nombre,
      badges: <Widget>[
        ExcepcionTipoDot(tipo: e.tipo),
        ExcepcionEstadoDot(activo: e.activo),
      ],
      tabs: <GestionDetailTab>[
        GestionDetailTab(label: 'General', child: _ExcepcionGeneralTab(item: e)),
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

class _ExcepcionGeneralTab extends StatelessWidget {
  const _ExcepcionGeneralTab({required this.item});

  final ExcepcionFestivoEntity item;

  @override
  Widget build(BuildContext context) {
    final ExcepcionFestivoEntity e = item;
    return GestionDetailBody(
      children: <Widget>[
        const GestionDetailSection(title: 'Datos'),
        GestionDetailField(label: 'Nombre', value: e.nombre),
        GestionDetailField(label: 'Fecha', value: GestionFormatters.fecha(e.fecha)),
        GestionDetailField(label: 'Tipo', child: ExcepcionTipoDot(tipo: e.tipo)),
        const GestionDetailSection(title: 'Comportamiento'),
        GestionDetailField(label: 'Repetir anual', value: e.repetirAnualmente ? 'Sí' : 'No'),
        GestionDetailField(label: 'Afecta dotac.', value: e.afectaDotaciones ? 'Sí' : 'No'),
        GestionDetailField(label: 'Estado', child: ExcepcionEstadoDot(activo: e.activo)),
        const GestionDetailSection(title: 'Descripción'),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(
            GestionFormatters.texto(e.descripcion),
            style: TextStyle(
              fontSize: 12.5,
              height: 1.4,
              color: e.descripcion?.trim().isNotEmpty ?? false ? AppColors.gray800 : AppColors.gray300,
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
