import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import 'estado_dotacion.dart';

/// Cabecera del sheet: asa, nombre, sección y estado
class SheetCabecera extends StatelessWidget {
  const SheetCabecera({required this.linea, required this.estado, super.key});

  final StockVehiculoEntity linea;
  final EstadoDotacion estado;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Center(
          child: Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(color: AppColors.gray300, borderRadius: BorderRadius.circular(2)),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          linea.productoNombre ?? 'Item',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.gray900),
        ),
        const SizedBox(height: 6),
        Row(
          children: <Widget>[
            Expanded(
              child: Text(seccionDe(linea), style: const TextStyle(fontSize: 13, color: AppColors.gray600)),
            ),
            EstadoDotacionBadge(estado: estado),
          ],
        ),
      ],
    );
  }
}

/// Selector de cantidad con botones − / +
class SheetCantidad extends StatelessWidget {
  const SheetCantidad({required this.cantidad, required this.requerida, required this.onChanged, super.key});

  final int cantidad;
  final int? requerida;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final bool completa = requerida == null || cantidad >= requerida!;
    return Row(
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text('Cantidad', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              if (requerida != null)
                Text(
                  'Requerida: $requerida',
                  style: TextStyle(fontSize: 13, color: completa ? AppColors.success : AppColors.error),
                ),
            ],
          ),
        ),
        IconButton.filledTonal(
          onPressed: cantidad > 0 ? () => onChanged(cantidad - 1) : null,
          icon: const Icon(Icons.remove_rounded),
        ),
        SizedBox(
          width: 56,
          child: Text(
            '$cantidad',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: completa ? AppColors.gray900 : AppColors.error,
            ),
          ),
        ),
        IconButton.filledTonal(onPressed: () => onChanged(cantidad + 1), icon: const Icon(Icons.add_rounded)),
      ],
    );
  }
}

/// Fecha de caducidad con botón para elegir y para quitar
class SheetCaducidad extends StatelessWidget {
  const SheetCaducidad({
    required this.texto,
    required this.obligatoria,
    required this.onElegir,
    required this.onQuitar,
    super.key,
  });

  final String? texto;
  final bool obligatoria;
  final VoidCallback onElegir;
  final VoidCallback? onQuitar;

  @override
  Widget build(BuildContext context) {
    final Color color = texto == null && obligatoria ? AppColors.warning : AppColors.gray300;
    return Row(
      children: <Widget>[
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onElegir,
            icon: const Icon(Icons.event_rounded),
            label: Text(texto ?? (obligatoria ? 'Indicar caducidad (obligatoria)' : 'Indicar caducidad')),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: BorderSide(color: color),
              alignment: Alignment.centerLeft,
            ),
          ),
        ),
        if (onQuitar != null)
          IconButton(
            tooltip: 'Quitar fecha',
            onPressed: onQuitar,
            icon: const Icon(Icons.close_rounded, color: AppColors.gray500),
          ),
      ],
    );
  }
}

/// Campo de texto del sheet
class SheetTexto extends StatelessWidget {
  const SheetTexto({
    required this.controller,
    required this.label,
    required this.action,
    this.maxLines = 1,
    super.key,
  });

  final TextEditingController controller;
  final String label;
  final TextInputAction action;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      textInputAction: action,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
