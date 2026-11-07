import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/constants/almacen_constants.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/form/gestion_form.dart';
import 'package:ambutrack_web/core/widgets/handlers/crud_operation_handler.dart';
import 'package:ambutrack_web/core/widgets/loading/app_loading_indicator.dart';
import 'package:ambutrack_web/features/almacen/presentation/bloc/producto/producto_bloc.dart';
import 'package:ambutrack_web/features/almacen/presentation/bloc/producto/producto_state.dart';
import 'package:ambutrack_web/features/almacen/presentation/bloc/stock/stock_bloc.dart';
import 'package:ambutrack_web/features/almacen/presentation/bloc/stock/stock_event.dart';
import 'package:ambutrack_web/features/almacen/presentation/bloc/stock/stock_state.dart';
import 'package:ambutrack_web/features/almacen/presentation/widgets/form/stock_entrada_form_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

  /// Obtener productos filtrados por categoría
  List<ProductoEntity> _getProductosFiltrados(List<ProductoEntity> productos) {
    if (_categoriaSeleccionada == null) {
      return <ProductoEntity>[];
    }
    return productos.where((ProductoEntity p) => p.categoria == _categoriaSeleccionada).toList();
  }

  void _onSave() {
    if (context.read<ProductoBloc>().state is ProductoLoading || !_formKey.currentState!.validate()) {
      return;
    }

    // Categoría, producto, lote, nº de serie y caducidad se validan en sus propios campos
    if (_categoriaSeleccionada == null || _productoSeleccionado == null) {
      return;
    }
    final ProductoEntity producto = _productoSeleccionado!;

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
          final List<ProductoEntity> productos =
              productoState is ProductoLoaded ? productoState.productos : <ProductoEntity>[];
          return GestionFormDialog(
            title: 'Nueva entrada de stock',
            icon: Icons.move_to_inbox_outlined,
            size: GestionFormSize.small,
            formKey: _formKey,
            isSaving: _isSaving,
            onSave: _onSave,
            children: <Widget>[
              if (productoState is ProductoLoading)
                const Padding(
                  padding: EdgeInsets.all(32),
                  child: AppLoadingIndicator(message: 'Cargando productos...'),
                )
              else
                StockEntradaFormBody(
                  categoria: _categoriaSeleccionada,
                  onCategoria: _onCategoriaChanged,
                  productos: _getProductosFiltrados(productos),
                  producto: _productoSeleccionado,
                  onProducto: _onProductoChanged,
                  lote: _loteController,
                  numeroSerie: _numeroSerieController,
                  observaciones: _observacionesController,
                  fechaCaducidad: _fechaCaducidad,
                  onFechaCaducidad: (DateTime? v) => setState(() => _fechaCaducidad = v),
                  cantidad: _cantidad,
                  onCantidad: (int v) => setState(() => _cantidad = v),
                ),
            ],
          );
        },
      ),
    );
  }

  void _onCategoriaChanged(CategoriaProducto? value) {
    setState(() {
      _categoriaSeleccionada = value;
      _productoSeleccionado = null; // Resetear producto al cambiar categoría
      _loteController.clear();
      _numeroSerieController.clear();
      _fechaCaducidad = null;
    });
  }

  void _onProductoChanged(ProductoEntity? value) {
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
  }
}
