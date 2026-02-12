import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/widgets/dropdowns/app_dropdown.dart';
import 'package:ambutrack_web/core/widgets/dropdowns/app_searchable_dropdown.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/bloc/vehiculos_bloc.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/bloc/vehiculos_event.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/bloc/vehiculos_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

/// Diálogo para programar/editar mantenimientos preventivos
class MantenimientoFormDialog extends StatefulWidget {
  const MantenimientoFormDialog({super.key, this.vehiculo});

  final VehiculoEntity? vehiculo;

  @override
  State<MantenimientoFormDialog> createState() => _MantenimientoFormDialogState();
}

class _MantenimientoFormDialogState extends State<MantenimientoFormDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  VehiculoEntity? _vehiculoSeleccionado;
  DateTime? _fechaUltimoMantenimiento;
  DateTime? _fechaProximoMantenimiento;
  late TextEditingController _kmProximoController;
  late TextEditingController _descripcionController;
  late TextEditingController _observacionesController;

  String _tipoMantenimiento = 'Preventivo';
  bool _isLoading = false;

  bool get _isEditing => widget.vehiculo != null;

  @override
  void initState() {
    super.initState();
    _vehiculoSeleccionado = widget.vehiculo;
    _fechaUltimoMantenimiento = widget.vehiculo?.ultimoMantenimiento;
    _fechaProximoMantenimiento = widget.vehiculo?.proximoMantenimiento;
    _kmProximoController = TextEditingController(
      text: widget.vehiculo?.kmProximoMantenimiento?.toString() ?? '',
    );
    _descripcionController = TextEditingController();
    _observacionesController = TextEditingController(
      text: widget.vehiculo?.observaciones ?? '',
    );
  }

  @override
  void dispose() {
    _kmProximoController.dispose();
    _descripcionController.dispose();
    _observacionesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<VehiculosBloc, VehiculosState>(
      listener: (BuildContext context, VehiculosState state) {
        if (state is VehiculosError) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${state.message}'),
              backgroundColor: AppColors.error,
            ),
          );
        }

        if (state is VehiculosLoaded && _isLoading) {
          setState(() => _isLoading = false);
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _isEditing
                    ? 'Mantenimiento actualizado correctamente'
                    : 'Mantenimiento programado correctamente',
              ),
              backgroundColor: AppColors.success,
            ),
          );
        }
      },
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 700,
          constraints: const BoxConstraints(maxHeight: 700),
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: AppColors.gray900.withValues(alpha: 0.2),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _buildHeader(),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSizes.paddingXl),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        _buildVehiculoSelector(),
                        const SizedBox(height: AppSizes.spacing),
                        _buildTipoMantenimiento(),
                        const SizedBox(height: AppSizes.spacing),
                        _buildFechas(),
                        const SizedBox(height: AppSizes.spacing),
                        _buildKilometraje(),
                        const SizedBox(height: AppSizes.spacing),
                        _buildDescripcion(),
                        const SizedBox(height: AppSizes.spacing),
                        _buildObservaciones(),
                      ],
                    ),
                  ),
                ),
              ),
              _buildActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingXl),
      decoration: BoxDecoration(
        color: AppColors.secondary.withValues(alpha: 0.1),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppSizes.radiusLarge),
          topRight: Radius.circular(AppSizes.radiusLarge),
        ),
      ),
      child: Row(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(AppSizes.paddingSmall),
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
            ),
            child: const Icon(
              Icons.build_circle,
              color: AppColors.secondary,
              size: 28,
            ),
          ),
          const SizedBox(width: AppSizes.spacingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  _isEditing ? 'Editar Mantenimiento' : 'Programar Mantenimiento',
                  style: GoogleFonts.inter(
                    fontSize: AppSizes.fontLarge,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimaryLight,
                  ),
                ),
                Text(
                  'Configura el mantenimiento preventivo del vehículo',
                  style: GoogleFonts.inter(
                    fontSize: AppSizes.fontSmall,
                    color: AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close),
            color: AppColors.textSecondaryLight,
          ),
        ],
      ),
    );
  }

  Widget _buildVehiculoSelector() {
    return BlocBuilder<VehiculosBloc, VehiculosState>(
      builder: (BuildContext context, VehiculosState state) {
        if (state is! VehiculosLoaded) {
          return const CircularProgressIndicator();
        }

        final List<VehiculoEntity> vehiculos = state.vehiculos;

        return AppSearchableDropdown<VehiculoEntity>(
          value: _vehiculoSeleccionado,
          label: 'Vehículo *',
          hint: 'Buscar por matrícula, marca o modelo',
          enabled: !_isEditing,
          prefixIcon: Icons.directions_car,
          searchHint: 'Escribe para buscar...',
          items: <AppSearchableDropdownItem<VehiculoEntity>>[
            ...vehiculos.map((VehiculoEntity v) => AppSearchableDropdownItem<VehiculoEntity>(
                  value: v,
                  label: '${v.matricula} - ${v.marca} ${v.modelo}',
                  icon: Icons.directions_car,
                  iconColor: v.estado == VehiculoEstado.activo
                      ? AppColors.success
                      : AppColors.warning,
                )),
          ],
          onChanged: (VehiculoEntity? value) {
            setState(() => _vehiculoSeleccionado = value);
          },
          displayStringForOption: (VehiculoEntity vehiculo) {
            return '${vehiculo.matricula} - ${vehiculo.marca} ${vehiculo.modelo}';
          },
        );
      },
    );
  }

  Widget _buildTipoMantenimiento() {
    return AppDropdown<String>(
      value: _tipoMantenimiento,
      label: 'Tipo de Mantenimiento *',
      items: const <AppDropdownItem<String>>[
        AppDropdownItem<String>(
          value: 'Preventivo',
          label: 'Preventivo',
          icon: Icons.schedule,
          iconColor: AppColors.success,
        ),
        AppDropdownItem<String>(
          value: 'Correctivo',
          label: 'Correctivo',
          icon: Icons.build,
          iconColor: AppColors.warning,
        ),
        AppDropdownItem<String>(
          value: 'Predictivo',
          label: 'Predictivo',
          icon: Icons.analytics,
          iconColor: AppColors.info,
        ),
      ],
      onChanged: (String? value) {
        if (value != null) {
          setState(() => _tipoMantenimiento = value);
        }
      },
    );
  }

  Widget _buildFechas() {
    return Row(
      children: <Widget>[
        Expanded(
          child: _buildDateField(
            label: 'Último Mantenimiento',
            value: _fechaUltimoMantenimiento,
            onChanged: (DateTime? date) => setState(() => _fechaUltimoMantenimiento = date),
          ),
        ),
        const SizedBox(width: AppSizes.spacing),
        Expanded(
          child: _buildDateField(
            label: 'Próximo Mantenimiento *',
            value: _fechaProximoMantenimiento,
            onChanged: (DateTime? date) => setState(() => _fechaProximoMantenimiento = date),
            isRequired: true,
          ),
        ),
      ],
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? value,
    required ValueChanged<DateTime?> onChanged,
    bool isRequired = false,
  }) {
    return InkWell(
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: value ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
          builder: (BuildContext context, Widget? child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.light(
                  primary: AppColors.secondary,
                ),
              ),
              child: child!,
            );
          },
        );
        if (picked != null) {
          onChanged(picked);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: const Icon(Icons.calendar_today, size: 20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSizes.paddingMedium,
            vertical: AppSizes.padding,
          ),
        ),
        child: Text(
          value != null ? DateFormat('dd/MM/yyyy').format(value) : 'Selecciona una fecha',
          style: TextStyle(
            color: value != null ? AppColors.textPrimaryLight : AppColors.gray400,
          ),
        ),
      ),
    );
  }

  Widget _buildKilometraje() {
    return TextFormField(
      controller: _kmProximoController,
      decoration: InputDecoration(
        labelText: 'Kilómetros para próximo mantenimiento',
        hintText: 'Ej: 150000',
        prefixIcon: const Icon(Icons.speed),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingMedium,
          vertical: AppSizes.padding,
        ),
      ),
      keyboardType: TextInputType.number,
      validator: (String? value) {
        if (value != null && value.isNotEmpty) {
          if (int.tryParse(value) == null) {
            return 'Ingresa un número válido';
          }
        }
        return null;
      },
    );
  }

  Widget _buildDescripcion() {
    return TextFormField(
      controller: _descripcionController,
      decoration: InputDecoration(
        labelText: 'Descripción del mantenimiento',
        hintText: 'Ej: Cambio de aceite y filtros',
        prefixIcon: const Icon(Icons.description),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingMedium,
          vertical: AppSizes.padding,
        ),
      ),
      maxLines: 2,
    );
  }

  Widget _buildObservaciones() {
    return TextFormField(
      controller: _observacionesController,
      decoration: InputDecoration(
        labelText: 'Observaciones',
        hintText: 'Notas adicionales...',
        prefixIcon: const Icon(Icons.note),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingMedium,
          vertical: AppSizes.padding,
        ),
      ),
      maxLines: 3,
    );
  }

  Widget _buildActions() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingXl),
      decoration: const BoxDecoration(
        color: AppColors.gray50,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(AppSizes.radiusLarge),
          bottomRight: Radius.circular(AppSizes.radiusLarge),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          TextButton(
            onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.paddingXl,
                vertical: AppSizes.padding,
              ),
            ),
            child: const Text('Cancelar'),
          ),
          const SizedBox(width: AppSizes.spacing),
          ElevatedButton.icon(
            onPressed: _isLoading ? null : _handleSave,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.paddingXl,
                vertical: AppSizes.padding,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radius),
              ),
            ),
            icon: _isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.save),
            label: Text(_isEditing ? 'Actualizar' : 'Programar'),
          ),
        ],
      ),
    );
  }

  void _handleSave() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_vehiculoSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona un vehículo'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    if (_fechaProximoMantenimiento == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona la fecha del próximo mantenimiento'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final VehiculoEntity vehiculoActualizado = _vehiculoSeleccionado!.copyWith(
      ultimoMantenimiento: _fechaUltimoMantenimiento,
      proximoMantenimiento: _fechaProximoMantenimiento,
      kmProximoMantenimiento: _kmProximoController.text.isNotEmpty
          ? int.tryParse(_kmProximoController.text.trim())
          : null,
      observaciones: _observacionesController.text.isNotEmpty
          ? _observacionesController.text.trim()
          : null,
    );

    debugPrint('🔧 MantenimientoFormDialog: Programando mantenimiento');
    debugPrint('   Vehículo: ${vehiculoActualizado.matricula}');
    debugPrint('   Próximo: $_fechaProximoMantenimiento');
    debugPrint('   Km Próximo: ${vehiculoActualizado.kmProximoMantenimiento}');

    context.read<VehiculosBloc>().add(
          VehiculoUpdateRequested(vehiculo: vehiculoActualizado),
        );
  }
}
