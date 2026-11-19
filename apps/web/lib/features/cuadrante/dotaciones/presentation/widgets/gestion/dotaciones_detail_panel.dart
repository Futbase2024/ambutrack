import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/cuadrante/dotaciones/presentation/widgets/gestion/dotaciones_catalogos.dart';
import 'package:ambutrack_web/features/cuadrante/dotaciones/presentation/widgets/gestion/dotaciones_gestion_columns.dart';
import 'package:flutter/material.dart';

/// Ficha lateral de la dotación seleccionada
class DotacionesDetailPanel extends StatelessWidget {
  const DotacionesDetailPanel({
    required this.dotacion,
    required this.catalogos,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  final DotacionEntity? dotacion;
  final DotacionesCatalogos catalogos;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final DotacionEntity? d = dotacion;
    if (d == null) {
      return const GestionDetailEmpty(message: 'Selecciona una dotación para ver su ficha');
    }
    return GestionDetailPanel(
      key: ValueKey<String>(d.id),
      title: d.nombre,
      badges: <Widget>[
        GestionDotLabel(label: d.tipoDestino, color: dotacionDestinoColor(d.tipoDestino)),
        DotacionEstadoDot(activo: d.activo),
      ],
      tabs: <GestionDetailTab>[
        GestionDetailTab(label: 'General', child: _DotacionGeneralTab(dotacion: d, catalogos: catalogos)),
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

class _DotacionGeneralTab extends StatelessWidget {
  const _DotacionGeneralTab({required this.dotacion, required this.catalogos});

  final DotacionEntity dotacion;
  final DotacionesCatalogos catalogos;

  @override
  Widget build(BuildContext context) {
    final DotacionEntity d = dotacion;
    final bool vigente = d.esVigenteEn(DateTime.now());
    return GestionDetailBody(
      children: <Widget>[
        const GestionDetailSection(title: 'Identificación'),
        GestionDetailField(label: 'Código', value: d.codigo),
        GestionDetailField(label: 'Nombre', value: d.nombre),
        GestionDetailField(label: 'Descripción', value: d.descripcion),
        const GestionDetailSection(title: 'Destino y recursos'),
        GestionDetailField(label: 'Tipo destino', value: d.tipoDestino),
        GestionDetailField(label: 'Destino', value: catalogos.destinoNombre(d)),
        GestionDetailField(label: 'Tipo vehículo', value: catalogos.tipoVehiculoNombre(d)),
        GestionDetailField(label: 'Unidades', value: '${d.cantidadUnidades}'),
        GestionDetailField(label: 'Prioridad', child: DotacionPrioridadDot(prioridad: d.prioridad)),
        GestionDetailField(label: 'Plantilla turno', value: d.plantillaTurnoId == null ? null : 'Asignada'),
        const GestionDetailSection(title: 'Vigencia'),
        GestionDetailField(label: 'Inicio', value: GestionFormatters.fecha(d.fechaInicio)),
        GestionDetailField(
          label: 'Fin',
          value: d.fechaFin == null ? 'Indefinido' : GestionFormatters.fecha(d.fechaFin),
        ),
        GestionDetailField(
          label: 'Situación',
          child: GestionDotLabel(
            label: vigente ? 'Vigente' : 'No vigente',
            color: vigente ? AppColors.success : AppColors.error,
          ),
        ),
        GestionDetailField(
          label: 'Días',
          value: d.diasAplicables.length == 7 ? 'Todos los días' : d.diasAplicables.join(', '),
        ),
        const GestionDetailSection(title: 'Registro'),
        GestionDetailField(label: 'Estado', child: DotacionEstadoDot(activo: d.activo)),
        GestionDetailField(label: 'Alta', value: GestionFormatters.fecha(d.createdAt)),
        GestionDetailField(label: 'Modificado', value: GestionFormatters.fecha(d.updatedAt)),
      ],
    );
  }
}
