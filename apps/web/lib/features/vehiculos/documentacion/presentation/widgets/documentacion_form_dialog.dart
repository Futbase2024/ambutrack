import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/widgets/buttons/app_button.dart';
import 'package:ambutrack_web/core/widgets/dropdowns/app_dropdown.dart';
import 'package:ambutrack_web/core/widgets/forms/app_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Diálogo de formulario para crear/editar Documentación de Vehículo
class DocumentacionFormDialog extends StatefulWidget {
  const DocumentacionFormDialog({
    super.key,
    this.documento,
    required this.vehiculoId,
  });

  final DocumentacionVehiculoEntity? documento;
  final String vehiculoId;

  @override
  State<DocumentacionFormDialog> createState() => _DocumentacionFormDialogState();
}

class _DocumentacionFormDialogState extends State<DocumentacionFormDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _numeroPolizaController = TextEditingController();
  final TextEditingController _companiaController = TextEditingController();
  final TextEditingController _costeAnualController = TextEditingController();
  final TextEditingController _observacionesController = TextEditingController();
  final TextEditingController _diasAlertaController = TextEditingController(
    text: '30',
  );

  String? _tipoDocumentoId;
  DateTime? _fechaEmision;
  DateTime? _fechaVencimiento;
  DateTime? _fechaProximoVencimiento;
  String _estado = 'vigente';
  bool _requiereRenovacion = false;
  int _diasAlerta = 30;

  bool get _isEditing => widget.documento != null;

  @override
  void initState() {
    super.initState();
    if (widget.documento != null) {
      _loadDocumentoData();
    } else {
      // Valor por defecto para crear nuevo documento
      _tipoDocumentoId = 'seguro_rc';
    }
  }

  void _loadDocumentoData() {
    final DocumentacionVehiculoEntity doc = widget.documento!;
    _tipoDocumentoId = doc.tipoDocumentoId;
    _numeroPolizaController.text = doc.numeroPoliza;
    _companiaController.text = doc.compania;
    _fechaEmision = doc.fechaEmision;
    _fechaVencimiento = doc.fechaVencimiento;
    _fechaProximoVencimiento = doc.fechaProximoVencimiento;
    _estado = doc.estado;
    _requiereRenovacion = doc.requiereRenovacion;
    _diasAlerta = doc.diasAlerta;
    _diasAlertaController.text = doc.diasAlerta.toString();
    if (doc.costeAnual != null) {
      _costeAnualController.text = doc.costeAnual.toString();
    }
    if (doc.observaciones != null) {
      _observacionesController.text = doc.observaciones!;
    }
  }

  @override
  void dispose() {
    _numeroPolizaController.dispose();
    _companiaController.dispose();
    _costeAnualController.dispose();
    _observacionesController.dispose();
    _diasAlertaController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, DateTime? initialDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onSurface: AppColors.textPrimaryLight,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                textStyle: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && mounted) {
      setState(() {
        if (_fechaEmision == null) {
          _fechaEmision = picked;
        } else if (_fechaVencimiento == null) {
          _fechaVencimiento = picked;
        } else {
          _fechaProximoVencimiento = picked;
        }
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final DocumentacionVehiculoEntity documento = DocumentacionVehiculoEntity(
        id: _isEditing ? widget.documento!.id : '',
        vehiculoId: widget.vehiculoId,
        tipoDocumentoId: _tipoDocumentoId!,
        numeroPoliza: _numeroPolizaController.text.trim(),
        compania: _companiaController.text.trim(),
        fechaEmision: _fechaEmision!,
        fechaVencimiento: _fechaVencimiento!,
        fechaProximoVencimiento: _fechaProximoVencimiento,
        estado: _estado,
        costeAnual: _costeAnualController.text.isEmpty
            ? null
            : double.tryParse(_costeAnualController.text),
        observaciones: _observacionesController.text.trim().isEmpty
            ? null
            : _observacionesController.text.trim(),
        requiereRenovacion: _requiereRenovacion,
        diasAlerta: _diasAlerta,
        createdAt: _isEditing ? widget.documento!.createdAt : DateTime.now(),
        updatedAt: DateTime.now(),
      );

      Navigator.of(context).pop(documento);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
      ),
      child: Container(
        width: 600,
        constraints: const BoxConstraints(maxWidth: 600),
        padding: const EdgeInsets.all(AppSizes.paddingXl),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Header
              _buildHeader(),
              const SizedBox(height: AppSizes.spacingXl),

              // Form fields
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      _buildTipoDocumentoField(),
                      const SizedBox(height: AppSizes.spacing),
                      _buildNumeroPolizaField(),
                      const SizedBox(height: AppSizes.spacing),
                      _buildCompaniaField(),
                      const SizedBox(height: AppSizes.spacing),
                      _buildFechasSection(),
                      const SizedBox(height: AppSizes.spacing),
                      _buildEstadoField(),
                      const SizedBox(height: AppSizes.spacing),
                      _buildCosteAnualField(),
                      const SizedBox(height: AppSizes.spacing),
                      _buildDiasAlertaField(),
                      const SizedBox(height: AppSizes.spacing),
                      _buildRenovacionField(),
                      const SizedBox(height: AppSizes.spacing),
                      _buildObservacionesField(),
                    ],
                  ),
                ),
              ),

              // Actions
              const SizedBox(height: AppSizes.spacingXl),
              _buildActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: <Widget>[
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: _isEditing
                ? AppColors.secondaryLight.withValues(alpha: 0.1)
                : AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          ),
          child: Icon(
            _isEditing ? Icons.edit : Icons.add_circle_outline,
            color: _isEditing ? AppColors.secondaryLight : AppColors.primary,
            size: 24,
          ),
        ),
        const SizedBox(width: AppSizes.paddingMedium),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                _isEditing ? 'Editar Documento' : 'Nuevo Documento',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _isEditing
                    ? 'Actualiza la información del documento'
                    : 'Completa los datos del nuevo documento',
                style: GoogleFonts.inter(
                  fontSize: AppSizes.fontSmall,
                  color: AppColors.textSecondaryLight,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTipoDocumentoField() {
    return AppDropdown<String>(
      value: _tipoDocumentoId,
      label: 'Tipo de Documento',
      hint: 'Selecciona el tipo',
      prefixIcon: Icons.description_outlined,
      items: const <AppDropdownItem<String>>[
        AppDropdownItem<String>(
          value: 'seguro_rc',
          label: 'Seguro RC',
          icon: Icons.security,
        ),
        AppDropdownItem<String>(
          value: 'seguro_todo_riesgo',
          label: 'Seguro Todo Riesgo',
          icon: Icons.security,
        ),
        AppDropdownItem<String>(
          value: 'itv',
          label: 'ITV',
          icon: Icons.verified,
        ),
        AppDropdownItem<String>(
          value: 'permiso_municipal',
          label: 'Permiso Municipal',
          icon: Icons.admin_panel_settings,
        ),
        AppDropdownItem<String>(
          value: 'tarjeta_transporte',
          label: 'Tarjeta de Transporte',
          icon: Icons.badge,
        ),
      ],
      onChanged: (String? value) {
        setState(() {
          _tipoDocumentoId = value;
        });
      },
    );
  }

  Widget _buildNumeroPolizaField() {
    return AppTextField(
      controller: _numeroPolizaController,
      label: 'Número de Póliza/Licencia',
      hint: 'Ej: 123456789',
      icon: Icons.numbers,
      validator: (String? value) {
        if (value == null || value.trim().isEmpty) {
          return 'El número es obligatorio';
        }
        return null;
      },
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.allow(RegExp('[a-zA-Z0-9-]')),
      ],
    );
  }

  Widget _buildCompaniaField() {
    return AppTextField(
      controller: _companiaController,
      label: 'Compañía/Entidad',
      hint: 'Ej: Mapfre, Dirección General de Tráfico',
      icon: Icons.business,
      validator: (String? value) {
        if (value == null || value.trim().isEmpty) {
          return 'La compañía es obligatoria';
        }
        return null;
      },
    );
  }

  Widget _buildFechasSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          children: <Widget>[
            const Icon(Icons.calendar_today, size: 16, color: AppColors.gray600),
            const SizedBox(width: 8),
            Text(
              'Fechas',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimaryLight,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: <Widget>[
            Expanded(
              child: _buildDateField(
                label: 'Fecha Emisión',
                date: _fechaEmision,
                onTap: () => _selectDate(context, _fechaEmision),
                validator: (DateTime? value) {
                  if (value == null) {
                    return 'Requerida';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: AppSizes.paddingMedium),
            Expanded(
              child: _buildDateField(
                label: 'Fecha Vencimiento',
                date: _fechaVencimiento,
                onTap: () => _selectDate(context, _fechaVencimiento),
                validator: (DateTime? value) {
                  if (value == null) {
                    return 'Requerida';
                  }
                  if (_fechaEmision != null && value.isBefore(_fechaEmision!)) {
                    return 'Debe ser posterior a emisión';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.paddingMedium),
        _buildDateField(
          label: 'Próximo Vencimiento (opcional)',
          date: _fechaProximoVencimiento,
          onTap: () => _selectDate(context, _fechaProximoVencimiento),
        ),
      ],
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
    String? Function(DateTime?)? validator,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: AppSizes.fontSmall,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: validator != null && validator(date) != null
                    ? AppColors.error
                    : AppColors.gray300,
                width: validator != null && validator(date) != null ? 2 : 1.5,
              ),
              borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
            ),
            child: Row(
              children: <Widget>[
                const Icon(
                  Icons.event,
                  size: 18,
                  color: AppColors.gray500,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    date != null
                        ? '${date.day}/${date.month}/${date.year}'
                        : 'Seleccionar fecha',
                    style: GoogleFonts.inter(
                      fontSize: AppSizes.fontSmall,
                      color: date != null
                          ? AppColors.textPrimaryLight
                          : AppColors.gray400,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Icon(
                  Icons.keyboard_arrow_down,
                  size: 20,
                  color: AppColors.gray500,
                ),
              ],
            ),
          ),
          if (validator != null && validator(date) != null) ...<Widget>[
            const SizedBox(height: 4),
            Text(
              validator(date)!,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppColors.error,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEstadoField() {
    return AppDropdown<String>(
      value: _estado,
      label: 'Estado',
      hint: 'Selecciona el estado',
      prefixIcon: Icons.playlist_add_check_circle,
      items: const <AppDropdownItem<String>>[
        AppDropdownItem<String>(
          value: 'vigente',
          label: 'Vigente',
          icon: Icons.check_circle,
          iconColor: AppColors.success,
        ),
        AppDropdownItem<String>(
          value: 'proxima_vencer',
          label: 'Próxima a Vencer',
          icon: Icons.warning,
          iconColor: AppColors.warning,
        ),
        AppDropdownItem<String>(
          value: 'vencida',
          label: 'Vencida',
          icon: Icons.cancel,
          iconColor: AppColors.error,
        ),
      ],
      onChanged: (String? value) {
        setState(() {
          _estado = value ?? 'vigente';
        });
      },
    );
  }

  Widget _buildCosteAnualField() {
    return AppTextField(
      controller: _costeAnualController,
      label: 'Coste Anual (€)',
      hint: 'Ej: 450.00',
      icon: Icons.euro,
      keyboardType: TextInputType.number,
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
      ],
    );
  }

  Widget _buildDiasAlertaField() {
    return AppTextField(
      controller: _diasAlertaController,
      label: 'Días de Alerta',
      hint: 'Ej: 30',
      icon: Icons.notifications,
      keyboardType: TextInputType.number,
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.digitsOnly,
      ],
      onChanged: (String value) {
        final int? days = int.tryParse(value);
        if (days != null) {
          setState(() {
            _diasAlerta = days;
          });
        }
      },
    );
  }

  Widget _buildRenovacionField() {
    return Row(
      children: <Widget>[
        Checkbox(
          value: _requiereRenovacion,
          onChanged: (bool? value) {
            setState(() {
              _requiereRenovacion = value ?? false;
            });
          },
          activeColor: AppColors.primary,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _requiereRenovacion = !_requiereRenovacion;
              });
            },
            child: Text(
              'Requiere renovación automática',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimaryLight,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildObservacionesField() {
    return AppTextField(
      controller: _observacionesController,
      label: 'Observaciones',
      hint: 'Notas adicionales...',
      icon: Icons.notes,
      maxLines: 3,
      minLines: 2,
    );
  }

  Widget _buildActions() {
    return Row(
      children: <Widget>[
        Expanded(
          child: AppButton(
            label: 'Cancelar',
            variant: AppButtonVariant.outline,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        const SizedBox(width: AppSizes.paddingMedium),
        Expanded(
          child: AppButton(
            label: _isEditing ? 'Guardar' : 'Crear',
            variant: _isEditing
                ? AppButtonVariant.secondary
                : AppButtonVariant.primary,
            onPressed: _submitForm,
            icon: _isEditing ? Icons.save : Icons.add,
          ),
        ),
      ],
    );
  }
}
