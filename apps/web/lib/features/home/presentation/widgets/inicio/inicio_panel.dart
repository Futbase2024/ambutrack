import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Panel con cabecera del dashboard de inicio (borde fino, estilo gestión)
class InicioPanel extends StatelessWidget {
  const InicioPanel({
    required this.title,
    required this.icon,
    required this.child,
    this.trailing,
    super.key,
  });

  final String title;
  final IconData icon;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: const BoxDecoration(
              color: AppColors.gray50,
              border: Border(bottom: BorderSide(color: AppColors.gray200)),
            ),
            child: Row(
              children: <Widget>[
                Icon(icon, size: 16, color: AppColors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.gray900),
                  ),
                ),
                if (trailing != null) ...<Widget>[
                  const SizedBox(width: 8),
                  Flexible(child: Align(alignment: Alignment.centerRight, child: trailing)),
                ],
              ],
            ),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}
