import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/theme/app_text_styles.dart';
import 'package:ambutrack_web/core/widgets/tables/app_data_grid_v5.dart';
import 'package:flutter/material.dart';

/// Tabla de registros de consumo de combustible
class ConsumoDataTable extends StatelessWidget {
  const ConsumoDataTable({
    required this.registros,
    required this.vehiculos,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  final List<ConsumoCombustibleEntity> registros;
  final List<VehiculoEntity> vehiculos;
  final void Function(ConsumoCombustibleEntity) onEdit;
  final void Function(ConsumoCombustibleEntity) onDelete;

  String _getVehiculoMatricula(String vehiculoId) {
    final VehiculoEntity? vehiculo = vehiculos.where((VehiculoEntity v) => v.id == vehiculoId).firstOrNull;
    return vehiculo?.matricula ?? 'N/A';
  }

  @override
  Widget build(BuildContext context) {
    final List<DataGridColumn> columns = <DataGridColumn>[
      const DataGridColumn(
        label: 'Fecha',
        fixedWidth: 120,
      ),
      const DataGridColumn(
        label: 'Vehículo',
        fixedWidth: 150,
      ),
      const DataGridColumn(
        label: 'KM Vehículo',
        fixedWidth: 120,
      ),
      const DataGridColumn(
        label: 'Tipo Combustible',
        fixedWidth: 120,
      ),
      const DataGridColumn(
        label: 'Litros',
        fixedWidth: 100,
      ),
      const DataGridColumn(
        label: 'Costo (€)',
        fixedWidth: 100,
      ),
      const DataGridColumn(
        label: 'L/100km',
        fixedWidth: 100,
      ),
      const DataGridColumn(
        label: 'Acciones',
        fixedWidth: 120,
      ),
    ];

    return AppDataGridV5<ConsumoCombustibleEntity>(
      columns: columns,
      rows: registros,
      buildCells: (ConsumoCombustibleEntity consumo) => <DataGridCell>[
        DataGridCell(
          child: Text(
            _formatDate(consumo.fecha),
            style: AppTextStyles.bodySmall,
          ),
        ),
        DataGridCell(
          child: Text(
            _getVehiculoMatricula(consumo.vehiculoId),
            style: AppTextStyles.bodySmall,
          ),
        ),
        DataGridCell(
          child: Text(
            '${consumo.kmVehiculo.toStringAsFixed(0)} km',
            style: AppTextStyles.bodySmall,
          ),
        ),
        DataGridCell(
          child: _buildTipoCombustibleBadge(consumo.tipoCombustible),
        ),
        DataGridCell(
          child: Text(
            '${consumo.litros.toStringAsFixed(1)} L',
            style: AppTextStyles.bodySmall,
          ),
        ),
        DataGridCell(
          child: Text(
            '${consumo.costoTotal.toStringAsFixed(2)} €',
            style: AppTextStyles.bodySmall,
          ),
        ),
        DataGridCell(
          child: consumo.consumoL100km != null
              ? Text(
                  '${consumo.consumoL100km!.toStringAsFixed(1)} L/100km',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: _getConsumoColor(consumo.consumoL100km!),
                  ),
                )
              : Text(
                  '-',
                  style: AppTextStyles.bodySmall,
                ),
        ),
      ],
      onEdit: onEdit,
      onDelete: onDelete,
      emptyMessage: 'No hay registros de consumo',
      headerColor: AppColors.warning.withValues(alpha: 0.1),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildTipoCombustibleBadge(String tipo) {
    Color color;
    String label;

    switch (tipo.toLowerCase()) {
      case 'gasolina95':
        color = AppColors.info;
        label = 'Gasolina 95';
        break;
      case 'gasolina98':
        color = AppColors.primary;
        label = 'Gasolina 98';
        break;
      case 'diesel':
        color = AppColors.warning;
        label = 'Diesel';
        break;
      case 'electrico':
        color = AppColors.success;
        label = 'Eléctrico';
        break;
      case 'hibrido':
        color = AppColors.secondary;
        label = 'Híbrido';
        break;
      default:
        color = AppColors.gray500;
        label = tipo;
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: IntrinsicWidth(
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.spacingSmall,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
            border: Border.all(
              color: color.withValues(alpha: 0.3),
            ),
          ),
          child: Text(
            label,
            style: AppTextStyles.badgeDark.copyWith(
              color: color,
            ),
          ),
        ),
      ),
    );
  }

  Color _getConsumoColor(double consumo) {
    if (consumo < 8.0) {
      return AppColors.success;
    } else if (consumo < 10.0) {
      return AppColors.warning;
    } else {
      return AppColors.error;
    }
  }
}
