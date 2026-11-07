import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:flutter/material.dart';

/// Filtro de fecha compacto con etiqueta delante: "Desde: [dd/mm/aaaa ×]"
class FichajesDateFilter extends StatelessWidget {
  const FichajesDateFilter({
    required this.label,
    required this.value,
    required this.onChanged,
    this.firstDate,
    super.key,
  });

  final String label;
  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;

  /// Fecha mínima seleccionable (por defecto 01/01/2020)
  final DateTime? firstDate;

  Future<void> _pick(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime first = firstDate ?? DateTime(2020);
    DateTime initial = value ?? now;
    if (initial.isBefore(first)) {
      initial = first;
    }
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: first,
      lastDate: now,
      locale: const Locale('es', 'ES'),
    );
    if (picked != null) {
      onChanged(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final DateTime? v = value;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text('$label:', style: const TextStyle(fontSize: 12.5, color: AppColors.gray600)),
        const SizedBox(width: 6),
        InkWell(
          onTap: () => _pick(context),
          borderRadius: BorderRadius.circular(6),
          child: Container(
            height: 32,
            padding: const EdgeInsets.only(left: 10, right: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.gray300),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  v == null ? 'Cualquiera' : GestionFormatters.fecha(v),
                  style: TextStyle(
                    fontSize: 13,
                    color: v == null ? AppColors.gray500 : AppColors.gray900,
                  ),
                ),
                const SizedBox(width: 6),
                if (v == null)
                  const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.gray500)
                else
                  InkWell(
                    onTap: () => onChanged(null),
                    child: const Icon(Icons.close, size: 14, color: AppColors.gray500),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
