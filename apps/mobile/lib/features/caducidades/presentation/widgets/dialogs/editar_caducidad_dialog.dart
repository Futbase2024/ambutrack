import 'package:flutter/material.dart';
import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_sizes.dart';

/// Diálogo para editar un item de caducidad
///
/// Permite modificar:
/// - Cantidad actual
/// - Fecha de caducidad
/// - Lote
/// - Ubicación
/// - Observaciones
class EditarCaducidadDialog extends StatefulWidget {
  const EditarCaducidadDialog({
    super.key,
    required this.item,
    required this.onGuardar,
  });

  final StockVehiculoEntity item;
  final Future<void> Function({
    required int cantidadActual,
    DateTime? fechaCaducidad,
    String? lote,
    String? ubicacion,
    String? observaciones,
  }) onGuardar;

  @override
  State<EditarCaducidadDialog> createState() => _EditarCaducidadDialogState();
}

class _EditarCaducidadDialogState extends State<EditarCaducidadDialog> {
  final _formKey = GlobalKey<FormState>();
  final _cantidadController = TextEditingController();
  final _loteController = TextEditingController();
  final _ubicacionController = TextEditingController();
  final _observacionesController = TextEditingController();

  DateTime? _fechaCaducidad;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    // Pre-rellenar con valores actuales
    _cantidadController.text = widget.item.cantidadActual.toString();
    _loteController.text = widget.item.lote ?? '';
    _ubicacionController.text = widget.item.ubicacion ?? '';
    _observacionesController.text = widget.item.observaciones ?? '';
    _fechaCaducidad = widget.item.fechaCaducidad;
  }

  @override
  void dispose() {
    _cantidadController.dispose();
    _loteController.dispose();
    _ubicacionController.dispose();
    _observacionesController.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isProcessing = true);

    try {
      await widget.onGuardar(
        cantidadActual: int.parse(_cantidadController.text),
        fechaCaducidad: _fechaCaducidad,
        lote: _loteController.text.isEmpty ? null : _loteController.text,
        ubicacion: _ubicacionController.text.isEmpty ? null : _ubicacionController.text,
        observaciones: _observacionesController.text.isEmpty ? null : _observacionesController.text,
      );

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      debugPrint('❌ Error al guardar cambios: $e');
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _seleccionarFecha() async {
    final fechaSeleccionada = await showDatePicker(
      context: context,
      initialDate: _fechaCaducidad ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)), // 10 años
      locale: const Locale('es', 'ES'),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.gray900,
            ),
          ),
          child: child!,
        );
      },
    );

    if (fechaSeleccionada != null) {
      setState(() => _fechaCaducidad = fechaSeleccionada);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.edit,
                            color: AppColors.secondary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Editar Item',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.gray900,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.item.productoNombre ?? 'Sin nombre',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.gray600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Campo: Cantidad actual
                    const Text(
                      'Cantidad Actual *',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.gray900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _cantidadController,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        hintText: 'Cantidad en unidades',
                        prefixIcon: const Icon(Icons.inventory_2_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'La cantidad es obligatoria';
                        }
                        final cantidad = int.tryParse(value);
                        if (cantidad == null || cantidad < 0) {
                          return 'Ingresa una cantidad válida';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Campo: Fecha de caducidad
                    const Text(
                      'Fecha de Caducidad',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.gray900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: _seleccionarFecha,
                      borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.gray400),
                          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.calendar_today_outlined,
                              color: AppColors.gray600,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _fechaCaducidad != null
                                    ? '${_fechaCaducidad!.day.toString().padLeft(2, '0')}/${_fechaCaducidad!.month.toString().padLeft(2, '0')}/${_fechaCaducidad!.year}'
                                    : 'Sin fecha de caducidad',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: _fechaCaducidad != null
                                      ? AppColors.gray900
                                      : AppColors.gray500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Campo: Lote
                    const Text(
                      'Lote',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.gray900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _loteController,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        hintText: 'Número de lote',
                        prefixIcon: const Icon(Icons.qr_code_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Campo: Ubicación
                    const Text(
                      'Ubicación',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.gray900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _ubicacionController,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        hintText: 'Ubicación en el vehículo',
                        prefixIcon: const Icon(Icons.location_on_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Campo: Observaciones
                    const Text(
                      'Observaciones',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.gray900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _observacionesController,
                      textInputAction: TextInputAction.newline,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Observaciones adicionales',
                        prefixIcon: const Icon(Icons.note_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Botones de acción
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _isProcessing ? null : () => Navigator.of(context).pop(),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text('Cancelar'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isProcessing ? null : _guardar,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.secondary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text('Guardar'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Loading overlay
          if (_isProcessing)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Card(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text(
                            'Guardando cambios...',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
