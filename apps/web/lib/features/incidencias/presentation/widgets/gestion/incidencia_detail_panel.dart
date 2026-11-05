import 'package:ambutrack_core_datasource/incidencias.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/incidencias/presentation/widgets/gestion/incidencia_gestion_columns.dart';
import 'package:flutter/material.dart';

/// Ficha lateral de la incidencia seleccionada
class IncidenciaDetailPanel extends StatelessWidget {
  const IncidenciaDetailPanel({
    required this.incidencia,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  final IncidenciaEntity? incidencia;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final IncidenciaEntity? i = incidencia;
    if (i == null) {
      return const GestionDetailEmpty(message: 'Selecciona una incidencia para ver su ficha');
    }
    return GestionDetailPanel(
      key: ValueKey<String>(i.id),
      title: i.titulo,
      badges: <Widget>[
        GestionDotLabel(label: i.estado.displayName, color: incidenciaEstadoColor(i.estado)),
        GestionDotLabel(label: i.prioridad.displayName, color: incidenciaPrioridadColor(i.prioridad)),
        GestionDotLabel(label: i.categoria.displayName, color: incidenciaCategoriaColor(i.categoria)),
      ],
      tabs: <GestionDetailTab>[
        GestionDetailTab(label: 'General', child: _IncidenciaGeneralTab(incidencia: i)),
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

class _IncidenciaGeneralTab extends StatelessWidget {
  const _IncidenciaGeneralTab({required this.incidencia});

  final IncidenciaEntity incidencia;

  @override
  Widget build(BuildContext context) {
    final IncidenciaEntity i = incidencia;
    return GestionDetailBody(
      children: <Widget>[
        const GestionDetailSection(title: 'Incidencia'),
        GestionDetailField(label: 'Categoría', value: i.categoria.displayName),
        GestionDetailField(label: 'Prioridad', value: i.prioridad.displayName),
        GestionDetailField(label: 'Estado', value: i.estado.displayName),
        GestionDetailField(label: 'Fecha', value: incidenciaFechaHora(i.fechaIncidencia)),
        GestionDetailField(label: 'Vehículo', value: i.vehiculoMatricula),
        const GestionDetailSection(title: 'Descripción'),
        IncidenciaDetailText(text: i.descripcion),
        const GestionDetailSection(title: 'Personas'),
        GestionDetailField(label: 'Responsable', value: i.responsableNombre),
        GestionDetailField(label: 'Reportado por', value: i.reportadoPorNombre),
        const GestionDetailSection(title: 'Resolución'),
        GestionDetailField(
          label: 'Fecha',
          value: i.fechaResolucion == null ? null : incidenciaFechaHora(i.fechaResolucion),
        ),
        IncidenciaDetailText(text: i.resolucion),
        const GestionDetailSection(title: 'Registro'),
        GestionDetailField(label: 'Alta', value: GestionFormatters.fecha(i.createdAt)),
        GestionDetailField(label: 'Modificado', value: GestionFormatters.fecha(i.updatedAt)),
      ],
    );
  }
}

/// Bloque de texto libre (descripción, resolución) con marcador de vacío
class IncidenciaDetailText extends StatelessWidget {
  const IncidenciaDetailText({required this.text, super.key});

  final String? text;

  @override
  Widget build(BuildContext context) {
    final bool empty = text?.trim().isEmpty ?? true;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        GestionFormatters.texto(text),
        style: TextStyle(
          fontSize: 12.5,
          height: 1.4,
          color: empty ? AppColors.gray300 : AppColors.gray800,
        ),
      ),
    );
  }
}
