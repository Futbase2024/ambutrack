import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/services/preferencias_dispositivo_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/dialogs/professional_result_dialog.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../bloc/registro_horario_state.dart';

/// Muestra el resultado de un fichaje con diálogo profesional (NO SnackBar)
///
/// [eraSalida]: el fichaje era el fin de jornada. En un dispositivo compartido
/// se cierra la sesión al cerrar el diálogo para que entre el siguiente técnico.
void mostrarResultadoRegistro(
  BuildContext context,
  RegistroHorarioState state, {
  required bool eraSalida,
}) {
  if (state is RegistroHorarioSuccess) {
    final bool cerrarSesion = eraSalida && getIt<PreferenciasDispositivoService>().esCompartido;
    final AuthBloc authBloc = context.read<AuthBloc>();
    showProfessionalResultDialog(
      context,
      title: 'Registro Exitoso',
      message: cerrarSesion
          ? '${state.mensaje}\n\nEste dispositivo es compartido: se cerrará tu sesión.'
          : state.mensaje,
      icon: Icons.check_circle_outline,
      iconColor: AppColors.success,
      onClose: cerrarSesion ? () => authBloc.add(const AuthSignOutRequested()) : null,
    );
  } else if (state is RegistroHorarioError) {
    showProfessionalResultDialog(
      context,
      title: 'Error al Registrar',
      message: state.mensaje,
      icon: Icons.error_outline,
      iconColor: AppColors.error,
    );
  }
}
