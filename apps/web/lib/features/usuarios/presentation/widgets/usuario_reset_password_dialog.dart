import 'dart:async';

import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/dialogs/result_dialog.dart';
import 'package:ambutrack_web/core/widgets/gestion/form/gestion_form.dart';
import 'package:ambutrack_web/core/widgets/loading/app_loading_indicator.dart';
import 'package:ambutrack_web/features/usuarios/presentation/bloc/usuarios_bloc.dart';
import 'package:ambutrack_web/features/usuarios/presentation/bloc/usuarios_event.dart';
import 'package:ambutrack_web/features/usuarios/presentation/bloc/usuarios_state.dart';
import 'package:ambutrack_web/features/usuarios/presentation/widgets/form/password_form_field.dart';
import 'package:ambutrack_web/features/usuarios/presentation/widgets/form/usuario_form_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Diálogo para resetear la contraseña de un usuario
class UsuarioResetPasswordDialog extends StatefulWidget {
  const UsuarioResetPasswordDialog({super.key, required this.usuario});

  final UserEntity usuario;

  @override
  State<UsuarioResetPasswordDialog> createState() => _UsuarioResetPasswordDialogState();
}

class _UsuarioResetPasswordDialogState extends State<UsuarioResetPasswordDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();

  bool _visible = true; // Mostrar por defecto para que se vea la generada
  bool _isSaving = false;

  String get _nombreUsuario => widget.usuario.displayName ?? widget.usuario.email;

  @override
  void initState() {
    super.initState();
    // Generar contraseña automáticamente al abrir el diálogo
    WidgetsBinding.instance.addPostFrameCallback((_) => _generatePassword());
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  void _onBlocState(BuildContext context, UsuariosState state) {
    if (!_isSaving) {
      return;
    }
    if (state is UsuariosPasswordReset) {
      Navigator.of(context).pop(); // Cierra el overlay de carga
      setState(() => _isSaving = false);
      Navigator.of(context).pop(); // Cierra este diálogo
      showResultDialog(
        context: context,
        type: ResultType.success,
        title: 'Contraseña Reseteada',
        message: 'La contraseña de $_nombreUsuario ha sido actualizada correctamente.',
      );
    } else if (state is UsuariosError) {
      Navigator.of(context).pop(); // Cierra el overlay de carga
      setState(() => _isSaving = false);
      showResultDialog(
        context: context,
        type: ResultType.error,
        title: 'Error',
        message: state.message,
      );
    }
  }

  /// Genera una contraseña segura aleatoria
  void _generatePassword() {
    setState(() {
      _passwordController.text = UsuarioFormData.generarPassword();
      _visible = true;
    });
  }

  /// Copia la contraseña al portapapeles
  void _copyPassword() {
    if (_passwordController.text.isEmpty) {
      return;
    }
    Clipboard.setData(ClipboardData(text: _passwordController.text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Contraseña copiada al portapapeles'),
        backgroundColor: AppColors.success,
        duration: Duration(seconds: 2),
      ),
    );
  }

  /// Confirma el reset de contraseña
  void _onConfirm() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    setState(() => _isSaving = true);
    unawaited(
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext _) => const AppLoadingOverlay(
          message: 'Reseteando contraseña...',
          color: AppColors.warning,
          icon: Icons.lock_reset,
        ),
      ),
    );
    debugPrint('🔐 Reseteando contraseña de usuario: ${widget.usuario.email}');
    context.read<UsuariosBloc>().add(
          UsuariosResetPasswordRequested(widget.usuario.uid, _passwordController.text),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<UsuariosBloc, UsuariosState>(
      listener: _onBlocState,
      child: GestionFormDialog(
        title: 'Resetear contraseña',
        subtitle: _nombreUsuario,
        icon: Icons.lock_reset,
        size: GestionFormSize.small,
        formKey: _formKey,
        isEditing: true,
        isSaving: _isSaving,
        saveLabel: 'Confirmar reset',
        onSave: _onConfirm,
        children: <Widget>[
          const GestionFormSection(title: 'Usuario', first: true),
          GestionFormRow(label: 'Email', child: GestionFormReadOnly(value: widget.usuario.email)),
          const GestionFormSection(title: 'Nueva contraseña'),
          GestionFormRow(
            label: 'Contraseña',
            required: true,
            child: PasswordFormField(
              controller: _passwordController,
              readOnly: true,
              visible: _visible,
              onVisibleChanged: (bool v) => setState(() => _visible = v),
              validator: (String? v) => (v == null || v.isEmpty) ? 'Debe generar una contraseña' : null,
              actions: <PasswordFieldAction>[
                PasswordFieldAction(icon: Icons.content_copy, tooltip: 'Copiar contraseña', onPressed: _copyPassword),
                PasswordFieldAction(
                  icon: Icons.refresh,
                  tooltip: 'Generar nueva contraseña',
                  onPressed: _generatePassword,
                ),
              ],
            ),
          ),
          const GestionFormNote(
            text: 'Se genera automáticamente. Cópiala y compártela con el usuario: '
                'deberá usarla en su próximo inicio de sesión.',
            icon: Icons.warning_amber,
            color: AppColors.warning,
          ),
        ],
      ),
    );
  }
}
