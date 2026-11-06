import 'dart:async';

import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/form/gestion_form.dart';
import 'package:ambutrack_web/core/widgets/handlers/crud_operation_handler.dart';
import 'package:ambutrack_web/core/widgets/loading/app_loading_indicator.dart';
import 'package:ambutrack_web/features/vehiculos/equipamiento/presentation/bloc/equipamiento_vehiculo_bloc.dart';
import 'package:ambutrack_web/features/vehiculos/equipamiento/presentation/bloc/equipamiento_vehiculo_event.dart';
import 'package:ambutrack_web/features/vehiculos/equipamiento/presentation/bloc/equipamiento_vehiculo_state.dart';
import 'package:ambutrack_web/features/vehiculos/equipamiento/presentation/widgets/producto_catalogo.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Formulario "Añadir extra": material que el vehículo lleva fuera de su plantilla
class EquipamientoExtraFormDialog extends StatefulWidget {
  const EquipamientoExtraFormDialog({required this.productosEnVehiculo, super.key});

  /// IDs de productos que ya tiene el vehículo (no se ofrecen)
  final Set<String> productosEnVehiculo;

  @override
  State<EquipamientoExtraFormDialog> createState() => _EquipamientoExtraFormDialogState();
}

class _EquipamientoExtraFormDialogState extends State<EquipamientoExtraFormDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _cantidad = TextEditingController(text: '1');
  final TextEditingController _lote = TextEditingController();
  final TextEditingController _observaciones = TextEditingController();
  List<ProductoEntity>? _productos;
  String? _errorCarga;
  ProductoEntity? _producto;
  DateTime? _caducidad;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    unawaited(_cargar());
  }

  Future<void> _cargar() async {
    try {
      final List<ProductoEntity> todos = await cargarCatalogoProductos();
      if (mounted) {
        setState(() => _productos = todos
            .where((ProductoEntity p) => !widget.productosEnVehiculo.contains(p.id))
            .toList());
      }
    } catch (e) {
      debugPrint('❌ EquipamientoExtraForm: error al cargar productos: $e');
      if (mounted) {
        setState(() => _errorCarga = e.toString());
      }
    }
  }

  @override
  void dispose() {
    _cantidad.dispose();
    _lote.dispose();
    _observaciones.dispose();
    super.dispose();
  }

  void _onBlocState(BuildContext context, EquipamientoVehiculoState state) {
    if (!_isSaving) {
      return;
    }
    if (state.resultado == EquipamientoResultado.exito) {
      unawaited(CrudOperationHandler.handleSuccess(
        context: context,
        isSaving: _isSaving,
        isEditing: false,
        entityName: 'Item extra',
        onClose: _reset,
      ));
    } else if (state.resultado == EquipamientoResultado.error) {
      unawaited(CrudOperationHandler.handleError(
        context: context,
        isSaving: _isSaving,
        isEditing: false,
        entityName: 'Item extra',
        errorMessage: state.error ?? 'Error desconocido',
        onClose: _reset,
      ));
    }
  }

  void _reset() {
    if (mounted) {
      setState(() => _isSaving = false);
    }
  }

  void _onSave() {
    if (_productos == null || !_formKey.currentState!.validate()) {
      return;
    }
    setState(() => _isSaving = true);
    unawaited(showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext _) => const AppLoadingOverlay(
        message: 'Añadiendo item extra...',
        color: AppColors.primary,
        icon: Icons.add_circle_outline,
      ),
    ));
    context.read<EquipamientoVehiculoBloc>().add(EquipamientoExtraAddRequested(
          productoId: _producto!.id,
          cantidad: int.parse(_cantidad.text),
          fechaCaducidad: _caducidad,
          lote: _lote.text,
          observaciones: _observaciones.text,
        ));
  }

  static String? _validarCantidad(String? v) {
    final int? n = int.tryParse(v ?? '');
    return n == null || n < 1 ? 'La cantidad debe ser 1 o más' : null;
  }

  @override
  Widget build(BuildContext context) {
    final DateTime hoy = DateTime.now();
    final List<ProductoEntity>? productos = _productos;
    return BlocListener<EquipamientoVehiculoBloc, EquipamientoVehiculoState>(
      listenWhen: (EquipamientoVehiculoState a, EquipamientoVehiculoState b) => a.operacion != b.operacion,
      listener: _onBlocState,
      child: GestionFormDialog(
        title: 'Añadir item extra',
        subtitle: 'Material fuera de la plantilla de este vehículo',
        icon: Icons.add_box_outlined,
        formKey: _formKey,
        isSaving: _isSaving,
        onSave: _onSave,
        children: <Widget>[
          if (productos == null)
            SizedBox(
              height: 220,
              child: Center(
                child: _errorCarga == null
                    ? const AppLoadingIndicator(message: 'Cargando productos...')
                    : Text('No se pudieron cargar los productos: $_errorCarga'),
              ),
            )
          else ...<Widget>[
            const GestionFormSection(title: 'Producto', first: true),
            GestionFormRow(
              label: 'Producto',
              required: true,
              child: GestionSearchField<ProductoEntity>(
                value: _producto,
                required: true,
                hint: 'Buscar por nombre o código...',
                options: opcionesProductos(productos),
                onChanged: (ProductoEntity? p) => setState(() => _producto = p),
              ),
            ),
            const GestionFormSection(title: 'Dotación'),
            GestionFormRow(
              label: 'Cantidad',
              required: true,
              child: GestionTextField(
                controller: _cantidad,
                textAlign: TextAlign.end,
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
                validator: _validarCantidad,
              ),
            ),
            GestionFormRow(
              label: 'Caducidad',
              child: GestionDateField(
                value: _caducidad,
                firstDate: DateTime(hoy.year - 5),
                lastDate: DateTime(hoy.year + 15),
                onChanged: (DateTime? v) => setState(() => _caducidad = v),
              ),
            ),
            GestionFormRow(label: 'Nº de lote', child: GestionTextField(controller: _lote)),
            GestionFormRow(
              label: 'Observaciones',
              multiline: true,
              child: GestionTextField(controller: _observaciones, maxLines: 3),
            ),
          ],
        ],
      ),
    );
  }
}
