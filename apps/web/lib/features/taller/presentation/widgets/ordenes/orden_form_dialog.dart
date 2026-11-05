import 'dart:async';

import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/handlers/crud_operation_handler.dart';
import 'package:ambutrack_web/core/widgets/loading/app_loading_indicator.dart';
import 'package:ambutrack_web/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ambutrack_web/features/auth/presentation/bloc/auth_state.dart';
import 'package:ambutrack_web/features/taller/domain/repositories/taller_repository.dart';
import 'package:ambutrack_web/features/taller/presentation/bloc/orden_reparacion_bloc.dart';
import 'package:ambutrack_web/features/taller/presentation/bloc/orden_reparacion_event.dart';
import 'package:ambutrack_web/features/taller/presentation/bloc/orden_reparacion_state.dart';
import 'package:ambutrack_web/features/taller/presentation/widgets/form/taller_form_components.dart';
import 'package:ambutrack_web/features/taller/presentation/widgets/ordenes/orden_form_fields.dart';
import 'package:ambutrack_web/features/taller/presentation/widgets/ordenes/orden_form_inputs.dart';
import 'package:ambutrack_web/features/vehiculos/domain/repositories/vehiculo_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

/// Diálogo de formulario para crear/editar una Orden de Reparación
class OrdenFormDialog extends StatefulWidget {
  const OrdenFormDialog({super.key, this.orden});

  final OrdenReparacionEntity? orden;

  @override
  State<OrdenFormDialog> createState() => _OrdenFormDialogState();
}

class _OrdenFormDialogState extends State<OrdenFormDialog> {
  static const String _empresaFallback = '00000000-0000-0000-0000-000000000001';
  static const String _entityName = 'Orden de Reparación';

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final OrdenFormControllers _c = OrdenFormControllers();

  List<VehiculoEntity> _vehiculos = <VehiculoEntity>[];
  List<TallerEntity> _talleres = <TallerEntity>[];
  bool _loadingCatalogos = true;
  bool _isSaving = false;

  String? _vehiculoId;
  String? _tallerId;
  OrigenOrdenReparacion _origen = OrigenOrdenReparacion.averia;
  PrioridadOrdenReparacion _prioridad = PrioridadOrdenReparacion.normal;
  DateTime _fechaEntrada = DateTime.now();
  bool _cubiertoSeguro = false;

  bool get _isEditing => widget.orden != null;

  @override
  void initState() {
    super.initState();
    final OrdenReparacionEntity? o = widget.orden;
    if (o != null) {
      _c.populate(o);
      _vehiculoId = o.vehiculoId;
      _tallerId = o.tallerId;
      _origen = o.origen;
      _prioridad = o.prioridad;
      _fechaEntrada = o.fechaEntrada.toLocal();
      _cubiertoSeguro = o.cubiertoSeguro;
    }
    unawaited(_loadCatalogos());
  }

  Future<void> _loadCatalogos() async {
    try {
      final List<VehiculoEntity> vehiculos = await getIt<VehiculoRepository>().getAll(orderBy: 'matricula');
      final List<TallerEntity> talleres = (await getIt<TallerRepository>().getActivos()).fold(
        (Exception _) => <TallerEntity>[],
        (List<TallerEntity> t) => t,
      );
      if (mounted) {
        setState(() {
          _vehiculos = vehiculos;
          _talleres = talleres;
        });
      }
    } catch (e) {
      debugPrint('❌ OrdenFormDialog: Error cargando catálogos: $e');
    } finally {
      if (mounted) {
        setState(() => _loadingCatalogos = false);
      }
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  Future<void> _pickFecha() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _fechaEntrada,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('es', 'ES'),
    );
    if (picked != null) {
      setState(() => _fechaEntrada = picked);
    }
  }

  String _empresaId() {
    final AuthState authState = context.read<AuthBloc>().state;
    return authState is AuthAuthenticated ? (authState.user.empresaId ?? _empresaFallback) : _empresaFallback;
  }

