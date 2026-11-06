import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/bloc/stock_equipamiento/stock_equipamiento_bloc.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/bloc/stock_equipamiento/stock_equipamiento_state.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/widgets/gestion/stock_equipamiento_detail_panel.dart';
import 'package:ambutrack_web/features/vehiculos/widgets/gestion/flota_gestion_common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Pestaña "Equipamiento" de la ficha del vehículo: resumen y acceso a la dotación
class VehiculoStockTab extends StatelessWidget {
  const VehiculoStockTab({required this.vehiculoId, required this.onOpenStock, super.key});

  final String vehiculoId;
  final VoidCallback onOpenStock;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StockEquipamientoBloc, StockEquipamientoState>(
      builder: (BuildContext context, StockEquipamientoState state) {
        final List<VehiculoStockResumenEntity>? resumenes = state is StockEquipamientoLoaded
            ? state.vehiculos
            : state is StockEquipamientoError
                ? state.previousVehiculos
                : null;
        if (resumenes == null && state is StockEquipamientoError) {
          return FlotaEmptyNote(state.message);
        }
        if (resumenes == null) {
          return const FlotaTabLoading();
        }
        VehiculoStockResumenEntity? resumen;
        for (final VehiculoStockResumenEntity r in resumenes) {
          if (r.vehiculoId == vehiculoId) {
            resumen = r;
          }
        }
        return GestionDetailBody(
          children: <Widget>[
            if (resumen == null)
              const FlotaEmptyNote('No hay información de stock para este vehículo')
            else
              StockResumenFields(resumen: resumen),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: FlotaPanelButton(
                icon: Icons.medical_services_outlined,
                label: 'Abrir equipamiento del vehículo',
                onPressed: onOpenStock,
              ),
            ),
          ],
        );
      },
    );
  }
}
