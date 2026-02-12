import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/widgets/buttons/app_button.dart';
import 'package:ambutrack_web/core/widgets/dialogs/app_dialog.dart';
import 'package:ambutrack_web/core/widgets/handlers/crud_operation_handler.dart';
import 'package:ambutrack_web/core/widgets/loading/app_loading_indicator.dart';
import 'package:ambutrack_web/features/tablas/tipos_vehiculo/presentation/bloc/tipo_vehiculo_bloc.dart';
import 'package:ambutrack_web/features/tablas/tipos_vehiculo/presentation/bloc/tipo_vehiculo_event.dart';
import 'package:ambutrack_web/features/tablas/tipos_vehiculo/presentation/bloc/tipo_vehiculo_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';

/// Diálogo para crear/editar tipos de vehículo
class TipoVehiculoFormDialog extends StatefulWidget {
  const TipoVehiculoFormDialog({super.key, this.tipoVehiculo});

  final TipoVehiculoEntity? tipoVehiculo;

  @override
  State<TipoVehiculoFormDialog> createState() => _TipoVehiculoFormDialogState();
}

class _TipoVehiculoFormDialogState extends State<TipoVehiculoFormDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late TextEditingController _nombreController;
  late TextEditingController _descripcionController;
  late TextEditingController _ordenController;

  late FocusNode _nombreFocusNode;
  late FocusNode _descripcionFocusNode;
  late FocusNode _ordenFocusNode;

  bool _activo = true;
  bool _isSaving = false;
  bool get _isEditing => widget.tipoVehiculo != null;

  @override
  void initState() {
    super.initState();
    final TipoVehiculoEntity? t = widget.tipoVehiculo;

    _nombreController = TextEditingController(text: t?.nombre ?? '');
    _descripcionController = TextEditingController(text: t?.descripcion ?? '');
    _ordenController = TextEditingController(text: t?.orden?.toString() ?? '');

    _nombreFocusNode = FocusNode();
    _descripcionFocusNode = FocusNode();
    _ordenFocusNode = FocusNode();

    _activo = t?.activo ?? true;
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    _ordenController.dispose();
    _nombreFocusNode.dispose();
    _descripcionFocusNode.dispose();
    _ordenFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TipoVehiculoBloc, TipoVehiculoState>(
      listener: (BuildContext context, TipoVehiculoState state) {
        if (state is TipoVehiculoLoaded && _isSaving) {
          CrudOperationHandler.handleSuccess(
            context: context,
            isSaving: _isSaving,
            isEditing: _isEditing,
            entityName: 'Tipo de Vehículo',
            onClose: () {
              if (mounted) {
                setState(() => _isSaving = false);
              }
            },
          );
        } else if (state is TipoVehiculoError && _isSaving) {
          CrudOperationHandler.handleError(
            context: context,
            isSaving: _isSaving,
            isEditing: _isEditing,
            entityName: 'Tipo de Vehículo',
            errorMessage: state.message,
            onClose: () {
              if (mounted) {
                setState(() => _isSaving = false);
              }
            },
          );
        }
      },
      child: AppDialog(
        title: _isEditing ? 'Editar Tipo de Vehículo' : 'Nuevo Tipo de Vehículo',
        icon: _isEditing ? Icons.edit : Icons.add,
        type: _isEditing ? AppDialogType.edit : AppDialogType.create,
        content: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _buildTextField(
                controller: _nombreController,
                label: 'Nombre *',
                hint: 'Ej: SVB, SVA, Colectiva',
                icon: Icons.local_shipping,
                focusNode: _nombreFocusNode,
                nextFocusNode: _descripcionFocusNode,
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'El nombre es obligatorio';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSizes.spacing),
              _buildTextField(
                controller: _descripcionController,
                label: 'Descripción',
                hint: 'Ej: Soporte Vital Básico',
                icon: Icons.description,
                focusNode: _descripcionFocusNode,
                nextFocusNode: _ordenFocusNode,
                maxLines: 3,
              ),
              const SizedBox(height: AppSizes.spacing),
              _buildTextField(
                controller: _ordenController,
                label: 'Orden',
                hint: 'Número de orden',
                icon: Icons.sort,
                focusNode: _ordenFocusNode,
                textInputAction: TextInputAction.done,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: AppSizes.spacing),
              _buildActivoSwitch(),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    FocusNode? focusNode,
    FocusNode? nextFocusNode,
    TextInputAction? textInputAction,
    TextInputType? keyboardType,
    int? maxLines,
  }) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      textInputAction: textInputAction ?? TextInputAction.next,
      keyboardType: keyboardType,
      maxLines: maxLines ?? 1,
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

  Widget _buildActivoSwitch() {
    return Row(
      children: <Widget>[
        const Icon(Icons.toggle_on, color: AppColors.primary),
        const SizedBox(width: AppSizes.spacingSmall),
        Text(
          'Estado',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimaryLight,
          ),
        ),
        const SizedBox(width: AppSizes.spacing),
        Switch(
          value: _activo,
          onChanged: (bool value) {
            setState(() => _activo = value);
          },
          activeTrackColor: AppColors.success,
        ),
        const SizedBox(width: AppSizes.spacingSmall),
        Text(
          _activo ? 'Activo' : 'Inactivo',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: _activo ? AppColors.success : AppColors.error,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final String ordenText = _ordenController.text.trim();
    final int? orden = ordenText.isEmpty ? null : int.tryParse(ordenText);

    final TipoVehiculoEntity tipo = TipoVehiculoEntity(
      id: widget.tipoVehiculo?.id ?? const Uuid().v4(),
      createdAt: widget.tipoVehiculo?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
      nombre: _nombreController.text.trim(),
      descripcion: _descripcionController.text.trim().isEmpty ? null : _descripcionController.text.trim(),
      activo: _activo,
      orden: orden,
    );

    setState(() => _isSaving = true);

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AppLoadingOverlay(
          message: _isEditing ? 'Actualizando tipo de vehículo...' : 'Creando tipo de vehículo...',
          color: AppColors.primary,
          icon: _isEditing ? Icons.edit : Icons.add,
        );
      },
    );

    if (_isEditing) {
      debugPrint('🔄 Actualizando tipo de vehículo: ${tipo.nombre}');
      context.read<TipoVehiculoBloc>().add(TipoVehiculoUpdateRequested(tipo));
    } else {
      debugPrint('➕ Creando nuevo tipo de vehículo: ${tipo.nombre}');
      context.read<TipoVehiculoBloc>().add(TipoVehiculoCreateRequested(tipo));
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
