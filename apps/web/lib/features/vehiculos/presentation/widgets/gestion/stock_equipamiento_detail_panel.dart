import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/widgets/gestion/stock_equipamiento_gestion_columns.dart';
import 'package:ambutrack_web/features/vehiculos/widgets/gestion/flota_gestion_common.dart';
import 'package:ambutrack_web/features/vehiculos/widgets/gestion/vehiculo_gestion_columns.dart';
import 'package:flutter/material.dart';

/// Ficha lateral del resumen de stock del vehículo seleccionado
class StockEquipamientoDetailPanel extends StatelessWidget {
  const StockEquipamientoDetailPanel({
    required this.resumen,
    required this.onVer,
    required this.onAdd,
    super.key,
  });

  final VehiculoStockResumenEntity? resumen;
  final VoidCallback onVer;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final VehiculoStockResumenEntity? r = resumen;
    if (r == null) {
      return const GestionDetailEmpty(message: 'Selecciona un vehículo para ver su stock');
    }
    return GestionDetailPanel(
      key: ValueKey<String>(r.vehiculoId),
      title: '${r.matricula} · ${r.marca} ${r.modelo}',
      badges: <Widget>[
        StockGeneralDot(estado: r.estadoGeneral),
        VehiculoEstadoDot(estado: r.estadoVehiculo),
      ],
      tabs: <GestionDetailTab>[
        GestionDetailTab(
          label: 'General',
          child: GestionDetailBody(
            children: <Widget>[
              const GestionDetailSection(title: 'Vehículo'),
              GestionDetailField(label: 'Matrícula', value: r.matricula),
              GestionDetailField(label: 'Marca', value: r.marca),
              GestionDetailField(label: 'Modelo', value: r.modelo),
              GestionDetailField(label: 'Tipo', value: r.tipoVehiculo),
              GestionDetailField(label: 'Estado', child: VehiculoEstadoDot(estado: r.estadoVehiculo)),
              StockResumenFields(resumen: r),
            ],
          ),
        ),
      ],
      actions: <Widget>[
        FlotaPanelButton(
          icon: Icons.visibility_outlined,
          label: 'Ver equipamiento',
          color: AppColors.info,
          onPressed: onVer,
        ),
        FlotaPanelButton(
          icon: Icons.add,
          label: 'Añadir item',
          color: AppColors.success,
          onPressed: onAdd,
        ),
      ],
    );
  }
}

/// Bloque de la ficha con los contadores de stock de un vehículo
class StockResumenFields extends StatelessWidget {
  const StockResumenFields({required this.resumen, super.key});

  final VehiculoStockResumenEntity resumen;

  @override
  Widget build(BuildContext context) {
    final VehiculoStockResumenEntity r = resumen;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const GestionDetailSection(title: 'Stock'),
        GestionDetailField(label: 'Estado', child: StockGeneralDot(estado: r.estadoGeneral)),
        GestionDetailField(label: 'Total items', value: '${r.totalItems}'),
        GestionDetailField(label: 'Correctos', value: '${r.itemsOk}'),
        GestionDetailField(label: '% correcto', value: '${r.porcentajeOk.round()} %'),
        const GestionDetailSection(title: 'Alertas'),
        GestionDetailField(
          label: 'Caducados',
          child: StockCountCell(value: r.itemsCaducados, color: AppColors.error),
        ),
        GestionDetailField(
          label: 'Sin stock',
          child: StockCountCell(value: r.itemsSinStock, color: AppColors.error),
        ),
        GestionDetailField(
          label: 'Stock bajo',
          child: StockCountCell(value: r.itemsStockBajo, color: AppColors.warning),
        ),
        GestionDetailField(
          label: 'Próx. caducar',
          child: StockCountCell(value: r.itemsProximosCaducar, color: AppColors.warning),
        ),
        GestionDetailField(
          label: 'Con alerta',
          child: StockCountCell(value: r.itemsConAlerta, color: AppColors.warning),
        ),
      ],
    );
  }
}
