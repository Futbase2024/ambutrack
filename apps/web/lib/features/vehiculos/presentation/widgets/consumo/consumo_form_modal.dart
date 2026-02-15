import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/services/auth_service.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/theme/app_text_styles.dart';
import 'package:ambutrack_web/core/widgets/dropdowns/app_dropdown.dart';
import 'package:ambutrack_web/core/widgets/dropdowns/app_searchable_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

/// Modal para crear/editar registros de consumo de combustible
///
/// Campos del formulario:
/// - Vehículo (dropdown con búsqueda)
/// - Fecha (date picker)
/// - Kilometraje del vehículo (validado ≥ último KM registrado)
/// - Tipo de combustible (dropdown)
/// - Litros (número decimal)
/// - Precio por litro (opcional, calcula costo total automáticamente)
/// - Costo total (calculado = litros × precio, editable)
/// - Estación (opcional)
/// - Notas (opcional, multilinea)
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
  final TextEditingController _fechaController = TextEditingController();
  final TextEditingController _kilometrajeController = TextEditingController();
  final TextEditingController _litrosController = TextEditingController();
  final TextEditingController _precioController = TextEditingController();
  final TextEditingController _costoController = TextEditingController();
  final TextEditingController _estacionController = TextEditingController();
  final TextEditingController _ubicacionController = TextEditingController();

  String? _vehiculoId;
  DateTime? _fechaSeleccionada;
  String? _tipoCombustible;
  bool _isSaving = false;

  bool get _isEditing => widget.consumo != null;

  @override
  void initState() {
    super.initState();
    _fechaSeleccionada = DateTime.now();
    _precioController.addListener(_actualizarCostoTotal);
    _litrosController.addListener(_actualizarCostoTotal);

    if (_isEditing) {
      _loadExistingData();
    } else {
      // Set initial date in controller
      _fechaController.text = _formatDate(_fechaSeleccionada!);
    }
  }

  @override
  void dispose() {
    _fechaController.dispose();
    _kilometrajeController.dispose();
    _litrosController.dispose();
    _precioController
      ..removeListener(_actualizarCostoTotal)
      ..dispose();
    _costoController.dispose();
    _estacionController.dispose();
    _ubicacionController.dispose();
    super.dispose();
  }

  void _loadExistingData() {
    final ConsumoCombustibleEntity consumo = widget.consumo!;
    _vehiculoId = consumo.vehiculoId;
    _fechaSeleccionada = consumo.fecha;
    _fechaController.text = _formatDate(consumo.fecha);
    _kilometrajeController.text = consumo.kmVehiculo.toStringAsFixed(0);
    _tipoCombustible = consumo.tipoCombustible;
    _litrosController.text = consumo.litros.toStringAsFixed(2);
    if (consumo.precioLitro != null) {
      _precioController.text = consumo.precioLitro!.toStringAsFixed(3);
    }
    _costoController.text = consumo.costoTotal.toStringAsFixed(2);
    if (consumo.estacion != null) {
      _estacionController.text = consumo.estacion!;
    }
    if (consumo.ubicacion != null) {
      _ubicacionController.text = consumo.ubicacion!;
    }
  }

  void _actualizarCostoTotal() {
    final double? litros = double.tryParse(_litrosController.text);
    final double? precio = double.tryParse(_precioController.text);

    if (litros != null && precio != null && litros > 0 && precio > 0) {
      final double costo = litros * precio;
      _costoController.text = costo.toStringAsFixed(2);
    }
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_vehiculoId == null ||
        _fechaSeleccionada == null ||
        _tipoCombustible == null) {
      _showErrorSnackBar('Por favor completa todos los campos obligatorios');
      return;
    }

    setState(() => _isSaving = true);

    try {
      final AuthService authService = AuthService();
      final User? currentUser = authService.currentUser;

      if (currentUser == null) {
        throw Exception('Usuario no autenticado');
      }

      final double kilometraje = double.parse(_kilometrajeController.text);
      final double litros = double.parse(_litrosController.text);
      final double costoTotal = double.parse(_costoController.text);
      final double? precioLitro = _precioController.text.isNotEmpty
          ? double.tryParse(_precioController.text)
          : null;

      final ConsumoCombustibleEntity consumo = _isEditing
          ? widget.consumo!.copyWith(
              vehiculoId: _vehiculoId!,
              fecha: _fechaSeleccionada!,
              kmVehiculo: kilometraje,
              tipoCombustible: _tipoCombustible!,
              litros: litros,
              precioLitro: precioLitro,
              costoTotal: costoTotal,
              estacion: _estacionController.text.trim().isEmpty
                  ? null
                  : _estacionController.text.trim(),
              ubicacion: _ubicacionController.text.trim().isEmpty
                  ? null
                  : _ubicacionController.text.trim(),
              updatedAt: DateTime.now(),
            )
          : ConsumoCombustibleEntity(
              id: const Uuid().v4(),
              vehiculoId: _vehiculoId!,
              fecha: _fechaSeleccionada!,
              kmVehiculo: kilometraje,
              tipoCombustible: _tipoCombustible!,
              litros: litros,
              precioLitro: precioLitro,
              costoTotal: costoTotal,
              estacion: _estacionController.text.trim().isEmpty
                  ? null
                  : _estacionController.text.trim(),
              ubicacion: _ubicacionController.text.trim().isEmpty
                  ? null
                  : _ubicacionController.text.trim(),
              empresaId:
                  currentUser.userMetadata?['empresa_id']?.toString() ?? '',
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            );

      await widget.onSave(consumo);

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        _showErrorSnackBar('Error al guardar: ${e.toString()}');
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _fechaSeleccionada ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      locale: const Locale('es', 'ES'),
      textDirection: TextDirection.ltr,
    );

    if (picked != null) {
      setState(() {
        _fechaSeleccionada = picked;
        _fechaController.text = _formatDate(picked);
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: <Widget>[
          Container(
            width: 650,
            constraints: const BoxConstraints(maxHeight: 750),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _buildHeader(),
                const SizedBox(height: 24),
                Expanded(
                  child: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          _buildVehiculoField(),
                          const SizedBox(height: 16),
                          Row(
                            children: <Widget>[
                              Expanded(child: _buildFechaField()),
                              const SizedBox(width: 12),
                              Expanded(child: _buildKilometrajeField()),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildTipoCombustibleField(),
                          const SizedBox(height: 16),
                          Row(
                            children: <Widget>[
                              Expanded(child: _buildLitrosField()),
                              const SizedBox(width: 12),
                              Expanded(child: _buildPrecioField()),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildCostoTotalField(),
                          const SizedBox(height: 16),
                          _buildEstacionField(),
                          const SizedBox(height: 16),
                          _buildUbicacionField(),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _buildActions(),
              ],
            ),
          ),
          if (_isSaving)
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.gray900.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.local_gas_station,
            size: 28,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                _isEditing ? 'Editar Consumo' : 'Registrar Consumo',
                style: AppTextStyles.h3,
              ),
              const SizedBox(height: 4),
              Text(
                _isEditing
                    ? 'Modifica los datos del registro de consumo'
                    : 'Registra un nuevo consumo de combustible',
                style: AppTextStyles.bodySecondary,
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close, color: AppColors.gray600),
        ),
      ],
    );
  }

  Widget _buildVehiculoField() {
    final List<AppSearchableDropdownItem<String>> items = widget.vehiculos
        .map(
          (VehiculoEntity v) => AppSearchableDropdownItem<String>(
            value: v.id,
            label: '${v.matricula} - ${v.marca} ${v.modelo}',
          ),
        )
        .toList();

    return AppSearchableDropdown<String>(
      label: 'Vehículo *',
      value: _vehiculoId,
      items: items,
      onChanged: (String? value) {
        setState(() => _vehiculoId = value);
      },
      enabled: !_isEditing,
    );
  }

  Widget _buildFechaField() {
    return InkWell(
      onTap: _selectDate,
      borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
      child: AbsorbPointer(
        child: TextFormField(
          controller: _fechaController,
          decoration: InputDecoration(
            labelText: 'Fecha *',
            hintText: 'DD/MM/AAAA',
            suffixIcon: const Icon(Icons.calendar_today),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
            ),
          ),
          textInputAction: TextInputAction.next,
          validator: (String? value) {
            if (value == null || value.trim().isEmpty) {
              return 'La fecha es obligatoria';
            }
            return null;
          },
        ),
      ),
    );
  }

  Widget _buildKilometrajeField() {
    final double minKm = _isEditing
        ? (widget.consumo?.kmVehiculo ?? 0)
        : widget.ultimoKmVehiculo;

    return TextFormField(
      controller: _kilometrajeController,
      decoration: InputDecoration(
        labelText: 'Kilometraje *',
        hintText: 'Ej: 150000',
        suffixText: 'km',
        helperText: _isEditing
            ? null
            : 'Mínimo: ${minKm.toStringAsFixed(0)} km (último registrado)',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        ),
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
      ],
      textInputAction: TextInputAction.next,
      validator: (String? value) {
        if (value == null || value.trim().isEmpty) {
          return 'El kilometraje es obligatorio';
        }
        final double? km = double.tryParse(value);
        if (km == null || km <= 0) {
          return 'Ingresa un kilometraje válido';
        }
        if (!_isEditing && km < minKm) {
          return 'KM no puede ser menor al último registrado (${minKm.toStringAsFixed(0)})';
        }
        return null;
      },
    );
  }

  Widget _buildTipoCombustibleField() {
    return AppDropdown<String>(
      label: 'Tipo de Combustible *',
      value: _tipoCombustible,
      items: TipoCombustible.values
          .map(
            (TipoCombustible tipo) => AppDropdownItem<String>(
              value: tipo.name,
              label: _getTipoCombustibleLabel(tipo),
            ),
          )
          .toList(),
      onChanged: (String? value) {
        setState(() => _tipoCombustible = value);
      },
      clearable: false,
    );
  }

  String _getTipoCombustibleLabel(TipoCombustible tipo) {
    switch (tipo) {
      case TipoCombustible.gasolina95:
        return 'Gasolina 95';
      case TipoCombustible.gasolina98:
        return 'Gasolina 98';
      case TipoCombustible.diesel:
        return 'Diesel';
      case TipoCombustible.electrico:
        return 'Eléctrico';
      case TipoCombustible.hibrido:
        return 'Híbrido';
      case TipoCombustible.glp:
        return 'GLP';
      case TipoCombustible.gnc:
        return 'GNC';
      case TipoCombustible.gnl:
        return 'GNL';
    }
  }

  Widget _buildLitrosField() {
    return TextFormField(
      controller: _litrosController,
      decoration: InputDecoration(
        labelText: 'Litros *',
        hintText: 'Ej: 45.50',
        suffixText: 'L',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        ),
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
      ],
      textInputAction: TextInputAction.next,
      validator: (String? value) {
        if (value == null || value.trim().isEmpty) {
          return 'Los litros son obligatorios';
        }
        final double? litros = double.tryParse(value);
        if (litros == null || litros <= 0) {
          return 'Ingresa una cantidad válida';
        }
        return null;
      },
    );
  }

  Widget _buildPrecioField() {
    return TextFormField(
      controller: _precioController,
      decoration: InputDecoration(
        labelText: 'Precio por Litro',
        hintText: 'Ej: 1.659',
        suffixText: '€/L',
        helperText: 'Opcional. Calcula costo total automáticamente.',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        ),
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,3}')),
      ],
      textInputAction: TextInputAction.next,
    );
  }

  Widget _buildCostoTotalField() {
    return TextFormField(
      controller: _costoController,
      decoration: InputDecoration(
        labelText: 'Costo Total *',
        hintText: 'Ej: 75.50',
        suffixText: '€',
        helperText: 'Calculado = Litros × Precio (puedes editarlo)',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        ),
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
      ],
      textInputAction: TextInputAction.next,
      validator: (String? value) {
        if (value == null || value.trim().isEmpty) {
          return 'El costo total es obligatorio';
        }
        final double? costo = double.tryParse(value);
        if (costo == null || costo <= 0) {
          return 'Ingresa un costo válido';
        }
        return null;
      },
    );
  }

  Widget _buildEstacionField() {
    return TextFormField(
      controller: _estacionController,
      decoration: InputDecoration(
        labelText: 'Estación de Servicio',
        hintText: 'Ej: Repsol, Cepsa, Shell...',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        ),
      ),
      textInputAction: TextInputAction.next,
    );
  }

  Widget _buildUbicacionField() {
    return TextFormField(
      controller: _ubicacionController,
      decoration: InputDecoration(
        labelText: 'Ubicación',
        hintText: 'Ej: Madrid, Calle Mayor...',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        ),
      ),
      textInputAction: TextInputAction.done,
    );
  }

  Widget _buildActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        const SizedBox(width: 12),
        FilledButton.icon(
          onPressed: _isSaving ? null : _onSave,
          icon: Icon(_isEditing ? Icons.save : Icons.add),
          label: Text(_isEditing ? 'Actualizar' : 'Guardar'),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          ),
        ),
      ],
    );
  }
}
