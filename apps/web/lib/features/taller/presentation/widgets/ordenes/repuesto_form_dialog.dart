import 'dart:async';

import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/handlers/crud_operation_handler.dart';
import 'package:ambutrack_web/core/widgets/loading/app_loading_indicator.dart';
import 'package:ambutrack_web/features/taller/domain/repositories/proveedor_taller_repository.dart';
import 'package:ambutrack_web/features/taller/presentation/bloc/repuesto_orden_bloc.dart';
import 'package:ambutrack_web/features/taller/presentation/bloc/repuesto_orden_event.dart';
import 'package:ambutrack_web/features/taller/presentation/bloc/repuesto_orden_state.dart';
import 'package:ambutrack_web/features/taller/presentation/widgets/form/taller_form_components.dart';
import 'package:ambutrack_web/features/taller/presentation/widgets/ordenes/orden_form_inputs.dart';
import 'package:ambutrack_web/features/taller/presentation/widgets/ordenes/repuesto_form_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

/// Diálogo para añadir/editar un repuesto de una orden
class RepuestoFormDialog extends StatefulWidget {
  const RepuestoFormDialog({required this.ordenId, this.repuesto, super.key});

  final String ordenId;
  final RepuestoOrdenEntity? repuesto;

  @override
  State<RepuestoFormDialog> createState() => _RepuestoFormDialogState();
}

class _RepuestoFormDialogState extends State<RepuestoFormDialog> {
  static const String _entityName = 'Repuesto';

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _descripcion = TextEditingController();
  final TextEditingController _referencia = TextEditingController();
  final TextEditingController _cantidad = TextEditingController(text: '1');
  final TextEditingController _precio = TextEditingController();
  final TextEditingController _observaciones = TextEditingController();

  List<ProveedorTallerEntity> _proveedores = <ProveedorTallerEntity>[];
  bool _loading = true;
  bool _isSaving = false;
  String? _proveedorId;
  EstadoRepuesto _estado = EstadoRepuesto.solicitado;

  bool get _isEditing => widget.repuesto != null;

  @override
  void initState() {
    super.initState();
    final RepuestoOrdenEntity? r = widget.repuesto;
    if (r != null) {
      _descripcion.text = r.descripcion;
      _referencia.text = r.referencia ?? '';
      _cantidad.text = r.cantidad.toString();
      _precio.text = numeroATexto(r.precioUnitario);
      _observaciones.text = r.observaciones ?? '';
      _proveedorId = r.proveedorId;
      _estado = r.estado;
    }
    unawaited(_loadProveedores());
  }

  Future<void> _loadProveedores() async {
    final List<ProveedorTallerEntity> proveedores = (await getIt<ProveedorTallerRepository>().getActivos()).fold(
      (Exception _) => <ProveedorTallerEntity>[],
      (List<ProveedorTallerEntity> p) => p,
    );
    if (mounted) {
      setState(() {
        _proveedores = proveedores;
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    for (final TextEditingController c in <TextEditingController>[
      _descripcion,
      _referencia,
      _cantidad,
      _precio,
      _observaciones,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  /// Fecha de pedido/recepción: se conserva la existente o se fija al alcanzar el estado
  DateTime? _fechaSi(bool alcanzado, DateTime? actual) => alcanzado ? (actual ?? DateTime.now()) : null;

  RepuestoOrdenEntity _buildEntity() {
    final RepuestoOrdenEntity? base = widget.repuesto;
    return RepuestoOrdenEntity(
      id: base?.id ?? const Uuid().v4(),
      ordenId: widget.ordenId,
      proveedorId: _proveedorId,
      descripcion: _descripcion.text.trim(),
      referencia: textOrNull(_referencia),
      cantidad: parseEntero(_cantidad.text) ?? 1,
      precioUnitario: parseDecimal(_precio.text) ?? 0,
      estado: _estado,
      fechaPedido: _fechaSi(_estado.index >= EstadoRepuesto.pedido.index, base?.fechaPedido),
      fechaRecibido: _fechaSi(_estado.index >= EstadoRepuesto.recibido.index, base?.fechaRecibido),
      observaciones: textOrNull(_observaciones),
      createdAt: base?.createdAt ?? DateTime.now(),
    );
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() => _isSaving = true);
    unawaited(
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext _) => AppLoadingOverlay(
          message: _isEditing ? 'Actualizando repuesto...' : 'Añadiendo repuesto...',
          color: _isEditing ? AppColors.secondary : AppColors.primary,
          icon: _isEditing ? Icons.edit : Icons.add_circle_outline,
        ),
      ),
    );
    final RepuestoOrdenEntity entity = _buildEntity();
    context.read<RepuestoOrdenBloc>().add(
      _isEditing ? RepuestoOrdenUpdateRequested(repuesto: entity) : RepuestoOrdenCreateRequested(repuesto: entity),
    );
  }

  void _onBlocResult(BuildContext context, RepuestoOrdenState state) {
    const List<RepuestoOperacion> ops = <RepuestoOperacion>[RepuestoOperacion.crear, RepuestoOperacion.actualizar];
    if (!_isSaving) {
      return;
    }
    void reset() => _isSaving = false;
    if (state is RepuestoOrdenOperationSuccess && ops.contains(state.operacion)) {
      CrudOperationHandler.handleSuccess(
        context: context,
        isSaving: true,
        isEditing: _isEditing,
        entityName: _entityName,
        onClose: reset,
      );
    } else if (state is RepuestoOrdenOperationFailure && ops.contains(state.operacion)) {
      CrudOperationHandler.handleError(
        context: context,
        isSaving: true,
        isEditing: _isEditing,
        entityName: _entityName,
        errorMessage: state.message,
        onClose: reset,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<RepuestoOrdenBloc, RepuestoOrdenState>(
      listener: _onBlocResult,
      child: TallerFormDialogShell(
        formKey: _formKey,
        header: TallerFormHeader(
          icon: Icons.settings_suggest_outlined,
          color: AppColors.primary,
          title: _isEditing ? 'Editar Repuesto' : 'Añadir Repuesto',
          subtitle: 'Pieza o material utilizado en la reparación',
        ),
        fields: _loading
            ? const Padding(
                padding: EdgeInsets.all(32),
                child: AppLoadingIndicator(message: 'Cargando proveedores...'),
              )
            : RepuestoFormFields(
                descripcion: _descripcion,
                referencia: _referencia,
                cantidad: _cantidad,
                precio: _precio,
                observaciones: _observaciones,
                proveedores: _proveedores,
                proveedorId: _proveedorId,
                estado: _estado,
                onProveedor: (String? v) => setState(() => _proveedorId = v),
                onEstado: (EstadoRepuesto v) => setState(() => _estado = v),
              ),
        actions: TallerFormActions(isSaving: _isSaving || _loading, isEditing: _isEditing, onSave: _onSave),
      ),
    );
  }
}
