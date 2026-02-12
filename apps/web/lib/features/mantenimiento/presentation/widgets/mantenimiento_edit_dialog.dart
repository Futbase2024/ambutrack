import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/widgets/buttons/app_button.dart';
import 'package:ambutrack_web/core/widgets/dialogs/app_dialog.dart';
import 'package:ambutrack_web/core/widgets/dropdowns/app_dropdown.dart';
import 'package:ambutrack_web/features/mantenimiento/presentation/bloc/mantenimiento_bloc.dart';
import 'package:ambutrack_web/features/mantenimiento/presentation/bloc/mantenimiento_event.dart';
import 'package:ambutrack_web/features/mantenimiento/presentation/bloc/mantenimiento_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Diálogo para editar un mantenimiento existente
class MantenimientoEditDialog extends StatefulWidget {
  const MantenimientoEditDialog({
    required this.mantenimiento,
    super.key,
  });

  final MantenimientoEntity mantenimiento;

  @override
  State<MantenimientoEditDialog> createState() => _MantenimientoEditDialogState();
}

class _MantenimientoEditDialogState extends State<MantenimientoEditDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late DateTime _fecha;
  late DateTime? _fechaProgramada;
  late DateTime? _fechaInicio;
  late DateTime? _fechaFin;
  late TextEditingController _kmVehiculoController;
  late TextEditingController _descripcionController;
  late TextEditingController _trabajosRealizadosController;
  late TextEditingController _tallerController;
  late TextEditingController _mecanicoController;
  late TextEditingController _numeroOrdenController;
  late TextEditingController _costoManoObraController;
  late TextEditingController _costoRepuestosController;
  late TextEditingController _costoTotalController;
  late TextEditingController _tiempoInoperativoController;
  late TextEditingController _proximoKmController;
  late DateTime? _proximaFechaSugerida;
  late TipoMantenimiento _tipoMantenimiento;
  late EstadoMantenimiento _estado;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeFields();
  }

  void _initializeFields() {
    _fecha = widget.mantenimiento.fecha;
    _fechaProgramada = widget.mantenimiento.fechaProgramada;
    _fechaInicio = widget.mantenimiento.fechaInicio;
    _fechaFin = widget.mantenimiento.fechaFin;
    _proximaFechaSugerida = widget.mantenimiento.proximaFechaSugerida;
    _tipoMantenimiento = widget.mantenimiento.tipoMantenimiento;
    _estado = widget.mantenimiento.estado;

    _kmVehiculoController = TextEditingController(
      text: widget.mantenimiento.kmVehiculo.toString(),
    );
    _descripcionController = TextEditingController(
      text: widget.mantenimiento.descripcion,
    );
    _trabajosRealizadosController = TextEditingController(
      text: widget.mantenimiento.trabajosRealizados ?? '',
    );
    _tallerController = TextEditingController(
      text: widget.mantenimiento.taller ?? '',
    );
    _mecanicoController = TextEditingController(
      text: widget.mantenimiento.mecanicoResponsable ?? '',
    );
    _numeroOrdenController = TextEditingController(
      text: widget.mantenimiento.numeroOrden ?? '',
    );
    _costoManoObraController = TextEditingController(
      text: widget.mantenimiento.costoManoObra?.toStringAsFixed(2) ?? '',
    );
    _costoRepuestosController = TextEditingController(
      text: widget.mantenimiento.costoRepuestos?.toStringAsFixed(2) ?? '',
    );
    _costoTotalController = TextEditingController(
      text: widget.mantenimiento.costoTotal.toStringAsFixed(2),
    );
    _tiempoInoperativoController = TextEditingController(
      text: widget.mantenimiento.tiempoInoperativoHoras?.toString() ?? '',
    );
    _proximoKmController = TextEditingController(
      text: widget.mantenimiento.proximoKmSugerido?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _kmVehiculoController.dispose();
    _descripcionController.dispose();
    _trabajosRealizadosController.dispose();
    _tallerController.dispose();
    _mecanicoController.dispose();
    _numeroOrdenController.dispose();
    _costoManoObraController.dispose();
    _costoRepuestosController.dispose();
    _costoTotalController.dispose();
    _tiempoInoperativoController.dispose();
    _proximoKmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MantenimientoBloc, MantenimientoState>(
      listener: (BuildContext context, MantenimientoState state) {
        if (state is MantenimientoError) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${state.message}'),
              backgroundColor: AppColors.error,
            ),
          );
        }

        if (state is MantenimientoOperationSuccess) {
          setState(() => _isLoading = false);
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.success,
            ),
          );
        }
      },
      child: AppDialog(
        title: 'Editar Mantenimiento\nID: ${widget.mantenimiento.id.substring(0, 12)}...',
        icon: Icons.edit,
        maxWidth: 900,
        type: AppDialogType.edit,
        content: Form(
          key: _formKey,
          child: _buildForm(),
        ),
        actions: <Widget>[
          AppButton(
            onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
            label: 'Cancelar',
            variant: AppButtonVariant.text,
          ),
          AppButton(
            onPressed: _isLoading ? null : _handleSubmit,
            label: 'Guardar Cambios',
            variant: AppButtonVariant.secondary,
            isLoading: _isLoading,
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        // Información General
        _buildSectionTitle('Información General', Icons.info_outline),
        const SizedBox(height: AppSizes.spacing),
        Row(
          children: <Widget>[
            Expanded(
              child: _buildDateField(
                label: 'Fecha',
                value: _fecha,
                onChanged: (DateTime value) => setState(() => _fecha = value),
              ),
            ),
            const SizedBox(width: AppSizes.spacing),
            Expanded(
              child: _buildNumberField(
                label: 'Kilometraje',
                controller: _kmVehiculoController,
                isRequired: true,
                suffix: 'km',
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.spacing),
        Row(
          children: <Widget>[
            Expanded(
              child: AppDropdown<TipoMantenimiento>(
                value: _tipoMantenimiento,
                label: 'Tipo de Mantenimiento',
                items: const <AppDropdownItem<TipoMantenimiento>>[
                  AppDropdownItem<TipoMantenimiento>(
                    value: TipoMantenimiento.basico,
                    label: 'Básico',
                    icon: Icons.build,
                    iconColor: AppColors.info,
                  ),
                  AppDropdownItem<TipoMantenimiento>(
                    value: TipoMantenimiento.completo,
                    label: 'Completo',
                    icon: Icons.build_circle,
                    iconColor: AppColors.warning,
                  ),
                  AppDropdownItem<TipoMantenimiento>(
                    value: TipoMantenimiento.especial,
                    label: 'Especial',
                    icon: Icons.star,
                    iconColor: AppColors.secondary,
                  ),
                  AppDropdownItem<TipoMantenimiento>(
                    value: TipoMantenimiento.urgente,
                    label: 'Urgente',
                    icon: Icons.priority_high,
                    iconColor: AppColors.error,
                  ),
                ],
                onChanged: (TipoMantenimiento? value) {
                  if (value != null) {
                    setState(() => _tipoMantenimiento = value);
                  }
                },
              ),
            ),
            const SizedBox(width: AppSizes.spacing),
            Expanded(
              child: AppDropdown<EstadoMantenimiento>(
                value: _estado,
                label: 'Estado',
                items: const <AppDropdownItem<EstadoMantenimiento>>[
                  AppDropdownItem<EstadoMantenimiento>(
                    value: EstadoMantenimiento.programado,
                    label: 'Programado',
                    icon: Icons.schedule,
                    iconColor: AppColors.info,
                  ),
                  AppDropdownItem<EstadoMantenimiento>(
                    value: EstadoMantenimiento.enProceso,
                    label: 'En Proceso',
                    icon: Icons.build,
                    iconColor: AppColors.warning,
                  ),
                  AppDropdownItem<EstadoMantenimiento>(
                    value: EstadoMantenimiento.completado,
                    label: 'Completado',
                    icon: Icons.check_circle,
                    iconColor: AppColors.success,
                  ),
                  AppDropdownItem<EstadoMantenimiento>(
                    value: EstadoMantenimiento.cancelado,
                    label: 'Cancelado',
                    icon: Icons.cancel,
                    iconColor: AppColors.error,
                  ),
                ],
                onChanged: (EstadoMantenimiento? value) {
                  if (value != null) {
                    setState(() => _estado = value);
                  }
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.spacing),
        _buildTextField(
          label: 'Descripción',
          controller: _descripcionController,
          maxLines: 2,
          isRequired: true,
        ),

        const SizedBox(height: AppSizes.spacingLarge),

        // Detalles del Servicio
        _buildSectionTitle('Detalles del Servicio', Icons.build),
        const SizedBox(height: AppSizes.spacing),
        _buildTextField(
          label: 'Trabajos Realizados',
          controller: _trabajosRealizadosController,
          maxLines: 3,
        ),
        const SizedBox(height: AppSizes.spacing),
        Row(
          children: <Widget>[
            Expanded(
              child: _buildTextField(
                label: 'Taller',
                controller: _tallerController,
              ),
            ),
            const SizedBox(width: AppSizes.spacing),
            Expanded(
              child: _buildTextField(
                label: 'Mecánico Responsable',
                controller: _mecanicoController,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.spacing),
        _buildTextField(
          label: 'Número de Orden',
          controller: _numeroOrdenController,
        ),

        const SizedBox(height: AppSizes.spacingLarge),

        // Fechas
        _buildSectionTitle('Fechas', Icons.calendar_today),
        const SizedBox(height: AppSizes.spacing),
        Row(
          children: <Widget>[
            Expanded(
              child: _buildOptionalDateField(
                label: 'Fecha Programada',
                value: _fechaProgramada,
                onChanged: (DateTime? value) => setState(() => _fechaProgramada = value),
              ),
            ),
            const SizedBox(width: AppSizes.spacing),
            Expanded(
              child: _buildOptionalDateField(
                label: 'Fecha Inicio',
                value: _fechaInicio,
                onChanged: (DateTime? value) => setState(() => _fechaInicio = value),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.spacing),
        Row(
          children: <Widget>[
            Expanded(
              child: _buildOptionalDateField(
                label: 'Fecha Fin',
                value: _fechaFin,
                onChanged: (DateTime? value) => setState(() => _fechaFin = value),
              ),
            ),
            const SizedBox(width: AppSizes.spacing),
            Expanded(
              child: _buildNumberField(
                label: 'Tiempo Inoperativo (horas)',
                controller: _tiempoInoperativoController,
                suffix: 'h',
              ),
            ),
          ],
        ),

        const SizedBox(height: AppSizes.spacingLarge),

        // Costos
        _buildSectionTitle('Costos', Icons.euro),
        const SizedBox(height: AppSizes.spacing),
        Row(
          children: <Widget>[
            Expanded(
              child: _buildNumberField(
                label: 'Mano de Obra',
                controller: _costoManoObraController,
                prefix: '€',
              ),
            ),
            const SizedBox(width: AppSizes.spacing),
            Expanded(
              child: _buildNumberField(
                label: 'Repuestos',
                controller: _costoRepuestosController,
                prefix: '€',
              ),
            ),
            const SizedBox(width: AppSizes.spacing),
            Expanded(
              child: _buildNumberField(
                label: 'Total',
                controller: _costoTotalController,
                isRequired: true,
                prefix: '€',
              ),
            ),
          ],
        ),

        const SizedBox(height: AppSizes.spacingLarge),

        // Próximo Mantenimiento
        _buildSectionTitle('Próximo Mantenimiento Sugerido', Icons.event_available),
        const SizedBox(height: AppSizes.spacing),
        Row(
          children: <Widget>[
            Expanded(
              child: _buildNumberField(
                label: 'Kilómetros',
                controller: _proximoKmController,
                suffix: 'km',
              ),
            ),
            const SizedBox(width: AppSizes.spacing),
            Expanded(
              child: _buildOptionalDateField(
                label: 'Fecha Sugerida',
                value: _proximaFechaSugerida,
                onChanged: (DateTime? value) => setState(() => _proximaFechaSugerida = value),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: <Widget>[
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: AppSizes.spacingSmall),
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: AppSizes.fontMedium,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    int maxLines = 1,
    bool isRequired = false,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        ),
      ),
      validator: isRequired
          ? (String? value) {
              if (value == null || value.isEmpty) {
                return 'Este campo es obligatorio';
              }
              return null;
            }
          : null,
    );
  }

  Widget _buildNumberField({
    required String label,
    required TextEditingController controller,
    bool isRequired = false,
    String? prefix,
    String? suffix,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
      ],
      decoration: InputDecoration(
        labelText: label,
        prefixText: prefix,
        suffixText: suffix,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        ),
      ),
      validator: isRequired
          ? (String? value) {
              if (value == null || value.isEmpty) {
                return 'Este campo es obligatorio';
              }
              return null;
            }
          : null,
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime value,
    required void Function(DateTime) onChanged,
  }) {
    return InkWell(
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: value,
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (picked != null) {
          onChanged(picked);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          ),
          suffixIcon: const Icon(Icons.calendar_today, size: 20),
        ),
        child: Text(DateFormat('dd/MM/yyyy').format(value)),
      ),
    );
  }

  Widget _buildOptionalDateField({
    required String label,
    required DateTime? value,
    required void Function(DateTime?) onChanged,
  }) {
    return InkWell(
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: value ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (picked != null) {
          onChanged(picked);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          ),
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (value != null)
                IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  onPressed: () => onChanged(null),
                  padding: EdgeInsets.zero,
                ),
              const Icon(Icons.calendar_today, size: 20),
              const SizedBox(width: 8),
            ],
          ),
        ),
        child: Text(
          value != null ? DateFormat('dd/MM/yyyy').format(value) : 'No establecida',
          style: TextStyle(
            color: value != null ? AppColors.textPrimaryLight : AppColors.textSecondaryLight,
          ),
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    final MantenimientoEntity updatedMantenimiento = widget.mantenimiento.copyWith(
      fecha: _fecha,
      kmVehiculo: double.tryParse(_kmVehiculoController.text) ?? widget.mantenimiento.kmVehiculo,
      tipoMantenimiento: _tipoMantenimiento,
      descripcion: _descripcionController.text,
      trabajosRealizados: _trabajosRealizadosController.text.isEmpty
          ? null
          : _trabajosRealizadosController.text,
      taller: _tallerController.text.isEmpty ? null : _tallerController.text,
      mecanicoResponsable: _mecanicoController.text.isEmpty ? null : _mecanicoController.text,
      numeroOrden: _numeroOrdenController.text.isEmpty ? null : _numeroOrdenController.text,
      costoManoObra: _costoManoObraController.text.isEmpty
          ? null
          : double.tryParse(_costoManoObraController.text),
      costoRepuestos: _costoRepuestosController.text.isEmpty
          ? null
          : double.tryParse(_costoRepuestosController.text),
      costoTotal: double.tryParse(_costoTotalController.text) ?? widget.mantenimiento.costoTotal,
      estado: _estado,
      fechaProgramada: _fechaProgramada,
      fechaInicio: _fechaInicio,
      fechaFin: _fechaFin,
      tiempoInoperativoHoras: _tiempoInoperativoController.text.isEmpty
          ? null
          : double.tryParse(_tiempoInoperativoController.text),
      proximoKmSugerido:
          _proximoKmController.text.isEmpty ? null : int.tryParse(_proximoKmController.text),
      proximaFechaSugerida: _proximaFechaSugerida,
      updatedAt: DateTime.now(),
      updatedBy: Supabase.instance.client.auth.currentUser?.id,
    );

    context.read<MantenimientoBloc>().add(
          MantenimientoUpdateRequested(mantenimiento: updatedMantenimiento),
        );
  }
}
