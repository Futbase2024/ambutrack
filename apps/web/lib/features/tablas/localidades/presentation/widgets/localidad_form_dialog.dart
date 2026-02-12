import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/widgets/buttons/app_button.dart';
import 'package:ambutrack_web/core/widgets/dialogs/app_dialog.dart';
import 'package:ambutrack_web/core/widgets/dropdowns/app_dropdown.dart';
import 'package:ambutrack_web/core/widgets/loading/app_loading_indicator.dart';
import 'package:ambutrack_web/features/tablas/localidades/presentation/bloc/localidad_bloc.dart';
import 'package:ambutrack_web/features/tablas/localidades/presentation/bloc/localidad_event.dart';
import 'package:ambutrack_web/features/tablas/localidades/presentation/bloc/localidad_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

/// Diálogo para crear/editar localidades
class LocalidadFormDialog extends StatefulWidget {
  const LocalidadFormDialog({super.key, this.localidad});

  final LocalidadEntity? localidad;

  @override
  State<LocalidadFormDialog> createState() => _LocalidadFormDialogState();
}

class _LocalidadFormDialogState extends State<LocalidadFormDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late TextEditingController _codigoController;
  late TextEditingController _nombreController;
  late TextEditingController _codigoPostalController;

  late FocusNode _codigoFocusNode;
  late FocusNode _nombreFocusNode;
  late FocusNode _codigoPostalFocusNode;

  List<ProvinciaEntity> _provincias = <ProvinciaEntity>[];
  String? _provinciaId;
  bool _isSaving = false;
  bool _isLoadingProvincias = false;
  bool get _isEditing => widget.localidad != null;

  @override
  void initState() {
    super.initState();
    final LocalidadEntity? l = widget.localidad;

    _codigoController = TextEditingController(text: l?.codigo ?? '');
    _nombreController = TextEditingController(text: l?.nombre ?? '');
    _codigoPostalController = TextEditingController(text: l?.codigoPostal ?? '');

    _codigoFocusNode = FocusNode();
    _nombreFocusNode = FocusNode();
    _codigoPostalFocusNode = FocusNode();

    _loadProvincias();
  }

  Future<void> _loadProvincias() async {
    setState(() {
      _isLoadingProvincias = true;
    });

    try {
      final ProvinciaDataSource dataSource = getIt<ProvinciaDataSource>();
      final List<ProvinciaEntity> provincias = await dataSource.getAll();

      if (mounted) {
        setState(() {
          _provincias = provincias;
          _isLoadingProvincias = false;

          // Si estamos editando, establecer el ID de la provincia desde la localidad
          if (widget.localidad?.provinciaId != null) {
            _provinciaId = widget.localidad!.provinciaId;
          }
        });
      }
    } catch (e) {
      debugPrint('❌ Error al cargar provincias: $e');
      if (mounted) {
        setState(() {
          _isLoadingProvincias = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _codigoController.dispose();
    _nombreController.dispose();
    _codigoPostalController.dispose();
    _codigoFocusNode.dispose();
    _nombreFocusNode.dispose();
    _codigoPostalFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LocalidadBloc, LocalidadState>(
      listener: (BuildContext context, LocalidadState state) {
        if (state is LocalidadLoaded) {
          debugPrint('✅ LocalidadFormDialog: Localidad guardada exitosamente, cerrando diálogo');

          // Cerrar loading overlay si está abierto
          if (_isSaving) {
            Navigator.of(context).pop(); // Cierra loading overlay
          }

          Navigator.of(context).pop(); // Cierra el formulario

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _isEditing ? '✅ Localidad actualizada exitosamente' : '✅ Localidad creada exitosamente',
              ),
              backgroundColor: AppColors.success,
              duration: const Duration(seconds: 3),
            ),
          );
        } else if (state is LocalidadError) {
          debugPrint('❌ LocalidadFormDialog: Error al guardar localidad - ${state.message}');

          // Cerrar loading overlay si está abierto
          if (_isSaving && mounted) {
            Navigator.of(context).pop(); // Cierra loading overlay
            setState(() {
              _isSaving = false;
            });
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Error: ${state.message}'),
              backgroundColor: AppColors.error,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      },
      child: AppDialog(
        title: _isEditing ? 'Editar Localidad' : 'Nueva Localidad',
        icon: _isEditing ? Icons.edit : Icons.add_location_alt,
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
                      hint: 'Ej: 28001',
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
                      hint: 'Ej: Alcalá de Henares',
                      icon: Icons.location_city,
                      focusNode: _nombreFocusNode,
                      nextFocusNode: _codigoPostalFocusNode,
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
              const SizedBox(height: AppSizes.spacing),

              // Código Postal
              _buildTextField(
                controller: _codigoPostalController,
                label: 'Código Postal',
                hint: 'Ej: 28801',
                icon: Icons.mail_outline,
                focusNode: _codigoPostalFocusNode,
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: AppSizes.spacingLarge),

              // Sección de ubicación
              _buildSectionTitle('Ubicación'),
              const SizedBox(height: AppSizes.spacingMedium),

              // Provincia Dropdown
              if (_isLoadingProvincias)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(AppSizes.paddingMedium),
                    child: CircularProgressIndicator(),
                  ),
                )
              else
                AppDropdown<String>(
                  value: _provinciaId,
                  label: 'Provincia',
                  hint: 'Selecciona una provincia',
                  prefixIcon: Icons.map,
                  items: _provincias
                      .map(
                        (ProvinciaEntity provincia) => AppDropdownItem<String>(
                          value: provincia.id,
                          label: provincia.nombre,
                        ),
                      )
                      .toList(),
                  onChanged: (String? value) {
                    setState(() {
                      _provinciaId = value;
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
      debugPrint('❌ LocalidadFormDialog: Validación fallida');
      return;
    }

    debugPrint('👍 LocalidadFormDialog: Validación exitosa, guardando localidad...');

    final String codigoText = _codigoController.text.trim();
    final String codigoPostalText = _codigoPostalController.text.trim();

    final LocalidadEntity localidad = LocalidadEntity(
      id: widget.localidad?.id ?? '',
      codigo: codigoText.isEmpty ? null : codigoText,
      nombre: _nombreController.text.trim(),
      provinciaId: _provinciaId, // Guardar el ID de la provincia
      codigoPostal: codigoPostalText.isEmpty ? null : codigoPostalText,
      createdAt: widget.localidad?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    debugPrint('📦 LocalidadFormDialog: ${_isEditing ? "Actualizando" : "Creando"} localidad - ${localidad.nombre}');

    // Mostrar loading overlay
    setState(() {
      _isSaving = true;
    });

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AppLoadingOverlay(
          message: _isEditing ? 'Actualizando localidad...' : 'Creando localidad...',
          color: _isEditing ? AppColors.secondary : AppColors.primary,
          icon: _isEditing ? Icons.edit : Icons.add_location_alt,
        );
      },
    );

    if (_isEditing) {
      debugPrint('📝 LocalidadFormDialog: Enviando evento LocalidadUpdateRequested al BLoC...');
      context.read<LocalidadBloc>().add(LocalidadUpdateRequested(localidad));
    } else {
      debugPrint('➕ LocalidadFormDialog: Enviando evento LocalidadCreateRequested al BLoC...');
      context.read<LocalidadBloc>().add(LocalidadCreateRequested(localidad));
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
