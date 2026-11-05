import 'dart:async';

import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/buttons/app_button.dart';
import 'package:ambutrack_web/core/widgets/dialogs/app_dialog.dart';
import 'package:ambutrack_web/core/widgets/handlers/crud_operation_handler.dart';
import 'package:ambutrack_web/core/widgets/loading/app_loading_indicator.dart';
import 'package:ambutrack_web/features/contratos/presentation/bloc/bloc.dart';
import 'package:ambutrack_web/features/contratos/presentation/widgets/form/contrato_form_fields.dart';
import 'package:ambutrack_web/features/contratos/presentation/widgets/form/contrato_form_sections.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Diálogo para crear o editar un contrato
class ContratoFormDialog extends StatefulWidget {
  const ContratoFormDialog({
    super.key,
    this.contrato,
    this.isViewOnly = false,
  });

  final ContratoEntity? contrato;
  final bool isViewOnly;

  @override
  State<ContratoFormDialog> createState() => _ContratoFormDialogState();
}

class _ContratoFormDialogState extends State<ContratoFormDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Controllers
  late TextEditingController _codigoController;
  late TextEditingController _descripcionController;
  late TextEditingController _importeController;
  late TextEditingController _condicionesController;

  // Datos del formulario
  String? _selectedHospitalId;
  DateTime? _fechaInicio;
  DateTime? _fechaFin;
  String? _tipoContrato;
  bool _activo = true;

  // Listas
  List<CentroHospitalarioEntity> _hospitales = <CentroHospitalarioEntity>[];
  bool _isLoadingHospitales = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _initControllers();
    _loadHospitales();
  }

  void _initControllers() {
    _codigoController = TextEditingController(text: widget.contrato?.codigo);
    _descripcionController =
        TextEditingController(text: widget.contrato?.descripcion);
    _importeController = TextEditingController(
      text: widget.contrato?.importeMensual?.toStringAsFixed(2),
    );
    _condicionesController = TextEditingController();

    if (widget.contrato != null) {
      _selectedHospitalId = widget.contrato!.hospitalId;
      _fechaInicio = widget.contrato!.fechaInicio;
      _fechaFin = widget.contrato!.fechaFin;
      _tipoContrato = widget.contrato!.tipoContrato;
      _activo = widget.contrato!.activo;
    }
  }

  Future<void> _loadHospitales() async {
    try {
      final CentroHospitalarioDataSource dataSource =
          CentroHospitalarioDataSourceFactory.createSupabase(
        supabase: Supabase.instance.client,
      );

      final List<CentroHospitalarioEntity> hospitales =
          await dataSource.getAll();

      if (mounted) {
        setState(() {
          _hospitales = hospitales
              .where((CentroHospitalarioEntity h) => h.activo)
              .toList();
          _isLoadingHospitales = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Error al cargar hospitales: $e');
      if (mounted) {
        setState(() {
          _isLoadingHospitales = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _codigoController.dispose();
    _descripcionController.dispose();
    _importeController.dispose();
    _condicionesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingHospitales) {
      return ContratoFormLoadingDialog(
        title: widget.contrato == null ? 'Nuevo Contrato' : 'Editar Contrato',
      );
    }

    return BlocListener<ContratoBloc, ContratoState>(
      listener: _onBlocStateChanged,
      child: AppDialog(
        title: widget.isViewOnly
            ? 'Ver Contrato'
            : (widget.contrato == null ? 'Nuevo Contrato' : 'Editar Contrato'),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: ContratoFormFields(
              isViewOnly: widget.isViewOnly,
              codigoController: _codigoController,
              importeController: _importeController,
              descripcionController: _descripcionController,
              hospitales: _hospitales,
              selectedHospitalId: _selectedHospitalId,
              tipoContrato: _tipoContrato,
              fechaInicio: _fechaInicio,
              fechaFin: _fechaFin,
              activo: _activo,
              onHospitalChanged: (String? value) => setState(() => _selectedHospitalId = value),
              onTipoChanged: (String? value) => setState(() => _tipoContrato = value),
              onFechaInicioChanged: (DateTime? date) => setState(() => _fechaInicio = date),
              onFechaFinChanged: (DateTime? date) => setState(() => _fechaFin = date),
              onActivoChanged: (bool value) => setState(() => _activo = value),
            ),
          ),
        ),
        actions: <Widget>[
          AppButton(
            onPressed: () => Navigator.of(context).pop(),
            label: widget.isViewOnly ? 'Cerrar' : 'Cancelar',
            variant: AppButtonVariant.text,
          ),
          if (!widget.isViewOnly)
            AppButton(
              onPressed: _onSave,
              label: widget.contrato == null ? 'Crear' : 'Actualizar',
            ),
        ],
      ),
    );
  }

  void _onBlocStateChanged(BuildContext context, ContratoState state) {
    if (!_isSaving) {
      return;
    }
    void reset() => _isSaving = false;
    if (state is ContratoOperationSuccess) {
      CrudOperationHandler.handleSuccess(
        context: context,
        isSaving: true,
        isEditing: widget.contrato != null,
        entityName: 'Contrato',
        onClose: reset,
      );
    } else if (state is ContratoError) {
      CrudOperationHandler.handleError(
        context: context,
        isSaving: true,
        isEditing: widget.contrato != null,
        entityName: 'Contrato',
        errorMessage: state.message,
        onClose: reset,
      );
    }
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_fechaInicio == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La fecha de inicio es obligatoria'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final ContratoEntity contrato = ContratoEntity(
      id: widget.contrato?.id ?? '',
      codigo: _codigoController.text.trim(),
      hospitalId: _selectedHospitalId!,
      fechaInicio: _fechaInicio!,
      fechaFin: _fechaFin,
      descripcion: _descripcionController.text.trim().isEmpty
          ? null
          : _descripcionController.text.trim(),
      tipoContrato: _tipoContrato,
      importeMensual: _importeController.text.trim().isEmpty
          ? null
          : double.tryParse(_importeController.text.trim()),
      activo: _activo,
      createdAt: widget.contrato?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
      createdBy: widget.contrato?.createdBy,
      updatedBy: widget.contrato?.updatedBy,
    );

    setState(() => _isSaving = true);

    final bool isEditing = widget.contrato != null;
    unawaited(
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext _) => AppLoadingOverlay(
          message: isEditing ? 'Actualizando contrato...' : 'Creando contrato...',
          color: isEditing ? AppColors.secondary : AppColors.primary,
          icon: isEditing ? Icons.edit : Icons.add_circle_outline,
        ),
      ),
    );

    if (widget.contrato == null) {
      context.read<ContratoBloc>().add(ContratoCreateRequested(contrato));
    } else {
      context.read<ContratoBloc>().add(ContratoUpdateRequested(contrato));
    }
  }
}
