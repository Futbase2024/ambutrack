import 'package:flutter/material.dart';

/// Indicador sobrio de estado/tipo: punto de color + texto
class GestionDotLabel extends StatelessWidget {
  const GestionDotLabel({
    required this.label,
    required this.color,
    this.fontSize = 12.5,
    super.key,
  });

  final String label;
  final Color color;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}
