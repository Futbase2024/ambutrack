import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../core/theme/app_colors.dart';

/// Selector de rango de fechas (desde / hasta) con el total de días
///
/// Si se pulsa "Hasta" sin fecha de inicio, se abre primero el selector de inicio.
class FechasRangoSelector extends StatelessWidget {
  const FechasRangoSelector({
    super.key,
    required this.inicio,
    required this.fin,
    required this.onChanged,
    required this.primeraFecha,
    this.enabled = true,
  });

  final DateTime? inicio;
  final DateTime? fin;
  final void Function(DateTime inicio, DateTime fin) onChanged;

  /// Primera fecha seleccionable como inicio
  final DateTime primeraFecha;
  final bool enabled;

  /// Días naturales incluidos en el rango (0 si está incompleto)
  static int diasEntre(DateTime? inicio, DateTime? fin) {
    if (inicio == null || fin == null) {
      return 0;
    }
    return DateUtils.dateOnly(fin).difference(DateUtils.dateOnly(inicio)).inDays + 1;
  }

  Future<DateTime?> _elegir(BuildContext context, DateTime inicial, DateTime primera) {
    return showDatePicker(
      context: context,
      initialDate: inicial.isBefore(primera) ? primera : inicial,
      firstDate: primera,
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('es', 'ES'),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.primary,
            onPrimary: Colors.white,
            surface: Colors.white,
            onSurface: AppColors.gray900,
          ),
        ),
        child: child!,
      ),
    );
  }

  Future<void> _elegirInicio(BuildContext context) async {
    final DateTime? fecha = await _elegir(context, inicio ?? DateTime.now(), primeraFecha);
    if (fecha == null) {
      return;
    }
    final DateTime? finActual = fin;
    onChanged(fecha, (finActual == null || finActual.isBefore(fecha)) ? fecha : finActual);
  }

  Future<void> _elegirFin(BuildContext context) async {
    final DateTime? inicioActual = inicio;
    if (inicioActual == null) {
      return _elegirInicio(context);
    }
    final DateTime? fecha = await _elegir(context, fin ?? inicioActual, inicioActual);
    if (fecha != null) {
      onChanged(inicioActual, fecha);
    }
  }

  @override
  Widget build(BuildContext context) {
    final int dias = diasEntre(inicio, fin);

    return Column(
      children: <Widget>[
        _FilaFecha(
          etiqueta: 'Desde',
          fecha: inicio,
          onTap: enabled ? () => _elegirInicio(context) : null,
        ),
        const Divider(height: 1, indent: 70, color: AppColors.gray100),
        _FilaFecha(
          etiqueta: 'Hasta',
          fecha: fin,
          onTap: enabled ? () => _elegirFin(context) : null,
        ),
        if (dias > 0) _ResumenDias(dias: dias),
      ],
    );
  }
}

/// Fila de una fecha del rango
class _FilaFecha extends StatelessWidget {
  const _FilaFecha({required this.etiqueta, required this.fecha, required this.onTap});

  final String etiqueta;
  final DateTime? fecha;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final DateTime? fecha = this.fecha;
    final String texto = fecha == null ? 'Seleccionar fecha' : DateFormat("EEEE, d 'de' MMMM yyyy", 'es').format(fecha);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: <Widget>[
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.calendar_today_outlined, size: 20, color: AppColors.primary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(etiqueta, style: const TextStyle(fontSize: 12, color: AppColors.gray500)),
                  const SizedBox(height: 2),
                  Text(
                    fecha == null ? texto : texto[0].toUpperCase() + texto.substring(1),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: fecha == null ? FontWeight.w400 : FontWeight.w600,
                      color: fecha == null ? AppColors.gray400 : AppColors.gray900,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.gray400),
          ],
        ),
      ),
    );
  }
}

/// Total de días del rango
class _ResumenDias extends StatelessWidget {
  const _ResumenDias({required this.dias});

  final int dias;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: AppColors.primarySurface,
      child: Row(
        children: <Widget>[
          const Icon(Icons.date_range_outlined, size: 18, color: AppColors.primary),
          const SizedBox(width: 8),
          const Expanded(
            child: Text('Total solicitado', style: TextStyle(fontSize: 14, color: AppColors.gray700)),
          ),
          Text(
            '$dias ${dias == 1 ? 'día' : 'días'} naturales',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}
