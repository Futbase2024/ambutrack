import 'dart:async';

import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/form/gestion_form.dart';
import 'package:ambutrack_web/core/widgets/handlers/crud_operation_handler.dart';
import 'package:ambutrack_web/core/widgets/loading/app_loading_indicator.dart';
import 'package:ambutrack_web/features/mantenimiento/presentation/bloc/mantenimiento_bloc.dart';
import 'package:ambutrack_web/features/mantenimiento/presentation/bloc/mantenimiento_event.dart';
import 'package:ambutrack_web/features/mantenimiento/presentation/bloc/mantenimiento_state.dart';
import 'package:ambutrack_web/features/mantenimiento/presentation/widgets/form/mantenimiento_edit_form_body.dart';
import 'package:ambutrack_web/features/mantenimiento/presentation/widgets/form/mantenimiento_form_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Diálogo para editar un mantenimiento existente
///
/// Requiere en el contexto: MantenimientoBloc y TallerBloc.
class MantenimientoEditDialog extends StatefulWidget {
  const MantenimientoEditDialog({
    required this.mantenimiento,
    super.key,
  });

  final MantenimientoEntity mantenimiento;

  @override
  State<MantenimientoEditDialog> createState() => _MantenimientoEditDialogState();
}

class _MantenimientoEditDialogState extends State<MantenimientoEditDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final MantenimientoEditFormData _data = MantenimientoEditFormData(widget.mantenimiento);
  bool _isLoading = false;

  @override
  void dispose() {
    _data.dispose();
    super.dispose();
  }

  void _onBlocState(BuildContext context, MantenimientoState state) {
    if (!_isLoading) {
      return;
    }
    if (state is MantenimientoError) {
      CrudOperationHandler.handleError(
        context: context,
        isSaving: _isLoading,
        isEditing: true,
        entityName: 'Mantenimiento',
        errorMessage: state.message,
        onClose: () => setState(() => _isLoading = false),
      );
    } else if (state is MantenimientoLoaded) {
      CrudOperationHandler.handleSuccess(
        context: context,
        isSaving: _isLoading,
        isEditing: true,
        entityName: 'Mantenimiento',
        onClose: () => setState(() => _isLoading = false),
      );
    }
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);
    unawaited(
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext _) => const AppLoadingOverlay(
          message: 'Actualizando Mantenimiento...',
          color: AppColors.secondary,
          icon: Icons.edit,
        ),
      ),
    );

    final MantenimientoEntity m = widget.mantenimiento;
    // Se construye la entidad completa (no copyWith) para que los campos que el
    // usuario ha vaciado queden en null y se guarden vacíos
    final MantenimientoEntity updatedMantenimiento = MantenimientoEntity(
      id: m.id,
      vehiculoId: m.vehiculoId,
      fecha: _data.fecha,
      kmVehiculo: GestionFormParse.entero(_data.km.text)?.toDouble() ?? m.kmVehiculo,
      tipoMantenimiento: _data.tipo,
      descripcion: _data.descripcion.text,
      trabajosRealizados: MantenimientoEditFormData.textOrNull(_data.trabajos),
      taller: _data.taller,
      mecanicoResponsable: MantenimientoEditFormData.textOrNull(_data.mecanico),
      numeroOrden: MantenimientoEditFormData.textOrNull(_data.numeroOrden),
      costoManoObra: MantenimientoEditFormData.decimalOrNull(_data.costeManoObra),
      costoRepuestos: MantenimientoEditFormData.decimalOrNull(_data.costeRepuestos),
      costoTotal: GestionFormParse.decimal(_data.costeTotal.text) ?? 0,
      estado: _data.estado,
      fechaProgramada: _data.fechaProgramada,
      fechaInicio: _data.fechaInicio,
      fechaFin: _data.fechaFin,
      tiempoInoperativoHoras: MantenimientoEditFormData.decimalOrNull(_data.horasInoperativo),
      proximoKmSugerido: GestionFormParse.entero(_data.proximoKm.text),
      proximaFechaSugerida: _data.proximaFechaSugerida,
      archivos: m.archivos,
      facturaUrl: m.facturaUrl,
      empresaId: m.empresaId,
      createdAt: m.createdAt,
      createdBy: m.createdBy,
      updatedAt: DateTime.now(),
      updatedBy: Supabase.instance.client.auth.currentUser?.id,
    );

    debugPrint('🔧 MantenimientoEditDialog: Actualizando ${m.id}');
    context.read<MantenimientoBloc>().add(
          MantenimientoUpdateRequested(mantenimiento: updatedMantenimiento),
        );
  }

  @override
  Widget build(BuildContext context) {
    final String id = widget.mantenimiento.id;
    return BlocListener<MantenimientoBloc, MantenimientoState>(
      listener: _onBlocState,
      child: GestionFormDialog(
        title: 'Editar mantenimiento',
        subtitle: 'ID ${id.length > 12 ? '${id.substring(0, 12)}…' : id}',
        icon: Icons.build_circle_outlined,
        size: GestionFormSize.large,
        formKey: _formKey,
        isEditing: true,
        isSaving: _isLoading,
        saveLabel: 'Guardar cambios',
        onSave: _handleSubmit,
        children: <Widget>[
          MantenimientoEditFormBody(data: _data, onChanged: () => setState(() {})),
        ],
      ),
    );
  }
}
