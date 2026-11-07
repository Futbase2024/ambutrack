import 'dart:async';

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
import 'package:ambutrack_web/features/vehiculos/presentation/bloc/vehiculos_bloc.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/bloc/vehiculos_event.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/bloc/vehiculos_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Diálogo para transferir stock entre almacenes o vehículos
class StockTransferenciaFormDialog extends StatefulWidget {
  const StockTransferenciaFormDialog({
    super.key,
    required this.stock,
  });

  final StockEntity stock;

  @override
  State<StockTransferenciaFormDialog> createState() => _StockTransferenciaFormDialogState();
}

class _StockTransferenciaFormDialogState extends State<StockTransferenciaFormDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late TextEditingController _motivoController;

  int _cantidadTransferir = 1;

  bool _isSaving = false;
  bool _isLoading = true;
  ProductoEntity? _producto;
  List<VehiculoEntity> _vehiculos = <VehiculoEntity>[];

  String? _vehiculoSeleccionado;

  /// Obtener lista de vehículos disponibles para transferencia
  List<String> get _vehiculosDisponibles {
    return _vehiculos
        .map((VehiculoEntity v) => '${v.matricula} - ${v.marca} ${v.modelo}')
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _motivoController = TextEditingController();
    _loadProducto();
  }

  @override
  void dispose() {
    _motivoController.dispose();
    super.dispose();
  }

  /// Cargar información del producto y vehículos
  Future<void> _loadProducto() async {
    final ProductoState productoState = context.read<ProductoBloc>().state;
    final VehiculosState vehiculosState = context.read<VehiculosBloc>().state;

    debugPrint('🔄 Cargando datos para formulario de transferencia...');

    // Cargar producto
    if (productoState is ProductoLoaded) {
      try {
        final ProductoEntity producto = productoState.productos.firstWhere(
          (ProductoEntity p) => p.id == widget.stock.idProducto,
        );

        if (mounted) {
          setState(() {
            _producto = producto;
          });
        }
      } catch (e) {
        debugPrint('⚠️ Producto no encontrado: ${widget.stock.idProducto}');
      }
    }

    // Cargar vehículos
    if (vehiculosState is VehiculosLoaded) {
      // Filtrar solo vehículos activos
      final List<VehiculoEntity> vehiculosActivos = vehiculosState.vehiculos
          .where((VehiculoEntity v) => v.estado == VehiculoEstado.activo)
          .toList();

      debugPrint('✅ ${vehiculosActivos.length} vehículos activos cargados');

      if (mounted) {
        setState(() {
          _vehiculos = vehiculosActivos;
        });
      }
    } else {
      // Si no hay vehículos cargados, disparar evento de carga
      debugPrint('⚠️ Vehículos no cargados, solicitando carga...');
      final VehiculosBloc vehiculosBloc = context.read<VehiculosBloc>()
        ..add(const VehiculosLoadRequested());

      // Esperar a que se carguen
      await Future<void>.delayed(const Duration(milliseconds: 500));

      // Reintentar obtener vehículos
      final VehiculosState newState = vehiculosBloc.state;
      if (newState is VehiculosLoaded) {
        final List<VehiculoEntity> vehiculosActivos = newState.vehiculos
            .where((VehiculoEntity v) => v.estado == VehiculoEstado.activo)
            .toList();

        if (mounted) {
          setState(() {
            _vehiculos = vehiculosActivos;
          });
        }
      }
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Guardar transferencia
  Future<void> _onSave() async {
    if (_isLoading || !_formKey.currentState!.validate()) {
      return;
    }

    // El vehículo destino se valida en su propio campo
    if (_vehiculoSeleccionado == null) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    // Mostrar loading overlay
    unawaited(
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const AppLoadingOverlay(
            message: 'Transfiriendo a vehículo...',
            color: AppColors.secondary,
            icon: Icons.local_shipping,
          );
        },
      ),
    );

    // Obtener ID del vehículo desde la selección
    final VehiculoEntity vehiculo = _vehiculos.firstWhere(
      (VehiculoEntity v) => '${v.matricula} - ${v.marca} ${v.modelo}' == _vehiculoSeleccionado,
      orElse: () => _vehiculos.first, // Fallback (no debería ocurrir)
    );

    debugPrint('🔄 Transfiriendo stock a vehículo:');
    debugPrint('   - Producto: ${_producto?.nombre}');
    debugPrint('   - Cantidad: $_cantidadTransferir');
    debugPrint('   - Vehículo: ${vehiculo.matricula} (${vehiculo.id})');
    debugPrint('   - Motivo: ${_motivoController.text}');

    // Disparar evento de transferencia a vehículo
    if (mounted) {
      context.read<StockBloc>().add(
            StockTransferirAVehiculoRequested(
              stockId: widget.stock.id,
              vehiculoId: vehiculo.id,
              cantidad: _cantidadTransferir.toDouble(),
              motivo: _motivoController.text.trim(),
              lote: widget.stock.lote,
              fechaCaducidad: widget.stock.fechaCaducidad,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<StockBloc, StockState>(
      listener: (BuildContext context, StockState state) {
        if (state is StockLoaded) {
          CrudOperationHandler.handleSuccess(
            context: context,
            isSaving: _isSaving,
            isEditing: false, // Transferencia es una creación
            entityName: 'Transferencia de Stock',
            onClose: () => setState(() => _isSaving = false),
          );
        } else if (state is StockError) {
          CrudOperationHandler.handleError(
            context: context,
            isSaving: _isSaving,
            isEditing: false,
            entityName: 'Transferencia de Stock',
            errorMessage: state.message,
            onClose: () => setState(() => _isSaving = false),
          );
        }
      },
      child: GestionFormDialog(
        title: 'Transferir stock',
        subtitle: _producto?.nombre,
        icon: Icons.local_shipping_outlined,
        size: GestionFormSize.small,
        formKey: _formKey,
        isSaving: _isSaving,
        saveLabel: 'Transferir',
        onSave: _onSave,
        children: <Widget>[
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(32),
              child: AppLoadingIndicator(message: 'Cargando datos...'),
            )
          else
            _TransferenciaBody(
              stock: widget.stock,
              producto: _producto,
              cantidad: _cantidadTransferir,
              onCantidad: (int v) => setState(() => _cantidadTransferir = v),
              vehiculos: _vehiculosDisponibles,
              vehiculo: _vehiculoSeleccionado,
              onVehiculo: (String? v) => setState(() => _vehiculoSeleccionado = v),
              motivo: _motivoController,
            ),
        ],
      ),
    );
  }
}

/// Campos del formulario de transferencia de stock
class _TransferenciaBody extends StatelessWidget {
  const _TransferenciaBody({
    required this.stock,
    required this.producto,
    required this.cantidad,
    required this.onCantidad,
    required this.vehiculos,
    required this.vehiculo,
    required this.onVehiculo,
    required this.motivo,
  });

  final StockEntity stock;
  final ProductoEntity? producto;
  final int cantidad;
  final ValueChanged<int> onCantidad;
  final List<String> vehiculos;
  final String? vehiculo;
  final ValueChanged<String?> onVehiculo;
  final TextEditingController motivo;

  @override
  Widget build(BuildContext context) {
    final ProductoEntity? p = producto;
    final String unidad = p?.unidadMedida ?? '';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const GestionFormSection(title: 'Origen', first: true),
        if (p != null) ...<Widget>[
          GestionFormRow(label: 'Producto', child: GestionFormReadOnly(value: p.nombre)),
          GestionFormRow(label: 'Categoría', child: GestionFormReadOnly(value: p.categoria?.label ?? '-')),
        ],
        GestionFormRow(
          label: 'Disponible',
          child: GestionFormReadOnly(value: '${stock.cantidadActual} $unidad'.trim()),
        ),
        if (stock.ubicacionFisica != null)
          GestionFormRow(label: 'Ubicación', child: GestionFormReadOnly(value: stock.ubicacionFisica!)),
        const GestionFormSection(title: 'Transferencia'),
        GestionFormRow(
          label: 'Cantidad',
          required: true,
          child: AlmacenCantidadStepper(
            value: cantidad.toDouble(),
            min: 1,
            max: stock.cantidadActual.toDouble(),
            unit: p != null ? unidad : null,
            onChanged: (double v) => onCantidad(v.toInt()),
          ),
        ),
        GestionFormRow(
          label: 'Vehículo',
          required: true,
          child: GestionSearchField<String>(
            value: vehiculo,
            required: true,
            hint: 'Selecciona el vehículo',
            options: vehiculos.map((String v) => GestionOption<String>(v, v)).toList(growable: false),
            onChanged: onVehiculo,
          ),
        ),
        GestionFormRow(
          label: 'Motivo',
          required: true,
          multiline: true,
          child: GestionTextField(
            controller: motivo,
            hint: 'Motivo de la transferencia',
            maxLines: 3,
            validator: (String? v) => (v == null || v.trim().isEmpty) ? 'El motivo es obligatorio' : null,
          ),
        ),
      ],
    );
  }
}
