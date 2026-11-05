// ignore_for_file: implementation_imports, avoid_redundant_argument_values, use_build_context_synchronously
import 'dart:async';

import 'package:ambutrack_core_datasource/src/datasources/stock/entities/producto_entity.dart'
    as stock_entities;
import 'package:ambutrack_core_datasource/src/datasources/stock/stock_contract.dart'
    as legacy_stock;
import 'package:ambutrack_core_datasource/src/datasources/stock/stock_factory.dart'
    as legacy_stock;
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/dialogs/result_dialog.dart';
import 'package:ambutrack_web/core/widgets/gestion/form/gestion_form.dart';
import 'package:ambutrack_web/core/widgets/handlers/crud_operation_handler.dart';
import 'package:ambutrack_web/core/widgets/loading/app_loading_indicator.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/widgets/form/stock_manual_form_body.dart';
import 'package:flutter/material.dart';

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

        unawaited(
          showResultDialog(
            context: context,
            title: 'Error al cargar productos',
            message: 'No se pudieron cargar los productos del catálogo.',
            details: e.toString(),
            type: ResultType.error,
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

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_productoSeleccionado == null) {
      await showResultDialog(
        context: context,
        title: 'Producto obligatorio',
        message: 'Debe seleccionar un producto',
        type: ResultType.warning,
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

  void _onSavePressed() {
    if (_isLoading) {
      return;
    }
    unawaited(_onSave());
  }

  @override
  Widget build(BuildContext context) {
    return GestionFormDialog(
      title: 'Añadir stock manual',
      icon: Icons.medication_outlined,
      formKey: _formKey,
      isSaving: _isSaving,
      onSave: _onSavePressed,
      children: <Widget>[
        if (_isLoading)
          const SizedBox(
            height: 320,
            child: Center(child: AppLoadingIndicator(message: 'Cargando productos...')),
          )
        else
          StockManualFormBody(
            categorias: _categorias,
            categoria: _categoriaSeleccionada,
            productos: _productosFiltrados,
            producto: _productoSeleccionado,
            fechaCaducidad: _fechaCaducidad,
            cantidad: _cantidadController,
            lote: _loteController,
            ubicacion: _ubicacionController,
            observaciones: _observacionesController,
            onCategoriaChanged: _onCategoriaChanged,
            onProductoChanged: _onProductoChanged,
            onFechaCaducidadChanged: (DateTime? v) => setState(() => _fechaCaducidad = v),
          ),
      ],
    );
  }
}
