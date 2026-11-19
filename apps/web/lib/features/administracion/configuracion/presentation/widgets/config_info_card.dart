import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:flutter/material.dart';

/// Par etiqueta/valor de una tarjeta de configuración
class ConfigInfoRow {
  const ConfigInfoRow(this.label, this.value);

  final String label;
  final String? value;
}

/// Tarjeta de solo lectura con un bloque de parámetros
class ConfigInfoCard extends StatelessWidget {
  const ConfigInfoCard({
    required this.title,
    required this.icon,
    required this.rows,
    this.footer,
    this.color = AppColors.primary,
    super.key,
  });

  final String title;
  final IconData icon;
  final List<ConfigInfoRow> rows;
  final String? footer;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: const BoxDecoration(
              color: AppColors.gray50,
              border: Border(bottom: BorderSide(color: AppColors.gray200)),
            ),
            child: Row(
              children: <Widget>[
                Icon(icon, size: 18, color: color),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.gray900),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 10),
            child: Column(
              children: <Widget>[
                for (final ConfigInfoRow r in rows)
                  GestionDetailField(label: r.label, value: r.value, labelWidth: 130),
                if (footer != null) ...<Widget>[
                  const SizedBox(height: 6),
                  Text(
                    footer!,
                    style: const TextStyle(fontSize: 11.5, height: 1.35, color: AppColors.gray500),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
