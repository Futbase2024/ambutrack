import 'package:ambutrack_web/core/widgets/gestion/form/gestion_form.dart';
import 'package:ambutrack_web/features/auth/domain/entities/user_entity.dart';
import 'package:ambutrack_web/features/perfil/presentation/bloc/perfil_bloc.dart';
import 'package:ambutrack_web/features/perfil/presentation/bloc/perfil_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
  late final TextEditingController _displayNameController =
      TextEditingController(text: widget.user.displayName ?? '');
  late final TextEditingController _phoneNumberController =
      TextEditingController(text: widget.user.phoneNumber ?? '');
  late final TextEditingController _photoUrlController = TextEditingController(text: widget.user.photoUrl ?? '');

  bool _isSaving = false;

  @override
  void dispose() {
    _displayNameController.dispose();
    _phoneNumberController.dispose();
    _photoUrlController.dispose();
    super.dispose();
  }

  static String? _nullIfEmpty(TextEditingController c) => c.text.trim().isEmpty ? null : c.text.trim();

  Future<void> _onSave() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    setState(() => _isSaving = true);
    try {
      debugPrint('👤 PerfilEditarDialog: enviando actualización de perfil');
      context.read<PerfilBloc>().add(
            PerfilEvent.updateProfileRequested(
              displayName: _nullIfEmpty(_displayNameController),
              phoneNumber: _nullIfEmpty(_phoneNumberController),
              photoUrl: _nullIfEmpty(_photoUrlController),
            ),
          );
      // El resultado lo gestiona el BlocListener de la página principal
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      debugPrint('❌ PerfilEditarDialog: $e');
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestionFormDialog(
      title: 'Editar perfil',
      subtitle: widget.user.email,
      icon: Icons.edit_outlined,
      size: GestionFormSize.small,
      formKey: _formKey,
      isEditing: true,
      isSaving: _isSaving,
      saveLabel: 'Guardar',
      onSave: _onSave,
      children: <Widget>[
        const GestionFormSection(title: 'Información personal', first: true),
        GestionFormRow(
          label: 'Nombre',
          child: GestionTextField(
            controller: _displayNameController,
            hint: 'Ej: Juan Pérez García',
            validator: _PerfilValidators.nombre,
          ),
        ),
        GestionFormRow(
          label: 'Teléfono',
          child: GestionTextField(
            controller: _phoneNumberController,
            hint: 'Ej: +34 600 000 000',
            keyboardType: TextInputType.phone,
            validator: _PerfilValidators.telefono,
          ),
        ),
        GestionFormRow(
          label: 'URL de foto',
          child: GestionTextField(
            controller: _photoUrlController,
            hint: 'https://ejemplo.com/foto.jpg',
            keyboardType: TextInputType.url,
            validator: _PerfilValidators.url,
          ),
        ),
      ],
    );
  }
}

/// Validaciones (todos los campos son opcionales)
class _PerfilValidators {
  const _PerfilValidators._();

  static String? nombre(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    return value.trim().length < 3 ? 'El nombre debe tener al menos 3 caracteres' : null;
  }

  static String? telefono(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    // Validación básica de formato (permite espacios, + y números)
    final RegExp phoneRegex = RegExp(r'^[\d\s\+\-\(\)]+$');
    return phoneRegex.hasMatch(value.trim()) ? null : 'Formato de teléfono inválido';
  }

  static String? url(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    final Uri? uri = Uri.tryParse(value.trim());
    return (uri == null || !uri.hasScheme || !uri.hasAuthority) ? 'URL inválida' : null;
  }
}
