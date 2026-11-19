import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Título de sección del formulario: "DATOS ──────────"
class GestionFormSection extends StatelessWidget {
  const GestionFormSection({required this.title, this.first = false, super.key});

  final String title;

  /// Sin margen superior (primera sección)
  final bool first;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: first ? 0 : 18, bottom: 10),
      child: Row(
        children: <Widget>[
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(child: Divider(height: 1, color: AppColors.gray200)),
        ],
      ),
    );
  }
}

/// Fila de formulario con la etiqueta a la izquierda y el campo a la derecha
class GestionFormRow extends StatelessWidget {
  const GestionFormRow({
    required this.label,
    required this.child,
    this.required = false,
    this.labelWidth = 118,
    this.multiline = false,
    super.key,
  });

  final String label;
  final Widget child;
  final bool required;
  final double labelWidth;

  /// Alinea la etiqueta arriba (áreas de texto)
  final bool multiline;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: labelWidth,
            child: Padding(
              padding: EdgeInsets.only(top: multiline ? 10 : 9, right: 8),
              child: Text.rich(
                TextSpan(
                  text: label,
                  children: <InlineSpan>[
                    if (required)
                      const TextSpan(text: ' *', style: TextStyle(color: AppColors.error)),
                  ],
                ),
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                  color: AppColors.gray600,
                ),
              ),
            ),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}

/// Dos (o más) columnas de filas, con separación estándar
class GestionFormColumns extends StatelessWidget {
  const GestionFormColumns({required this.children, this.spacing = 24, super.key});

  final List<Widget> children;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        for (int i = 0; i < children.length; i++) ...<Widget>[
          if (i > 0) SizedBox(width: spacing),
          Expanded(child: children[i]),
        ],
      ],
    );
  }
}

/// Valor de solo lectura con el mismo alto que un campo (p.ej. datos no editables)
class GestionFormReadOnly extends StatelessWidget {
  const GestionFormReadOnly({required this.value, super.key});

  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.gray50,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Text(
        value,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 13, color: AppColors.gray700, fontWeight: FontWeight.w500),
      ),
    );
  }
}
