import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Barra de filtros compacta (una sola línea)
class GestionFilterBar extends StatelessWidget {
  const GestionFilterBar({required this.children, super.key});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: const BoxDecoration(
        color: AppColors.gray50,
        border: Border(bottom: BorderSide(color: AppColors.gray200)),
      ),
      // Si no cabe en una línea, se desplaza en horizontal en lugar de desbordarse
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: <Widget>[
            for (int i = 0; i < children.length; i++) ...<Widget>[
              if (i > 0) const SizedBox(width: 12),
              children[i],
            ],
          ],
        ),
      ),
    );
  }
}

/// Campo de búsqueda compacto (32px de alto)
class GestionSearchField extends StatelessWidget {
  const GestionSearchField({
    required this.controller,
    required this.onChanged,
    this.hint = 'Buscar...',
    this.width = 300,
    super.key,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String hint;
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: 32,
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: const TextStyle(fontSize: 13),
        decoration: InputDecoration(
          isDense: true,
          filled: true,
          fillColor: Colors.white,
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 13, color: AppColors.gray400),
          prefixIcon: const Icon(Icons.search, size: 16, color: AppColors.gray500),
          prefixIconConstraints: const BoxConstraints(minWidth: 32),
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
          enabledBorder: _border(AppColors.gray300),
          focusedBorder: _border(AppColors.primary),
        ),
      ),
    );
  }

  static OutlineInputBorder _border(Color color) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: BorderSide(color: color),
      );
}

/// Desplegable compacto con etiqueta delante: "Tipo: [Todos ▾]"
class GestionFilterDropdown<T> extends StatelessWidget {
  const GestionFilterDropdown({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
    super.key,
  });

  final String label;
  final T value;

  /// Valor → texto visible
  final Map<T, String> options;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          '$label:',
          style: const TextStyle(fontSize: 12.5, color: AppColors.gray600),
        ),
        const SizedBox(width: 6),
        Container(
          height: 32,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: AppColors.gray300),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              isDense: true,
              focusColor: Colors.transparent,
              icon: const Icon(Icons.expand_more, size: 16),
              style: const TextStyle(fontSize: 13, color: AppColors.gray900),
              items: options.entries
                  .map(
                    (MapEntry<T, String> e) => DropdownMenuItem<T>(
                      value: e.key,
                      child: Text(e.value),
                    ),
                  )
                  .toList(),
              onChanged: (T? v) {
                if (v != null) {
                  onChanged(v);
                }
              },
            ),
          ),
        ),
      ],
    );
  }
}

/// Botón "Limpiar filtros"
class GestionClearFiltersButton extends StatelessWidget {
  const GestionClearFiltersButton({required this.onPressed, super.key});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.filter_alt_off_outlined, size: 16),
      label: const Text('Limpiar', style: TextStyle(fontSize: 13)),
      style: TextButton.styleFrom(
        foregroundColor: AppColors.gray600,
        minimumSize: const Size(0, 32),
        padding: const EdgeInsets.symmetric(horizontal: 8),
      ),
    );
  }
}
