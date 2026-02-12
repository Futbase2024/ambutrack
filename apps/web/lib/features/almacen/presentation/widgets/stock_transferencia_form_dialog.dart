import 'dart:async';

import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/widgets/buttons/app_button.dart';
import 'package:ambutrack_web/core/widgets/dialogs/app_dialog.dart';
import 'package:ambutrack_web/core/widgets/dropdowns/app_dropdown.dart';
import 'package:ambutrack_web/core/widgets/handlers/crud_operation_handler.dart';
import 'package:ambutrack_web/core/widgets/loading/app_loading_indicator.dart';
import 'package:ambutrack_web/features/almacen/presentation/bloc/producto/producto_bloc.dart';
import 'package:ambutrack_web/features/almacen/presentation/bloc/producto/producto_state.dart';
import 'package:ambutrack_web/features/almacen/presentation/bloc/stock/stock_bloc.dart';
import 'package:ambutrack_web/features/almacen/presentation/bloc/stock/stock_event.dart';
import 'package:ambutrack_web/features/almacen/presentation/bloc/stock/stock_state.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/bloc/vehiculos_bloc.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/bloc/vehiculos_event.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/bloc/vehiculos_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

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
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validación: Vehículo seleccionado
    if (_vehiculoSeleccionado == null) {
      await CrudOperationHandler.handleWarning(
        context: context,
        title: 'Campo Requerido',
        message: 'Debes seleccionar el vehículo de destino.',
        details: 'Selecciona un vehículo activo de la lista',
      );
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
      child: AppDialog(
        title: 'Transferir Stock',
        content: _isLoading
          ? const Center(
              child: AppLoadingIndicator(
                message: 'Cargando datos...',
                size: 100,
              ),
            )
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    // === SECCIÓN: INFORMACIÓN DEL PRODUCTO ===
                    if (_producto != null) ...<Widget>[
                      _buildProductoInfo(),
                      const SizedBox(height: AppSizes.spacing),
                      const Divider(),
                      const SizedBox(height: AppSizes.spacing),
                    ],

                    // === SECCIÓN: CANTIDAD A TRANSFERIR ===
                    _buildSectionTitle('Cantidad a Transferir'),
                    const SizedBox(height: AppSizes.spacing),
                    _buildCantidadSection(),
                    const SizedBox(height: AppSizes.spacing),
                    const Divider(),
                    const SizedBox(height: AppSizes.spacing),

                    // === SECCIÓN: VEHÍCULO DESTINO ===
                    _buildSectionTitle('Vehículo de Destino'),
                    const SizedBox(height: AppSizes.spacing),

                    // Vehículo destino
                    Text(
                      'Vehículo *',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimaryLight,
                      ),
                    ),
                    const SizedBox(height: AppSizes.spacingSmall),
                    AppDropdown<String>(
                      value: _vehiculoSeleccionado,
                      hint: 'Selecciona el vehículo',
                      prefixIcon: Icons.local_shipping,
                      items: _vehiculosDisponibles
                          .map(
                            (String vehiculo) => AppDropdownItem<String>(
                              value: vehiculo,
                              label: vehiculo,
                              icon: Icons.directions_car,
                              iconColor: AppColors.secondary,
                            ),
                          )
                          .toList(),
                      onChanged: (String? value) {
                        setState(() {
                          _vehiculoSeleccionado = value;
                        });
                      },
                    ),
                    const SizedBox(height: AppSizes.spacing),
                    const Divider(),
                    const SizedBox(height: AppSizes.spacing),

                    // === SECCIÓN: MOTIVO ===
                    _buildSectionTitle('Motivo de la Transferencia'),
                    const SizedBox(height: AppSizes.spacing),
                    TextFormField(
                      controller: _motivoController,
                      maxLines: 3,
                      textInputAction: TextInputAction.newline,
                      decoration: InputDecoration(
                        labelText: 'Motivo *',
                        hintText: 'Describe el motivo de la transferencia',
                        prefixIcon: const Icon(Icons.description, size: 20),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                        ),
                      ),
                      validator: (String? value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'El motivo es obligatorio';
                        }
                        return null;
                        },
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
            onPressed: _isSaving ? null : _onSave,
            label: 'Transferir',
            icon: Icons.send,
          ),
        ],
      ),
    );
  }

  /// Info del producto
  Widget _buildProductoInfo() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        border: Border.all(color: AppColors.info.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(
                (_producto?.categoria?.icon ?? '') == '💊'
                    ? Icons.medication
                    : (_producto?.categoria?.icon ?? '') == '⚡'
                        ? Icons.electrical_services
                        : Icons.medical_services,
                color: AppColors.info,
                size: 24,
              ),
              const SizedBox(width: AppSizes.spacingSmall),
              Expanded(
                child: Text(
                  _producto!.nombre,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimaryLight,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spacingSmall),
          Text(
            'Categoría: ${_producto?.categoria?.label ?? '-'}',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.textSecondaryLight,
            ),
          ),
          Text(
            'Disponible: ${widget.stock.cantidadActual} ${_producto?.unidadMedida ?? ''}',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.success,
            ),
          ),
          if (widget.stock.ubicacionFisica != null)
            Text(
              'Ubicación: ${widget.stock.ubicacionFisica}',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.textSecondaryLight,
              ),
            ),
        ],
      ),
    );
  }

  /// Sección de cantidad a transferir
  Widget _buildCantidadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Cantidad a Transferir *',
          style: GoogleFonts.inter(
            fontSize: 13,
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
            children: <Widget>[
              const Icon(Icons.inventory_2, size: 20, color: AppColors.textSecondaryLight),
              const SizedBox(width: AppSizes.spacingSmall),
              IconButton(
                icon: const Icon(Icons.remove, size: 20),
                onPressed: _cantidadTransferir > 1
                    ? () => setState(() => _cantidadTransferir--)
                    : null,
                color: AppColors.primary,
              ),
              Expanded(
                child: Column(
                  children: <Widget>[
                    Text(
                      '$_cantidadTransferir',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    if (_producto != null)
                      Text(
                        _producto?.unidadMedida ?? '',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.textSecondaryLight,
                        ),
                      ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add, size: 20),
                onPressed: _cantidadTransferir < widget.stock.cantidadActual
                    ? () => setState(() => _cantidadTransferir++)
                    : null,
                color: AppColors.primary,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSizes.spacingSmall),
        Text(
          'Máximo: ${widget.stock.cantidadActual} ${_producto?.unidadMedida ?? ""}',
          style: GoogleFonts.inter(
            fontSize: 12,
            color: AppColors.textSecondaryLight,
          ),
        ),
      ],
    );
  }

  /// Título de sección
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.primary,
      ),
    );
  }
}
