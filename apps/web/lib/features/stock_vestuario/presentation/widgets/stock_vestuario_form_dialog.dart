import 'package:ambutrack_core/ambutrack_core.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/widgets/buttons/app_button.dart';
import 'package:ambutrack_web/core/widgets/dialogs/app_dialog.dart';
import 'package:ambutrack_web/core/widgets/handlers/crud_operation_handler.dart';
import 'package:ambutrack_web/core/widgets/loading/app_loading_indicator.dart';
import 'package:ambutrack_web/features/stock_vestuario/presentation/bloc/stock_vestuario_bloc.dart';
import 'package:ambutrack_web/features/stock_vestuario/presentation/bloc/stock_vestuario_event.dart';
import 'package:ambutrack_web/features/stock_vestuario/presentation/bloc/stock_vestuario_state.dart';
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
    _precioController.text = item.precioUnitario?.toString() ?? '';
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

  @override
  Widget build(BuildContext context) {
    return BlocListener<StockVestuarioBloc, StockVestuarioState>(
      listener: (BuildContext context, StockVestuarioState state) {
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
      },
      child: AppDialog(
        title: _isEditing ? 'Editar Stock de Vestuario' : 'Agregar Stock de Vestuario',
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Prenda
              TextFormField(
                controller: _prendaController,
                textInputAction: TextInputAction.next,
                textCapitalization: TextCapitalization.characters,
                inputFormatters: <TextInputFormatter>[
                  UpperCaseTextFormatter(),
                ],
                decoration: const InputDecoration(
                  labelText: 'Prenda *',
                  hintText: 'Ej: CAMISA, PANTALÓN, CHAQUETA',
                ),
                validator: (String? value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'La prenda es obligatoria';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSizes.spacing),

              Row(
                children: <Widget>[
                  // Talla
                  Expanded(
                    child: TextFormField(
                      controller: _tallaController,
                      textInputAction: TextInputAction.next,
                      textCapitalization: TextCapitalization.characters,
                      inputFormatters: <TextInputFormatter>[
                        UpperCaseTextFormatter(),
                      ],
                      decoration: const InputDecoration(
                        labelText: 'Talla *',
                        hintText: 'Ej: S, M, L, XL',
                      ),
                      validator: (String? value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'La talla es obligatoria';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: AppSizes.spacing),

                  // Marca
                  Expanded(
                    child: TextFormField(
                      controller: _marcaController,
                      textInputAction: TextInputAction.next,
                      textCapitalization: TextCapitalization.characters,
                      inputFormatters: <TextInputFormatter>[
                        UpperCaseTextFormatter(),
                      ],
                      decoration: const InputDecoration(
                        labelText: 'Marca',
                        hintText: 'Opcional',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.spacing),

              Row(
                children: <Widget>[
                  // Color
                  Expanded(
                    child: TextFormField(
                      controller: _colorController,
                      textInputAction: TextInputAction.next,
                      textCapitalization: TextCapitalization.characters,
                      inputFormatters: <TextInputFormatter>[
                        UpperCaseTextFormatter(),
                      ],
                      decoration: const InputDecoration(
                        labelText: 'Color',
                        hintText: 'Opcional',
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSizes.spacing),

                  // Cantidad - Comportamiento diferente según modo
                  if (!_isEditing)
                    // MODO CREAR: Campo normal "Cantidad Total"
                    Expanded(
                      child: TextFormField(
                        controller: _cantidadTotalController,
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: const InputDecoration(
                          labelText: 'Cantidad Total *',
                          hintText: '0',
                        ),
                        validator: (String? value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'La cantidad es obligatoria';
                          }
                          final int? cantidad = int.tryParse(value);
                          if (cantidad == null || cantidad < 0) {
                            return 'Cantidad inválida';
                          }
                          return null;
                        },
                      ),
                    )
                  else
                    // MODO EDITAR: Mostrar cantidad actual (solo lectura)
                    Expanded(
                      child: TextFormField(
                        controller: _cantidadTotalController,
                        enabled: false,
                        decoration: const InputDecoration(
                          labelText: 'Cantidad Actual',
                          hintText: '0',
                        ),
                      ),
                    ),
                ],
              ),

              // MODO EDITAR: Campo para agregar unidades
              if (_isEditing) ...<Widget>[
                const SizedBox(height: AppSizes.spacing),
                TextFormField(
                  controller: _cantidadAgregarController,
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  decoration: InputDecoration(
                    labelText: 'Agregar Unidades',
                    hintText: '0',
                    helperText: 'Cantidad a sumar al stock actual ($_cantidadActual unidades)',
                    prefixIcon: const Icon(Icons.add_circle_outline, color: AppColors.success),
                  ),
                  onChanged: (String value) {
                    // Actualizar cantidad total calculada
                    final int agregar = int.tryParse(value) ?? 0;
                    setState(() {
                      _cantidadTotalController.text = (_cantidadActual + agregar).toString();
                    });
                  },
                  validator: (String? value) {
                    if (value == null || value.trim().isEmpty) {
                      return null; // Opcional al editar
                    }
                    final int? cantidad = int.tryParse(value);
                    if (cantidad == null || cantidad < 0) {
                      return 'Cantidad inválida';
                    }
                    return null;
                  },
                ),
              ],
              const SizedBox(height: AppSizes.spacing),

              Row(
                children: <Widget>[
                  // Precio Unitario
                  Expanded(
                    child: TextFormField(
                      controller: _precioController,
                      textInputAction: TextInputAction.next,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                      ],
                      decoration: const InputDecoration(
                        labelText: 'Precio Unitario (€)',
                        hintText: '0.00',
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSizes.spacing),

                  // Stock Mínimo
                  Expanded(
                    child: TextFormField(
                      controller: _stockMinimoController,
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      decoration: const InputDecoration(
                        labelText: 'Stock Mínimo',
                        hintText: '5',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.spacing),

              // Proveedor
              TextFormField(
                controller: _proveedorController,
                textInputAction: TextInputAction.next,
                textCapitalization: TextCapitalization.characters,
                inputFormatters: <TextInputFormatter>[
                  UpperCaseTextFormatter(),
                ],
                decoration: const InputDecoration(
                  labelText: 'Proveedor',
                  hintText: 'Opcional',
                ),
              ),
              const SizedBox(height: AppSizes.spacing),

              // Ubicación Almacén
              TextFormField(
                controller: _ubicacionController,
                textInputAction: TextInputAction.next,
                textCapitalization: TextCapitalization.characters,
                inputFormatters: <TextInputFormatter>[
                  UpperCaseTextFormatter(),
                ],
                decoration: const InputDecoration(
                  labelText: 'Ubicación en Almacén',
                  hintText: 'Ej: ESTANTERÍA A3, ALMACÉN 2',
                ),
              ),
              const SizedBox(height: AppSizes.spacing),

              // Observaciones
              TextFormField(
                controller: _observacionesController,
                textInputAction: TextInputAction.newline,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Observaciones',
                  hintText: 'Información adicional',
                ),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          AppButton(
            onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
            label: 'Cancelar',
            variant: AppButtonVariant.text,
          ),
          AppButton(
            onPressed: _isSaving ? null : _onSave,
            label: _isEditing ? 'Actualizar' : 'Guardar',
            icon: _isEditing ? Icons.save : Icons.add,
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
      precioUnitario: _precioController.text.trim().isEmpty ? null : double.tryParse(_precioController.text.trim()),
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

/// Custom TextInputFormatter to convert all input to uppercase
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
