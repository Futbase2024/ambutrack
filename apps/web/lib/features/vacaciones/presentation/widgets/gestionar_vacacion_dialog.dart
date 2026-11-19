import 'dart:async';

import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/widgets/dialogs/confirmation_dialog.dart';
import 'package:ambutrack_web/core/widgets/dialogs/result_dialog.dart';
import 'package:ambutrack_web/core/widgets/gestion/form/gestion_form.dart';
import 'package:ambutrack_web/features/ausencias/presentation/widgets/form/solicitud_gestion_body.dart';
import 'package:ambutrack_web/features/ausencias/presentation/widgets/form/solicitud_gestion_utils.dart';
import 'package:ambutrack_web/features/personal/domain/entities/personal_entity.dart';
import 'package:ambutrack_web/features/vacaciones/presentation/bloc/vacaciones_bloc.dart';
import 'package:ambutrack_web/features/vacaciones/presentation/bloc/vacaciones_event.dart';
import 'package:ambutrack_web/features/vacaciones/presentation/widgets/eliminar_dias_parcial_vacacion_dialog.dart';
import 'package:ambutrack_web/features/vacaciones/presentation/widgets/form/vacacion_form_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Diálogo para gestionar vacaciones en cualquier estado
///
/// **Acciones disponibles según estado**:
/// - **Pendiente**: Aprobar, Rechazar, Eliminar
/// - **Aprobada**: Volver a Pendiente, Rechazar, Eliminar
/// - **Rechazada**: Volver a Pendiente, Aprobar, Eliminar
class GestionarVacacionDialog extends StatefulWidget {
  const GestionarVacacionDialog({
    required this.vacacion,
    required this.nombrePersonal,
    super.key,
  });

  final VacacionesEntity vacacion;
  final String nombrePersonal;

  @override
  State<GestionarVacacionDialog> createState() =>
      _GestionarVacacionDialogState();
}

