// ignore_for_file: implementation_imports, avoid_redundant_argument_values, use_build_context_synchronously
import 'dart:async';

import 'package:ambutrack_core_datasource/src/datasources/stock/entities/producto_entity.dart'
    as stock_entities;
import 'package:ambutrack_core_datasource/src/datasources/stock/stock_contract.dart'
    as legacy_stock;
import 'package:ambutrack_core_datasource/src/datasources/stock/stock_factory.dart'
    as legacy_stock;
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/widgets/buttons/app_button.dart';
import 'package:ambutrack_web/core/widgets/dialogs/app_dialog.dart';
import 'package:ambutrack_web/core/widgets/dropdowns/app_searchable_dropdown.dart';
import 'package:ambutrack_web/core/widgets/handlers/crud_operation_handler.dart';
import 'package:ambutrack_web/core/widgets/loading/app_loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Diálogo para añadir stock manual a un vehículo
///
/// Permite añadir medicamentos, electromedicina y material de ambulancia
/// que NO provienen del almacén (ya estaban en ambulancia o se suministraron externamente)
class StockManualFormDialog extends StatefulWidget {
  const StockManualFormDialog({
    required this.vehiculoId,
    super.key,
  });

  final String vehiculoId;

  @override
  State<StockManualFormDialog> createState() => _StockManualFormDialogState();
}

