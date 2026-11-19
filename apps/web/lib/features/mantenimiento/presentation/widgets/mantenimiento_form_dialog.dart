import 'dart:async';

import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/utils/crud_operation_handler.dart';
import 'package:ambutrack_web/core/widgets/dialogs/result_dialog.dart';
import 'package:ambutrack_web/core/widgets/gestion/form/gestion_form.dart';
import 'package:ambutrack_web/core/widgets/loading/app_loading_indicator.dart';
import 'package:ambutrack_web/features/mantenimiento/presentation/bloc/mantenimiento_bloc.dart';
import 'package:ambutrack_web/features/mantenimiento/presentation/bloc/mantenimiento_event.dart';
import 'package:ambutrack_web/features/mantenimiento/presentation/bloc/mantenimiento_state.dart';
import 'package:ambutrack_web/features/mantenimiento/presentation/widgets/form/mantenimiento_create_form_body.dart';
import 'package:ambutrack_web/features/mantenimiento/presentation/widgets/form/mantenimiento_form_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

/// Diálogo para programar mantenimientos
///
/// Requiere en el contexto: MantenimientoBloc, VehiculosBloc y TallerBloc.
class MantenimientoFormDialog extends StatefulWidget {
  const MantenimientoFormDialog({super.key, this.mantenimiento});

  final MantenimientoEntity? mantenimiento;

  @override
  State<MantenimientoFormDialog> createState() => _MantenimientoFormDialogState();
}

class _MantenimientoFormDialogState extends State<MantenimientoFormDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final MantenimientoCreateFormData _data = MantenimientoCreateFormData(original: widget.mantenimiento);
  bool _isSaving = false;

  bool get _isEditing => widget.mantenimiento != null;

  @override
  void dispose() {
    _data.dispose();
    super.dispose();
  }

  void _onBlocState(BuildContext context, MantenimientoState state) {
    if (state is MantenimientoError && _isSaving) {
      CrudOperationHandler.handleError(
        context: context,
        isSaving: _isSaving,
        errorMessage: state.message,
        onComplete: () {
          if (mounted) {
            setState(() => _isSaving = false);
          }
        },
      );
    }

    if (state is MantenimientoLoaded && _isSaving) {
      CrudOperationHandler.handleSuccess(
        context: context,
        isSaving: _isSaving,
        isEditing: _isEditing,
        entityName: 'Mantenimiento',
        onComplete: () {
          if (mounted) {
            setState(() => _isSaving = false);
          }
        },
      );
    }
  }

  Future<void> _showError(String title, String message, {ResultType type = ResultType.error}) {
    return showResultDialog(context: context, title: title, message: message, type: type);
  }

  /// Cierra el overlay de guardado y muestra el error
  Future<void> _abortSave(String message) async {
    if (!mounted) {
      return;
    }
    Navigator.of(context).pop(); // Cerrar loading overlay
    setState(() => _isSaving = false);
    await _showError('No se pudo guardar', message);
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_data.vehiculo == null) {
      await _showError('Vehículo obligatorio', 'Selecciona un vehículo', type: ResultType.warning);
      return;
    }

    // Marcar que estamos guardando
    setState(() => _isSaving = true);

    unawaited(
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext dialogContext) => AppLoadingOverlay(
          message: _isEditing ? 'Actualizando Mantenimiento...' : 'Guardando Mantenimiento...',
          color: AppColors.secondary,
          icon: Icons.build_circle,
        ),
      ),
    );

    try {
      // Obtener userId del usuario actual
      final String? userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        await _abortSave('Error: Usuario no autenticado');
        return;
      }

      // Consultar la tabla usuarios para obtener empresa_id
      final Map<String, dynamic> userData =
          await Supabase.instance.client.from('usuarios').select('empresa_id').eq('id', userId).single();
      final String? empresaId = userData['empresa_id'] as String?;
      if (empresaId == null) {
        await _abortSave('Error: El usuario no tiene empresa asignada');
        return;
      }

      final MantenimientoEntity mantenimiento = MantenimientoEntity(
        id: widget.mantenimiento?.id ?? const Uuid().v4(),
        vehiculoId: _data.vehiculo!.id,
        fecha: _data.fecha,
        kmVehiculo: _data.kmValue,
        tipoMantenimiento: _data.tipo,
        descripcion: _data.descripcion.text.trim(),
        taller: _data.taller,
        costoTotal: _data.costeValue,
        estado: EstadoMantenimiento.programado,
        fechaProgramada: _data.fechaProgramada,
        empresaId: empresaId,
        createdAt: DateTime.now(),
        createdBy: userId,
      );

      if (!mounted) {
        return;
      }

      context.read<MantenimientoBloc>().add(
            _isEditing
                ? MantenimientoUpdateRequested(mantenimiento: mantenimiento)
                : MantenimientoCreateRequested(mantenimiento: mantenimiento),
          );
    } catch (e) {
      debugPrint('❌ Error al guardar mantenimiento: $e');
      await _abortSave('Error al obtener datos del usuario: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MantenimientoBloc, MantenimientoState>(
      listener: _onBlocState,
      child: GestionFormDialog(
        title: _isEditing ? 'Editar mantenimiento' : 'Nuevo mantenimiento',
        subtitle: _isEditing ? _data.descripcion.text : null,
        icon: Icons.build_circle_outlined,
        formKey: _formKey,
        isEditing: _isEditing,
        isSaving: _isSaving,
        onSave: _handleSave,
        children: <Widget>[
          MantenimientoCreateFormBody(
            data: _data,
            isEditing: _isEditing,
            onChanged: () => setState(() {}),
          ),
        ],
      ),
    );
  }
}
