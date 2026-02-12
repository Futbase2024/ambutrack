import 'dart:math';

import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/widgets/buttons/app_button.dart';
import 'package:ambutrack_web/core/widgets/dialogs/app_dialog.dart';
import 'package:ambutrack_web/core/widgets/dialogs/result_dialog.dart';
import 'package:ambutrack_web/core/widgets/loading/app_loading_indicator.dart';
import 'package:ambutrack_web/features/usuarios/presentation/bloc/usuarios_bloc.dart';
import 'package:ambutrack_web/features/usuarios/presentation/bloc/usuarios_event.dart';
import 'package:ambutrack_web/features/usuarios/presentation/bloc/usuarios_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

/// Diálogo para resetear la contraseña de un usuario
class UsuarioResetPasswordDialog extends StatefulWidget {
  const UsuarioResetPasswordDialog({super.key, required this.usuario});

  final UserEntity usuario;

  @override
  State<UsuarioResetPasswordDialog> createState() =>
      _UsuarioResetPasswordDialogState();
}

class _UsuarioResetPasswordDialogState
    extends State<UsuarioResetPasswordDialog> {
  late TextEditingController _passwordController;
  late FocusNode _passwordFocusNode;

  bool _obscurePassword = false; // Mostrar por defecto para que se vea la generada
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _passwordController = TextEditingController();
    _passwordFocusNode = FocusNode();

    // Generar contraseña automáticamente al abrir el diálogo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _generatePassword();
    });
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<UsuariosBloc, UsuariosState>(
      listener: (BuildContext context, UsuariosState state) {
        if (state is UsuariosPasswordReset && _isSaving) {
          // Cerrar el loading dialog
          Navigator.of(context).pop();

          setState(() => _isSaving = false);

          // Cerrar este dialog
          Navigator.of(context).pop();

          // Mostrar diálogo de éxito
          showResultDialog(
            context: context,
            type: ResultType.success,
            title: 'Contraseña Reseteada',
            message: 'La contraseña de ${widget.usuario.displayName ?? widget.usuario.email} ha sido actualizada correctamente.',
          );
        } else if (state is UsuariosError && _isSaving) {
          // Cerrar el loading dialog
          Navigator.of(context).pop();

          setState(() => _isSaving = false);

          // Mostrar error
          showResultDialog(
            context: context,
            type: ResultType.error,
            title: 'Error',
            message: state.message,
          );
        }
      },
      child: AppDialog(
        title: 'Resetear Contraseña',
        icon: Icons.lock_reset,
        type: AppDialogType.warning,
        maxWidth: 500,
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            // Información del usuario
            Container(
              padding: const EdgeInsets.all(AppSizes.paddingMedium),
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: <Widget>[
                  const Icon(Icons.person, color: AppColors.primary),
                  const SizedBox(width: AppSizes.spacingSmall),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          widget.usuario.displayName ?? 'Sin nombre',
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimaryLight,
                          ),
                        ),
                        Text(
                          widget.usuario.email,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.spacingLarge),

            // Instrucciones
            Text(
              'Nueva contraseña',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: AppSizes.spacingSmall),
            Text(
              'Se generará una nueva contraseña automáticamente. Puedes copiarla y compartirla con el usuario.',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.textSecondaryLight,
                height: 1.4,
              ),
            ),
            const SizedBox(height: AppSizes.spacing),

            // Campo de contraseña
            TextFormField(
              controller: _passwordController,
              focusNode: _passwordFocusNode,
              obscureText: _obscurePassword,
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Contraseña generada',
                hintText: 'Contraseña',
                prefixIcon: const Icon(Icons.lock, color: AppColors.warning),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility : Icons.visibility_off,
                        color: AppColors.gray600,
                      ),
                      onPressed: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                      tooltip: _obscurePassword ? 'Mostrar contraseña' : 'Ocultar contraseña',
                    ),
                    IconButton(
                      icon: const Icon(Icons.content_copy, color: AppColors.primary),
                      onPressed: _copyPassword,
                      tooltip: 'Copiar contraseña',
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh, color: AppColors.warning),
                      onPressed: _generatePassword,
                      tooltip: 'Generar nueva contraseña',
                    ),
                  ],
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                  borderSide: const BorderSide(color: AppColors.gray300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                  borderSide: const BorderSide(color: AppColors.gray300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                  borderSide: const BorderSide(color: AppColors.warning, width: 2),
                ),
                filled: true,
                fillColor: AppColors.gray50,
              ),
            ),
            const SizedBox(height: AppSizes.spacing),

            // Advertencia
            Container(
              padding: const EdgeInsets.all(AppSizes.paddingMedium),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Icon(Icons.warning_amber, color: AppColors.warning, size: 20),
                  const SizedBox(width: AppSizes.spacingSmall),
                  Expanded(
                    child: Text(
                      'El usuario deberá usar esta nueva contraseña en su próximo inicio de sesión.',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.textPrimaryLight,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: <Widget>[
          AppButton(
            onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
            label: 'Cancelar',
            variant: AppButtonVariant.text,
          ),
          AppButton(
            onPressed: _isSaving ? null : _onConfirm,
            label: 'Confirmar Reset',
            variant: AppButtonVariant.warning,
            icon: Icons.lock_reset,
          ),
        ],
      ),
    );
  }

  /// Genera una contraseña segura aleatoria
  void _generatePassword() {
    const String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#\$%^&*';
    final Random rnd = Random.secure();
    final String password = String.fromCharCodes(
      Iterable<int>.generate(12, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))),
    );

    setState(() {
      _passwordController.text = password;
      _obscurePassword = false; // Mostrar la contraseña generada
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
    if (_passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debe generar una contraseña'),
          backgroundColor: AppColors.error,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(AppSizes.paddingXl),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
            ),
            child: const AppLoadingIndicator(
              message: 'Reseteando contraseña...',
              color: AppColors.warning,
              icon: Icons.lock_reset,
            ),
          ),
        );
      },
    );

    debugPrint('🔐 Reseteando contraseña de usuario: ${widget.usuario.email}');
    context.read<UsuariosBloc>().add(
          UsuariosResetPasswordRequested(
            widget.usuario.uid,
            _passwordController.text,
          ),
        );
  }
}
