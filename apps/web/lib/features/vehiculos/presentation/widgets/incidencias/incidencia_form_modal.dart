import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/services/auth_service.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/dialogs/result_dialog.dart';
import 'package:ambutrack_web/core/widgets/gestion/form/gestion_form.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/bloc/vehiculos_bloc.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/bloc/vehiculos_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

  /// Km actual del vehículo seleccionado (mínimo para una avería nueva).
  /// Al editar no se exige: el vehículo ha podido sumar km desde el reporte.
  double? _kmMinimo(BuildContext context) {
    if (_isEditing || _vehiculoId == null) {
      return null;
    }
    final VehiculosState state = context.watch<VehiculosBloc>().state;
    if (state is! VehiculosLoaded) {
      return null;
    }
    return state.vehiculos.where((VehiculoEntity v) => v.id == _vehiculoId).firstOrNull?.kmActual;
  }

  double? get _kilometraje =>
      _kilometrajeController.text.isNotEmpty ? double.tryParse(_kilometrajeController.text) : null;

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_vehiculoId == null || _tipo == null || _prioridad == null) {
      await _showError('Por favor completa todos los campos obligatorios');
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
              kilometrajeReporte: _kilometraje,
              updatedAt: DateTime.now(),
            )
          : IncidenciaVehiculoEntity(
              id: const Uuid().v4(),
              vehiculoId: _vehiculoId!,
              reportadoPor: currentUser.id,
              reportadoPorNombre: (currentUser.userMetadata?['nombre']?.toString() ?? 'Usuario').toUpperCase(),
              fechaReporte: DateTime.now(),
              tipo: _tipo!,
              prioridad: _prioridad!,
              estado: EstadoIncidencia.reportada,
              titulo: _tituloController.text.trim(),
              descripcion: _descripcionController.text.trim(),
              kilometrajeReporte: _kilometraje,
              empresaId: currentUser.userMetadata?['empresa_id']?.toString() ?? '',
              createdAt: DateTime.now(),
            );

      await widget.onSave(incidencia);

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      debugPrint('❌ IncidenciaFormModal: $e');
      if (mounted) {
        setState(() => _isSaving = false);
        await _showError('Error al guardar: ${e.toString()}');
      }
    }
  }

  Future<void> _showError(String message) {
    return showResultDialog(
      context: context,
      title: 'No se pudo guardar',
      message: message,
      type: ResultType.error,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestionFormDialog(
      title: _isEditing ? 'Editar incidencia' : 'Reportar avería',
      subtitle: _isEditing ? widget.incidencia!.titulo : null,
      icon: Icons.report_problem_outlined,
      formKey: _formKey,
      isEditing: _isEditing,
      isSaving: _isSaving,
      onSave: _onSave,
      children: <Widget>[
        const GestionFormSection(title: 'Incidencia', first: true),
        GestionFormRow(
          label: 'Vehículo',
          required: true,
          child: _VehiculoField(
            value: _vehiculoId,
            isEditing: _isEditing,
            onChanged: (String? v) => setState(() => _vehiculoId = v),
          ),
        ),
        GestionFormColumns(
          children: <Widget>[
            GestionFormRow(
              label: 'Tipo',
              required: true,
              child: GestionDropdownField<TipoIncidencia>(
                value: _tipo,
                required: true,
                options: TipoIncidencia.values
                    .map((TipoIncidencia t) => GestionOption<TipoIncidencia>(t, t.nombre))
                    .toList(),
                onChanged: (TipoIncidencia? v) => setState(() => _tipo = v),
              ),
            ),
            GestionFormRow(
              label: 'Prioridad',
              required: true,
              child: GestionDropdownField<PrioridadIncidencia>(
                value: _prioridad,
                required: true,
                options: PrioridadIncidencia.values
                    .map((PrioridadIncidencia p) => GestionOption<PrioridadIncidencia>(p, p.nombre))
                    .toList(),
                onChanged: (PrioridadIncidencia? v) => setState(() => _prioridad = v),
              ),
            ),
          ],
        ),
        GestionFormColumns(
          children: <Widget>[
            GestionFormRow(
              label: 'Kilometraje',
              child: _KilometrajeField(controller: _kilometrajeController, kmMinimo: _kmMinimo(context)),
            ),
            const SizedBox.shrink(),
          ],
        ),
        const GestionFormSection(title: 'Descripción'),
        GestionFormRow(
          label: 'Título',
          required: true,
          child: GestionTextField(
            controller: _tituloController,
            hint: 'Ej: Fallo en el motor',
            maxLength: 100,
            validator: (String? v) => (v == null || v.trim().isEmpty) ? 'El título es obligatorio' : null,
          ),
        ),
        GestionFormRow(
          label: 'Descripción',
          required: true,
          multiline: true,
          child: GestionTextField(
            controller: _descripcionController,
            hint: 'Describe el problema en detalle...',
            maxLines: 4,
            maxLength: 500,
            validator: (String? v) =>
                (v == null || v.trim().isEmpty) ? 'La descripción es obligatoria' : null,
          ),
        ),
      ],
    );
  }
}

/// Selector de vehículo con los vehículos reales de la flota (VehiculosBloc del contexto)
class _VehiculoField extends StatelessWidget {
  const _VehiculoField({required this.value, required this.isEditing, required this.onChanged});

  final String? value;
  final bool isEditing;
  final ValueChanged<String?> onChanged;

  static String _label(VehiculoEntity v) => '${v.matricula} · ${v.marca} ${v.modelo}';

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VehiculosBloc, VehiculosState>(
      builder: (BuildContext context, VehiculosState state) {
        final List<VehiculoEntity> vehiculos =
            state is VehiculosLoaded ? state.vehiculos : <VehiculoEntity>[];
        if (isEditing) {
          final VehiculoEntity? v = vehiculos.where((VehiculoEntity e) => e.id == value).firstOrNull;
          return GestionFormReadOnly(value: v == null ? (value ?? '—') : _label(v));
        }
        return GestionSearchField<String>(
          value: value,
          required: true,
          loading: state is! VehiculosLoaded,
          hint: 'Buscar por matrícula, marca o modelo',
          options: vehiculos
              .map(
                (VehiculoEntity v) => GestionOption<String>(
                  v.id,
                  _label(v),
                  color: v.estado == VehiculoEstado.activo ? AppColors.success : AppColors.warning,
                ),
              )
              .toList(),
          onChanged: onChanged,
        );
      },
    );
  }
}

/// Kilometraje opcional (entero, sin separadores para conservar el parseo).
/// Si se indica [kmMinimo], no admite un valor inferior (km actual del vehículo).
class _KilometrajeField extends StatelessWidget {
  const _KilometrajeField({required this.controller, this.kmMinimo});

  final TextEditingController controller;
  final double? kmMinimo;

  @override
  Widget build(BuildContext context) {
    return GestionTextField(
      controller: controller,
      hint: kmMinimo == null ? 'Ej: 150000' : 'Mínimo ${kmMinimo!.round()}',
      suffixText: 'km',
      textAlign: TextAlign.end,
      keyboardType: TextInputType.number,
      inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
      validator: (String? value) {
        if (value != null && value.isNotEmpty) {
          final double? km = double.tryParse(value);
          if (km == null || km < 0) {
            return 'Ingresa un kilometraje válido';
          }
          final double? minimo = kmMinimo;
          if (minimo != null && km < minimo) {
            return 'No puede ser menor que el km actual del vehículo (${minimo.round()} km)';
          }
        }
        return null;
      },
    );
  }
}
