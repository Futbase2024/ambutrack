import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/forms/app_text_field.dart';
import '../bloc/perfil_bloc.dart';
import '../bloc/perfil_event.dart';

/// Diálogo para cambiar la contraseña del usuario
class PerfilCambiarPasswordDialog extends StatefulWidget {
  const PerfilCambiarPasswordDialog({super.key});

  @override
  State<PerfilCambiarPasswordDialog> createState() =>
      _PerfilCambiarPasswordDialogState();
}

class _PerfilCambiarPasswordDialogState
    extends State<PerfilCambiarPasswordDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isSaving = false;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
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
                newPasswordController: _newPasswordController,
                confirmPasswordController: _confirmPasswordController,
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
            PerfilEvent.updatePasswordRequested(
              newPassword: _newPasswordController.text.trim(),
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
            color: AppColors.warning.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppSizes.radius),
          ),
          child: const Icon(
            Icons.lock_outlined,
            color: AppColors.warning,
            size: 24,
          ),
        ),
        const SizedBox(width: AppSizes.spacing),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Cambiar Contraseña',
                style: GoogleFonts.inter(
                  fontSize: AppSizes.fontLarge,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Establece una nueva contraseña segura',
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
    required this.newPasswordController,
    required this.confirmPasswordController,
  });

  final TextEditingController newPasswordController;
  final TextEditingController confirmPasswordController;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        AppPasswordField(
          controller: newPasswordController,
          label: 'Nueva contraseña',
          hint: 'Mínimo 6 caracteres',
          textInputAction: TextInputAction.next,
          validator: (String? value) {
            if (value == null || value.trim().isEmpty) {
              return 'La contraseña es obligatoria';
            }
            if (value.trim().length < 6) {
              return 'La contraseña debe tener al menos 6 caracteres';
            }
            return null;
          },
        ),
        const SizedBox(height: AppSizes.spacing),
        AppPasswordField(
          controller: confirmPasswordController,
          label: 'Confirmar contraseña',
          hint: 'Repite la contraseña',
          textInputAction: TextInputAction.done,
          validator: (String? value) {
            if (value == null || value.trim().isEmpty) {
              return 'Debes confirmar la contraseña';
            }
            if (value.trim() != newPasswordController.text.trim()) {
              return 'Las contraseñas no coinciden';
            }
            return null;
          },
        ),
        const SizedBox(height: AppSizes.spacing),
        _SecurityHint(),
      ],
    );
  }
}

/// Mensaje de seguridad
class _SecurityHint extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        border: Border.all(
          color: AppColors.info.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: <Widget>[
          const Icon(
            Icons.info_outline,
            size: 20,
            color: AppColors.info,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Recomendamos usar una combinación de letras, números y símbolos para mayor seguridad.',
              style: GoogleFonts.inter(
                fontSize: AppSizes.fontSmall,
                color: AppColors.info,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
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
          label: 'Cambiar Contraseña',
          icon: Icons.lock_reset,
          isLoading: isSaving,
          onPressed: isSaving ? null : onSave,
        ),
      ],
    );
  }
}
