import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/utils/upper_case_text_formatter.dart';
import 'package:ambutrack_web/core/widgets/gestion/form/gestion_form.dart';
import 'package:ambutrack_web/core/widgets/handlers/crud_operation_handler.dart';
import 'package:ambutrack_web/core/widgets/loading/app_loading_indicator.dart';
import 'package:ambutrack_web/features/stock_vestuario/presentation/bloc/stock_vestuario_bloc.dart';
import 'package:ambutrack_web/features/stock_vestuario/presentation/bloc/stock_vestuario_event.dart';
import 'package:ambutrack_web/features/stock_vestuario/presentation/bloc/stock_vestuario_state.dart';
import 'package:ambutrack_web/features/stock_vestuario/presentation/widgets/form/stock_vestuario_cantidades.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

/// Formulario de Stock de Vestuario
class StockVestuarioFormDialog extends StatefulWidget {
  const StockVestuarioFormDialog({super.key, this.item});

  final StockVestuarioEntity? item;

  @override
  State<StockVestuarioFormDialog> createState() => _StockVestuarioFormDialogState();
}

class _StockVestuarioFormDialogState extends State<StockVestuarioFormDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _prendaController = TextEditingController();
  final TextEditingController _tallaController = TextEditingController();
  final TextEditingController _marcaController = TextEditingController();
  final TextEditingController _colorController = TextEditingController();
  final TextEditingController _cantidadTotalController = TextEditingController();
  final TextEditingController _cantidadAgregarController = TextEditingController();
  final TextEditingController _precioController = TextEditingController();
  final TextEditingController _proveedorController = TextEditingController();
  final TextEditingController _ubicacionController = TextEditingController();
  final TextEditingController _stockMinimoController = TextEditingController();
  final TextEditingController _observacionesController = TextEditingController();

  bool _isSaving = false;
  int _cantidadActual = 0;

  bool get _isEditing => widget.item != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _initializeFields();
    }
  }

  void _initializeFields() {
    final StockVestuarioEntity item = widget.item!;
    _cantidadActual = item.cantidadTotal;
    _prendaController.text = item.prenda;
    _tallaController.text = item.talla;
    _marcaController.text = item.marca ?? '';
    _colorController.text = item.color ?? '';
    _cantidadTotalController.text = item.cantidadTotal.toString();
    _cantidadAgregarController.text = '0';
    _precioController.text = GestionFormParse.formatDecimal(item.precioUnitario);
    _proveedorController.text = item.proveedor ?? '';
    _ubicacionController.text = item.ubicacionAlmacen ?? '';
    _stockMinimoController.text = item.stockMinimo?.toString() ?? '';
    _observacionesController.text = item.observaciones ?? '';
  }

  @override
  void dispose() {
    _prendaController.dispose();
    _tallaController.dispose();
    _marcaController.dispose();
    _colorController.dispose();
    _cantidadTotalController.dispose();
    _cantidadAgregarController.dispose();
    _precioController.dispose();
    _proveedorController.dispose();
    _ubicacionController.dispose();
    _stockMinimoController.dispose();
    _observacionesController.dispose();
    super.dispose();
  }

  void _onBlocState(BuildContext context, StockVestuarioState state) {
    if (!_isSaving) {
      return;
    }
    if (state is StockVestuarioLoaded) {
      CrudOperationHandler.handleSuccess(
        context: context,
        isSaving: _isSaving,
        isEditing: _isEditing,
        entityName: 'Stock de Vestuario',
        onClose: () => setState(() => _isSaving = false),
      );
    } else if (state is StockVestuarioError) {
      CrudOperationHandler.handleError(
        context: context,
        isSaving: _isSaving,
        isEditing: _isEditing,
        entityName: 'Stock de Vestuario',
        errorMessage: state.message,
        onClose: () => setState(() => _isSaving = false),
      );
    }
  }

  void _onAgregarChanged(String value) {
    // Actualizar cantidad total calculada
    final int agregar = int.tryParse(value) ?? 0;
    setState(() {
      _cantidadTotalController.text = (_cantidadActual + agregar).toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<StockVestuarioBloc, StockVestuarioState>(
      listener: _onBlocState,
      child: GestionFormDialog(
        title: _isEditing ? 'Editar stock de vestuario' : 'Nuevo stock de vestuario',
        subtitle: _isEditing ? '${widget.item!.prenda} · ${widget.item!.talla}' : null,
        icon: Icons.checkroom_outlined,
        formKey: _formKey,
        isEditing: _isEditing,
        isSaving: _isSaving,
        onSave: _onSave,
        children: <Widget>[
          const GestionFormSection(title: 'Prenda', first: true),
          GestionFormRow(
            label: 'Prenda',
            required: true,
            child: _UpperField(
              controller: _prendaController,
              hint: 'Ej: CAMISA, PANTALÓN, CHAQUETA',
              validator: (String? v) => (v == null || v.trim().isEmpty) ? 'La prenda es obligatoria' : null,
            ),
          ),
          GestionFormColumns(
            children: <Widget>[
              Column(
                children: <Widget>[
                  GestionFormRow(
                    label: 'Talla',
                    required: true,
                    child: _UpperField(
                      controller: _tallaController,
                      hint: 'Ej: S, M, L, XL',
                      validator: (String? v) =>
                          (v == null || v.trim().isEmpty) ? 'La talla es obligatoria' : null,
                    ),
                  ),
                  GestionFormRow(
                    label: 'Color',
                    child: _UpperField(controller: _colorController, hint: 'Opcional'),
                  ),
                ],
              ),
              GestionFormRow(
                label: 'Marca',
                child: _UpperField(controller: _marcaController, hint: 'Opcional'),
              ),
            ],
          ),
          const GestionFormSection(title: 'Cantidades'),
          StockVestuarioCantidades(
            isEditing: _isEditing,
            cantidadActual: _cantidadActual,
            cantidadTotal: _cantidadTotalController,
            cantidadAgregar: _cantidadAgregarController,
            stockMinimo: _stockMinimoController,
            onAgregarChanged: _onAgregarChanged,
          ),
          const GestionFormSection(title: 'Compra y almacén'),
          GestionFormColumns(
            children: <Widget>[
              GestionFormRow(
                label: 'Precio unitario',
                child: GestionMoneyField(controller: _precioController),
              ),
              GestionFormRow(
                label: 'Proveedor',
                child: _UpperField(controller: _proveedorController, hint: 'Opcional'),
              ),
            ],
          ),
          GestionFormRow(
            label: 'Ubicación',
            child: _UpperField(controller: _ubicacionController, hint: 'Ej: ESTANTERÍA A3, ALMACÉN 2'),
          ),
          GestionFormRow(
            label: 'Observaciones',
            multiline: true,
            child: GestionTextField(
              controller: _observacionesController,
              maxLines: 3,
              hint: 'Información adicional',
            ),
          ),
        ],
      ),
    );
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AppLoadingOverlay(
          message: _isEditing ? 'Actualizando stock...' : 'Creando stock...',
          color: _isEditing ? AppColors.secondary : AppColors.primary,
          icon: _isEditing ? Icons.edit : Icons.add_circle_outline,
        );
      },
    );

    // Calcular cantidades según modo
    final int nuevaCantidadTotal;
    final int nuevaCantidadDisponible;

    if (_isEditing) {
      // Al editar, sumar unidades agregadas al total y disponible
      final int unidadesAgregadas = int.tryParse(_cantidadAgregarController.text.trim()) ?? 0;
      nuevaCantidadTotal = _cantidadActual + unidadesAgregadas;
      nuevaCantidadDisponible = widget.item!.cantidadDisponible + unidadesAgregadas;
    } else {
      // Al crear, cantidad total = disponible (no hay asignadas aún)
      nuevaCantidadTotal = int.parse(_cantidadTotalController.text.trim());
      nuevaCantidadDisponible = nuevaCantidadTotal;
    }

    final StockVestuarioEntity item = StockVestuarioEntity(
      id: _isEditing ? widget.item!.id : const Uuid().v4(),
      prenda: _prendaController.text.trim(),
      talla: _tallaController.text.trim(),
      marca: _marcaController.text.trim().isEmpty ? null : _marcaController.text.trim(),
      color: _colorController.text.trim().isEmpty ? null : _colorController.text.trim(),
      cantidadTotal: nuevaCantidadTotal,
      cantidadAsignada: _isEditing ? widget.item!.cantidadAsignada : 0,
      cantidadDisponible: nuevaCantidadDisponible,
      precioUnitario:
          _precioController.text.trim().isEmpty ? null : GestionFormParse.decimal(_precioController.text),
      proveedor: _proveedorController.text.trim().isEmpty ? null : _proveedorController.text.trim(),
      ubicacionAlmacen: _ubicacionController.text.trim().isEmpty ? null : _ubicacionController.text.trim(),
      stockMinimo: _stockMinimoController.text.trim().isEmpty ? null : int.tryParse(_stockMinimoController.text.trim()),
      observaciones: _observacionesController.text.trim().isEmpty ? null : _observacionesController.text.trim(),
      activo: true,
    );

    if (_isEditing) {
      context.read<StockVestuarioBloc>().add(StockVestuarioUpdateRequested(item));
    } else {
      context.read<StockVestuarioBloc>().add(StockVestuarioCreateRequested(item));
    }
  }
}

/// Texto en mayúsculas (prenda, talla, marca, proveedor...)
class _UpperField extends StatelessWidget {
  const _UpperField({required this.controller, this.hint, this.validator});

  final TextEditingController controller;
  final String? hint;
  final FormFieldValidator<String>? validator;

  @override
  Widget build(BuildContext context) {
    return GestionTextField(
      controller: controller,
      hint: hint,
      validator: validator,
      inputFormatters: <TextInputFormatter>[UpperCaseTextFormatter()],
    );
  }
}
