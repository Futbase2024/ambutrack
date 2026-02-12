import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/utils/crud_operation_handler.dart';
import 'package:ambutrack_web/core/widgets/buttons/app_button.dart';
import 'package:ambutrack_web/core/widgets/dialogs/app_dialog.dart';
import 'package:ambutrack_web/core/widgets/dropdowns/app_dropdown.dart';
import 'package:ambutrack_web/core/widgets/loading/app_loading_indicator.dart';
import 'package:ambutrack_web/features/contratos/presentation/bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Diálogo para crear o editar un contrato
class ContratoFormDialog extends StatefulWidget {
  const ContratoFormDialog({
    super.key,
    this.contrato,
    this.isViewOnly = false,
  });

  final ContratoEntity? contrato;
  final bool isViewOnly;

  @override
  State<ContratoFormDialog> createState() => _ContratoFormDialogState();
}

class _ContratoFormDialogState extends State<ContratoFormDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Controllers
  late TextEditingController _codigoController;
  late TextEditingController _descripcionController;
  late TextEditingController _importeController;
  late TextEditingController _condicionesController;

  // Datos del formulario
  String? _selectedHospitalId;
  DateTime? _fechaInicio;
  DateTime? _fechaFin;
  String? _tipoContrato;
  bool _activo = true;

  // Listas
  List<CentroHospitalarioEntity> _hospitales = <CentroHospitalarioEntity>[];
  bool _isLoadingHospitales = true;
  bool _isSaving = false;

  // Tipos de contrato
  final List<String> _tiposContrato = <String>[
    'URGENCIAS',
    'PROGRAMADO',
    'MIXTO',
    'EVENTOS',
    'TRASLADOS',
  ];

  @override
  void initState() {
    super.initState();
    _initControllers();
    _loadHospitales();
  }

  void _initControllers() {
    _codigoController = TextEditingController(text: widget.contrato?.codigo);
    _descripcionController =
        TextEditingController(text: widget.contrato?.descripcion);
    _importeController = TextEditingController(
      text: widget.contrato?.importeMensual?.toStringAsFixed(2),
    );
    _condicionesController = TextEditingController();

    if (widget.contrato != null) {
      _selectedHospitalId = widget.contrato!.hospitalId;
      _fechaInicio = widget.contrato!.fechaInicio;
      _fechaFin = widget.contrato!.fechaFin;
      _tipoContrato = widget.contrato!.tipoContrato;
      _activo = widget.contrato!.activo;
    }
  }

  Future<void> _loadHospitales() async {
    try {
      final CentroHospitalarioDataSource dataSource =
          CentroHospitalarioDataSourceFactory.createSupabase(
        supabase: Supabase.instance.client,
      );

      final List<CentroHospitalarioEntity> hospitales =
          await dataSource.getAll();

      if (mounted) {
        setState(() {
          _hospitales = hospitales
              .where((CentroHospitalarioEntity h) => h.activo)
              .toList();
          _isLoadingHospitales = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Error al cargar hospitales: $e');
      if (mounted) {
        setState(() {
          _isLoadingHospitales = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _codigoController.dispose();
    _descripcionController.dispose();
    _importeController.dispose();
    _condicionesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingHospitales) {
      return AppDialog(
        title: widget.contrato == null ? 'Nuevo Contrato' : 'Editar Contrato',
        content: const SizedBox(
          height: 400,
          child: Center(
            child: AppLoadingIndicator(
              message: 'Cargando datos...',
              size: 100,
            ),
          ),
        ),
        actions: <Widget>[
          AppButton(
            onPressed: () => Navigator.of(context).pop(),
            label: 'Cancelar',
            variant: AppButtonVariant.text,
          ),
        ],
      );
    }

    return BlocListener<ContratoBloc, ContratoState>(
      listener: (BuildContext context, ContratoState state) {
        if (_isSaving) {
          if (state is ContratoLoaded) {
            CrudOperationHandler.handleSuccess(
              context: context,
              isSaving: _isSaving,
              isEditing: widget.contrato != null,
              entityName: 'Contrato',
              onComplete: () {
                setState(() => _isSaving = false);
              },
            );
          } else if (state is ContratoError) {
            CrudOperationHandler.handleError(
              context: context,
              isSaving: _isSaving,
              errorMessage: state.message,
              onComplete: () {
                setState(() => _isSaving = false);
              },
            );
          }
        }
      },
      child: AppDialog(
      title: widget.isViewOnly
          ? 'Ver Contrato'
          : (widget.contrato == null ? 'Nuevo Contrato' : 'Editar Contrato'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Código
              _buildTextField(
                controller: _codigoController,
                label: 'Código del Contrato',
                hint: 'Ej: AYT2024',
                icon: Icons.tag,
                validator: (String? value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'El código es obligatorio';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSizes.spacing),

              // Hospital
              AppDropdown<String>(
                value: _selectedHospitalId,
                label: 'Centro Hospitalario',
                hint: 'Selecciona un hospital',
                prefixIcon: Icons.local_hospital,
                enabled: !widget.isViewOnly,
                items: _hospitales.map((CentroHospitalarioEntity hospital) {
                  return AppDropdownItem<String>(
                    value: hospital.id,
                    label: hospital.nombre,
                    icon: Icons.local_hospital,
                    iconColor: AppColors.primary,
                  );
                }).toList(),
                onChanged: (String? value) {
                  setState(() => _selectedHospitalId = value);
                },
              ),
              const SizedBox(height: AppSizes.spacing),

              // Tipo de Contrato
              AppDropdown<String>(
                value: _tipoContrato,
                label: 'Tipo de Contrato',
                hint: 'Selecciona el tipo',
                prefixIcon: Icons.category,
                enabled: !widget.isViewOnly,
                items: _tiposContrato.map((String tipo) {
                  return AppDropdownItem<String>(
                    value: tipo,
                    label: tipo,
                  );
                }).toList(),
                onChanged: (String? value) {
                  setState(() => _tipoContrato = value);
                },
              ),
              const SizedBox(height: AppSizes.spacing),

              // Fechas
              Row(
                children: <Widget>[
                  Expanded(
                    child: _buildDateField(
                      label: 'Fecha Inicio',
                      value: _fechaInicio,
                      onChanged: (DateTime? date) {
                        setState(() => _fechaInicio = date);
                      },
                      validator: (DateTime? value) {
                        if (value == null) {
                          return 'Fecha obligatoria';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: AppSizes.spacing),
                  Expanded(
                    child: _buildDateField(
                      label: 'Fecha Fin (Opcional)',
                      value: _fechaFin,
                      onChanged: (DateTime? date) {
                        setState(() => _fechaFin = date);
                      },
                      validator: (DateTime? value) {
                        if (value != null &&
                            _fechaInicio != null &&
                            value.isBefore(_fechaInicio!)) {
                          return 'Debe ser posterior a inicio';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.spacing),

              // Importe Mensual
              _buildTextField(
                controller: _importeController,
                label: 'Importe Mensual (€)',
                hint: 'Ej: 5000.00',
                icon: Icons.euro,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
              ),
              const SizedBox(height: AppSizes.spacing),

              // Descripción
              _buildTextField(
                controller: _descripcionController,
                label: 'Descripción',
                hint: 'Descripción del contrato',
                icon: Icons.description,
                maxLines: 3,
              ),
              const SizedBox(height: AppSizes.spacing),

              // Estado Activo
              if (!widget.isViewOnly)
                Row(
                  children: <Widget>[
                    Checkbox(
                      value: _activo,
                      onChanged: (bool? value) {
                        setState(() => _activo = value ?? true);
                      },
                      activeColor: AppColors.primary,
                    ),
                    Text(
                      'Contrato activo',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppColors.textPrimaryLight,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        AppButton(
          onPressed: () => Navigator.of(context).pop(),
          label: widget.isViewOnly ? 'Cerrar' : 'Cancelar',
          variant: AppButtonVariant.text,
        ),
        if (!widget.isViewOnly)
          AppButton(
            onPressed: _onSave,
            label: widget.contrato == null ? 'Crear' : 'Actualizar',
          ),
      ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      enabled: !widget.isViewOnly,
      maxLines: maxLines,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      textInputAction: maxLines == 1 ? TextInputAction.next : TextInputAction.newline,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        ),
      ),
      validator: validator,
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? value,
    required void Function(DateTime?) onChanged,
    String? Function(DateTime?)? validator,
  }) {
    return InkWell(
      onTap: widget.isViewOnly
          ? null
          : () async {
              final DateTime? date = await showDatePicker(
                context: context,
                initialDate: value ?? DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime(2050),
              );
              if (date != null) {
                onChanged(date);
              }
            },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.calendar_today, size: 20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          ),
          errorText: validator?.call(value),
        ),
        child: Text(
          value == null
              ? 'Selecciona fecha'
              : '${value.day.toString().padLeft(2, '0')}/'
                  '${value.month.toString().padLeft(2, '0')}/'
                  '${value.year}',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: value == null
                ? AppColors.textSecondaryLight
                : AppColors.textPrimaryLight,
          ),
        ),
      ),
    );
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_fechaInicio == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La fecha de inicio es obligatoria'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final ContratoEntity contrato = ContratoEntity(
      id: widget.contrato?.id ?? '',
      codigo: _codigoController.text.trim(),
      hospitalId: _selectedHospitalId!,
      fechaInicio: _fechaInicio!,
      fechaFin: _fechaFin,
      descripcion: _descripcionController.text.trim().isEmpty
          ? null
          : _descripcionController.text.trim(),
      tipoContrato: _tipoContrato,
      importeMensual: _importeController.text.trim().isEmpty
          ? null
          : double.tryParse(_importeController.text.trim()),
      activo: _activo,
      createdAt: widget.contrato?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
      createdBy: widget.contrato?.createdBy,
      updatedBy: widget.contrato?.updatedBy,
    );

    setState(() => _isSaving = true);

    CrudOperationHandler.showLoadingOverlay(
      context: context,
      isEditing: widget.contrato != null,
      entityName: 'Contrato',
    );

    if (widget.contrato == null) {
      context.read<ContratoBloc>().add(ContratoCreateRequested(contrato));
    } else {
      context.read<ContratoBloc>().add(ContratoUpdateRequested(contrato));
    }
  }
}
