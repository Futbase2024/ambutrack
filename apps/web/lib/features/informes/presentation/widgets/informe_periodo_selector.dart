import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_filter_bar.dart';
import 'package:ambutrack_web/features/informes/domain/informe_filtro.dart';
import 'package:flutter/material.dart';

/// Selector de periodo: desplegable de periodos + rango de fechas editable
class InformePeriodoSelector extends StatelessWidget {
  const InformePeriodoSelector({
    required this.filtro,
    required this.onChanged,
    super.key,
  });

  final InformeFiltro filtro;
  final ValueChanged<InformeFiltro> onChanged;

  Future<void> _elegirRango(BuildContext context) async {
    final DateTime hoy = DateTime.now();
    final DateTimeRange? rango = await showDateRangePicker(
      context: context,
      firstDate: DateTime(hoy.year - 10),
      lastDate: DateTime(hoy.year + 1, 12, 31),
      initialDateRange: DateTimeRange(start: filtro.desde, end: filtro.hasta),
      helpText: 'Selecciona el periodo del informe',
      saveText: 'Aplicar',
    );
    if (rango != null) {
      onChanged(filtro.conRango(rango.start, rango.end));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        GestionFilterDropdown<InformePeriodo>(
          label: 'Periodo',
          value: filtro.periodo,
          options: <InformePeriodo, String>{
            for (final InformePeriodo p in InformePeriodo.values) p: p.label,
          },
          onChanged: (InformePeriodo p) {
            if (p == InformePeriodo.personalizado) {
              _elegirRango(context);
            } else {
              onChanged(filtro.conPeriodo(p));
            }
          },
        ),
        const SizedBox(width: 6),
        Tooltip(
          message: 'Elegir fechas',
          child: InkWell(
            onTap: () => _elegirRango(context),
            borderRadius: BorderRadius.circular(6),
            child: Container(
              height: 32,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.gray300),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Icon(Icons.date_range, size: 15, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Text(
                    filtro.etiqueta,
                    style: const TextStyle(fontSize: 13, color: AppColors.gray900),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
