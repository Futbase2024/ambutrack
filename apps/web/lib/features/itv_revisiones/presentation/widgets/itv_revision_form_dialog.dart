import 'dart:async';

import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/dialogs/result_dialog.dart';
import 'package:ambutrack_web/core/widgets/gestion/form/gestion_form.dart';
import 'package:ambutrack_web/core/widgets/handlers/crud_operation_handler.dart';
import 'package:ambutrack_web/core/widgets/loading/app_loading_indicator.dart';
import 'package:ambutrack_web/features/itv_revisiones/presentation/bloc/itv_revision_bloc.dart';
import 'package:ambutrack_web/features/itv_revisiones/presentation/bloc/itv_revision_event.dart';
import 'package:ambutrack_web/features/itv_revisiones/presentation/bloc/itv_revision_state.dart';
import 'package:ambutrack_web/features/itv_revisiones/presentation/widgets/form/itv_revision_form_body.dart';
import 'package:ambutrack_web/features/itv_revisiones/presentation/widgets/form/itv_revision_form_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Formulario de ITV/Revisión (crear si [itvRevision] es null, editar en otro caso).
///
/// Requiere en el contexto: ItvRevisionBloc, VehiculosBloc y TallerBloc.
class ItvRevisionFormDialog extends StatefulWidget {
  const ItvRevisionFormDialog({this.itvRevision, this.vehiculoMatricula, super.key});

  final ItvRevisionEntity? itvRevision;

  /// Matrícula para la barra de título en edición (opcional)
  final String? vehiculoMatricula;

  @override
  State<ItvRevisionFormDialog> createState() => _ItvRevisionFormDialogState();
}

class _ItvRevisionFormDialogState extends State<ItvRevisionFormDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final ItvRevisionFormData _data = ItvRevisionFormData(original: widget.itvRevision);
  bool _isSaving = false;

  bool get _isEditing => widget.itvRevision != null;

  @override
  void dispose() {
    _data.dispose();
    super.dispose();
  }

  void _onBlocState(BuildContext context, ItvRevisionState state) {
    if (!_isSaving) {
      return;
    }
    if (state is ItvRevisionOperationSuccess) {
      CrudOperationHandler.handleSuccess(
        context: context,
        isSaving: _isSaving,
        isEditing: _isEditing,
        entityName: 'ITV/Revisión',
        onClose: () => setState(() => _isSaving = false),
      );
    } else if (state is ItvRevisionError) {
      CrudOperationHandler.handleError(
        context: context,
        isSaving: _isSaving,
        isEditing: _isEditing,
        entityName: 'ITV/Revisión',
        errorMessage: state.message,
        onClose: () => setState(() => _isSaving = false),
      );
    }
  }

  void _showSavingOverlay() {
    unawaited(
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext _) => AppLoadingOverlay(
          message: _isEditing ? 'Actualizando ITV/Revisión...' : 'Guardando ITV/Revisión...',
          color: _isEditing ? AppColors.secondary : AppColors.primary,
          icon: _isEditing ? Icons.edit : Icons.fact_check,
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    setState(() => _isSaving = true);
    _showSavingOverlay();
    try {
      final ItvRevisionEntity entity = _isEditing ? _buildUpdated() : await _buildNew();
      if (!mounted) {
        return;
      }
      context.read<ItvRevisionBloc>().add(
            _isEditing
                ? ItvRevisionUpdateRequested(itvRevision: entity)
                : ItvRevisionCreateRequested(itvRevision: entity),
          );
    } catch (e) {
      debugPrint('❌ ItvRevisionFormDialog: $e');
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop(); // cierra overlay
      setState(() => _isSaving = false);
      await showResultDialog(
        context: context,
        title: 'No se pudo guardar',
        message: 'Revisa los datos e inténtalo de nuevo.',
        details: e.toString(),
        type: ResultType.error,
      );
    }
  }

  ItvRevisionEntity _buildUpdated() {
    return widget.itvRevision!.copyWith(
      fecha: _data.fecha,
      tipo: _data.tipo,
      resultado: _data.resultado,
      kmVehiculo: _data.kmValue,
      fechaVencimiento: _data.fechaVencimiento,
      taller: _data.taller,
      numeroDocumento: _data.documentoValue,
      costoTotal: _data.costeValue,
      observaciones: _data.observacionesValue,
      estado: _data.estado,
      updatedAt: DateTime.now(),
      updatedBy: Supabase.instance.client.auth.currentUser?.id,
    );
  }

  Future<ItvRevisionEntity> _buildNew() async {
    final String? userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('Usuario no autenticado');
    }
    final Map<String, dynamic> userData =
        await Supabase.instance.client.from('usuarios').select('empresa_id').eq('id', userId).single();
    final String? empresaId = userData['empresa_id'] as String?;
    if (empresaId == null) {
      throw Exception('Usuario sin empresa asignada');
    }
    debugPrint('🚀 Creando ITV/Revisión con vehiculoId: ${_data.vehiculoId}');
    return ItvRevisionEntity(
      id: '',
      vehiculoId: _data.vehiculoId!,
      fecha: _data.fecha!,
      tipo: _data.tipo,
      resultado: _data.resultado,
      kmVehiculo: _data.kmValue,
      fechaVencimiento: _data.fechaVencimiento,
      observaciones: _data.observacionesValue,
      taller: _data.taller,
      numeroDocumento: _data.documentoValue,
      costoTotal: _data.costeValue,
      estado: _data.estado,
      empresaId: empresaId,
      createdAt: DateTime.now(),
      createdBy: userId,
      updatedAt: DateTime.now(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ItvRevisionBloc, ItvRevisionState>(
      listener: _onBlocState,
      child: GestionFormDialog(
        title: _isEditing ? 'Editar ITV / Revisión' : 'Nueva ITV / Revisión',
        subtitle: _isEditing ? widget.vehiculoMatricula : null,
        icon: Icons.fact_check_outlined,
        formKey: _formKey,
        isEditing: _isEditing,
        isSaving: _isSaving,
        onSave: _save,
        children: <Widget>[
          ItvRevisionFormBody(
            data: _data,
            isEditing: _isEditing,
            onChanged: () => setState(() {}),
          ),
        ],
      ),
    );
  }
}
