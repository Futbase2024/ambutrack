import 'dart:async';

import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/widgets/dialogs/confirmation_dialog.dart';
import 'package:ambutrack_web/core/widgets/dialogs/result_dialog.dart';
import 'package:ambutrack_web/core/widgets/gestion/form/gestion_form.dart';
import 'package:ambutrack_web/features/ausencias/presentation/bloc/ausencias_bloc.dart';
import 'package:ambutrack_web/features/ausencias/presentation/bloc/ausencias_event.dart';
import 'package:ambutrack_web/features/ausencias/presentation/widgets/eliminar_dias_parcial_dialog.dart';
import 'package:ambutrack_web/features/ausencias/presentation/widgets/form/ausencia_form_data.dart';
import 'package:ambutrack_web/features/ausencias/presentation/widgets/form/solicitud_gestion_body.dart';
import 'package:ambutrack_web/features/ausencias/presentation/widgets/form/solicitud_gestion_utils.dart';
import 'package:ambutrack_web/features/personal/domain/entities/personal_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Diálogo para gestionar ausencias en cualquier estado
///
/// **Acciones disponibles según estado**:
/// - **Pendiente**: Aprobar, Rechazar, Eliminar
/// - **Aprobada**: Volver a Pendiente, Rechazar, Eliminar
/// - **Rechazada**: Volver a Pendiente, Aprobar, Eliminar
class GestionarAusenciaDialog extends StatefulWidget {
  const GestionarAusenciaDialog({
    required this.ausencia,
    required this.nombrePersonal,
    super.key,
  });

  final AusenciaEntity ausencia;
  final String nombrePersonal;

  @override
  State<GestionarAusenciaDialog> createState() =>
      _GestionarAusenciaDialogState();
}

