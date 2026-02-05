import 'package:ambutrack_core/ambutrack_core.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/widgets/buttons/app_button.dart';
import 'package:ambutrack_web/core/widgets/dialogs/app_dialog.dart';
import 'package:ambutrack_web/core/widgets/dropdowns/app_dropdown.dart';
import 'package:ambutrack_web/features/cuadrante/bases/presentation/bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

/// Diálogo de formulario para crear/editar una Base
class BaseFormDialog extends StatefulWidget {
  const BaseFormDialog({super.key, this.base});

  final BaseCentroEntity? base;

  @override
  State<BaseFormDialog> createState() => _BaseFormDialogState();
}

class _BaseFormDialogState extends State<BaseFormDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreController;
  late TextEditingController _direccionController;

  String _tipoSeleccionado = 'Permanente';
  bool _activo = true;

  bool get _isEditing => widget.base != null;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    final BaseCentroEntity? base = widget.base;

    _nombreController = TextEditingController(text: base?.nombre ?? '');
    _direccionController = TextEditingController(text: base?.direccion ?? '');

    if (base != null) {
      _tipoSeleccionado = base.tipo ?? 'Permanente';
      _activo = base.activo;
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _direccionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppDialog(
      title: _isEditing ? 'Editar Base' : 'Nueva Base',
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _buildInfoSection(),
              const SizedBox(height: AppSizes.spacing),
              _buildUbicacionSection(),
              const SizedBox(height: AppSizes.spacing),
              _buildConfiguracionSection(),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        AppButton(
          onPressed: () => Navigator.of(context).pop(),
          label: 'Cancelar',
          variant: AppButtonVariant.text,
        ),
        AppButton(
          onPressed: _onSave,
          label: _isEditing ? 'Actualizar' : 'Crear',
        ),
      ],
    );
  }

  Widget _buildInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Información Básica',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimaryLight,
          ),
        ),
        const SizedBox(height: AppSizes.spacingSmall),
        TextFormField(
          controller: _nombreController,
          textInputAction: TextInputAction.next,
          decoration: const InputDecoration(
            labelText: 'Nombre *',
            hintText: 'Ej: Base Central Madrid',
            prefixIcon: Icon(Icons.business),
          ),
          validator: (String? value) {
            if (value == null || value.isEmpty) {
              return 'El nombre es obligatorio';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildUbicacionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Ubicación',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimaryLight,
          ),
        ),
        const SizedBox(height: AppSizes.spacingSmall),
        TextFormField(
          controller: _direccionController,
          textInputAction: TextInputAction.next,
          maxLines: 2,
          decoration: const InputDecoration(
            labelText: 'Dirección',
            hintText: 'Calle, número, piso...',
            prefixIcon: Icon(Icons.location_on),
          ),
        ),
      ],
    );
  }

  Widget _buildConfiguracionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Configuración',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimaryLight,
          ),
        ),
        const SizedBox(height: AppSizes.spacingSmall),
        AppDropdown<String>(
          value: _tipoSeleccionado,
          label: 'Tipo de Base *',
          hint: 'Selecciona tipo',
          prefixIcon: Icons.category,
          items: const <AppDropdownItem<String>>[
            AppDropdownItem<String>(
              value: 'Permanente',
              label: 'Permanente',
              icon: Icons.business,
              iconColor: AppColors.primary,
            ),
            AppDropdownItem<String>(
              value: 'Temporal',
              label: 'Temporal',
              icon: Icons.access_time,
              iconColor: AppColors.warning,
            ),
          ],
          onChanged: (String? value) {
            if (value != null) {
              setState(() => _tipoSeleccionado = value);
            }
          },
        ),
        const SizedBox(height: AppSizes.spacingSmall),
        SwitchListTile(
          title: Text(
            'Base Activa',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimaryLight,
            ),
          ),
          subtitle: Text(
            _activo ? 'La base está operativa' : 'La base está desactivada',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppColors.textSecondaryLight,
            ),
          ),
          value: _activo,
          onChanged: (bool value) => setState(() => _activo = value),
          activeThumbColor: AppColors.success,
        ),
      ],
    );
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final BaseCentroEntity base = BaseCentroEntity(
      id: widget.base?.id ?? '',
      codigo: widget.base?.codigo, // Mantener código existente si es edición
      nombre: _nombreController.text.trim(),
      direccion: _direccionController.text.trim().isEmpty ? null : _direccionController.text.trim(),
      tipo: _tipoSeleccionado,
      activo: _activo,
      createdAt: widget.base?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    if (_isEditing) {
      context.read<BasesBloc>().add(BaseUpdateRequested(base));
    } else {
      context.read<BasesBloc>().add(BaseCreateRequested(base));
    }

    Navigator.of(context).pop();
  }
}
