import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Barra de filtros y búsqueda para el dashboard
///
/// Incluye campo de búsqueda, dropdown de estado y selector de fecha.
/// Sigue el diseño Material Design 3 con bordes sutiles y estados claros.
class DashboardFilterBar extends StatelessWidget {
  const DashboardFilterBar({
    super.key,
    this.searchHint = 'Buscar por paciente, ID o servicio...',
    this.onSearchChanged,
    this.onEstadoChanged,
    this.onFechaChanged,
    this.onClear,
    this.selectedEstado,
    this.selectedFecha,
  });

  final String searchHint;
  final ValueChanged<String>? onSearchChanged;
  final ValueChanged<String?>? onEstadoChanged;
  final ValueChanged<DateTime?>? onFechaChanged;
  final VoidCallback? onClear;
  final String? selectedEstado;
  final DateTime? selectedFecha;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.gray200,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return Wrap(
            spacing: 12,
            runSpacing: 12,
            children: <Widget>[
              // Campo de búsqueda
              SizedBox(
                width: constraints.maxWidth > 600 ? 350 : double.infinity,
                child: _SearchField(
                  hint: searchHint,
                  onChanged: onSearchChanged,
                ),
              ),
              // Dropdown de estado
              SizedBox(
                width: 140,
                child: _EstadoDropdown(
                  initialValue: selectedEstado,
                  onChanged: onEstadoChanged,
                ),
              ),
              // Selector de fecha
              SizedBox(
                width: 160,
                child: _FechaSelector(
                  value: selectedFecha,
                  onChanged: onFechaChanged,
                ),
              ),
              // Botón limpiar
              if (onClear != null)
                TextButton.icon(
                  onPressed: onClear,
                  icon: const Icon(
                    Icons.close,
                    size: 18,
                    color: AppColors.gray500,
                  ),
                  label: const Text(
                    'Limpiar',
                    style: TextStyle(
                      color: AppColors.gray500,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

/// Campo de búsqueda con icono
class _SearchField extends StatefulWidget {
  const _SearchField({
    required this.hint,
    this.onChanged,
  });

  final String hint;
  final ValueChanged<String>? onChanged;

  @override
  State<_SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<_SearchField> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      onChanged: widget.onChanged,
      decoration: InputDecoration(
        hintText: widget.hint,
        hintStyle: const TextStyle(
          color: AppColors.gray400,
          fontSize: 14,
        ),
        prefixIcon: const Icon(
          Icons.search,
          color: AppColors.gray400,
          size: 20,
        ),
        filled: true,
        fillColor: AppColors.gray50,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.gray200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.gray200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }
}

/// Dropdown para seleccionar estado
class _EstadoDropdown extends StatelessWidget {
  const _EstadoDropdown({
    this.initialValue,
    this.onChanged,
  });

  final String? initialValue;
  final ValueChanged<String?>? onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: initialValue,
      decoration: InputDecoration(
        hintText: 'Estado',
        hintStyle: const TextStyle(
          color: AppColors.gray500,
          fontSize: 14,
        ),
        filled: true,
        fillColor: AppColors.gray50,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.gray200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.gray200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
      items: const <DropdownMenuItem<String>>[
        DropdownMenuItem<String>(
          value: '',
          child: Text('Todos'),
        ),
        DropdownMenuItem<String>(
          value: 'en_ruta',
          child: Text('En Ruta'),
        ),
        DropdownMenuItem<String>(
          value: 'pendiente',
          child: Text('Pendiente'),
        ),
        DropdownMenuItem<String>(
          value: 'finalizado',
          child: Text('Finalizado'),
        ),
      ],
      onChanged: onChanged,
      dropdownColor: Colors.white,
      style: const TextStyle(
        color: AppColors.gray900,
        fontSize: 14,
      ),
    );
  }
}

/// Selector de fecha
class _FechaSelector extends StatelessWidget {
  const _FechaSelector({
    this.value,
    this.onChanged,
  });

  final DateTime? value;
  final ValueChanged<DateTime?>? onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      readOnly: true,
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: value ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
          locale: const Locale('es', 'ES'),
        );
        onChanged?.call(picked);
      },
      decoration: InputDecoration(
        hintText: value != null
            ? '${value!.day}/${value!.month}/${value!.year}'
            : 'Seleccionar fecha',
        hintStyle: TextStyle(
          color: value != null ? AppColors.gray900 : AppColors.gray500,
          fontSize: 14,
        ),
        prefixIcon: const Icon(
          Icons.calendar_today_outlined,
          color: AppColors.gray400,
          size: 18,
        ),
        filled: true,
        fillColor: AppColors.gray50,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.gray200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.gray200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }
}