class _GestionarAusenciaDialogState extends State<GestionarAusenciaDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _observacionesController =
      TextEditingController();
  bool _isProcessing = false;
  late EstadoAusencia _estadoActual;

  @override
  void initState() {
    super.initState();
    _observacionesController.text = widget.ausencia.observaciones ?? '';
    _estadoActual = widget.ausencia.estado;
  }

  @override
  void dispose() {
    _observacionesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final EstadoAusencia estado = _estadoActual;
    final bool tieneMasDeUnDia = widget.ausencia.diasAusencia > 1;
    // Acción principal (pie) según estado: Aprobar o Volver a pendiente
    final bool principalPendiente = estado == EstadoAusencia.aprobada;
    final bool sinAccionPrincipal = estado == EstadoAusencia.cancelada;

    return GestionFormDialog(
      title: 'Gestionar ausencia',
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
          periodo: SolicitudGestionUtils.periodo(widget.ausencia.fechaInicio, widget.ausencia.fechaFin),
          dias: '${widget.ausencia.diasAusencia} días',
          estadoLabel: AusenciaFormOptions.estadoGestionLabel(estado),
          estadoColor: AusenciaFormOptions.estadoColor(estado),
          extras: <String, String>{
            if (widget.ausencia.motivo != null && widget.ausencia.motivo!.isNotEmpty)
              'Motivo': widget.ausencia.motivo!,
            if (widget.ausencia.fechaAprobacion != null)
              widget.ausencia.estado == EstadoAusencia.aprobada ? 'Aprobada el' : 'Rechazada el':
                  SolicitudGestionUtils.formatDate(widget.ausencia.fechaAprobacion!),
          },
          observacionesActuales: widget.ausencia.observaciones,
          observacionesController: _observacionesController,
          acciones: SolicitudGestionAcciones(
            enabled: !_isProcessing,
            onRechazar:
                estado == EstadoAusencia.pendiente || estado == EstadoAusencia.aprobada ? _rechazar : null,
            onVolverPendiente: estado == EstadoAusencia.rechazada ? _volverPendiente : null,
            onEliminar: _confirmarEliminar,
            onEliminarDias: tieneMasDeUnDia ? _eliminarDiasParciales : null,
          ),
        ),
      ],
    );
  }

  Future<void> _aprobar() async {
    setState(() => _isProcessing = true);

    debugPrint('✅ Aprobando ausencia ${widget.ausencia.id}');

    try {
      final PersonalEntity personalAprobador = await SolicitudGestionUtils.obtenerPersonalAprobador();

      if (mounted) {
        // Disparar evento con actualización optimista
        context.read<AusenciasBloc>().add(
              AusenciaAprobarRequested(
                idAusencia: widget.ausencia.id,
                aprobadoPor: personalAprobador.id,
                observaciones: _observacionesController.text.trim().isEmpty
                    ? null
                    : _observacionesController.text.trim(),
              ),
            );

        Navigator.of(context).pop();

        unawaited(
          showResultDialog(
            context: context,
            title: 'Ausencia Aprobada',
            message: 'La ausencia ha sido aprobada exitosamente.',
            type: ResultType.success,
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Error al aprobar ausencia: $e');
      if (mounted) {
        setState(() => _isProcessing = false);
        unawaited(
          showResultDialog(
            context: context,
            title: 'Error al Aprobar',
            message: 'No se pudo aprobar la ausencia.',
            type: ResultType.error,
            details: e.toString(),
          ),
        );
      }
    }
  }

  Future<void> _rechazar() async {
    setState(() => _isProcessing = true);

    debugPrint('❌ Rechazando ausencia ${widget.ausencia.id}');

    try {
      final PersonalEntity personalAprobador = await SolicitudGestionUtils.obtenerPersonalAprobador();

      if (mounted) {
        // Disparar evento con actualización optimista
        context.read<AusenciasBloc>().add(
              AusenciaRechazarRequested(
                idAusencia: widget.ausencia.id,
                aprobadoPor: personalAprobador.id,
                observaciones: _observacionesController.text.trim().isEmpty
                    ? null
                    : _observacionesController.text.trim(),
              ),
            );

        Navigator.of(context).pop();

        unawaited(
          showResultDialog(
            context: context,
            title: 'Ausencia Rechazada',
            message: 'La ausencia ha sido rechazada.',
            type: ResultType.warning,
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Error al rechazar ausencia: $e');
      if (mounted) {
        setState(() => _isProcessing = false);
        unawaited(
          showResultDialog(
            context: context,
            title: 'Error al Rechazar',
            message: 'No se pudo rechazar la ausencia.',
            type: ResultType.error,
            details: e.toString(),
          ),
        );
      }
    }
  }

  Future<void> _volverPendiente() async {
    setState(() => _isProcessing = true);

    debugPrint('⏳ Volviendo ausencia a pendiente ${widget.ausencia.id}');

    try {
      final PersonalEntity personalAprobador = await SolicitudGestionUtils.obtenerPersonalAprobador();

      final AusenciaEntity ausenciaPendiente = widget.ausencia.copyWith(
        estado: EstadoAusencia.pendiente,
        aprobadoPor: personalAprobador.id,
        fechaAprobacion: DateTime.now(),
        observaciones: _observacionesController.text.trim().isEmpty
            ? widget.ausencia.observaciones
            : _observacionesController.text.trim(),
      );

      if (mounted) {
        // Actualización directa en el BLoC (optimista)
        context.read<AusenciasBloc>().add(
              AusenciaUpdateRequested(ausenciaPendiente),
            );

        Navigator.of(context).pop();

        unawaited(
          showResultDialog(
            context: context,
            title: 'Ausencia Actualizada',
            message: 'La ausencia ha vuelto a estado pendiente.',
            type: ResultType.info,
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Error al volver ausencia a pendiente: $e');
      if (mounted) {
        setState(() => _isProcessing = false);
        unawaited(
          showResultDialog(
            context: context,
            title: 'Error al Actualizar',
            message: 'No se pudo cambiar el estado de la ausencia.',
            type: ResultType.error,
            details: e.toString(),
          ),
        );
      }
    }
  }

  Future<void> _confirmarEliminar() async {
    final bool? confirmed = await showConfirmationDialog(
      context: context,
      title: 'Confirmar Eliminación',
      message:
          '¿Estás seguro de que deseas eliminar esta ausencia? Esta acción no se puede deshacer.',
      itemDetails: <String, String>{
        'Personal': widget.nombrePersonal,
        'Periodo':
            SolicitudGestionUtils.periodo(widget.ausencia.fechaInicio, widget.ausencia.fechaFin),
        'Días': '${widget.ausencia.diasAusencia} días',
        'Estado': AusenciaFormOptions.estadoGestionLabel(widget.ausencia.estado),
      },
    );

    if (confirmed == true && mounted) {
      await _eliminar();
    }
  }

  /// Abre el diálogo para eliminar días parciales
  Future<void> _eliminarDiasParciales() async {
    final ({DateTime fechaInicio, DateTime fechaFin})? resultado =
        await showEliminarDiasParcialDialog(
      context: context,
      ausencia: widget.ausencia,
      nombrePersonal: widget.nombrePersonal,
    );

    if (resultado != null && mounted) {
      setState(() => _isProcessing = true);

      debugPrint('✂️ Eliminando días parciales:');
      debugPrint('   Desde: ${resultado.fechaInicio}');
      debugPrint('   Hasta: ${resultado.fechaFin}');

      context.read<AusenciasBloc>().add(
            AusenciaEliminarDiasParcialRequested(
              ausencia: widget.ausencia,
              fechaInicioEliminar: resultado.fechaInicio,
              fechaFinEliminar: resultado.fechaFin,
            ),
          );

      Navigator.of(context).pop();

      unawaited(
        showResultDialog(
          context: context,
          title: 'Días Eliminados',
          message: 'Los días seleccionados han sido eliminados de la ausencia.',
          type: ResultType.success,
        ),
      );
    }
  }

  Future<void> _eliminar() async {
    setState(() => _isProcessing = true);

    debugPrint('🗑️ Eliminando ausencia ${widget.ausencia.id}');

    try {
      if (mounted) {
        context.read<AusenciasBloc>().add(
              AusenciaDeleteRequested(widget.ausencia.id),
            );
        Navigator.of(context).pop();

        unawaited(
          showResultDialog(
            context: context,
            title: 'Ausencia Eliminada',
            message: 'La ausencia ha sido eliminada exitosamente.',
            type: ResultType.success,
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Error al eliminar ausencia: $e');
      if (mounted) {
        setState(() => _isProcessing = false);
        unawaited(
          showResultDialog(
            context: context,
            title: 'Error al Eliminar',
            message: 'No se pudo eliminar la ausencia.',
            type: ResultType.error,
            details: e.toString(),
          ),
        );
      }
    }
  }
}
