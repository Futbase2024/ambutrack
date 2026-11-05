import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion_frame/gestion_frame.dart';
import 'package:flutter/material.dart';

/// Navegador de rango de fechas: `‹ 01/10/2026 – 31/10/2026 ›`.
///
/// Las flechas desplazan el rango completo; el texto abre el selector.
class GestionDateRangeNavigator extends StatelessWidget {
  const GestionDateRangeNavigator({
    required this.range,
    required this.onChanged,
    super.key,
  });

  final DateTimeRange range;
  final ValueChanged<DateTimeRange> onChanged;

  void _shift(int sign) {
    final Duration span = range.end.difference(range.start) + const Duration(days: 1);
    onChanged(
      DateTimeRange(
        start: range.start.add(span * sign),
        end: range.end.add(span * sign),
      ),
    );
  }

  Future<void> _pick(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange: range,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      locale: const Locale('es', 'ES'),
      builder: (BuildContext context, Widget? child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.primary,
            onSurface: AppColors.textPrimaryLight,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      onChanged(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestionPeriodNavigator(
      label: '${GestionFormatters.fecha(range.start)} – ${GestionFormatters.fecha(range.end)}',
      previousTooltip: 'Periodo anterior',
      nextTooltip: 'Periodo siguiente',
      onPrevious: () => _shift(-1),
      onNext: () => _shift(1),
      onLabelTap: () => _pick(context),
    );
  }
}
