import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import 'estado_dotacion.dart';

/// Cabecera: matrícula, progreso de dotación y contadores por gravedad
class EquipamientoResumenHeader extends StatelessWidget {
  const EquipamientoResumenHeader({required this.matricula, required this.lineas, super.key});

  final String matricula;
  final List<StockVehiculoEntity> lineas;

  int _count(bool Function(EstadoDotacion e) test) =>
      lineas.where((StockVehiculoEntity l) => test(EstadoDotacion.of(l))).length;

  @override
  Widget build(BuildContext context) {
    final int total = lineas.length;
    final int ok = _count((EstadoDotacion e) => e == EstadoDotacion.ok);
    final int criticos = _count((EstadoDotacion e) => e.color == AppColors.error);
    final int avisos = _count((EstadoDotacion e) => e.color == AppColors.warning);
    final double progreso = total == 0 ? 0 : ok / total;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Icon(Icons.local_shipping_rounded, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  matricula,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.gray900),
                ),
              ),
              Text(
                '$ok / $total OK',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.gray700),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progreso,
              minHeight: 10,
              backgroundColor: AppColors.gray200,
              color: progreso == 1 ? AppColors.success : AppColors.secondary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              _Contador(color: AppColors.error, label: 'Críticos', valor: criticos),
              const SizedBox(width: 8),
              _Contador(color: AppColors.warning, label: 'Avisos', valor: avisos),
              const SizedBox(width: 8),
              _Contador(color: AppColors.success, label: 'OK', valor: ok),
            ],
          ),
        ],
      ),
    );
  }
}

class _Contador extends StatelessWidget {
  const _Contador({required this.color, required this.label, required this.valor});

  final Color color;
  final String label;
  final int valor;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: <Widget>[
            Text('$valor', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: color)),
            Text(label, style: TextStyle(fontSize: 12, color: color)),
          ],
        ),
      ),
    );
  }
}