  OrdenReparacionEntity _buildEntity() {
    final OrdenReparacionEntity? base = widget.orden;
    final String? mecanico = textOrNull(_c.mecanico)?.toUpperCase();
    return OrdenReparacionEntity(
      id: base?.id ?? const Uuid().v4(),
      empresaId: base?.empresaId ?? _empresaId(),
      numeroOrden: base?.numeroOrden ?? '',
      vehiculoId: _vehiculoId!,
      tallerId: _tallerId,
      origen: _origen,
      incidenciaId: base?.incidenciaId,
      mantenimientoId: base?.mantenimientoId,
      estado: base?.estado ?? EstadoOrdenReparacion.abierta,
      prioridad: _prioridad,
      diagnostico: textOrNull(_c.diagnostico),
      trabajosRealizados: _isEditing ? textOrNull(_c.trabajos) : null,
      kilometrajeEntrada: parseEntero(_c.kmEntrada.text),
      kilometrajeSalida: _isEditing ? parseEntero(_c.kmSalida.text) : null,
      mecanicoAsignado: base?.mecanicoAsignado,
      mecanicoNombre: mecanico,
      fechaEntrada: _fechaEntrada,
      fechaInicioTrabajo: base?.fechaInicioTrabajo,
      fechaEsperaRepuestos: base?.fechaEsperaRepuestos,
      fechaFinalizacion: base?.fechaFinalizacion,
      fechaCierre: base?.fechaCierre,
      manoObraHoras: parseDecimal(_c.horas.text) ?? 0,
      costoManoObra: parseDecimal(_c.costeManoObra.text) ?? 0,
      costoRepuestos: base?.costoRepuestos ?? 0,
      costoGrua: parseDecimal(_c.costeGrua.text) ?? 0,
      cubiertoSeguro: _cubiertoSeguro,
      garantiaMeses: parseEntero(_c.garantia.text),
      fechaFinGarantia: base?.fechaFinGarantia,
      observaciones: textOrNull(_c.observaciones),
      createdAt: base?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
      createdBy: base?.createdBy,
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
          message: _isEditing ? 'Actualizando orden...' : 'Creando orden...',
          color: _isEditing ? AppColors.secondary : AppColors.primary,
          icon: _isEditing ? Icons.edit : Icons.add_circle_outline,
        ),
      ),
    );
    final OrdenReparacionEntity entity = _buildEntity();
    context.read<OrdenReparacionBloc>().add(
      _isEditing ? OrdenReparacionUpdateRequested(orden: entity) : OrdenReparacionCreateRequested(orden: entity),
    );
  }

  void _onBlocResult(BuildContext context, OrdenReparacionState state) {
    const List<OrdenOperacion> ops = <OrdenOperacion>[OrdenOperacion.crear, OrdenOperacion.actualizar];
    if (!_isSaving) {
      return;
    }
    void reset() => _isSaving = false;
    if (state is OrdenReparacionOperationSuccess && ops.contains(state.operacion)) {
      CrudOperationHandler.handleSuccess(
        context: context,
        isSaving: true,
        isEditing: _isEditing,
        entityName: _entityName,
        onClose: reset,
      );
    } else if (state is OrdenReparacionOperationFailure && ops.contains(state.operacion)) {
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

  OrdenFormSelection get _selection => OrdenFormSelection(
    vehiculoId: _vehiculoId,
    tallerId: _tallerId,
    origen: _origen,
    prioridad: _prioridad,
    fechaEntrada: _fechaEntrada,
    cubiertoSeguro: _cubiertoSeguro,
  );

  OrdenFormCallbacks get _callbacks => OrdenFormCallbacks(
    onVehiculo: (String? v) => setState(() => _vehiculoId = v),
    onTaller: (String? v) => setState(() => _tallerId = v),
    onOrigen: (OrigenOrdenReparacion v) => setState(() => _origen = v),
    onPrioridad: (PrioridadOrdenReparacion v) => setState(() => _prioridad = v),
    onPickFecha: _pickFecha,
    onSeguro: (bool v) => setState(() => _cubiertoSeguro = v),
  );

  @override
  Widget build(BuildContext context) {
    return BlocListener<OrdenReparacionBloc, OrdenReparacionState>(
      listener: _onBlocResult,
      child: TallerFormDialogShell(
        formKey: _formKey,
        maxWidth: 820,
        header: TallerFormHeader(
          icon: Icons.build,
          color: AppColors.primary,
          title: _isEditing ? 'Editar Orden ${widget.orden!.numeroOrden}' : 'Nueva Orden de Reparación',
          subtitle: _isEditing ? 'Modifica los datos de la orden' : 'Registra la entrada de un vehículo en el taller',
        ),
        fields: _loadingCatalogos
            ? const Padding(
                padding: EdgeInsets.all(32),
                child: AppLoadingIndicator(message: 'Cargando vehículos y talleres...'),
              )
            : OrdenFormFields(
                controllers: _c,
                isEditing: _isEditing,
                vehiculos: _vehiculos,
                talleres: _talleres,
                selection: _selection,
                callbacks: _callbacks,
              ),
        actions: TallerFormActions(isSaving: _isSaving || _loadingCatalogos, isEditing: _isEditing, onSave: _onSave),
      ),
    );
  }
}
