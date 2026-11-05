import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart'
    hide EstadoIncidencia, PrioridadIncidencia;
import 'package:ambutrack_core_datasource/incidencias.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/widgets/buttons/app_button.dart';
import 'package:ambutrack_web/core/widgets/dialogs/app_dialog.dart';
import 'package:ambutrack_web/core/widgets/dropdowns/app_dropdown.dart';
import 'package:ambutrack_web/core/widgets/dropdowns/app_searchable_dropdown.dart';
import 'package:ambutrack_web/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ambutrack_web/features/auth/presentation/bloc/auth_state.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/bloc/vehiculos_bloc.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/bloc/vehiculos_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import 'package:uuid/uuid.dart';

/// Diálogo de formulario para crear/editar incidencias
class IncidenciaFormDialog extends StatefulWidget {
  const IncidenciaFormDialog({
    this.incidencia,
    required this.onSave,
    super.key,
  });

  final IncidenciaEntity? incidencia;
  final Future<void> Function(IncidenciaEntity) onSave;

  @override
  State<IncidenciaFormDialog> createState() => _IncidenciaFormDialogState();
}

class _IncidenciaFormDialogState extends State<IncidenciaFormDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _resolucionController = TextEditingController();

  CategoriaIncidencia _categoria = CategoriaIncidencia.servicio;
  PrioridadIncidencia _prioridad = PrioridadIncidencia.media;
  EstadoIncidencia _estado = EstadoIncidencia.reportada;
  DateTime _fechaIncidencia = DateTime.now();
  TimeOfDay _horaIncidencia = TimeOfDay.now();
  DateTime? _fechaResolucion;
  String? _vehiculoId;
  String? _vehiculoMatricula;
  bool _isSaving = false;
  String? _initialVehiculoId;

  bool get _isEditing => widget.incidencia != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final IncidenciaEntity i = widget.incidencia!;
      _tituloController.text = i.titulo;
      _descripcionController.text = i.descripcion ?? '';
      _resolucionController.text = i.resolucion ?? '';
      _categoria = i.categoria;
      _prioridad = i.prioridad;
      _estado = i.estado;
      _fechaIncidencia = i.fechaIncidencia;
      _horaIncidencia = TimeOfDay.fromDateTime(i.fechaIncidencia);
      _fechaResolucion = i.fechaResolucion;
      _vehiculoId = i.vehiculoId;
      _vehiculoMatricula = i.vehiculoMatricula;
      _initialVehiculoId = i.vehiculoId;
    }
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descripcionController.dispose();
    _resolucionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppDialog(
      title: _isEditing ? 'Editar Incidencia' : 'Nueva Incidencia',
      icon: Icons.report_problem_outlined,
      type: _isEditing ? AppDialogType.edit : AppDialogType.create,
      maxWidth: 650,
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            // Título
            _FormField(
              label: 'Título *',
              child: TextFormField(
                controller: _tituloController,
                decoration: const InputDecoration(
                  hintText: 'Título de la incidencia',
                  isDense: true,
                ),
                validator: (String? v) =>
                    v == null || v.trim().isEmpty ? 'Campo obligatorio' : null,
              ),
            ),
            const SizedBox(height: AppSizes.spacingMedium),

            // Descripción
            _FormField(
              label: 'Descripción',
              child: TextFormField(
                controller: _descripcionController,
                decoration: const InputDecoration(
                  hintText: 'Descripción detallada de la incidencia',
                  isDense: true,
                ),
                minLines: 4,
                maxLines: 8,
                textInputAction: TextInputAction.newline,
              ),
            ),
            const SizedBox(height: AppSizes.spacingMedium),

            // Categoría + Prioridad
            Row(
              children: <Widget>[
                Expanded(
                  child: _FormField(
                    label: 'Categoría',
                    child: AppDropdown<CategoriaIncidencia>(
                      value: _categoria,
                      items: CategoriaIncidencia.values
                          .map((CategoriaIncidencia c) => AppDropdownItem<CategoriaIncidencia>(
                                value: c,
                                label: c.displayName,
                              ))
                          .toList(),
                      onChanged: (CategoriaIncidencia? v) =>
                          setState(() => _categoria = v ?? _categoria),
                    ),
                  ),
                ),
                const SizedBox(width: AppSizes.spacingMedium),
                Expanded(
                  child: _FormField(
                    label: 'Prioridad',
                    child: AppDropdown<PrioridadIncidencia>(
                      value: _prioridad,
                      items: PrioridadIncidencia.values
                          .map((PrioridadIncidencia p) => AppDropdownItem<PrioridadIncidencia>(
                                value: p,
                                label: p.displayName,
                              ))
                          .toList(),
                      onChanged: (PrioridadIncidencia? v) =>
                          setState(() => _prioridad = v ?? _prioridad),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.spacingMedium),

            // Estado + Fecha
            Row(
              children: <Widget>[
                Expanded(
                  child: _FormField(
                    label: 'Estado',
                    child: AppDropdown<EstadoIncidencia>(
                      value: _estado,
                      items: EstadoIncidencia.values
                          .map((EstadoIncidencia e) => AppDropdownItem<EstadoIncidencia>(
                                value: e,
                                label: e.displayName,
                              ))
                          .toList(),
                      onChanged: (EstadoIncidencia? v) =>
                          setState(() => _estado = v ?? _estado),
                    ),
                  ),
                ),
                const SizedBox(width: AppSizes.spacingMedium),
                Expanded(
                  child: _FormField(
                    label: 'Fecha Incidencia',
                    child: _DateField(
                      value: _fechaIncidencia,
                      onChanged: (DateTime d) =>
                          setState(() => _fechaIncidencia = d),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.spacingMedium),

            // Hora
            _FormField(
              label: 'Hora',
              child: InkWell(
                onTap: () async {
                  final TimeOfDay? picked = await showTimePicker(
                    context: context,
                    initialTime: _horaIncidencia,
                  );
                  if (picked != null) {
                    setState(() => _horaIncidencia = picked);
                  }
                },
                child: InputDecorationBuilder.build(
                  _horaIncidencia.format(context),
                ),
              ),
            ),
            const SizedBox(height: AppSizes.spacingMedium),

            // Selector de vehículo (solo si categoría == vehiculo)
            if (_categoria == CategoriaIncidencia.vehiculo) ...<Widget>[
              _buildVehiculoSelector(),
              const SizedBox(height: AppSizes.spacingMedium),
            ],

            // Resolución + Fecha resolución (solo si estado resuelta/cerrada)
            if (_estado == EstadoIncidencia.resuelta ||
                _estado == EstadoIncidencia.cerrada) ...<Widget>[
              _FormField(
                label: 'Resolución',
                child: TextFormField(
                  controller: _resolucionController,
                  decoration: const InputDecoration(
                    hintText: 'Solución aplicada',
                    isDense: true,
                  ),
                  maxLines: 2,
                ),
              ),
              const SizedBox(height: AppSizes.spacingMedium),
              _FormField(
                label: 'Fecha Resolución',
                child: _DateField(
                  value: _fechaResolucion ?? DateTime.now(),
                  onChanged: (DateTime d) =>
                      setState(() => _fechaResolucion = d),
                ),
              ),
              const SizedBox(height: AppSizes.spacingMedium),
            ],
          ],
        ),
      ),
      actions: <Widget>[
        AppButton(
          label: 'Cancelar',
          onPressed: () => Navigator.of(context).pop(),
          variant: AppButtonVariant.outline,
        ),
        AppButton(
          label: _isEditing ? 'Actualizar' : 'Guardar',
          icon: _isEditing ? Icons.save : Icons.add,
          onPressed: _isSaving ? null : _onSave,
          isLoading: _isSaving,
        ),
      ],
    );
  }

  Widget _buildVehiculoSelector() {
    return _FormField(
      label: 'Vehículo',
      child: BlocBuilder<VehiculosBloc, VehiculosState>(
        builder: (BuildContext context, VehiculosState state) {
          final List<VehiculoEntity> vehiculos = state is VehiculosLoaded
              ? state.vehiculos
              : <VehiculoEntity>[];

          // En edición, restaurar vehículo inicial
          if (_initialVehiculoId != null && _vehiculoId == null) {
            final Iterable<VehiculoEntity> match = vehiculos.where(
              (VehiculoEntity v) => v.id == _initialVehiculoId,
            );
            if (match.isNotEmpty) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  setState(() {
                    _vehiculoId = match.first.id;
                    _vehiculoMatricula = match.first.matricula;
                  });
                }
              });
            }
          }

          return AppSearchableDropdown<VehiculoEntity>(
            label: 'Seleccionar vehículo',
            value: vehiculos
                .where((VehiculoEntity v) => v.id == _vehiculoId)
                .firstOrNull,
            items: vehiculos
                .map((VehiculoEntity v) => AppSearchableDropdownItem<VehiculoEntity>(
                      value: v,
                      label: '${v.matricula} - ${v.marca} ${v.modelo}',
                    ))
                .toList(),
            displayStringForOption: (VehiculoEntity v) =>
                '${v.matricula} - ${v.marca} ${v.modelo}',
            onChanged: (VehiculoEntity? v) {
              setState(() {
                _vehiculoId = v?.id;
                _vehiculoMatricula = v?.matricula;
              });
            },
          );
        },
      ),
    );
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      final User? user = Supabase.instance.client.auth.currentUser;

      // Obtener datos del usuario desde AuthBloc (fuente fiable)
      final AuthState authState = context.read<AuthBloc>().state;
      String nombreCompleto = user?.email ?? 'Sin nombre';
      String? empresaId;

      if (authState is AuthAuthenticated) {
        nombreCompleto =
            authState.user.displayName ?? authState.user.email;
        empresaId = authState.user.empresaId;
      }

      final DateTime fechaCompleta = DateTime(
        _fechaIncidencia.year,
        _fechaIncidencia.month,
        _fechaIncidencia.day,
        _horaIncidencia.hour,
        _horaIncidencia.minute,
      );

      final IncidenciaEntity incidencia = IncidenciaEntity(
        id: _isEditing ? widget.incidencia!.id : const Uuid().v4(),
        titulo: _tituloController.text.trim(),
        descripcion: _descripcionController.text.trim().isEmpty
            ? null
            : _descripcionController.text.trim(),
        categoria: _categoria,
        prioridad: _prioridad,
        estado: _estado,
        fechaIncidencia: fechaCompleta,
        responsableId: user?.id,
        responsableNombre: nombreCompleto.toUpperCase(),
        reportadoPor: _isEditing ? widget.incidencia!.reportadoPor : user?.id,
        reportadoPorNombre: _isEditing
            ? widget.incidencia!.reportadoPorNombre
            : nombreCompleto.toUpperCase(),
        fechaResolucion: _estado == EstadoIncidencia.resuelta ||
                _estado == EstadoIncidencia.cerrada
            ? (_fechaResolucion ?? DateTime.now())
            : null,
        resolucion: _resolucionController.text.trim().isEmpty
            ? null
            : _resolucionController.text.trim(),
        vehiculoId: _categoria == CategoriaIncidencia.vehiculo
            ? _vehiculoId
            : null,
        vehiculoMatricula: _categoria == CategoriaIncidencia.vehiculo
            ? _vehiculoMatricula
            : null,
        empresaId: _isEditing ? widget.incidencia!.empresaId : empresaId,
        createdAt: _isEditing ? widget.incidencia!.createdAt : DateTime.now(),
        updatedAt: DateTime.now(),
        createdBy: _isEditing
            ? widget.incidencia!.createdBy
            : user?.id,
        updatedBy: user?.id,
      );

      await widget.onSave(incidencia);

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      debugPrint('❌ Error al guardar incidencia: $e');
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}

/// Widget auxiliar para label + campo de formulario
class _FormField extends StatelessWidget {
  const _FormField({
    required this.label,
    required this.child,
  });

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.gray700,
          ),
        ),
        const SizedBox(height: 4),
        child,
      ],
    );
  }
}

/// Campo de fecha reutilizable
class _DateField extends StatelessWidget {
  const _DateField({
    required this.value,
    required this.onChanged,
  });

  final DateTime value;
  final ValueChanged<DateTime> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: value,
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
          locale: const Locale('es', 'ES'),
        );
        if (picked != null) {
          onChanged(picked);
        }
      },
      child: InputDecorationBuilder.build(
        '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}',
      ),
    );
  }
}

/// Helper para construir InputDecorations consistentes
class InputDecorationBuilder {
  InputDecorationBuilder._();

  static Widget build(String text) {
    return InputDecorator(
      decoration: const InputDecoration(
        isDense: true,
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
      child: Text(text),
    );
  }
}
