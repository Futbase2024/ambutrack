import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/dialogs/confirmation_dialog.dart';
import 'package:ambutrack_web/features/cuadrante/cuadrante_module/presentation/bloc/cuadrante_bloc.dart';
import 'package:ambutrack_web/features/personal/domain/entities/personal_entity.dart';
import 'package:ambutrack_web/features/turnos/presentation/bloc/turnos_bloc.dart';
import 'package:ambutrack_web/features/turnos/presentation/bloc/turnos_event.dart';
import 'package:ambutrack_web/features/turnos/presentation/widgets/turno_form_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Acciones sobre turnos lanzadas desde la tabla del cuadrante
abstract final class CuadranteTablaAcciones {
  /// Abre el formulario para crear un turno a [personal] en [fecha]
  static Future<void> crearTurno(BuildContext context, PersonalEntity personal, DateTime fecha) {
    debugPrint('📅 Asignar turno a ${personal.nombreCompleto} el $fecha');
    return _abrirFormulario(context, TurnoFormDialog(personal: personal, fechaInicio: fecha));
  }

  /// Abre el formulario para editar [turno]
  static Future<void> editarTurno(BuildContext context, TurnoEntity turno) {
    debugPrint('✏️ Editar turno ${turno.id} de ${turno.nombrePersonal}');
    return _abrirFormulario(context, TurnoFormDialog(turno: turno));
  }

  /// Pide confirmación y elimina [turno]
  static Future<void> eliminarTurno(BuildContext context, TurnoEntity turno) async {
    final TurnosBloc bloc = context.read<TurnosBloc>();
    final DateTime f = turno.fechaInicio;
    final bool? confirmado = await showSimpleConfirmationDialog(
      context: context,
      title: 'Eliminar turno',
      message: '¿Seguro que deseas eliminar este turno?\n\n'
          '${turno.nombrePersonal}\n'
          '${turno.tipoTurno.nombre} · ${turno.horaInicio} - ${turno.horaFin} · ${f.day}/${f.month}/${f.year}\n\n'
          'Esta acción no se puede deshacer.',
      confirmText: 'Eliminar',
      icon: Icons.delete_outline,
    );
    if (confirmado ?? false) {
      debugPrint('🗑️ Eliminando turno ${turno.id}');
      bloc.add(TurnoDeleteRequested(turno.id));
    }
  }

  /// Pide confirmación y valida un turno creado desde la app móvil
  static Future<void> validarTurnoApp(BuildContext context, TurnoEntity turno) async {
    final TurnosBloc bloc = context.read<TurnosBloc>();
    final bool? confirmado = await showSimpleConfirmationDialog(
      context: context,
      title: 'Validar turno',
      message: '${turno.nombrePersonal} inició este turno desde la app sin tenerlo planificado.\n\n'
          '${turno.tipoTurno.nombre} · ${turno.horaInicio} - ${turno.horaFin}\n\n'
          'Revisa horario y vehículo (puedes editarlo pulsando el turno) y valídalo.',
      confirmText: 'Validar',
      icon: Icons.verified_outlined,
      iconColor: AppColors.success,
      confirmButtonColor: AppColors.success,
    );
    if (confirmado ?? false) {
      bloc.add(TurnoValidarRequested(turno.id));
    }
  }

  /// Muestra el formulario de turno propagando los BLoCs del cuadrante
  static Future<void> _abrirFormulario(BuildContext context, TurnoFormDialog formulario) {
    final TurnosBloc turnosBloc = context.read<TurnosBloc>();
    final CuadranteBloc cuadranteBloc = context.read<CuadranteBloc>();

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return MultiBlocProvider(
          providers: <BlocProvider<dynamic>>[
            BlocProvider<TurnosBloc>.value(value: turnosBloc),
            BlocProvider<CuadranteBloc>.value(value: cuadranteBloc),
          ],
          child: formulario,
        );
      },
    );
  }
}