class _GestionarVacacionDialogState extends State<GestionarVacacionDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _observacionesController =
      TextEditingController();
  bool _isProcessing = false;
  late String _estadoActual;

  @override
  void initState() {
    super.initState();
    _observacionesController.text = widget.vacacion.observaciones ?? '';
    _estadoActual = widget.vacacion.estado;
  }

  @override
  void dispose() {
    _observacionesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String estado = _estadoActual.toLowerCase();
    final bool puedeEliminarDias = widget.vacacion.diasSolicitados > 1;
    // Acción principal (pie) según estado: Aprobar o Volver a pendiente
    final bool principalPendiente = estado == 'aprobada';
    final bool sinAccionPrincipal = estado != 'pendiente' && estado != 'aprobada' && estado != 'rechazada';

    return GestionFormDialog(
      title: 'Gestionar vacaciones',
      subtitle: widget.nombrePersonal,
      icon: Icons.fact_check_outlined,
      formKey: _formKey,
      isEditing: true,
      isSaving: _isProcessing,
      saveLabel: sinAccionPrincipal ? 'Cerrar' : (principalPendiente ? 'Volver a pendiente' : 'Aprobar'),
      onSave: sinAccionPrincipal
          ? () => Navigator.of(context).pop()
          : (principalPendiente ? _volverPendiente : _aprobar),
      children: <Widget>[
        SolicitudGestionBody(
          periodo: SolicitudGestionUtils.periodo(widget.vacacion.fechaInicio, widget.vacacion.fechaFin),
          dias: '${widget.vacacion.diasSolicitados} días',
          estadoLabel: VacacionFormOptions.estadoGestionLabel(_estadoActual),
          estadoColor: VacacionFormOptions.estadoColor(_estadoActual),
          extras: <String, String>{
            if (widget.vacacion.fechaSolicitud != null)
              'Solicitada el': SolicitudGestionUtils.formatDate(widget.vacacion.fechaSolicitud!),
            if (widget.vacacion.fechaAprobacion != null)
              widget.vacacion.estado == 'aprobada' ? 'Aprobada el' : 'Rechazada el':
                  SolicitudGestionUtils.formatDate(widget.vacacion.fechaAprobacion!),
          },
          observacionesActuales: widget.vacacion.observaciones,
          observacionesController: _observacionesController,
          acciones: SolicitudGestionAcciones(
            enabled: !_isProcessing,
            onRechazar: estado == 'pendiente' || estado == 'aprobada' ? _rechazar : null,
            onVolverPendiente: estado == 'rechazada' ? _volverPendiente : null,
            onEliminar: _confirmarEliminar,
            onEliminarDias: puedeEliminarDias ? _eliminarDiasParciales : null,
          ),
        ),
      ],
    );
  }

  Future<void> _aprobar() async {
    setState(() => _isProcessing = true);

    debugPrint('✅ Aprobando vacación ${widget.vacacion.id}');

    try {
      final PersonalEntity personalAprobador = await SolicitudGestionUtils.obtenerPersonalAprobador();

      final VacacionesEntity vacacionAprobada = widget.vacacion.copyWith(
        estado: 'aprobada',
        aprobadoPor: personalAprobador.id,
        fechaAprobacion: DateTime.now(),
        observaciones: _observacionesController.text.trim().isEmpty
            ? widget.vacacion.observaciones
            : _observacionesController.text.trim(),
      );

      if (mounted) {
        context.read<VacacionesBloc>().add(
              VacacionesUpdateRequested(vacacionAprobada),
            );

        Navigator.of(context).pop();

        unawaited(
          showResultDialog(
            context: context,
            title: 'Vacación Aprobada',
            message: 'La vacación ha sido aprobada exitosamente.',
            type: ResultType.success,
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Error al aprobar vacación: $e');
      if (mounted) {
        setState(() => _isProcessing = false);
        unawaited(
          showResultDialog(
            context: context,
            title: 'Error al Aprobar',
            message: 'No se pudo aprobar la vacación.',
            type: ResultType.error,
            details: e.toString(),
          ),
        );
      }
    }
  }

  Future<void> _rechazar() async {
    setState(() => _isProcessing = true);

    debugPrint('❌ Rechazando vacación ${widget.vacacion.id}');

    try {
      final PersonalEntity personalAprobador = await SolicitudGestionUtils.obtenerPersonalAprobador();

      final VacacionesEntity vacacionRechazada = widget.vacacion.copyWith(
        estado: 'rechazada',
        aprobadoPor: personalAprobador.id,
        fechaAprobacion: DateTime.now(),
        observaciones: _observacionesController.text.trim().isEmpty
            ? widget.vacacion.observaciones
            : _observacionesController.text.trim(),
      );

      if (mounted) {
        context.read<VacacionesBloc>().add(
              VacacionesUpdateRequested(vacacionRechazada),
            );

        Navigator.of(context).pop();

        unawaited(
          showResultDialog(
            context: context,
            title: 'Vacación Rechazada',
            message: 'La vacación ha sido rechazada.',
            type: ResultType.warning,
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Error al rechazar vacación: $e');
      if (mounted) {
        setState(() => _isProcessing = false);
        unawaited(
          showResultDialog(
            context: context,
            title: 'Error al Rechazar',
            message: 'No se pudo rechazar la vacación.',
            type: ResultType.error,
            details: e.toString(),
          ),
        );
      }
    }
  }

  Future<void> _volverPendiente() async {
    setState(() => _isProcessing = true);

    debugPrint('⏳ Volviendo vacación a pendiente ${widget.vacacion.id}');

    try {
      final PersonalEntity personalAprobador = await SolicitudGestionUtils.obtenerPersonalAprobador();

      final VacacionesEntity vacacionPendiente = widget.vacacion.copyWith(
        estado: 'pendiente',
        aprobadoPor: personalAprobador.id,
        fechaAprobacion: DateTime.now(),
        observaciones: _observacionesController.text.trim().isEmpty
            ? widget.vacacion.observaciones
            : _observacionesController.text.trim(),
      );

      if (mounted) {
        context.read<VacacionesBloc>().add(
              VacacionesUpdateRequested(vacacionPendiente),
            );

        Navigator.of(context).pop();

        unawaited(
          showResultDialog(
            context: context,
            title: 'Vacación Actualizada',
            message: 'La vacación ha vuelto a estado pendiente.',
            type: ResultType.info,
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Error al volver vacación a pendiente: $e');
      if (mounted) {
        setState(() => _isProcessing = false);
        unawaited(
          showResultDialog(
            context: context,
            title: 'Error al Actualizar',
            message: 'No se pudo cambiar el estado de la vacación.',
            type: ResultType.error,
            details: e.toString(),
          ),
        );
      }
    }
  }

  Future<void> _eliminarDiasParciales() async {
    debugPrint('✂️ Abriendo diálogo de eliminación parcial de vacación');

    final ({DateTime fechaInicio, DateTime fechaFin})? resultado =
        await showEliminarDiasParcialVacacionDialog(
      context: context,
      vacacion: widget.vacacion,
      nombrePersonal: widget.nombrePersonal,
    );

    if (resultado != null && mounted) {
      debugPrint('✂️ Eliminando días: ${resultado.fechaInicio} - ${resultado.fechaFin}');

      context.read<VacacionesBloc>().add(
            VacacionEliminarDiasParcialRequested(
              vacacion: widget.vacacion,
              fechaInicioEliminar: resultado.fechaInicio,
              fechaFinEliminar: resultado.fechaFin,
            ),
          );

      Navigator.of(context).pop();

      unawaited(
        showResultDialog(
          context: context,
          title: 'Días Eliminados',
          message: 'Los días seleccionados han sido eliminados de la vacación.',
          type: ResultType.success,
        ),
      );
    }
  }

  Future<void> _confirmarEliminar() async {
    final bool? confirmed = await showConfirmationDialog(
      context: context,
      title: 'Confirmar Eliminación',
      message:
          '¿Estás seguro de que deseas eliminar esta vacación? Esta acción no se puede deshacer.',
      itemDetails: <String, String>{
        'Personal': widget.nombrePersonal,
        'Periodo':
            SolicitudGestionUtils.periodo(widget.vacacion.fechaInicio, widget.vacacion.fechaFin),
        'Días': '${widget.vacacion.diasSolicitados} días',
        'Estado': VacacionFormOptions.estadoGestionLabel(widget.vacacion.estado),
      },
    );

    if (confirmed == true && mounted) {
      await _eliminar();
    }
  }

  Future<void> _eliminar() async {
    setState(() => _isProcessing = true);

    debugPrint('🗑️ Eliminando vacación ${widget.vacacion.id}');

    try {
      if (mounted) {
        context.read<VacacionesBloc>().add(
              VacacionesDeleteRequested(widget.vacacion.id),
            );
        Navigator.of(context).pop();

        unawaited(
          showResultDialog(
            context: context,
            title: 'Vacación Eliminada',
            message: 'La vacación ha sido eliminada exitosamente.',
            type: ResultType.success,
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Error al eliminar vacación: $e');
      if (mounted) {
        setState(() => _isProcessing = false);
        unawaited(
          showResultDialog(
            context: context,
            title: 'Error al Eliminar',
            message: 'No se pudo eliminar la vacación.',
            type: ResultType.error,
            details: e.toString(),
          ),
        );
      }
    }
  }
}
