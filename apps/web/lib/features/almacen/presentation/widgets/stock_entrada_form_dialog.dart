import 'package:ambutrack_core/ambutrack_core.dart';
import 'package:ambutrack_web/core/constants/almacen_constants.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/widgets/buttons/app_button.dart';
import 'package:ambutrack_web/core/widgets/dialogs/app_dialog.dart';
import 'package:ambutrack_web/core/widgets/dropdowns/app_dropdown.dart';
import 'package:ambutrack_web/core/widgets/dropdowns/app_searchable_dropdown.dart';
import 'package:ambutrack_web/core/widgets/handlers/crud_operation_handler.dart';
import 'package:ambutrack_web/core/widgets/loading/app_loading_indicator.dart';
import 'package:ambutrack_web/features/almacen/presentation/bloc/producto/producto_bloc.dart';
import 'package:ambutrack_web/features/almacen/presentation/bloc/producto/producto_state.dart';
import 'package:ambutrack_web/features/almacen/presentation/bloc/stock/stock_bloc.dart';
import 'package:ambutrack_web/features/almacen/presentation/bloc/stock/stock_event.dart';
import 'package:ambutrack_web/features/almacen/presentation/bloc/stock/stock_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

/// Diálogo para registrar una nueva entrada de stock en el Almacén General
class StockEntradaFormDialog extends StatefulWidget {
  const StockEntradaFormDialog({
    super.key,
    this.categoriaInicial,
  });

  /// Categoría preseleccionada según el tab activo
  final CategoriaProducto? categoriaInicial;

  @override
  State<StockEntradaFormDialog> createState() => _StockEntradaFormDialogState();
}

