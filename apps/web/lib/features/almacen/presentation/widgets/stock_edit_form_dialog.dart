import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/form/gestion_form.dart';
import 'package:ambutrack_web/core/widgets/handlers/crud_operation_handler.dart';
import 'package:ambutrack_web/core/widgets/loading/app_loading_indicator.dart';
import 'package:ambutrack_web/features/almacen/presentation/bloc/producto/producto_bloc.dart';
import 'package:ambutrack_web/features/almacen/presentation/bloc/producto/producto_state.dart';
import 'package:ambutrack_web/features/almacen/presentation/bloc/stock/stock_bloc.dart';
import 'package:ambutrack_web/features/almacen/presentation/bloc/stock/stock_event.dart';
import 'package:ambutrack_web/features/almacen/presentation/bloc/stock/stock_state.dart';
import 'package:ambutrack_web/features/almacen/presentation/widgets/form/almacen_cantidad_stepper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Diálogo para editar un registro de stock existente
class StockEditFormDialog extends StatefulWidget {
  const StockEditFormDialog({
    super.key,
    required this.stock,
  });

  final StockEntity stock;

  @override
  State<StockEditFormDialog> createState() => _StockEditFormDialogState();
}

class _StockEditFormDialogState extends State<StockEditFormDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Controladores de texto
  late TextEditingController _loteController;
  late TextEditingController _numeroSerieController;
  late TextEditingController _observacionesController;
  late TextEditingController _ubicacionController;

  // Valores
  DateTime? _fechaCaducidad;
  double _cantidadActual = 0;
  double _cantidadMinima = 1;
  double _cantidadMaxima = 100;

  bool _isSaving = false;
  bool _isLoading = true;
  ProductoEntity? _producto;

  @override
  void initState() {
    super.initState();

    // Inicializar controladores con valores actuales
    _loteController = TextEditingController(text: widget.stock.lote);
    _numeroSerieController = TextEditingController(text: widget.stock.numeroSerie);
    _observacionesController = TextEditingController(text: widget.stock.observaciones);
    _ubicacionController = TextEditingController(text: widget.stock.ubicacionFisica);

    _fechaCaducidad = widget.stock.fechaCaducidad;
    _cantidadActual = widget.stock.cantidadActual.toDouble();
    _cantidadMinima = widget.stock.cantidadMinima.toDouble();
    _cantidadMaxima = (widget.stock.cantidadMaxima ?? 100).toDouble();

    _loadProducto();
  }

  @override
  void dispose() {
    _loteController.dispose();
    _numeroSerieController.dispose();
    _observacionesController.dispose();
    _ubicacionController.dispose();
    super.dispose();
  }

  /// Cargar información del producto
  Future<void> _loadProducto() async {
    final ProductoState state = context.read<ProductoBloc>().state;

    if (state is ProductoLoaded) {
      try {
        final ProductoEntity producto = state.productos.firstWhere(
          (ProductoEntity p) => p.id == widget.stock.idProducto,
        );

        if (mounted) {
          setState(() {
            _producto = producto;
            _isLoading = false;
          });
        }
      } catch (e) {
        debugPrint('⚠️ Producto no encontrado: ${widget.stock.idProducto}');
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } else {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Guardar cambios
  void _onSave() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    // Mostrar loading overlay
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AppLoadingOverlay(
          message: 'Actualizando stock...',
          color: AppColors.secondary,
          icon: Icons.edit,
        );
      },
    );

    // Crear entidad actualizada
    final StockEntity stockActualizado = widget.stock.copyWith(
      cantidadActual: _cantidadActual,
      cantidadMinima: _cantidadMinima,
      cantidadMaxima: _cantidadMaxima,
      lote: _loteController.text.trim().isEmpty ? null : _loteController.text.trim(),
      numeroSerie: _numeroSerieController.text.trim().isEmpty ? null : _numeroSerieController.text.trim(),
      observaciones: _observacionesController.text.trim().isEmpty ? null : _observacionesController.text.trim(),
      ubicacionFisica: _ubicacionController.text.trim().isEmpty ? null : _ubicacionController.text.trim(),
      fechaCaducidad: _fechaCaducidad,
    );

    debugPrint('💾 Actualizando stock: ${stockActualizado.id}');

    // Disparar evento de actualización
    context.read<StockBloc>().add(StockUpdateRequested(stockActualizado));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<StockBloc, StockState>(
      listener: (BuildContext context, StockState state) {
        if (state is StockLoaded) {
          CrudOperationHandler.handleSuccess(
            context: context,
            isSaving: _isSaving,
            isEditing: true,
            entityName: 'Stock',
            onClose: () => setState(() => _isSaving = false),
          );
        } else if (state is StockError) {
          CrudOperationHandler.handleError(
            context: context,
            isSaving: _isSaving,
            isEditing: true,
            entityName: 'Stock',
            errorMessage: state.message,
            onClose: () => setState(() => _isSaving = false),
          );
        }
      },
      child: GestionFormDialog(
        title: 'Editar stock',
        subtitle: _producto?.nombre,
        icon: Icons.inventory_2_outlined,
        formKey: _formKey,
        isEditing: true,
        isSaving: _isSaving,
        saveLabel: 'Guardar cambios',
        onSave: _onSave,
        children: <Widget>[
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(32),
              child: AppLoadingIndicator(message: 'Cargando datos...'),
            )
          else
            _StockEditBody(
              producto: _producto,
              cantidadActual: _cantidadActual,
              cantidadMinima: _cantidadMinima,
              cantidadMaxima: _cantidadMaxima,
              onActual: (double v) => setState(() => _cantidadActual = v),
              onMinima: (double v) => setState(() => _cantidadMinima = v),
              onMaxima: (double v) => setState(() => _cantidadMaxima = v),
              lote: _loteController,
              numeroSerie: _numeroSerieController,
              ubicacion: _ubicacionController,
              observaciones: _observacionesController,
              fechaCaducidad: _fechaCaducidad,
              onFechaCaducidad: (DateTime? v) => setState(() => _fechaCaducidad = v),
            ),
        ],
      ),
    );
  }
}

