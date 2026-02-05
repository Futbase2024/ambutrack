import 'dart:async';

import 'package:ambutrack_core/ambutrack_core.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/utils/crud_operation_handler.dart';
import 'package:ambutrack_web/core/widgets/buttons/app_button.dart';
import 'package:ambutrack_web/core/widgets/dialogs/app_dialog.dart';
import 'package:ambutrack_web/core/widgets/dropdowns/app_dropdown.dart';
import 'package:ambutrack_web/core/widgets/dropdowns/app_searchable_dropdown.dart';
import 'package:ambutrack_web/core/widgets/loading/app_loading_indicator.dart';
import 'package:ambutrack_web/features/mantenimiento/presentation/bloc/mantenimiento_bloc.dart';
import 'package:ambutrack_web/features/mantenimiento/presentation/bloc/mantenimiento_event.dart';
import 'package:ambutrack_web/features/mantenimiento/presentation/bloc/mantenimiento_state.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/bloc/vehiculos_bloc.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/bloc/vehiculos_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Diálogo para programar mantenimientos
class MantenimientoFormDialog extends StatefulWidget {
  const MantenimientoFormDialog({super.key, this.mantenimiento});

  final MantenimientoEntity? mantenimiento;

  @override
  State<MantenimientoFormDialog> createState() => _MantenimientoFormDialogState();
}

