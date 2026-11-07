import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import 'estado_dotacion.dart';

/// Fila de un item: icono de estado, nombre, cantidad y caducidad
class EquipamientoLineaTile extends StatelessWidget {
  const EquipamientoLineaTile({required this.linea, required this.onTap, super.key});

  final StockVehiculoEntity linea;
  final VoidCallback onTap;

  static final DateFormat _fecha = DateFormat('dd/MM/yyyy');

  String get _detalle {
    if (linea.esDocumento) {
      final String presente = linea.cantidadActual > 0 ? 'SÍ está en la ambulancia' : 'NO está en la ambulancia';
      final String caducidad =
          linea.fechaCaducidad != null ? ' · Cad. ${_fecha.format(linea.fechaCaducidad!)}' : '';
      return '$presente$caducidad';
    }
    final String cantidad = !linea.obligatorio || linea.cantidadMinima == null
        ? '${linea.cantidadActual}${linea.obligatorio ? '' : ' (opcional)'}'
        : '${linea.cantidadActual}/${linea.cantidadMinima}';
    final String caducidad = linea.fechaCaducidad != null
        ? ' · Cad. ${_fecha.format(linea.fechaCaducidad!)}'
        : (linea.requiereCaducidad ? ' · Sin fecha' : '');
    return 'Cant. $cantidad$caducidad';
  }

  @override
  Widget build(BuildContext context) {
    final EstadoDotacion estado = EstadoDotacion.of(linea);
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      leading: Icon(estado.icon, color: estado.color, size: 28),
      title: Text(
        linea.productoNombre ?? 'Item',
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.gray900),
      ),
      subtitle: Text(_detalle, style: const TextStyle(fontSize: 13, color: AppColors.gray600)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (linea.esDocumento)
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: Icon(
                Icons.description_outlined,
                size: 18,
                color: linea.tieneAdjunto ? AppColors.success : AppColors.gray400,
              ),
            ),
          EstadoDotacionBadge(estado: estado),
        ],
      ),
    );
  }
}
