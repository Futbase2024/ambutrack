import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_sizes.dart';

/// Buscador + lista de vehículos operativos para iniciar turno
class SelectorVehiculoLista extends StatelessWidget {
  const SelectorVehiculoLista({
    required this.vehiculos,
    required this.seleccionado,
    required this.onSeleccionar,
    required this.onFiltrar,
    super.key,
  });

  final List<VehiculoEntity> vehiculos;
  final VehiculoEntity? seleccionado;
  final ValueChanged<VehiculoEntity> onSeleccionar;
  final ValueChanged<String> onFiltrar;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        TextField(
          onChanged: onFiltrar,
          textInputAction: TextInputAction.search,
          textCapitalization: TextCapitalization.characters,
          decoration: InputDecoration(
            hintText: 'Buscar matrícula o nº interno',
            prefixIcon: const Icon(Icons.search_rounded),
            isDense: true,
            filled: true,
            fillColor: AppColors.gray50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
              borderSide: const BorderSide(color: AppColors.gray300),
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (vehiculos.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Text(
              'No hay vehículos que coincidan',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.gray600),
            ),
          ),
        ...vehiculos.map(
          (VehiculoEntity v) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _VehiculoItem(
              vehiculo: v,
              seleccionado: v.id == seleccionado?.id,
              onTap: () => onSeleccionar(v),
            ),
          ),
        ),
      ],
    );
  }
}

class _VehiculoItem extends StatelessWidget {
  const _VehiculoItem({required this.vehiculo, required this.seleccionado, required this.onTap});

  final VehiculoEntity vehiculo;
  final bool seleccionado;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color color = seleccionado ? AppColors.primary : AppColors.gray600;
    final String interno = vehiculo.numeroInterno?.isNotEmpty ?? false ? 'Nº ${vehiculo.numeroInterno} · ' : '';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: seleccionado ? AppColors.primarySurface : Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          border: Border.all(color: seleccionado ? AppColors.primary : AppColors.gray300, width: seleccionado ? 2 : 1),
        ),
        child: Row(
          children: <Widget>[
            Icon(Icons.local_shipping_rounded, color: color),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    vehiculo.matricula,
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: seleccionado ? AppColors.primary : AppColors.gray900),
                  ),
                  Text(
                    '$interno${vehiculo.marca} ${vehiculo.modelo}'.trim(),
                    style: const TextStyle(fontSize: 12, color: AppColors.gray600),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (seleccionado) const Icon(Icons.check_circle_rounded, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}