class _MantenimientoFormDialogState extends State<MantenimientoFormDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  VehiculoEntity? _vehiculoSeleccionado;
  DateTime _fecha = DateTime.now();
  DateTime? _fechaProgramada;
  late TextEditingController _kmVehiculoController;
  late TextEditingController _descripcionController;
  late TextEditingController _costoTotalController;
  TipoMantenimiento _tipoMantenimiento = TipoMantenimiento.basico;
  final bool _isLoading = false;
  bool _isSaving = false;

  bool get _isEditing => widget.mantenimiento != null;

  @override
  void initState() {
    super.initState();
    if (widget.mantenimiento != null) {
      _vehiculoSeleccionado = null; // Cargar desde vehículoId si es necesario
      _fecha = widget.mantenimiento!.fecha;
      _fechaProgramada = widget.mantenimiento!.fechaProgramada;
      _tipoMantenimiento = widget.mantenimiento!.tipoMantenimiento;
      _kmVehiculoController = TextEditingController(
        text: widget.mantenimiento!.kmVehiculo.toString(),
      );
      _descripcionController = TextEditingController(
        text: widget.mantenimiento!.descripcion,
      );
      _costoTotalController = TextEditingController(
        text: widget.mantenimiento!.costoTotal.toString(),
      );
    } else {
      _kmVehiculoController = TextEditingController();
      _descripcionController = TextEditingController();
      _costoTotalController = TextEditingController(text: '0.00');
    }
  }

  @override
  void dispose() {
    _kmVehiculoController.dispose();
    _descripcionController.dispose();
    _costoTotalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MantenimientoBloc, MantenimientoState>(
      listener: (BuildContext context, MantenimientoState state) {
        if (state is MantenimientoError && _isSaving) {
          CrudOperationHandler.handleError(
            context: context,
            isSaving: _isSaving,
            errorMessage: state.message,
            onComplete: () {
              if (mounted) {
                setState(() => _isSaving = false);
              }
            },
          );
        }

        if (state is MantenimientoOperationSuccess && _isSaving) {
          CrudOperationHandler.handleSuccess(
            context: context,
            isSaving: _isSaving,
            isEditing: _isEditing,
            entityName: 'Mantenimiento',
            onComplete: () {
              if (mounted) {
                setState(() => _isSaving = false);
              }
            },
          );
        }
      },
      child: AppDialog(
        title: _isEditing ? 'Editar Mantenimiento' : 'Programar Mantenimiento',
        icon: Icons.build_circle,
        maxWidth: 700,
        type: _isEditing ? AppDialogType.edit : AppDialogType.create,
        content: Form(
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
              _buildKmVehiculo(),
              const SizedBox(height: AppSizes.spacing),
              _buildDescripcion(),
              const SizedBox(height: AppSizes.spacing),
              _buildCostoTotal(),
            ],
          ),
        ),
        actions: <Widget>[
          AppButton(
            onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
            label: 'Cancelar',
            variant: AppButtonVariant.text,
          ),
          AppButton(
            onPressed: _isLoading ? null : _handleSave,
            label: _isEditing ? 'Actualizar' : 'Guardar',
            isLoading: _isLoading,
          ),
        ],
      ),
    );
  }

  Widget _buildVehiculoSelector() {
    return BlocBuilder<VehiculosBloc, VehiculosState>(
      builder: (BuildContext context, VehiculosState state) {
        if (state is! VehiculosLoaded) {
          return Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.paddingLarge,
              vertical: AppSizes.paddingXl,
            ),
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: <Widget>[
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ),
                const SizedBox(width: AppSizes.paddingLarge),
                Text(
                  'Cargando vehículos...',
                  style: GoogleFonts.inter(
                    fontSize: AppSizes.fontMedium,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
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
            setState(() {
              _vehiculoSeleccionado = value;
              // Pre-rellenar con el kilometraje actual del vehículo si existe
              if (value != null && value.kmActual != null) {
                _kmVehiculoController.text = value.kmActual.toString();
              }
            });
          },
          displayStringForOption: (VehiculoEntity vehiculo) {
            return '${vehiculo.matricula} - ${vehiculo.marca} ${vehiculo.modelo}';
          },
        );
      },
    );
  }

  Widget _buildTipoMantenimiento() {
    return AppDropdown<TipoMantenimiento>(
      value: _tipoMantenimiento,
      label: 'Tipo de Mantenimiento *',
      items: <AppDropdownItem<TipoMantenimiento>>[
        AppDropdownItem<TipoMantenimiento>(
          value: TipoMantenimiento.basico,
          label: TipoMantenimiento.basico.displayName,
          icon: Icons.build,
          iconColor: AppColors.info,
        ),
        AppDropdownItem<TipoMantenimiento>(
          value: TipoMantenimiento.completo,
          label: TipoMantenimiento.completo.displayName,
          icon: Icons.construction,
          iconColor: AppColors.warning,
        ),
        AppDropdownItem<TipoMantenimiento>(
          value: TipoMantenimiento.especial,
          label: TipoMantenimiento.especial.displayName,
          icon: Icons.settings_suggest,
          iconColor: AppColors.secondary,
        ),
        AppDropdownItem<TipoMantenimiento>(
          value: TipoMantenimiento.urgente,
          label: TipoMantenimiento.urgente.displayName,
          icon: Icons.emergency,
          iconColor: AppColors.error,
        ),
      ],
      onChanged: (TipoMantenimiento? value) {
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
            label: 'Fecha *',
            value: _fecha,
            onChanged: (DateTime? date) {
              if (date != null) {
                setState(() => _fecha = date);
              }
            },
            isRequired: true,
          ),
        ),
        const SizedBox(width: AppSizes.spacing),
        Expanded(
          child: _buildDateField(
            label: 'Fecha Programada',
            value: _fechaProgramada,
            onChanged: (DateTime? date) {
              setState(() => _fechaProgramada = date);
            },
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
          filled: true,
          fillColor: Colors.white,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
            borderSide: const BorderSide(color: AppColors.gray300, width: 1.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
            borderSide: const BorderSide(color: AppColors.gray300, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
        ),
        child: Text(
          value != null ? DateFormat('dd/MM/yyyy').format(value) : 'Selecciona una fecha',
          style: GoogleFonts.inter(
            fontSize: AppSizes.fontSmall,
            color: value != null ? AppColors.textPrimaryLight : AppColors.gray400,
          ),
        ),
      ),
    );
  }

  Widget _buildKmVehiculo() {
    return TextFormField(
      controller: _kmVehiculoController,
      decoration: InputDecoration(
        labelText: 'Kilometraje Actual *',
        hintText: 'Ej: 50000.00',
        prefixIcon: const Icon(Icons.speed, size: 18),
        filled: true,
        fillColor: Colors.white,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          borderSide: const BorderSide(color: AppColors.gray300, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          borderSide: const BorderSide(color: AppColors.gray300, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
      ],
      validator: (String? value) {
        if (value == null || value.isEmpty) {
          return 'Campo obligatorio';
        }
        final double? km = double.tryParse(value);
        if (km == null || km < 0) {
          return 'Kilometraje inválido';
        }
        return null;
      },
    );
  }

  Widget _buildDescripcion() {
    return TextFormField(
      controller: _descripcionController,
      decoration: InputDecoration(
        labelText: 'Descripción *',
        hintText: 'Describe el mantenimiento a realizar',
        prefixIcon: const Icon(Icons.description, size: 18),
        filled: true,
        fillColor: Colors.white,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          borderSide: const BorderSide(color: AppColors.gray300, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          borderSide: const BorderSide(color: AppColors.gray300, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
      maxLines: 3,
      validator: (String? value) {
        if (value == null || value.trim().isEmpty) {
          return 'La descripción es obligatoria';
        }
        return null;
      },
    );
  }

  Widget _buildCostoTotal() {
    return TextFormField(
      controller: _costoTotalController,
      decoration: InputDecoration(
        labelText: 'Costo Total *',
        hintText: 'Ej: 150.00',
        prefixIcon: const Icon(Icons.euro, size: 18),
        filled: true,
        fillColor: Colors.white,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          borderSide: const BorderSide(color: AppColors.gray300, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          borderSide: const BorderSide(color: AppColors.gray300, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
      ],
      validator: (String? value) {
        if (value == null || value.isEmpty) {
          return 'Campo obligatorio';
        }
        final double? costo = double.tryParse(value);
        if (costo == null || costo < 0) {
          return 'Costo inválido';
        }
        return null;
      },
    );
  }

  Future<void> _handleSave() async {
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

    // Marcar que estamos guardando
    setState(() => _isSaving = true);

    // Mostrar loading overlay
    if (!mounted) {
      return;
    }

    unawaited(
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext dialogContext) {
          return AppLoadingOverlay(
            message: _isEditing ? 'Actualizando Mantenimiento...' : 'Guardando Mantenimiento...',
            color: AppColors.secondary,
            icon: Icons.build_circle,
          );
        },
      ),
    );

    try {
      // Obtener userId del usuario actual
      final String? userId = Supabase.instance.client.auth.currentUser?.id;

      if (userId == null) {
        if (!mounted) {
          return;
        }
        Navigator.of(context).pop(); // Cerrar loading overlay
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error: Usuario no autenticado'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      // Consultar la tabla usuarios para obtener empresa_id
      final Map<String, dynamic> userData = await Supabase.instance.client
          .from('usuarios')
          .select('empresa_id')
          .eq('id', userId)
          .single();

      final String? empresaId = userData['empresa_id'] as String?;

      if (empresaId == null) {
        if (!mounted) {
          return;
        }
        Navigator.of(context).pop(); // Cerrar loading overlay
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error: El usuario no tiene empresa asignada'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      final MantenimientoEntity mantenimiento = MantenimientoEntity(
        id: widget.mantenimiento?.id ?? '',
        vehiculoId: _vehiculoSeleccionado!.id,
        fecha: _fecha,
        kmVehiculo: double.parse(_kmVehiculoController.text.trim()),
        tipoMantenimiento: _tipoMantenimiento,
        descripcion: _descripcionController.text.trim(),
        costoTotal: double.parse(_costoTotalController.text.trim()),
        estado: EstadoMantenimiento.programado,
        fechaProgramada: _fechaProgramada,
        empresaId: empresaId,
        createdAt: DateTime.now(),
        createdBy: userId,
      );

      if (!mounted) {
        return;
      }

      if (_isEditing) {
        context.read<MantenimientoBloc>().add(
              MantenimientoUpdateRequested(mantenimiento: mantenimiento),
            );
      } else {
        context.read<MantenimientoBloc>().add(
              MantenimientoCreateRequested(mantenimiento: mantenimiento),
            );
      }
    } catch (e) {
      debugPrint('❌ Error al guardar mantenimiento: $e');
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop(); // Cerrar loading overlay
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al obtener datos del usuario: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
}
