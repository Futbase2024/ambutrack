import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/widgets/buttons/app_button.dart';
import 'package:ambutrack_web/core/widgets/dialogs/app_dialog.dart';
import 'package:ambutrack_web/core/widgets/dropdowns/app_dropdown.dart';
import 'package:ambutrack_web/features/itv_revisiones/presentation/bloc/itv_revision_bloc.dart';
import 'package:ambutrack_web/features/itv_revisiones/presentation/bloc/itv_revision_event.dart';
import 'package:ambutrack_web/features/itv_revisiones/presentation/bloc/itv_revision_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Diálogo para editar una ITV/Revisión existente
class ItvRevisionEditDialog extends StatefulWidget {
  const ItvRevisionEditDialog({
    required this.itvRevision,
    super.key,
  });

  final ItvRevisionEntity itvRevision;

  @override
  State<ItvRevisionEditDialog> createState() => _ItvRevisionEditDialogState();
}

class _ItvRevisionEditDialogState extends State<ItvRevisionEditDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late DateTime _fecha;
  late DateTime? _fechaVencimiento;
  late TextEditingController _kmVehiculoController;
  late TextEditingController _tallerController;
  late TextEditingController _numeroDocumentoController;
  late TextEditingController _costoTotalController;
  late TextEditingController _observacionesController;
  late TipoItvRevision _tipo;
  late ResultadoItvRevision _resultado;
  late EstadoItvRevision _estado;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeFields();
  }

  void _initializeFields() {
    _fecha = widget.itvRevision.fecha;
    _fechaVencimiento = widget.itvRevision.fechaVencimiento;
    _tipo = widget.itvRevision.tipo;
    _resultado = widget.itvRevision.resultado;
    _estado = widget.itvRevision.estado;

    _kmVehiculoController = TextEditingController(
      text: widget.itvRevision.kmVehiculo.toString(),
    );
    _tallerController = TextEditingController(
      text: widget.itvRevision.taller ?? '',
    );
    _numeroDocumentoController = TextEditingController(
      text: widget.itvRevision.numeroDocumento ?? '',
    );
    _costoTotalController = TextEditingController(
      text: widget.itvRevision.costoTotal.toStringAsFixed(2),
    );
    _observacionesController = TextEditingController(
      text: widget.itvRevision.observaciones ?? '',
    );
  }

  @override
  void dispose() {
    _kmVehiculoController.dispose();
    _tallerController.dispose();
    _numeroDocumentoController.dispose();
    _costoTotalController.dispose();
    _observacionesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ItvRevisionBloc, ItvRevisionState>(
      listener: (BuildContext context, ItvRevisionState state) {
        if (state is ItvRevisionError) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${state.message}'),
              backgroundColor: AppColors.error,
            ),
          );
        }

        if (state is ItvRevisionOperationSuccess) {
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
        title: 'Editar ITV/Revisión\nID: ${widget.itvRevision.id.substring(0, 12)}...',
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
        _buildSectionTitle('Información General'),
        const SizedBox(height: AppSizes.spacing),
        Row(
          children: <Widget>[
            Expanded(
              child: _buildDateField(
                label: 'Fecha de ITV/Revisión',
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
              child: AppDropdown<TipoItvRevision>(
                value: _tipo,
                label: 'Tipo',
                items: const <AppDropdownItem<TipoItvRevision>>[
                  AppDropdownItem<TipoItvRevision>(
                    value: TipoItvRevision.itv,
                    label: 'ITV',
                    icon: Icons.fact_check,
                    iconColor: AppColors.info,
                  ),
                  AppDropdownItem<TipoItvRevision>(
                    value: TipoItvRevision.revisionTecnica,
                    label: 'Revisión Técnica',
                    icon: Icons.build_circle,
                    iconColor: AppColors.secondary,
                  ),
                  AppDropdownItem<TipoItvRevision>(
                    value: TipoItvRevision.inspeccionAnual,
                    label: 'Inspección Anual',
                    icon: Icons.calendar_today,
                    iconColor: AppColors.warning,
                  ),
                  AppDropdownItem<TipoItvRevision>(
                    value: TipoItvRevision.inspeccionEspecial,
                    label: 'Inspección Especial',
                    icon: Icons.star,
                    iconColor: AppColors.primary,
                  ),
                ],
                onChanged: (TipoItvRevision? value) {
                  if (value != null) {
                    setState(() => _tipo = value);
                  }
                },
              ),
            ),
            const SizedBox(width: AppSizes.spacing),
            Expanded(
              child: AppDropdown<ResultadoItvRevision>(
                value: _resultado,
                label: 'Resultado',
                items: const <AppDropdownItem<ResultadoItvRevision>>[
                  AppDropdownItem<ResultadoItvRevision>(
                    value: ResultadoItvRevision.favorable,
                    label: 'Favorable',
                    icon: Icons.check_circle,
                    iconColor: AppColors.success,
                  ),
                  AppDropdownItem<ResultadoItvRevision>(
                    value: ResultadoItvRevision.desfavorable,
                    label: 'Desfavorable',
                    icon: Icons.warning,
                    iconColor: AppColors.warning,
                  ),
                  AppDropdownItem<ResultadoItvRevision>(
                    value: ResultadoItvRevision.negativo,
                    label: 'Negativo',
                    icon: Icons.cancel,
                    iconColor: AppColors.error,
                  ),
                  AppDropdownItem<ResultadoItvRevision>(
                    value: ResultadoItvRevision.pendiente,
                    label: 'Pendiente',
                    icon: Icons.pending,
                    iconColor: AppColors.gray600,
                  ),
                ],
                onChanged: (ResultadoItvRevision? value) {
                  if (value != null) {
                    setState(() => _resultado = value);
                  }
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.spacing),
        Row(
          children: <Widget>[
            Expanded(
              child: _buildDateField(
                label: 'Fecha de Vencimiento',
                value: _fechaVencimiento,
                onChanged: (DateTime value) => setState(() => _fechaVencimiento = value),
                isRequired: false,
                canClear: true,
              ),
            ),
            const SizedBox(width: AppSizes.spacing),
            Expanded(
              child: AppDropdown<EstadoItvRevision>(
                value: _estado,
                label: 'Estado',
                items: const <AppDropdownItem<EstadoItvRevision>>[
                  AppDropdownItem<EstadoItvRevision>(
                    value: EstadoItvRevision.pendiente,
                    label: 'Pendiente',
                    icon: Icons.schedule,
                    iconColor: AppColors.info,
                  ),
                  AppDropdownItem<EstadoItvRevision>(
                    value: EstadoItvRevision.realizada,
                    label: 'Realizada',
                    icon: Icons.check_circle,
                    iconColor: AppColors.success,
                  ),
                  AppDropdownItem<EstadoItvRevision>(
                    value: EstadoItvRevision.vencida,
                    label: 'Vencida',
                    icon: Icons.error,
                    iconColor: AppColors.error,
                  ),
                  AppDropdownItem<EstadoItvRevision>(
                    value: EstadoItvRevision.cancelada,
                    label: 'Cancelada',
                    icon: Icons.cancel,
                    iconColor: AppColors.gray600,
                  ),
                ],
                onChanged: (EstadoItvRevision? value) {
                  if (value != null) {
                    setState(() => _estado = value);
                  }
                },
              ),
            ),
          ],
        ),

        const SizedBox(height: AppSizes.spacingLarge),
        const Divider(),
        const SizedBox(height: AppSizes.spacingLarge),

        // Información del Taller
        _buildSectionTitle('Información del Taller'),
        const SizedBox(height: AppSizes.spacing),
        Row(
          children: <Widget>[
            Expanded(
              child: _buildTextField(
                controller: _tallerController,
                label: 'Taller',
                hint: 'Nombre del taller',
              ),
            ),
            const SizedBox(width: AppSizes.spacing),
            Expanded(
              child: _buildTextField(
                controller: _numeroDocumentoController,
                label: 'Nº Documento',
                hint: 'Número de factura/documento',
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.spacing),
        _buildNumberField(
          label: 'Costo Total',
          controller: _costoTotalController,
          isRequired: true,
          suffix: '€',
        ),

        const SizedBox(height: AppSizes.spacingLarge),
        const Divider(),
        const SizedBox(height: AppSizes.spacingLarge),

        // Observaciones
        _buildSectionTitle('Observaciones'),
        const SizedBox(height: AppSizes.spacing),
        _buildTextField(
          controller: _observacionesController,
          label: 'Observaciones',
          hint: 'Detalles adicionales, defectos encontrados, reparaciones...',
          maxLines: 4,
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: AppSizes.fontMedium,
        fontWeight: FontWeight.bold,
        color: AppColors.secondary,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        ),
        filled: true,
        fillColor: AppColors.backgroundLight,
      ),
    );
  }

  Widget _buildNumberField({
    required String label,
    required TextEditingController controller,
    required bool isRequired,
    String? suffix,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
      ],
      validator: isRequired
          ? (String? value) {
              if (value == null || value.isEmpty) {
                return 'Campo requerido';
              }
              if (double.tryParse(value) == null) {
                return 'Valor numérico inválido';
              }
              return null;
            }
          : null,
      decoration: InputDecoration(
        labelText: label,
        suffixText: suffix,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        ),
        filled: true,
        fillColor: AppColors.backgroundLight,
      ),
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? value,
    required void Function(DateTime) onChanged,
    bool isRequired = true,
    bool canClear = false,
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
          filled: true,
          fillColor: AppColors.backgroundLight,
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (canClear && value != null)
                IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  onPressed: () => setState(() {
                    _fechaVencimiento = null;
                  }),
                  tooltip: 'Limpiar',
                ),
              const Icon(Icons.calendar_today, size: 18),
              const SizedBox(width: AppSizes.paddingSmall),
            ],
          ),
        ),
        child: Text(
          value != null ? DateFormat('dd/MM/yyyy').format(value) : 'Seleccionar fecha',
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

    final ItvRevisionEntity updatedItvRevision = widget.itvRevision.copyWith(
      fecha: _fecha,
      tipo: _tipo,
      resultado: _resultado,
      kmVehiculo: double.tryParse(_kmVehiculoController.text) ?? widget.itvRevision.kmVehiculo,
      fechaVencimiento: _fechaVencimiento,
      taller: _tallerController.text.isEmpty ? null : _tallerController.text,
      numeroDocumento: _numeroDocumentoController.text.isEmpty ? null : _numeroDocumentoController.text,
      costoTotal: double.tryParse(_costoTotalController.text) ?? widget.itvRevision.costoTotal,
      observaciones: _observacionesController.text.isEmpty ? null : _observacionesController.text,
      estado: _estado,
      updatedAt: DateTime.now(),
      updatedBy: Supabase.instance.client.auth.currentUser?.id,
    );

    context.read<ItvRevisionBloc>().add(
          ItvRevisionUpdateRequested(itvRevision: updatedItvRevision),
        );
  }
}
