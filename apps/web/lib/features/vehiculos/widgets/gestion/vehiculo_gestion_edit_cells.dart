import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/features/vehiculos/widgets/gestion/vehiculo_gestion_columns.dart';
import 'package:flutter/material.dart';

/// Casilla Sí/No editable con un clic (CAP, silla eléctrica...)
class VehiculoFlagEditCell extends StatelessWidget {
  const VehiculoFlagEditCell({required this.value, required this.onChanged, super.key});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Tooltip(
        message: value ? 'Pulsa para quitar' : 'Pulsa para marcar',
        waitDuration: const Duration(milliseconds: 500),
        child: InkWell(
          onTap: () => onChanged(!value),
          borderRadius: BorderRadius.circular(4),
          child: Padding(
            padding: const EdgeInsets.all(2),
            child: Icon(
              value ? Icons.check_box : Icons.check_box_outline_blank,
              size: 20,
              color: value ? AppColors.success : AppColors.gray400,
            ),
          ),
        ),
      ),
    );
  }
}

/// Estado del vehículo con menú desplegable para cambiarlo
class VehiculoEstadoEditCell extends StatelessWidget {
  const VehiculoEstadoEditCell({required this.estado, required this.onChanged, super.key});

  final VehiculoEstado estado;
  final ValueChanged<VehiculoEstado> onChanged;

  @override
  Widget build(BuildContext context) {
    return VehiculoEstadoMenu(
      tooltip: 'Cambiar estado',
      onSelected: (VehiculoEstado e) {
        if (e != estado) {
          onChanged(e);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.gray300),
          borderRadius: BorderRadius.circular(4),
          color: Colors.white,
        ),
        child: Row(
          children: <Widget>[
            Expanded(child: VehiculoEstadoDot(estado: estado)),
            const Icon(Icons.arrow_drop_down, size: 18, color: AppColors.gray500),
          ],
        ),
      ),
    );
  }
}

/// Número de carros con menú desplegable (1 a 4)
class VehiculoCarrosEditCell extends StatelessWidget {
  const VehiculoCarrosEditCell({required this.carros, required this.onChanged, super.key});

  final int? carros;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return VehiculoCarrosMenu(
      onSelected: (int n) {
        if (n != carros) {
          onChanged(n);
        }
      },
      child: Container(
        padding: const EdgeInsets.only(left: 8, top: 3, bottom: 3),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.gray300),
          borderRadius: BorderRadius.circular(4),
          color: Colors.white,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              carros == null ? '—' : '$carros',
              style: TextStyle(color: carros == null ? AppColors.gray400 : AppColors.gray900),
            ),
            const Icon(Icons.arrow_drop_down, size: 18, color: AppColors.gray500),
          ],
        ),
      ),
    );
  }
}

/// Menú con el número de carros (1 a 4)
class VehiculoCarrosMenu extends StatelessWidget {
  const VehiculoCarrosMenu({required this.onSelected, required this.child, super.key});

  final ValueChanged<int> onSelected;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<int>(
      tooltip: 'Cambiar número de carros',
      onSelected: onSelected,
      position: PopupMenuPosition.under,
      itemBuilder: (BuildContext _) => <PopupMenuEntry<int>>[
        for (int n = 1; n <= 4; n++)
          PopupMenuItem<int>(value: n, height: 36, child: Text(n == 1 ? '1 carro' : '$n carros')),
      ],
      child: child,
    );
  }
}

/// Menú con los estados del vehículo
class VehiculoEstadoMenu extends StatelessWidget {
  const VehiculoEstadoMenu({required this.onSelected, required this.child, this.tooltip, super.key});

  final ValueChanged<VehiculoEstado> onSelected;
  final Widget child;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<VehiculoEstado>(
      tooltip: tooltip,
      onSelected: onSelected,
      position: PopupMenuPosition.under,
      itemBuilder: (BuildContext _) => <PopupMenuEntry<VehiculoEstado>>[
        for (final VehiculoEstado e in VehiculoEstado.values)
          PopupMenuItem<VehiculoEstado>(
            value: e,
            height: 36,
            child: VehiculoEstadoDot(estado: e),
          ),
      ],
      child: child,
    );
  }
}
