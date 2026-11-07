import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/services/auth_service.dart';
import 'package:ambutrack_web/core/widgets/dialogs/result_dialog.dart';
import 'package:ambutrack_web/core/widgets/gestion/form/gestion_form.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/widgets/consumo/form/consumo_form_body.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/widgets/consumo/form/consumo_form_data.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

/// Modal para crear/editar registros de consumo de combustible
///
/// Campos del formulario:
/// - Vehículo (desplegable con búsqueda)
/// - Fecha
/// - Kilometraje del vehículo (validado ≥ último KM registrado)
/// - Tipo de combustible
/// - Litros (número decimal)
/// - Precio por litro (opcional, calcula costo total automáticamente)
/// - Costo total (calculado = litros × precio, editable)
/// - Estación y ubicación (opcionales)
class ConsumoFormModal extends StatefulWidget {
  const ConsumoFormModal({
    this.consumo,
    this.ultimoKmVehiculo = 0.0,
    required this.vehiculos,
    required this.onSave,
    super.key,
  });

  final ConsumoCombustibleEntity? consumo;
  final double ultimoKmVehiculo;
  final List<VehiculoEntity> vehiculos;
  final Future<void> Function(ConsumoCombustibleEntity) onSave;

  @override
  State<ConsumoFormModal> createState() => _ConsumoFormModalState();
}

class _ConsumoFormModalState extends State<ConsumoFormModal> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final ConsumoFormData _data = ConsumoFormData(original: widget.consumo);
  bool _isSaving = false;

  bool get _isEditing => widget.consumo != null;

  double get _minKm => _isEditing ? (widget.consumo?.kmVehiculo ?? 0) : widget.ultimoKmVehiculo;

  @override
  void dispose() {
    _data.dispose();
    super.dispose();
  }

  String? get _matricula {
    for (final VehiculoEntity v in widget.vehiculos) {
      if (v.id == widget.consumo?.vehiculoId) {
        return v.matricula;
      }
    }
    return null;
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    // Los obligatorios se validan en cada campo; salvaguarda adicional
    if (_data.vehiculoId == null || _data.fecha == null || _data.tipoCombustible == null) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      final AuthService authService = AuthService();
      final User? currentUser = authService.currentUser;

      if (currentUser == null) {
        throw Exception('Usuario no autenticado');
      }

      final ConsumoCombustibleEntity consumo = _buildConsumo(currentUser);

      await widget.onSave(consumo);

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      debugPrint('❌ ConsumoFormModal: Error al guardar: $e');
      if (mounted) {
        setState(() => _isSaving = false);
        await showResultDialog(
          context: context,
          title: 'Error al Guardar',
          message: _isEditing
              ? 'No se pudo actualizar el registro de consumo.'
              : 'No se pudo crear el registro de consumo.',
          details: e.toString(),
          type: ResultType.error,
        );
      }
    }
  }

  ConsumoCombustibleEntity _buildConsumo(User currentUser) {
    final double kilometraje = _data.kilometrajeValue!;
    final double litros = _data.litrosValue!;
    final double costoTotal = _data.costoValue!;
    final double? precioLitro = _data.precioValue;

    if (_isEditing) {
      return widget.consumo!.copyWith(
        vehiculoId: _data.vehiculoId,
        fecha: _data.fecha,
        kmVehiculo: kilometraje,
        tipoCombustible: _data.tipoCombustible,
        litros: litros,
        precioLitro: precioLitro,
        costoTotal: costoTotal,
        estacion: _data.estacionValue,
        ubicacion: _data.ubicacionValue,
        updatedAt: DateTime.now(),
      );
    }
    return ConsumoCombustibleEntity(
      id: const Uuid().v4(),
      vehiculoId: _data.vehiculoId!,
      fecha: _data.fecha!,
      kmVehiculo: kilometraje,
      tipoCombustible: _data.tipoCombustible!,
      litros: litros,
      precioLitro: precioLitro,
      costoTotal: costoTotal,
      estacion: _data.estacionValue,
      ubicacion: _data.ubicacionValue,
      empresaId: currentUser.userMetadata?['empresa_id']?.toString() ?? '',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestionFormDialog(
      title: _isEditing ? 'Editar consumo' : 'Nuevo consumo',
      subtitle: _isEditing ? _matricula : null,
      icon: Icons.local_gas_station_outlined,
      formKey: _formKey,
      isEditing: _isEditing,
      isSaving: _isSaving,
      onSave: _onSave,
      children: <Widget>[
        ConsumoFormBody(
          data: _data,
          vehiculos: widget.vehiculos,
          isEditing: _isEditing,
          minKm: _minKm,
          onChanged: () => setState(() {}),
        ),
      ],
    );
  }
}
