import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/services/preferencias_dispositivo_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/dialogs/professional_result_dialog.dart';
import '../../../alertas_turno/presentation/cubit/alertas_turno_cubit.dart';
import '../../../alertas_turno/presentation/widgets/resumen_inicio_turno_dialog.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../checklist_ambulancia/data/services/vehiculo_cache_service.dart';
import '../bloc/registro_horario_state.dart';

/// Tipo de fichaje en curso (para decidir qué mostrar al terminar)
enum FichajeEnCurso { ninguno, entrada, salida }

/// Muestra el resultado de un fichaje con diálogo profesional (NO SnackBar)
///
/// - Entrada: resumen "Turno iniciado" con todas las caducidades (si las hay)
/// - Salida en dispositivo compartido: se cierra la sesión al cerrar el diálogo
/// - Tras cualquier fichaje se recalcula el indicador de caducidades y se
///   invalida la caché del vehículo asignado (caducidades, checklist)
Future<void> mostrarResultadoRegistro(
  BuildContext context,
  RegistroHorarioState state, {
  required FichajeEnCurso fichaje,
}) async {
  if (state is RegistroHorarioError) {
    await showProfessionalResultDialog(
      context,
      title: 'Error al Registrar',
      message: state.mensaje,
      icon: Icons.error_outline,
      iconColor: AppColors.error,
    );
    return;
  }
  if (state is! RegistroHorarioSuccess) {
    return;
  }

  final AuthBloc authBloc = context.read<AuthBloc>();
  final AlertasTurnoCubit alertas = context.read<AlertasTurnoCubit>();
  final AuthState auth = authBloc.state;
  final String? idPersonal = auth is AuthAuthenticated ? auth.personal?.id : null;
  if (idPersonal != null) {
    // El vehículo puede haber cambiado (entrada, salida o cambio de vehículo)
    VehiculoCacheService.instance.invalidate(idPersonal);
    await alertas.actualizar(idPersonal);
  }
  if (!context.mounted) {
    return;
  }

  if (fichaje == FichajeEnCurso.entrada && alertas.state.hayAvisos) {
    await showResumenInicioTurnoDialog(context, mensaje: state.mensaje, avisos: alertas.state.avisos);
    return;
  }

  final bool cerrarSesion =
      fichaje == FichajeEnCurso.salida && getIt<PreferenciasDispositivoService>().esCompartido;
  await showProfessionalResultDialog(
    context,
    title: fichaje == FichajeEnCurso.entrada ? 'Turno iniciado' : 'Registro Exitoso',
    message: cerrarSesion
        ? '${state.mensaje}\n\nEste dispositivo es compartido: se cerrará tu sesión.'
        : state.mensaje,
    icon: Icons.check_circle_outline,
    iconColor: AppColors.success,
    onClose: cerrarSesion ? () => authBloc.add(const AuthSignOutRequested()) : null,
  );
}
