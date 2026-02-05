import 'package:ambutrack_core/ambutrack_core.dart';
import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/utils/crud_operation_handler.dart';
import 'package:ambutrack_web/core/widgets/buttons/app_button.dart';
import 'package:ambutrack_web/core/widgets/dialogs/app_dialog.dart';
import 'package:ambutrack_web/core/widgets/dropdowns/app_dropdown.dart';
import 'package:ambutrack_web/features/tablas/provincias/presentation/bloc/provincia_bloc.dart';
import 'package:ambutrack_web/features/tablas/provincias/presentation/bloc/provincia_event.dart';
import 'package:ambutrack_web/features/tablas/provincias/presentation/bloc/provincia_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

/// Diálogo para crear/editar provincias
class ProvinciaFormDialog extends StatefulWidget {
  const ProvinciaFormDialog({super.key, this.provincia});

  final ProvinciaEntity? provincia;

  @override
  State<ProvinciaFormDialog> createState() => _ProvinciaFormDialogState();
}

class _ProvinciaFormDialogState extends State<ProvinciaFormDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late TextEditingController _codigoController;
  late TextEditingController _nombreController;

  late FocusNode _codigoFocusNode;
  late FocusNode _nombreFocusNode;

  List<ComunidadAutonomaEntity> _comunidades = <ComunidadAutonomaEntity>[];
  String? _comunidadId;
  bool _isSaving = false;
  bool _isLoadingComunidades = false;
  bool get _isEditing => widget.provincia != null;

  @override
  void initState() {
    super.initState();
    final ProvinciaEntity? p = widget.provincia;

    _codigoController = TextEditingController(text: p?.codigo ?? '');
    _nombreController = TextEditingController(text: p?.nombre ?? '');

    _codigoFocusNode = FocusNode();
    _nombreFocusNode = FocusNode();

    _loadComunidades();
  }

  Future<void> _loadComunidades() async {
    setState(() {
      _isLoadingComunidades = true;
    });

    try {
      final ComunidadAutonomaDataSource dataSource = getIt<ComunidadAutonomaDataSource>();
      final List<ComunidadAutonomaEntity> comunidades = await dataSource.getAll();

      if (mounted) {
        setState(() {
          _comunidades = comunidades;
          _isLoadingComunidades = false;

          // Si estamos editando, establecer el ID de la comunidad desde la provincia
          if (widget.provincia?.comunidadId != null) {
            _comunidadId = widget.provincia!.comunidadId;
          }
        });
      }
    } catch (e) {
      debugPrint('❌ Error al cargar comunidades autónomas: $e');
      if (mounted) {
        setState(() {
          _isLoadingComunidades = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _codigoController.dispose();
    _nombreController.dispose();
    _codigoFocusNode.dispose();
    _nombreFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProvinciaBloc, ProvinciaState>(
      listener: (BuildContext context, ProvinciaState state) {
        if (state is ProvinciaLoaded) {
          CrudOperationHandler.handleSuccess(
            context: context,
            isSaving: _isSaving,
            isEditing: _isEditing,
            entityName: 'Provincia',
            onComplete: () {
              if (mounted) {
                setState(() => _isSaving = false);
              }
            },
          );
        } else if (state is ProvinciaError) {
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
      },
      child: AppDialog(
        title: _isEditing ? 'Editar Provincia' : 'Nueva Provincia',
        icon: _isEditing ? Icons.edit : Icons.add_location,
        maxWidth: 700,
        type: _isEditing ? AppDialogType.edit : AppDialogType.create,
        content: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // Sección de información básica
              _buildSectionTitle('Información Básica'),
              const SizedBox(height: AppSizes.spacingMedium),

              // Código y Nombre en la misma fila
              Row(
                children: <Widget>[
                  Expanded(
                    child: _buildTextField(
                      controller: _codigoController,
                      label: 'Código',
                      hint: 'Ej: 01',
                      icon: Icons.tag,
                      focusNode: _codigoFocusNode,
                      nextFocusNode: _nombreFocusNode,
                    ),
                  ),
                  const SizedBox(width: AppSizes.spacing),
                  Expanded(
                    flex: 2,
                    child: _buildTextField(
                      controller: _nombreController,
                      label: 'Nombre *',
                      hint: 'Ej: Madrid',
                      icon: Icons.location_city,
                      focusNode: _nombreFocusNode,
                      textInputAction: TextInputAction.done,
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return 'El nombre es obligatorio';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.spacingLarge),

              // Sección de ubicación
              _buildSectionTitle('Ubicación'),
              const SizedBox(height: AppSizes.spacingMedium),

              // Comunidad Autónoma Dropdown
              if (_isLoadingComunidades)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(AppSizes.paddingMedium),
                    child: CircularProgressIndicator(),
                  ),
                )
              else
                AppDropdown<String>(
                  value: _comunidadId,
                  label: 'Comunidad Autónoma',
                  hint: 'Selecciona una comunidad',
                  prefixIcon: Icons.map,
                  items: _comunidades
                      .map(
                        (ComunidadAutonomaEntity comunidad) => AppDropdownItem<String>(
                          value: comunidad.id,
                          label: comunidad.nombre,
                        ),
                      )
                      .toList(),
                  onChanged: (String? value) {
                    setState(() {
                      _comunidadId = value;
                    });
                  },
                ),
            ],
          ),
        ),
        actions: <Widget>[
          AppButton(
            onPressed: () => Navigator.of(context).pop(),
            label: 'Cancelar',
            variant: AppButtonVariant.text,
          ),
          AppButton(
            onPressed: _isSaving ? null : _onSave,
            label: _isEditing ? 'Actualizar' : 'Crear',
            variant: _isEditing ? AppButtonVariant.secondary : AppButtonVariant.primary,
            icon: _isEditing ? Icons.save : Icons.add,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: AppSizes.fontMedium,
        fontWeight: FontWeight.bold,
        color: AppColors.primary,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    FocusNode? focusNode,
    FocusNode? nextFocusNode,
    TextInputAction? textInputAction,
  }) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      textInputAction: textInputAction ?? TextInputAction.next,
      onFieldSubmitted: (_) {
        if (nextFocusNode != null) {
          nextFocusNode.requestFocus();
        } else {
          _onSave();
        }
      },
      inputFormatters: label.contains('Nombre')
          ? <TextInputFormatter>[
              UpperCaseTextFormatter(),
            ]
          : null,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          borderSide: const BorderSide(color: AppColors.gray300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          borderSide: const BorderSide(color: AppColors.gray300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      validator: validator,
    );
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) {
      debugPrint('❌ ProvinciaFormDialog: Validación fallida');
      return;
    }

    debugPrint('👍 ProvinciaFormDialog: Validación exitosa, guardando provincia...');

    final String codigoText = _codigoController.text.trim();

    final ProvinciaEntity provincia = ProvinciaEntity(
      id: widget.provincia?.id ?? '',
      codigo: codigoText.isEmpty ? null : codigoText,
      nombre: _nombreController.text.trim(),
      comunidadId: _comunidadId, // Guardar el ID de la comunidad
      createdAt: widget.provincia?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    debugPrint('📦 ProvinciaFormDialog: ${_isEditing ? "Actualizando" : "Creando"} provincia - ${provincia.nombre}');

    // Mostrar loading overlay
    setState(() {
      _isSaving = true;
    });

    CrudOperationHandler.showLoadingOverlay(
      context: context,
      isEditing: _isEditing,
      entityName: 'Provincia',
    );

    if (_isEditing) {
      debugPrint('📝 ProvinciaFormDialog: Enviando evento ProvinciaUpdateRequested al BLoC...');
      context.read<ProvinciaBloc>().add(ProvinciaUpdateRequested(provincia));
    } else {
      debugPrint('➕ ProvinciaFormDialog: Enviando evento ProvinciaCreateRequested al BLoC...');
      context.read<ProvinciaBloc>().add(ProvinciaCreateRequested(provincia));
    }
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
