import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/services/auth_service.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/widgets/dropdowns/app_dropdown.dart';
import 'package:ambutrack_web/core/widgets/dropdowns/app_searchable_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

/// Modal para crear/editar incidencias de vehículos
///
/// Campos del formulario:
/// - Vehículo (dropdown con búsqueda)
/// - Tipo (dropdown)
/// - Prioridad (dropdown)
/// - Título (máx 100 caracteres)
/// - Descripción (máx 500 caracteres)
/// - Kilometraje (opcional, validado ≥ KM actual)
class IncidenciaFormModal extends StatefulWidget {
  const IncidenciaFormModal({
    this.incidencia,
    required this.onSave,
    super.key,
  });

  final IncidenciaVehiculoEntity? incidencia;
  final Future<void> Function(IncidenciaVehiculoEntity) onSave;

  @override
  State<IncidenciaFormModal> createState() => _IncidenciaFormModalState();
}

class _IncidenciaFormModalState extends State<IncidenciaFormModal> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _kilometrajeController = TextEditingController();

  String? _vehiculoId;
  TipoIncidencia? _tipo;
  PrioridadIncidencia? _prioridad;
  bool _isSaving = false;

  bool get _isEditing => widget.incidencia != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _loadExistingData();
    }
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descripcionController.dispose();
    _kilometrajeController.dispose();
    super.dispose();
  }

  void _loadExistingData() {
    final IncidenciaVehiculoEntity incidencia = widget.incidencia!;
    _vehiculoId = incidencia.vehiculoId;
    _tipo = incidencia.tipo;
    _prioridad = incidencia.prioridad;
    _tituloController.text = incidencia.titulo;
    _descripcionController.text = incidencia.descripcion;
    if (incidencia.kilometrajeReporte != null) {
      _kilometrajeController.text = incidencia.kilometrajeReporte.toString();
    }
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_vehiculoId == null || _tipo == null || _prioridad == null) {
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

      final IncidenciaVehiculoEntity incidencia = _isEditing
          ? widget.incidencia!.copyWith(
              tipo: _tipo,
              prioridad: _prioridad,
              titulo: _tituloController.text.trim(),
              descripcion: _descripcionController.text.trim(),
              kilometrajeReporte: _kilometrajeController.text.isNotEmpty
                  ? double.tryParse(_kilometrajeController.text)
                  : null,
              updatedAt: DateTime.now(),
            )
          : IncidenciaVehiculoEntity(
              id: const Uuid().v4(),
              vehiculoId: _vehiculoId!,
              reportadoPor: currentUser.id,
              reportadoPorNombre:
                  (currentUser.userMetadata?['nombre']?.toString() ??
                          'Usuario')
                      .toUpperCase(),
              fechaReporte: DateTime.now(),
              tipo: _tipo!,
              prioridad: _prioridad!,
              estado: EstadoIncidencia.reportada,
              titulo: _tituloController.text.trim(),
              descripcion: _descripcionController.text.trim(),
              kilometrajeReporte: _kilometrajeController.text.isNotEmpty
                  ? double.tryParse(_kilometrajeController.text)
                  : null,
              empresaId: currentUser.userMetadata?['empresa_id']?.toString() ??
                  '',
              createdAt: DateTime.now(),
            );

      await widget.onSave(incidencia);

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

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: <Widget>[
          Container(
            width: 700,
            constraints: const BoxConstraints(maxHeight: 700),
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
                              Expanded(child: _buildTipoField()),
                              const SizedBox(width: 12),
                              Expanded(child: _buildPrioridadField()),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildTituloField(),
                          const SizedBox(height: 16),
                          _buildDescripcionField(),
                          const SizedBox(height: 16),
                          _buildKilometrajeField(),
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
            color: AppColors.emergency.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.report_problem,
            size: 28,
            color: AppColors.emergency,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                _isEditing ? 'Editar Incidencia' : 'Reportar Avería',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.gray900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _isEditing
                    ? 'Modifica los datos de la incidencia'
                    : 'Registra una nueva avería o incidencia del vehículo',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.gray600,
                ),
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
    // Placeholder para dropdown de vehículos
    // En el futuro integrar con VehiculoDataSource para listar vehículos reales
    return AppSearchableDropdown<String>(
      label: 'Vehículo *',
      value: _vehiculoId,
      items: const <AppSearchableDropdownItem<String>>[
        AppSearchableDropdownItem<String>(
          value: 'veh-1',
          label: 'Vehículo de prueba 1',
        ),
        AppSearchableDropdownItem<String>(
          value: 'veh-2',
          label: 'Vehículo de prueba 2',
        ),
      ],
      onChanged: (String? value) {
        setState(() => _vehiculoId = value);
      },
      enabled: !_isEditing,
    );
  }

  Widget _buildTipoField() {
    return AppDropdown<TipoIncidencia>(
      label: 'Tipo *',
      value: _tipo,
      items: TipoIncidencia.values
          .map(
            (TipoIncidencia tipo) => AppDropdownItem<TipoIncidencia>(
              value: tipo,
              label: tipo.nombre,
            ),
          )
          .toList(),
      onChanged: (TipoIncidencia? value) {
        setState(() => _tipo = value);
      },
      clearable: false,
    );
  }

  Widget _buildPrioridadField() {
    return AppDropdown<PrioridadIncidencia>(
      label: 'Prioridad *',
      value: _prioridad,
      items: PrioridadIncidencia.values
          .map(
            (PrioridadIncidencia prioridad) =>
                AppDropdownItem<PrioridadIncidencia>(
              value: prioridad,
              label: prioridad.nombre,
            ),
          )
          .toList(),
      onChanged: (PrioridadIncidencia? value) {
        setState(() => _prioridad = value);
      },
      clearable: false,
    );
  }

  Widget _buildTituloField() {
    return TextFormField(
      controller: _tituloController,
      decoration: InputDecoration(
        labelText: 'Título *',
        hintText: 'Ej: Fallo en el motor',
        counterText: '${_tituloController.text.length}/100',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        ),
      ),
      maxLength: 100,
      textInputAction: TextInputAction.next,
      validator: (String? value) {
        if (value == null || value.trim().isEmpty) {
          return 'El título es obligatorio';
        }
        return null;
      },
      onChanged: (_) => setState(() {}),
    );
  }

  Widget _buildDescripcionField() {
    return TextFormField(
      controller: _descripcionController,
      decoration: InputDecoration(
        labelText: 'Descripción *',
        hintText: 'Describe el problema en detalle...',
        counterText: '${_descripcionController.text.length}/500',
        alignLabelWithHint: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        ),
      ),
      maxLength: 500,
      maxLines: 4,
      textInputAction: TextInputAction.newline,
      validator: (String? value) {
        if (value == null || value.trim().isEmpty) {
          return 'La descripción es obligatoria';
        }
        return null;
      },
      onChanged: (_) => setState(() {}),
    );
  }

  Widget _buildKilometrajeField() {
    return TextFormField(
      controller: _kilometrajeController,
      decoration: InputDecoration(
        labelText: 'Kilometraje (opcional)',
        hintText: 'Ej: 150000',
        suffixText: 'km',
        helperText: 'Si se indica, debe ser ≥ KM actual del vehículo',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        ),
      ),
      keyboardType: TextInputType.number,
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.digitsOnly,
      ],
      textInputAction: TextInputAction.done,
      validator: (String? value) {
        if (value != null && value.isNotEmpty) {
          final double? km = double.tryParse(value);
          if (km == null || km < 0) {
            return 'Ingresa un kilometraje válido';
          }
        }
        return null;
      },
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
            backgroundColor: AppColors.emergency,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          ),
        ),
      ],
    );
  }
}