class _StockEntradaFormDialogState extends State<StockEntradaFormDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Controladores de texto
  late TextEditingController _loteController;
  late TextEditingController _numeroSerieController;
  late TextEditingController _observacionesController;

  // Valores seleccionados
  CategoriaProducto? _categoriaSeleccionada;
  ProductoEntity? _productoSeleccionado;
  DateTime? _fechaCaducidad;
  int _cantidad = 1;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loteController = TextEditingController();
    _numeroSerieController = TextEditingController();
    _observacionesController = TextEditingController();

    // Preseleccionar categoría según tab activo
    _categoriaSeleccionada = widget.categoriaInicial;
    if (_categoriaSeleccionada != null) {
      debugPrint('📦 Categoría preseleccionada en formulario: ${_categoriaSeleccionada!.label}');
    }
  }

  @override
  void dispose() {
    _loteController.dispose();
    _numeroSerieController.dispose();
    _observacionesController.dispose();
    super.dispose();
  }

  /// Incrementar cantidad
  void _incrementarCantidad() {
    setState(() {
      _cantidad++;
    });
  }

  /// Decrementar cantidad
  void _decrementarCantidad() {
    if (_cantidad > 1) {
      setState(() {
        _cantidad--;
      });
    }
  }

  /// Obtener productos filtrados por categoría
  List<ProductoEntity> _getProductosFiltrados(List<ProductoEntity> productos) {
    if (_categoriaSeleccionada == null) {
      return <ProductoEntity>[];
    }
    return productos.where((ProductoEntity p) => p.categoria == _categoriaSeleccionada).toList();
  }

  /// Obtener label de categoría en español
  String _getCategoriaLabel(CategoriaProducto categoria) {
    switch (categoria) {
      case CategoriaProducto.medicacion:
        return 'Medicamento';
      case CategoriaProducto.electromedicina:
        return 'Electromedicina';
      case CategoriaProducto.fungibles:
        return 'Fungible';
      case CategoriaProducto.materialAmbulancia:
        return 'Material';
      case CategoriaProducto.gasesMedicinales:
        return 'Gas Medicinal';
      case CategoriaProducto.otros:
        return 'Otro';
    }
  }

  /// Selector de fecha de caducidad
  Widget _buildDatePicker() {
    final DateFormat formatter = DateFormat('dd/MM/yyyy');
    final String dateText = _fechaCaducidad != null ? formatter.format(_fechaCaducidad!) : '';

    return InkWell(
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: _fechaCaducidad ?? DateTime.now().add(const Duration(days: 365)),
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 3650)),
          locale: const Locale('es', 'ES'),
        );

        if (picked != null && mounted) {
          setState(() {
            _fechaCaducidad = picked;
          });
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Fecha de Caducidad',
          hintText: 'Selecciona fecha',
          prefixIcon: const Icon(Icons.calendar_today),
          suffixIcon: _fechaCaducidad != null
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  onPressed: () {
                    setState(() {
                      _fechaCaducidad = null;
                    });
                  },
                )
              : null,
          border: const OutlineInputBorder(),
        ),
        child: Text(
          dateText.isEmpty ? '' : dateText,
          style: TextStyle(
            color: dateText.isEmpty ? AppColors.textSecondaryLight : AppColors.textPrimaryLight,
          ),
        ),
      ),
    );
  }

  /// Widget de cantidad con botones +/-
  Widget _buildCantidadSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Cantidad *',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimaryLight,
          ),
        ),
        const SizedBox(height: AppSizes.spacingSmall),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.paddingMedium,
            vertical: AppSizes.paddingSmall,
          ),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.gray300),
            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              // Botón decrementar
              IconButton(
                onPressed: _cantidad > 1 ? _decrementarCantidad : null,
                icon: const Icon(Icons.remove),
                color: _cantidad > 1 ? AppColors.primary : AppColors.gray400,
                iconSize: 24,
              ),

              // Valor actual
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingLarge,
                  vertical: AppSizes.paddingSmall,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                ),
                child: Text(
                  '$_cantidad',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),

              // Botón incrementar
              IconButton(
                onPressed: _incrementarCantidad,
                icon: const Icon(Icons.add),
                color: AppColors.primary,
                iconSize: 24,
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_categoriaSeleccionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes seleccionar una categoría'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_productoSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes seleccionar un producto'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Validaciones condicionales según producto
    final ProductoEntity producto = _productoSeleccionado!;

    if (producto.loteObligatorio && _loteController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El lote es obligatorio para este producto'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (producto.numeroSerieObligatorio && _numeroSerieController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El número de serie es obligatorio para este producto'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (producto.tieneCaducidad && _fechaCaducidad == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La fecha de caducidad es obligatoria para este producto'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AppLoadingOverlay(
          message: 'Creando entrada de stock...',
          color: AppColors.primary,
          icon: Icons.add_circle_outline,
        );
      },
    );

    final String lote = _loteController.text.trim();
    final String numeroSerie = _numeroSerieController.text.trim();
    final String observaciones = _observacionesController.text.trim();

    // Crear entrada de stock
    final StockEntity entrada = StockEntity(
      id: const Uuid().v4(),
      idAlmacen: AlmacenConstants.almacenGeneralId,
      idProducto: producto.id,
      cantidadActual: _cantidad.toDouble(),
      lote: lote.isNotEmpty ? lote : null,
      fechaCaducidad: _fechaCaducidad,
      numeroSerie: numeroSerie.isNotEmpty ? numeroSerie : null,
      observaciones: observaciones.isNotEmpty ? observaciones : null,
      fechaEntrada: DateTime.now(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    debugPrint('📦 Creando entrada de stock: ${entrada.toJson()}');

    context.read<StockBloc>().add(StockCreateRequested(entrada));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<StockBloc, StockState>(
      listener: (BuildContext context, StockState state) {
        if (state is StockLoaded) {
          CrudOperationHandler.handleSuccess(
            context: context,
            isSaving: _isSaving,
            isEditing: false,
            entityName: 'Entrada de Stock',
            onClose: () => setState(() => _isSaving = false),
          );
        } else if (state is StockError) {
          CrudOperationHandler.handleError(
            context: context,
            isSaving: _isSaving,
            isEditing: false,
            entityName: 'Entrada de Stock',
            errorMessage: state.message,
            onClose: () => setState(() => _isSaving = false),
          );
        }
      },
      child: BlocBuilder<ProductoBloc, ProductoState>(
        builder: (BuildContext context, ProductoState productoState) {
          if (productoState is ProductoLoading) {
            return AppDialog(
              title: 'Nueva Entrada de Stock',
              content: const Center(
                child: AppLoadingIndicator(
                  message: 'Cargando productos...',
                  size: 100,
                ),
              ),
              actions: <Widget>[
                AppButton(
                  onPressed: () => Navigator.of(context).pop(),
                  label: 'Cancelar',
                  variant: AppButtonVariant.text,
                ),
              ],
            );
          }

          final List<ProductoEntity> productos = productoState is ProductoLoaded ? productoState.productos : <ProductoEntity>[];
          final List<ProductoEntity> productosFiltrados = _getProductosFiltrados(productos);

          // Mostrar campos condicionales según producto seleccionado
          final bool mostrarLote = _productoSeleccionado?.loteObligatorio ?? false;
          final bool mostrarNumeroSerie = _productoSeleccionado?.numeroSerieObligatorio ?? false;
          final bool mostrarFechaCaducidad = _productoSeleccionado?.tieneCaducidad ?? false;

          return AppDialog(
            title: 'Nueva Entrada de Stock',
            content: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  // Selector de categoría
                  AppDropdown<CategoriaProducto>(
                    value: _categoriaSeleccionada,
                    label: 'Categoría *',
                    hint: 'Selecciona categoría',
                    prefixIcon: Icons.category,
                    items: CategoriaProducto.values
                        .map(
                          (CategoriaProducto cat) => AppDropdownItem<CategoriaProducto>(
                            value: cat,
                            label: _getCategoriaLabel(cat),
                          ),
                        )
                        .toList(),
                    onChanged: (CategoriaProducto? value) {
                      setState(() {
                        _categoriaSeleccionada = value;
                        _productoSeleccionado = null; // Resetear producto al cambiar categoría
                        _loteController.clear();
                        _numeroSerieController.clear();
                        _fechaCaducidad = null;
                      });
                    },
                  ),
                  const SizedBox(height: AppSizes.spacing),

                  // Selector de producto (filtrado por categoría)
                  if (_categoriaSeleccionada != null) ...<Widget>[
                    AppSearchableDropdown<ProductoEntity>(
                      value: _productoSeleccionado,
                      label: 'Producto *',
                      hint: 'Buscar producto por nombre o código',
                      prefixIcon: Icons.inventory_2,
                      searchHint: 'Escribe para buscar...',
                      items: productosFiltrados
                          .map(
                            (ProductoEntity p) => AppSearchableDropdownItem<ProductoEntity>(
                              value: p,
                              label: '${p.nombre} (${p.codigo})',
                              icon: Icons.medical_services,
                              iconColor: p.activo ? AppColors.success : AppColors.gray400,
                            ),
                          )
                          .toList(),
                      onChanged: (ProductoEntity? value) {
                        setState(() {
                          _productoSeleccionado = value;
                          // Limpiar campos opcionales al cambiar producto
                          if (value != null) {
                            if (!value.loteObligatorio) {
                              _loteController.clear();
                            }
                            if (!value.numeroSerieObligatorio) {
                              _numeroSerieController.clear();
                            }
                            if (!value.tieneCaducidad) {
                              _fechaCaducidad = null;
                            }
                          }
                        });
                      },
                      displayStringForOption: (ProductoEntity producto) => '${producto.nombre} (${producto.codigo})',
                    ),
                    const SizedBox(height: AppSizes.spacing),
                  ],

                  // Lote (condicional)
                  if (mostrarLote) ...<Widget>[
                    TextFormField(
                      controller: _loteController,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: _productoSeleccionado!.loteObligatorio ? 'Lote *' : 'Lote',
                        hintText: 'Ej: LOTE-2024-001',
                        prefixIcon: const Icon(Icons.qr_code),
                      ),
                      validator: _productoSeleccionado!.loteObligatorio
                          ? (String? value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'El lote es obligatorio';
                              }
                              return null;
                            }
                          : null,
                    ),
                    const SizedBox(height: AppSizes.spacing),
                  ],

                  // Número de Serie (condicional)
                  if (mostrarNumeroSerie) ...<Widget>[
                    TextFormField(
                      controller: _numeroSerieController,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: _productoSeleccionado!.numeroSerieObligatorio ? 'Número de Serie *' : 'Número de Serie',
                        hintText: 'Ej: NS-12345678',
                        prefixIcon: const Icon(Icons.tag),
                      ),
                      validator: _productoSeleccionado!.numeroSerieObligatorio
                          ? (String? value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'El número de serie es obligatorio';
                              }
                              return null;
                            }
                          : null,
                    ),
                    const SizedBox(height: AppSizes.spacing),
                  ],

                  // Fecha de Caducidad (condicional)
                  if (mostrarFechaCaducidad) ...<Widget>[
                    _buildDatePicker(),
                    const SizedBox(height: AppSizes.spacing),
                  ],

                  // Cantidad con botones +/-
                  _buildCantidadSelector(),
                  const SizedBox(height: AppSizes.spacing),

                  // Observaciones
                  TextFormField(
                    controller: _observacionesController,
                    maxLines: 3,
                    textInputAction: TextInputAction.newline,
                    decoration: const InputDecoration(
                      labelText: 'Observaciones',
                      hintText: 'Notas adicionales sobre la entrada...',
                      prefixIcon: Icon(Icons.notes),
                      alignLabelWithHint: true,
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
                label: 'Guardar',
                icon: Icons.add,
              ),
            ],
          );
        },
      ),
    );
  }
}
