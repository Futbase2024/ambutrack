import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/tablas/plantillas_equipamiento/presentation/widgets/plantilla_items_columns.dart';
import 'package:ambutrack_web/features/vehiculos/widgets/gestion/flota_gestion_common.dart';
import 'package:flutter/material.dart';

/// Ficha lateral del item de plantilla seleccionado
class PlantillaItemDetailPanel extends StatelessWidget {
  const PlantillaItemDetailPanel({
    required this.item,
    required this.plantilla,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  final PlantillaEquipamientoItemEntity? item;
  final PlantillaEquipamientoEntity? plantilla;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final PlantillaEquipamientoItemEntity? i = item;
    if (i == null) {
      return _PlantillaResumen(plantilla: plantilla);
    }
    return GestionDetailPanel(
      key: ValueKey<String>(i.id),
      title: GestionFormatters.texto(i.productoNombre),
      badges: <Widget>[ItemEstadoDot(item: i)],
      tabs: <GestionDetailTab>[
        GestionDetailTab(
          label: 'General',
          child: GestionDetailBody(
            children: <Widget>[
              const GestionDetailSection(title: 'Item'),
              GestionDetailField(label: 'Código', value: i.productoCodigo),
              GestionDetailField(label: 'Tipo', value: itemTipoLabel(i)),
              GestionDetailField(label: 'Sección', value: i.seccion),
              GestionDetailField(label: 'Orden', value: '${i.orden}'),
              const GestionDetailSection(title: 'Requisitos en cada vehículo'),
              GestionDetailField(label: 'Cantidad', value: '${i.cantidadRequerida}'),
              GestionDetailField(label: 'Requisito', value: i.obligatorio ? 'Obligatorio' : 'Opcional'),
              GestionDetailField(label: 'Caducidad', value: i.requiereCaducidad ? 'Se registra' : 'No aplica'),
              GestionDetailField(label: 'Adjunto', value: i.requiereAdjunto ? 'Obligatorio' : 'No'),
              const GestionDetailSection(title: 'Notas'),
              FlotaNotes(i.notas),
            ],
          ),
        ),
      ],
      actions: <Widget>[
        FlotaPanelButton.edit(onPressed: onEdit),
        FlotaPanelButton.delete(onPressed: onDelete),
      ],
    );
  }
}

/// Resumen de la plantilla cuando no hay item seleccionado
class _PlantillaResumen extends StatelessWidget {
  const _PlantillaResumen({required this.plantilla});

  final PlantillaEquipamientoEntity? plantilla;

  @override
  Widget build(BuildContext context) {
    final PlantillaEquipamientoEntity? p = plantilla;
    if (p == null) {
      return const GestionDetailEmpty(message: 'Crea una plantilla con "Nueva plantilla"');
    }
    return GestionDetailPanel(
      key: ValueKey<String>('plantilla-${p.id}'),
      title: p.nombre,
      badges: <Widget>[
        GestionDotLabel(
          label: p.activo ? 'Activa' : 'Inactiva',
          color: p.activo ? AppColors.success : AppColors.gray500,
        ),
      ],
      tabs: <GestionDetailTab>[
        GestionDetailTab(
          label: 'Plantilla',
          child: GestionDetailBody(
            children: <Widget>[
              const GestionDetailSection(title: 'Aplicación'),
              GestionDetailField(label: 'Tipos', value: p.tiposVehiculo.join(', ')),
              GestionDetailField(label: 'Items', value: p.numItems?.toString()),
              GestionDetailField(
                label: 'Versión',
                value: p.fechaVersion == null ? null : GestionFormatters.fecha(p.fechaVersion),
              ),
              const GestionDetailSection(title: 'Descripción'),
              FlotaNotes(p.descripcion),
              const SizedBox(height: 8),
              const FlotaEmptyNote('Selecciona un item para ver o editar sus requisitos'),
            ],
          ),
        ),
      ],
    );
  }
}
