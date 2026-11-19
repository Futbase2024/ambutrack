import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/utils/rol_label.dart';
import '../../../../../core/widgets/dialogs/professional_confirm_dialog.dart';
import '../../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../../auth/presentation/bloc/auth_state.dart';
import '../../bloc/registro_horario_event.dart';
import 'iniciar_turno_sheet.dart';

/// Pide al usuario los datos para iniciar turno y devuelve el evento a lanzar
///
/// - Puestos sin vehículo (jefaturas, administración, coordinación): confirmación simple,
///   salvo que la ficha de personal sea de categoría operativa (TES, conductor...).
/// - Resto: asistente completo "Iniciar turno" (turno, vehículo, km, checklist...).
/// Devuelve null si el usuario cancela.
Future<RegistroHorarioEvent?> solicitarInicioTurno(
  BuildContext context, {
  required String idPersonal,
  required double latitud,
  required double longitud,
  required double precisionGps,
  String? observaciones,
}) async {
  final AuthState auth = context.read<AuthBloc>().state;
  final String? rol = auth is AuthAuthenticated ? auth.user.rol : null;
  final String? categoria = auth is AuthAuthenticated ? auth.personal?.categoria : null;

  if (rolFichaSinVehiculo(rol, categoria: categoria)) {
    final bool? confirmado = await showProfessionalConfirmDialog(
      context,
      title: 'Iniciar jornada',
      message: 'Se registrará tu entrada con la ubicación actual.',
      confirmLabel: 'Fichar entrada',
      cancelLabel: 'Cancelar',
      icon: Icons.login_rounded,
      iconColor: AppColors.primary,
    );
    if (confirmado != true) {
      return null;
    }
    return FicharEntradaSinVehiculo(
      latitud: latitud,
      longitud: longitud,
      precisionGps: precisionGps,
      observaciones: observaciones,
    );
  }

  final InicioTurnoSeleccion? seleccion = await showIniciarTurnoSheet(
    context,
    idPersonal: idPersonal,
    latitud: latitud,
    longitud: longitud,
  );
  if (seleccion == null) {
    return null;
  }
  return FicharEntrada(
    latitud: latitud,
    longitud: longitud,
    precisionGps: precisionGps,
    seleccion: seleccion,
    observaciones: observaciones,
  );
}
