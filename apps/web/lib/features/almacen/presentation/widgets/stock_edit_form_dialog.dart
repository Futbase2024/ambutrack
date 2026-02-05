import 'package:ambutrack_core/ambutrack_core.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/widgets/buttons/app_button.dart';
import 'package:ambutrack_web/core/widgets/dialogs/app_dialog.dart';
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
      child: AppDialog(
        title: 'Editar Stock',
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

                      // === SECCIÓN: CANTIDADES ===
                      _buildSectionTitle('Cantidades de Stock'),
                      const SizedBox(height: AppSizes.spacing),
                      _buildCantidadesSection(),
                      const SizedBox(height: AppSizes.spacing),
                      const Divider(),
                      const SizedBox(height: AppSizes.spacing),

                      // === SECCIÓN: INFORMACIÓN ESPECÍFICA (según categoría) ===
                      if (_producto?.categoria == CategoriaProducto.medicacion) ...<Widget>[
                        _buildSectionTitle('Información de Medicación'),
                        const SizedBox(height: AppSizes.spacing),
                        _buildMedicacionFields(),
                        const SizedBox(height: AppSizes.spacing),
                        const Divider(),
                        const SizedBox(height: AppSizes.spacing),
                      ],

                      if (_producto?.categoria == CategoriaProducto.electromedicina) ...<Widget>[
                        _buildSectionTitle('Información de Electromedicina'),
                        const SizedBox(height: AppSizes.spacing),
                        _buildElectromedicinaFields(),
                        const SizedBox(height: AppSizes.spacing),
                        const Divider(),
                        const SizedBox(height: AppSizes.spacing),
                      ],

                      // === SECCIÓN: UBICACIÓN Y OBSERVACIONES ===
                      _buildSectionTitle('Ubicación y Notas'),
                      const SizedBox(height: AppSizes.spacing),

                      // Ubicación física
                      _buildTextField(
                        controller: _ubicacionController,
                        label: 'Ubicación Física',
                        hint: 'Ej: Estantería A, Nivel 2',
                        icon: Icons.place_outlined,
                      ),
                      const SizedBox(height: AppSizes.spacing),

                      // Observaciones
                      _buildTextField(
                        controller: _observacionesController,
                        label: 'Observaciones',
                        hint: 'Notas adicionales sobre este stock',
                        icon: Icons.notes,
                        maxLines: 3,
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
            label: 'Guardar Cambios',
            icon: Icons.save,
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
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
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
                color: AppColors.primary,
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
        ],
      ),
    );
  }

  /// Sección de cantidades (actual, mínima, máxima)
  Widget _buildCantidadesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        // Cantidad Actual (campo principal)
        _buildNumberField(
          label: 'Cantidad Actual *',
          value: _cantidadActual,
          onChanged: (double value) => setState(() => _cantidadActual = value),
          icon: Icons.inventory_2,
          min: 0,
        ),
        const SizedBox(height: AppSizes.spacing),

        // Cantidad Mínima y Máxima (en fila)
        Row(
          children: <Widget>[
            Expanded(
              child: _buildNumberField(
                label: 'Cantidad Mínima *',
                value: _cantidadMinima,
                onChanged: (double value) => setState(() => _cantidadMinima = value),
                icon: Icons.arrow_downward,
                min: 0,
              ),
            ),
            const SizedBox(width: AppSizes.spacing),
            Expanded(
              child: _buildNumberField(
                label: 'Cantidad Máxima',
                value: _cantidadMaxima,
                onChanged: (double value) => setState(() => _cantidadMaxima = value),
                min: _cantidadMinima,
                icon: Icons.arrow_upward,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Campos específicos de medicación
  Widget _buildMedicacionFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _buildTextField(
          controller: _loteController,
          label: 'Lote',
          hint: 'Ej: LOT-2024-001',
          icon: Icons.tag,
        ),
        const SizedBox(height: AppSizes.spacing),
        _buildDateField(),
      ],
    );
  }

  /// Campos específicos de electromedicina
  Widget _buildElectromedicinaFields() {
    return _buildTextField(
      controller: _numeroSerieController,
      label: 'Número de Serie',
      hint: 'Ej: SN-123456',
      icon: Icons.qr_code,
    );
  }

  /// Campo de fecha de caducidad
  Widget _buildDateField() {
    return InkWell(
      onTap: () async {
        final DateTime? fecha = await showDatePicker(
          context: context,
          initialDate: _fechaCaducidad ?? DateTime.now().add(const Duration(days: 365)),
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 3650)),
          builder: (BuildContext context, Widget? child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.light(
                  primary: AppColors.primary,
                ),
              ),
              child: child!,
            );
          },
        );

        if (fecha != null) {
          setState(() {
            _fechaCaducidad = fecha;
          });
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Fecha de Caducidad',
          hintText: 'Seleccionar fecha',
          prefixIcon: const Icon(Icons.calendar_today, size: 20),
          suffixIcon: _fechaCaducidad != null
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  onPressed: () => setState(() => _fechaCaducidad = null),
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          ),
        ),
        child: Text(
          _fechaCaducidad != null
              ? DateFormat('dd/MM/yyyy').format(_fechaCaducidad!)
              : 'Sin fecha',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: _fechaCaducidad != null ? AppColors.textPrimaryLight : AppColors.textSecondaryLight,
          ),
        ),
      ),
    );
  }

  /// Campo de texto genérico
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      textInputAction: maxLines == 1 ? TextInputAction.next : TextInputAction.newline,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        ),
      ),
    );
  }

  /// Campo numérico con botones +/-
  Widget _buildNumberField({
    required String label,
    required double value,
    required void Function(double) onChanged,
    required IconData icon,
    double min = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimaryLight,
          ),
        ),
        const SizedBox(height: AppSizes.spacingSmall),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingSmall),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.gray300),
            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          ),
          child: Row(
            children: <Widget>[
              Icon(icon, size: 18, color: AppColors.textSecondaryLight),
              const SizedBox(width: AppSizes.spacingSmall),
              IconButton(
                icon: const Icon(Icons.remove, size: 18),
                onPressed: value > min ? () => onChanged(value - 1) : null,
                color: AppColors.primary,
              ),
              Expanded(
                child: Text(
                  '${value.toInt()}',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimaryLight,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add, size: 18),
                onPressed: () => onChanged(value + 1),
                color: AppColors.primary,
              ),
            ],
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
