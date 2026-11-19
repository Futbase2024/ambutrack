import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/menu/app_menu.dart';

/// Sección de formulario: título en mayúsculas y tarjeta blanca con el contenido
class TramiteFormSeccion extends StatelessWidget {
  const TramiteFormSeccion({
    super.key,
    required this.titulo,
    required this.child,
    this.obligatorio = false,
    this.padding = const EdgeInsets.all(16),
  });

  final String titulo;
  final Widget child;
  final bool obligatorio;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          AppMenuSeccion(obligatorio ? '$titulo *' : titulo),
          Container(
            width: double.infinity,
            padding: padding,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.gray200),
            ),
            clipBehavior: Clip.antiAlias,
            child: child,
          ),
        ],
      ),
    );
  }
}

/// Campo de texto multilínea con el estilo de los formularios de trámites
class TramiteCampoTexto extends StatelessWidget {
  const TramiteCampoTexto({
    super.key,
    required this.controller,
    required this.hint,
    this.enabled = true,
    this.maxLines = 4,
    this.validator,
  });

  final TextEditingController controller;
  final String hint;
  final bool enabled;
  final int maxLines;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      minLines: 2,
      maxLines: maxLines,
      validator: validator,
      textInputAction: TextInputAction.newline,
      textCapitalization: TextCapitalization.sentences,
      style: const TextStyle(fontSize: 15, color: AppColors.gray900, height: 1.4),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.gray400, fontSize: 15),
        isDense: true,
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        focusedErrorBorder: InputBorder.none,
        contentPadding: EdgeInsets.zero,
      ),
    );
  }
}

/// Aviso informativo dentro de un formulario
class TramiteAviso extends StatelessWidget {
  const TramiteAviso({super.key, required this.texto, this.color = AppColors.info, this.icon = Icons.info_outline});

  final String texto;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(texto, style: const TextStyle(fontSize: 13, color: AppColors.gray700, height: 1.4)),
          ),
        ],
      ),
    );
  }
}
