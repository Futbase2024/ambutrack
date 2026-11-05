import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:flutter/material.dart';

/// Filtro de fecha compacto para la barra de filtros: "Desde: [dd/mm/aaaa ×]"
class FlotaDateFilter extends StatelessWidget {
  const FlotaDateFilter({
    required this.label,
    required this.value,
    required this.onChanged,
    super.key,
  });

  final String label;
  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;

  Future<void> _pick(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: value ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('es', 'ES'),
    );
    if (picked != null) {
      onChanged(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool hasValue = value != null;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text('$label:', style: const TextStyle(fontSize: 12.5, color: AppColors.gray600)),
        const SizedBox(width: 6),
        Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
          child: InkWell(
            onTap: () => _pick(context),
            borderRadius: BorderRadius.circular(6),
            child: Container(
              height: 32,
              padding: const EdgeInsets.only(left: 10, right: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.gray300),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.gray500),
                  const SizedBox(width: 6),
                  Text(
                    hasValue ? GestionFormatters.fecha(value) : 'Cualquiera',
                    style: TextStyle(
                      fontSize: 13,
                      color: hasValue ? AppColors.gray900 : AppColors.gray400,
                    ),
                  ),
                  if (hasValue)
                    InkWell(
                      onTap: () => onChanged(null),
                      child: const Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(Icons.close, size: 14, color: AppColors.gray500),
                      ),
                    )
                  else
                    const SizedBox(width: 6),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
