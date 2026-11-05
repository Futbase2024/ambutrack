import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:flutter/material.dart';

/// Devuelve el texto recortado del controller o `null` si está vacío
String? textOrNull(TextEditingController controller) {
  final String value = controller.text.trim();
  return value.isEmpty ? null : value;
}

/// Contenedor común de los diálogos de formulario del módulo Taller
class TallerFormDialogShell extends StatelessWidget {
  const TallerFormDialogShell({
    required this.formKey,
    required this.header,
    required this.fields,
    required this.actions,
    super.key,
  });

  final GlobalKey<FormState> formKey;
  final Widget header;
  final Widget fields;
  final Widget actions;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.paddingXl),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  header,
                  const SizedBox(height: AppSizes.spacingLarge),
                  Flexible(child: SingleChildScrollView(child: fields)),
                  const SizedBox(height: AppSizes.spacingLarge),
                  actions,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Cabecera del diálogo con icono, título y subtítulo
class TallerFormHeader extends StatelessWidget {
  const TallerFormHeader({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    super.key,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(AppSizes.paddingMedium),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(width: AppSizes.spacingMedium),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.gray900,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 13, color: AppColors.gray500),
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}

/// Campo de texto estándar de los formularios del Taller
class TallerFormField extends StatelessWidget {
  const TallerFormField({
    required this.controller,
    required this.label,
    this.hint,
    this.icon,
    this.maxLines = 1,
    this.isRequired = false,
    this.keyboardType,
    super.key,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final IconData? icon;
  final int maxLines;
  final bool isRequired;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      textInputAction: maxLines > 1 ? TextInputAction.newline : TextInputAction.next,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: icon != null ? Icon(icon, size: 20) : null,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
      ),
      validator: (String? value) {
        if (isRequired && (value == null || value.trim().isEmpty)) {
          return '$label es obligatorio';
        }
        return null;
      },
    );
  }
}

/// Dropdown genérico para seleccionar el tipo (taller / proveedor)
class TallerTipoDropdown<T> extends StatelessWidget {
  const TallerTipoDropdown({
    required this.label,
    required this.value,
    required this.values,
    required this.labelOf,
    required this.onChanged,
    super.key,
  });

  final String label;
  final T value;
  final List<T> values;
  final String Function(T) labelOf;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.category_outlined, size: 20),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
      ),
      items: values
          .map((T item) => DropdownMenuItem<T>(value: item, child: Text(labelOf(item))))
          .toList(),
      onChanged: (T? selected) {
        if (selected != null) {
          onChanged(selected);
        }
      },
    );
  }
}

/// Switch de activo/inactivo
class TallerActivoSwitch extends StatelessWidget {
  const TallerActivoSwitch({
    required this.value,
    required this.title,
    required this.activeText,
    required this.inactiveText,
    required this.onChanged,
    super.key,
  });

  final bool value;
  final String title;
  final String activeText;
  final String inactiveText;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      title: Text(title),
      subtitle: Text(
        value ? activeText : inactiveText,
        style: const TextStyle(fontSize: 12, color: AppColors.gray500),
      ),
      activeThumbColor: AppColors.success,
      contentPadding: EdgeInsets.zero,
      dense: true,
    );
  }
}

/// Botones Cancelar / Guardar-Actualizar
class TallerFormActions extends StatelessWidget {
  const TallerFormActions({
    required this.isSaving,
    required this.isEditing,
    required this.onSave,
    super.key,
  });

  final bool isSaving;
  final bool isEditing;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final String label = isSaving ? 'Guardando...' : (isEditing ? 'Actualizar' : 'Guardar');
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        TextButton(
          onPressed: isSaving ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        const SizedBox(width: AppSizes.spacingMedium),
        ElevatedButton.icon(
          onPressed: isSaving ? null : onSave,
          icon: Icon(isEditing ? Icons.save : Icons.add),
          label: Text(label),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.paddingLarge,
              vertical: AppSizes.paddingMedium,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
            ),
          ),
        ),
      ],
    );
  }
}