/// Campos del formulario de edición de stock
class _StockEditBody extends StatelessWidget {
  const _StockEditBody({
    required this.producto,
    required this.cantidadActual,
    required this.cantidadMinima,
    required this.cantidadMaxima,
    required this.onActual,
    required this.onMinima,
    required this.onMaxima,
    required this.lote,
    required this.numeroSerie,
    required this.ubicacion,
    required this.observaciones,
    required this.fechaCaducidad,
    required this.onFechaCaducidad,
  });

  final ProductoEntity? producto;
  final double cantidadActual;
  final double cantidadMinima;
  final double cantidadMaxima;
  final ValueChanged<double> onActual;
  final ValueChanged<double> onMinima;
  final ValueChanged<double> onMaxima;
  final TextEditingController lote;
  final TextEditingController numeroSerie;
  final TextEditingController ubicacion;
  final TextEditingController observaciones;
  final DateTime? fechaCaducidad;
  final ValueChanged<DateTime?> onFechaCaducidad;

  @override
  Widget build(BuildContext context) {
    final ProductoEntity? p = producto;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (p != null) ...<Widget>[
          const GestionFormSection(title: 'Producto', first: true),
          GestionFormColumns(
            children: <Widget>[
              GestionFormRow(label: 'Producto', child: GestionFormReadOnly(value: p.nombre)),
              GestionFormRow(label: 'Categoría', child: GestionFormReadOnly(value: p.categoria?.label ?? '-')),
            ],
          ),
        ],
        GestionFormSection(title: 'Cantidades', first: p == null),
        GestionFormColumns(
          children: <Widget>[
            GestionFormRow(
              label: 'Cantidad actual',
              required: true,
              child: AlmacenCantidadStepper(value: cantidadActual, onChanged: onActual),
            ),
            const SizedBox.shrink(),
          ],
        ),
        GestionFormColumns(
          children: <Widget>[
            GestionFormRow(
              label: 'Mínima',
              required: true,
              child: AlmacenCantidadStepper(value: cantidadMinima, onChanged: onMinima),
            ),
            GestionFormRow(
              label: 'Máxima',
              child: AlmacenCantidadStepper(value: cantidadMaxima, min: cantidadMinima, onChanged: onMaxima),
            ),
          ],
        ),
        if (p?.categoria == CategoriaProducto.medicacion) ...<Widget>[
          const GestionFormSection(title: 'Medicación'),
          GestionFormColumns(
            children: <Widget>[
              GestionFormRow(
                label: 'Lote',
                child: GestionTextField(controller: lote, hint: 'LOT-2024-001'),
              ),
              GestionFormRow(
                label: 'Caducidad',
                child: GestionDateField(
                  value: fechaCaducidad,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 3650)),
                  onChanged: onFechaCaducidad,
                ),
              ),
            ],
          ),
        ],
        if (p?.categoria == CategoriaProducto.electromedicina) ...<Widget>[
          const GestionFormSection(title: 'Electromedicina'),
          GestionFormRow(
            label: 'Nº de serie',
            child: GestionTextField(controller: numeroSerie, hint: 'SN-123456'),
          ),
        ],
        const GestionFormSection(title: 'Ubicación y notas'),
        GestionFormRow(
          label: 'Ubicación',
          child: GestionTextField(controller: ubicacion, hint: 'Estantería A, nivel 2'),
        ),
        GestionFormRow(
          label: 'Observaciones',
          multiline: true,
          child: GestionTextField(controller: observaciones, hint: 'Notas sobre este stock', maxLines: 3),
        ),
      ],
    );
  }
}
