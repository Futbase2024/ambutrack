import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/dialogs/confirmation_dialog.dart';
import 'package:ambutrack_web/core/widgets/dialogs/result_dialog.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/personal/horarios/presentation/cubit/inicio_turno_validacion_cubit.dart';
import 'package:ambutrack_web/features/personal/horarios/presentation/cubit/inicio_turno_validacion_state.dart';
import 'package:ambutrack_web/features/personal/horarios/presentation/widgets/gestion/inicios_turno/inicio_turno_dialogs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Acciones de la pantalla de inicios de turno: aprobar, rechazar y ver foto
mixin IniciosTurnoAcciones<T extends StatefulWidget> on State<T> {
  InicioTurnoValidacionCubit get _cubit => context.read<InicioTurnoValidacionCubit>();

  String _descripcion(InicioTurnoEntity i) {
    final String tecnico = GestionFormatters.texto(i.personalNombre);
    final String vehiculo = i.vehiculoMatricula == null ? '' : ' con el vehículo ${i.vehiculoMatricula}';
    return '$tecnico$vehiculo';
  }

  /// Confirma y aprueba un inicio de turno pendiente
  Future<void> aprobarInicio(InicioTurnoEntity i) async {
    final bool? ok = await showSimpleConfirmationDialog(
      context: context,
      title: 'Aprobar inicio de turno',
      message: '¿Aprobar el inicio de turno fuera de base de ${_descripcion(i)}?',
      confirmText: 'Aprobar',
      icon: Icons.check_circle_outline,
      iconColor: AppColors.success,
      confirmButtonColor: AppColors.success,
    );
    if (ok != true || !mounted) {
      return;
    }
    await _cubit.validar(id: i.id, aprobado: true);
  }

  /// Pide motivo, confirma y rechaza un inicio de turno pendiente
  Future<void> rechazarInicio(InicioTurnoEntity i) async {
    final String? motivo = await pedirMotivoRechazo(context, tecnico: GestionFormatters.texto(i.personalNombre));
    if (motivo == null || !mounted) {
      return;
    }
    final bool? ok = await showSimpleConfirmationDialog(
      context: context,
      title: 'Rechazar inicio de turno',
      message: '¿Rechazar el inicio de turno de ${_descripcion(i)}?\n\nMotivo: $motivo',
      confirmText: 'Rechazar',
      icon: Icons.cancel_outlined,
    );
    if (ok != true || !mounted) {
      return;
    }
    await _cubit.validar(id: i.id, aprobado: false, motivoRechazo: motivo);
  }

  /// Muestra la foto del cuentakilómetros en un diálogo
  Future<void> verFotoKm(InicioTurnoEntity i) {
    final String? ruta = i.fotoKmUrl;
    if (ruta == null || ruta.isEmpty) {
      return Future<void>.value();
    }
    return showDialog<void>(
      context: context,
      builder: (BuildContext _) => FotoKmDialog(
        url: _cubit.urlFotoKm(ruta),
        titulo: 'Cuentakilómetros · ${GestionFormatters.texto(i.vehiculoMatricula)}',
      ),
    );
  }

  /// Muestra el resultado de la última aprobación / rechazo
  void mostrarResultadoValidacion(InicioTurnoValidacionResultado r) {
    final String accion = r.aprobado ? 'aprobado' : 'rechazado';
    if (r.ok) {
      showResultDialog(
        context: context,
        title: 'Inicio de turno $accion',
        message: 'El inicio de turno se ha $accion. El técnico recibirá una notificación.',
        type: ResultType.success,
      );
    } else {
      showResultDialog(
        context: context,
        title: 'Error al validar',
        message: 'No se pudo guardar la validación del inicio de turno.',
        details: r.error,
        type: ResultType.error,
      );
    }
  }
}