class _StockManualFormDialogState extends State<StockManualFormDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _cantidadController = TextEditingController(text: '1');
  final TextEditingController _loteController = TextEditingController();
  final TextEditingController _ubicacionController = TextEditingController();
  final TextEditingController _observacionesController = TextEditingController();

  // DataSource
  late final legacy_stock.StockDataSource _stockDataSource;

  // Estado de carga
  bool _isLoading = true;
  bool _isSaving = false;
  DateTime? _saveStartTime;

  // Categorías fijas de productos
  static const List<String> _categorias = <String>[
    'MEDICACION',
    'ELECTROMEDICINA',
    'MATERIAL',
  ];

  // Datos cargados
  final List<stock_entities.ProductoEntity> _productos = <stock_entities.ProductoEntity>[];
  List<stock_entities.ProductoEntity> _productosFiltrados = <stock_entities.ProductoEntity>[];

  // Selecciones
  String? _categoriaSeleccionada;
  stock_entities.ProductoEntity? _productoSeleccionado;
  DateTime? _fechaCaducidad;

  @override
  void initState() {
    super.initState();
    _stockDataSource = legacy_stock.StockDataSourceFactory.createSupabase();
    _loadData();
  }

  @override
  void dispose() {
    _cantidadController.dispose();
    _loteController.dispose();
    _ubicacionController.dispose();
    _observacionesController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    debugPrint('🔄 Cargando productos...');

    try {
      final List<stock_entities.ProductoEntity> productos = await _stockDataSource.getProductos();

      if (mounted) {
        setState(() {
          _productos
            ..clear()
            ..addAll(productos.where((stock_entities.ProductoEntity p) => p.activo));
          _productosFiltrados = List<stock_entities.ProductoEntity>.from(_productos);
          _isLoading = false;
        });
      }

      debugPrint('✅ Cargados ${_productos.length} productos activos');
    } catch (e) {
      debugPrint('❌ Error al cargar productos: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar productos: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _onCategoriaChanged(String? categoria) {
    setState(() {
      _categoriaSeleccionada = categoria;
      _productoSeleccionado = null;

      if (categoria == null) {
        _productosFiltrados = _productos;
      } else {
        _productosFiltrados = _productos
            .where((stock_entities.ProductoEntity p) => p.categoria == categoria)
            .toList();
      }
    });
  }

  void _onProductoChanged(stock_entities.ProductoEntity? producto) {
    setState(() {
      _productoSeleccionado = producto;

      // Pre-rellenar ubicación por defecto si existe
      if (producto?.ubicacionDefault != null) {
        _ubicacionController.text = producto!.ubicacionDefault!;
      }
    });
  }

  Future<void> _selectFechaCaducidad() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 90)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)), // 10 años
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              surface: AppColors.surfaceLight,
              onSurface: AppColors.textPrimaryLight,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _fechaCaducidad) {
      setState(() {
        _fechaCaducidad = picked;
      });
    }
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_productoSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debe seleccionar un producto'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
      _saveStartTime = DateTime.now();
    });

    debugPrint('💾 Guardando stock manual:');
    debugPrint('  - Vehículo: ${widget.vehiculoId}');
    debugPrint('  - Producto: ${_productoSeleccionado!.nombre}');
    debugPrint('  - Cantidad: ${_cantidadController.text}');

    // Mostrar loading overlay
    // CrudOperationHandler se encargará de cerrarlo automáticamente
    unawaited(
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext dialogContext) {
          return const AppLoadingOverlay(
            message: 'Añadiendo stock manual...',
            color: AppColors.primary,
            icon: Icons.add_circle_outline,
          );
        },
      ),
    );

    try {
      final int cantidad = int.parse(_cantidadController.text);
      final String motivo = 'Stock manual añadido: ${_observacionesController.text.isNotEmpty ? _observacionesController.text : "Origen externo al almacén"}';

      // Registrar stock manual (INSERT directo sin RPC)
      final Map<String, dynamic> response = await _stockDataSource.registrarStockManual(
        vehiculoId: widget.vehiculoId,
        productoId: _productoSeleccionado!.id,
        cantidad: cantidad,
        lote: _loteController.text.isNotEmpty ? _loteController.text : null,
        fechaCaducidad: _fechaCaducidad,
        motivo: motivo,
        usuarioId: null, // Dejar explícitamente como null
      );

      final Duration elapsed = DateTime.now().difference(_saveStartTime!);
      debugPrint('✅ Stock manual añadido exitosamente (${elapsed.inMilliseconds}ms)');
      debugPrint('📊 Respuesta: $response');

      // NO hacer pops manuales, dejar que CrudOperationHandler los haga
      // El handler se encarga de:
      // 1. Cerrar loading overlay (si _isSaving = true)
      // 2. Cerrar el formulario
      // 3. Mostrar ResultDialog

      if (mounted) {
        unawaited(
          CrudOperationHandler.handleSuccess(
            context: context,
            isSaving: _isSaving,
            isEditing: false,
            entityName: 'Stock Manual',
            durationMs: elapsed.inMilliseconds,
            onClose: () {
              if (mounted) {
                setState(() {
                  _isSaving = false;
                });
              }
            },
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Error al guardar stock manual: $e');

      // NO hacer pops manuales, dejar que CrudOperationHandler los haga
      // El handler se encarga de:
      // 1. Cerrar loading overlay (si _isSaving = true)
      // 2. Cerrar el formulario
      // 3. Mostrar ResultDialog con error

      if (mounted) {
        unawaited(
          CrudOperationHandler.handleError(
            context: context,
            isSaving: _isSaving,
            isEditing: false,
            entityName: 'Stock Manual',
            errorMessage: e.toString(),
            onClose: () {
              if (mounted) {
                setState(() {
                  _isSaving = false;
                });
              }
            },
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppDialog(
      title: 'Añadir Stock Manual',
      content: _isLoading
          ? const SizedBox(
              height: 400,
              child: Center(
                child: AppLoadingIndicator(
                  message: 'Cargando productos...',
                ),
              ),
            )
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    // Mensaje informativo
                    Container(
                      padding: const EdgeInsets.all(AppSizes.paddingMedium),
                      decoration: BoxDecoration(
                        color: AppColors.info.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                        border: Border.all(
                          color: AppColors.info.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: <Widget>[
                          const Icon(
                            Icons.info_outline,
                            color: AppColors.info,
                            size: AppSizes.iconSmall,
                          ),
                          const SizedBox(width: AppSizes.spacingSmall),
                          Expanded(
                            child: Text(
                              'Añade productos que ya estaban en la ambulancia o se suministraron externamente (no desde almacén)',
                              style: GoogleFonts.inter(
                                fontSize: AppSizes.fontXs,
                                color: AppColors.info,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSizes.spacing),

                    // Categoría (opcional)
                    AppSearchableDropdown<String>(
                      value: _categoriaSeleccionada,
                      label: 'Filtrar por Categoría (opcional)',
                      hint: 'Todas las categorías',
                      prefixIcon: Icons.category,
                      items: _categorias
                          .map(
                            (String categoria) => AppSearchableDropdownItem<String>(
                              value: categoria,
                              label: categoria,
                              icon: Icons.category,
                              iconColor: AppColors.primary,
                            ),
                          )
                          .toList(),
                      onChanged: _onCategoriaChanged,
                      displayStringForOption: (String categoria) => categoria,
                    ),
                    const SizedBox(height: AppSizes.spacing),

                    // Producto *
                    AppSearchableDropdown<stock_entities.ProductoEntity>(
                      value: _productoSeleccionado,
                      label: 'Producto *',
                      hint: 'Buscar medicamento, equipamiento...',
                      prefixIcon: Icons.medication,
                      searchHint: 'Escribe para buscar...',
                      items: _productosFiltrados
                          .map(
                            (stock_entities.ProductoEntity p) => AppSearchableDropdownItem<stock_entities.ProductoEntity>(
                              value: p,
                              label: p.nombreComercial != null
                                  ? '${p.nombre} (${p.nombreComercial})'
                                  : p.nombre,
                              icon: Icons.medication,
                              iconColor: p.requiereRefrigeracion
                                  ? AppColors.info
                                  : AppColors.success,
                            ),
                          )
                          .toList(),
                      onChanged: _onProductoChanged,
                      displayStringForOption: (stock_entities.ProductoEntity p) =>
                          p.nombreComercial != null
                              ? '${p.nombre} (${p.nombreComercial})'
                              : p.nombre,
                    ),
                    const SizedBox(height: AppSizes.spacing),

                    // Cantidad *
                    TextFormField(
                      controller: _cantidadController,
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: 'Cantidad *',
                        hintText: 'Ej: 5',
                        prefixIcon: const Icon(Icons.numbers, size: 20),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                        ),
                      ),
                      onTap: () {
                        // Seleccionar todo el texto al hacer click para facilitar edición
                        _cantidadController.selection = TextSelection(
                          baseOffset: 0,
                          extentOffset: _cantidadController.text.length,
                        );
                      },
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return 'La cantidad es obligatoria';
                        }
                        final int? cantidad = int.tryParse(value);
                        if (cantidad == null || cantidad <= 0) {
                          return 'La cantidad debe ser mayor a 0';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSizes.spacing),

                    // Lote
                    TextFormField(
                      controller: _loteController,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: 'Número de Lote',
                        hintText: 'Ej: LOT123456',
                        prefixIcon: const Icon(Icons.qr_code, size: 20),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSizes.spacing),

                    // Fecha de caducidad
                    InkWell(
                      onTap: _selectFechaCaducidad,
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Fecha de Caducidad',
                          hintText: 'Seleccionar fecha',
                          prefixIcon: const Icon(Icons.calendar_today, size: 20),
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
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                          ),
                        ),
                        child: Text(
                          _fechaCaducidad != null
                              ? '${_fechaCaducidad!.day.toString().padLeft(2, '0')}/${_fechaCaducidad!.month.toString().padLeft(2, '0')}/${_fechaCaducidad!.year}'
                              : 'Sin fecha de caducidad',
                          style: GoogleFonts.inter(
                            fontSize: AppSizes.fontSmall,
                            color: _fechaCaducidad != null
                                ? AppColors.textPrimaryLight
                                : AppColors.textSecondaryLight,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSizes.spacing),

                    // Ubicación
                    TextFormField(
                      controller: _ubicacionController,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: 'Ubicación en Ambulancia',
                        hintText: 'Ej: Mochila naranja, Nevera...',
                        prefixIcon: const Icon(Icons.place, size: 20),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSizes.spacing),

                    // Observaciones
                    TextFormField(
                      controller: _observacionesController,
                      maxLines: 3,
                      textInputAction: TextInputAction.newline,
                      decoration: InputDecoration(
                        labelText: 'Observaciones',
                        hintText: 'Notas adicionales sobre el origen o estado...',
                        prefixIcon: const Padding(
                          padding: EdgeInsets.only(bottom: 40),
                          child: Icon(Icons.notes, size: 20),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
      actions: <Widget>[
        AppButton(
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
          label: 'Cancelar',
          variant: AppButtonVariant.text,
        ),
        AppButton(
          onPressed: _isSaving || _isLoading ? null : _onSave,
          label: 'Guardar',
          icon: Icons.add,
        ),
      ],
    );
  }
}
