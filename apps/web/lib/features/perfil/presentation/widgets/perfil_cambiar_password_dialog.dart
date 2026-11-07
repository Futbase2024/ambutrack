import 'package:ambutrack_web/core/widgets/gestion/form/gestion_form.dart';
import 'package:ambutrack_web/features/perfil/presentation/bloc/perfil_bloc.dart';
import 'package:ambutrack_web/features/perfil/presentation/bloc/perfil_event.dart';
import 'package:ambutrack_web/features/usuarios/presentation/widgets/form/password_form_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Diálogo para cambiar la contraseña del usuario
class PerfilCambiarPasswordDialog extends StatefulWidget {
  const PerfilCambiarPasswordDialog({super.key});

  @override
  State<PerfilCambiarPasswordDialog> createState() => _PerfilCambiarPasswordDialogState();
}

class _PerfilCambiarPasswordDialogState extends State<PerfilCambiarPasswordDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isSaving = false;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validateNueva(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'La contraseña es obligatoria';
    }
    if (value.trim().length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres';
    }
    return null;
  }

  String? _validateConfirmacion(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Debes confirmar la contraseña';
    }
    if (value.trim() != _newPasswordController.text.trim()) {
      return 'Las contraseñas no coinciden';
    }
    return null;
  }

  Future<void> _onSave() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    setState(() => _isSaving = true);
    try {
      debugPrint('🔐 PerfilCambiarPasswordDialog: enviando cambio de contraseña');
      context.read<PerfilBloc>().add(
            PerfilEvent.updatePasswordRequested(newPassword: _newPasswordController.text.trim()),
          );
      // El resultado lo gestiona el BlocListener de la página principal
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      debugPrint('❌ PerfilCambiarPasswordDialog: $e');
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestionFormDialog(
      title: 'Cambiar contraseña',
      icon: Icons.lock_outlined,
      size: GestionFormSize.small,
      formKey: _formKey,
      isEditing: true,
      isSaving: _isSaving,
      saveLabel: 'Cambiar contraseña',
      onSave: _onSave,
      children: <Widget>[
        const GestionFormSection(title: 'Nueva contraseña', first: true),
        GestionFormRow(
          label: 'Contraseña',
          required: true,
          child: PasswordFormField(
            controller: _newPasswordController,
            hint: 'Mínimo 6 caracteres',
            validator: _validateNueva,
          ),
        ),
        GestionFormRow(
          label: 'Confirmar',
          required: true,
          child: PasswordFormField(
            controller: _confirmPasswordController,
            hint: 'Repite la contraseña',
            validator: _validateConfirmacion,
          ),
        ),
        const GestionFormNote(
          text: 'Recomendamos usar una combinación de letras, números y símbolos para mayor seguridad.',
        ),
      ],
    );
  }
}
