import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/forms/app_text_field.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../bloc/perfil_bloc.dart';
import '../bloc/perfil_event.dart';

/// Diálogo para editar el perfil del usuario
class PerfilEditarDialog extends StatefulWidget {
  const PerfilEditarDialog({
    required this.user,
    super.key,
  });

  final UserEntity user;

  @override
  State<PerfilEditarDialog> createState() => _PerfilEditarDialogState();
}

class _PerfilEditarDialogState extends State<PerfilEditarDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _displayNameController;
  late final TextEditingController _phoneNumberController;
  late final TextEditingController _photoUrlController;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _displayNameController = TextEditingController(
      text: widget.user.displayName ?? '',
    );
    _phoneNumberController = TextEditingController(
      text: widget.user.phoneNumber ?? '',
    );
    _photoUrlController = TextEditingController(
      text: widget.user.photoUrl ?? '',
    );
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _phoneNumberController.dispose();
    _photoUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
      ),
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(AppSizes.paddingXl),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _DialogHeader(),
              const SizedBox(height: AppSizes.spacingXl),
              _FormFields(
                displayNameController: _displayNameController,
                phoneNumberController: _phoneNumberController,
                photoUrlController: _photoUrlController,
              ),
              const SizedBox(height: AppSizes.spacingXl),
              _DialogActions(
                isSaving: _isSaving,
                onCancel: () => Navigator.of(context).pop(),
                onSave: _onSave,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      // Enviar evento al BLoC
      context.read<PerfilBloc>().add(
            PerfilEvent.updateProfileRequested(
              displayName: _displayNameController.text.trim().isEmpty
                  ? null
                  : _displayNameController.text.trim(),
              phoneNumber: _phoneNumberController.text.trim().isEmpty
                  ? null
                  : _phoneNumberController.text.trim(),
              photoUrl: _photoUrlController.text.trim().isEmpty
                  ? null
                  : _photoUrlController.text.trim(),
            ),
          );

      // Cerrar el diálogo
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      // El error se manejará en el BlocListener de la página principal
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}

/// Header del diálogo
class _DialogHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppSizes.radius),
          ),
          child: const Icon(
            Icons.edit_outlined,
            color: AppColors.primary,
            size: 24,
          ),
        ),
        const SizedBox(width: AppSizes.spacing),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Editar Perfil',
                style: GoogleFonts.inter(
                  fontSize: AppSizes.fontLarge,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Actualiza tu información personal',
                style: GoogleFonts.inter(
                  fontSize: AppSizes.fontSmall,
                  color: AppColors.textSecondaryLight,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Campos del formulario
class _FormFields extends StatelessWidget {
  const _FormFields({
    required this.displayNameController,
    required this.phoneNumberController,
    required this.photoUrlController,
  });

  final TextEditingController displayNameController;
  final TextEditingController phoneNumberController;
  final TextEditingController photoUrlController;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        AppTextField(
          controller: displayNameController,
          label: 'Nombre completo',
          hint: 'Ej: Juan Pérez García',
          prefixIcon: const Icon(Icons.person_outline),
          textInputAction: TextInputAction.next,
          validator: (String? value) {
            if (value == null || value.trim().isEmpty) {
              return null; // Opcional
            }
            if (value.trim().length < 3) {
              return 'El nombre debe tener al menos 3 caracteres';
            }
            return null;
          },
        ),
        const SizedBox(height: AppSizes.spacing),
        AppTextField(
          controller: phoneNumberController,
          label: 'Teléfono',
          hint: 'Ej: +34 600 000 000',
          prefixIcon: const Icon(Icons.phone_outlined),
          textInputAction: TextInputAction.next,
          validator: (String? value) {
            if (value == null || value.trim().isEmpty) {
              return null; // Opcional
            }
            // Validación básica de formato (permite espacios, + y números)
            final RegExp phoneRegex = RegExp(r'^[\d\s\+\-\(\)]+$');
            if (!phoneRegex.hasMatch(value.trim())) {
              return 'Formato de teléfono inválido';
            }
            return null;
          },
        ),
        const SizedBox(height: AppSizes.spacing),
        AppTextField(
          controller: photoUrlController,
          label: 'URL de foto de perfil',
          hint: 'https://ejemplo.com/foto.jpg',
          prefixIcon: const Icon(Icons.link_outlined),
          textInputAction: TextInputAction.done,
          validator: (String? value) {
            if (value == null || value.trim().isEmpty) {
              return null; // Opcional
            }
            // Validación básica de URL
            final Uri? uri = Uri.tryParse(value.trim());
            if (uri == null || !uri.hasScheme || !uri.hasAuthority) {
              return 'URL inválida';
            }
            return null;
          },
        ),
      ],
    );
  }
}

/// Botones de acción del diálogo
class _DialogActions extends StatelessWidget {
  const _DialogActions({
    required this.isSaving,
    required this.onCancel,
    required this.onSave,
  });

  final bool isSaving;
  final VoidCallback onCancel;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        AppButton(
          label: 'Cancelar',
          variant: AppButtonVariant.outline,
          onPressed: isSaving ? null : onCancel,
        ),
        const SizedBox(width: AppSizes.spacing),
        AppButton(
          label: 'Guardar',
          icon: Icons.save_outlined,
          isLoading: isSaving,
          onPressed: isSaving ? null : onSave,
        ),
      ],
    );
  }
}
