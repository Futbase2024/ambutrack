import 'package:ambutrack_core/ambutrack_core.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/widgets/buttons/app_button.dart';
import 'package:ambutrack_web/core/widgets/dialogs/app_dialog.dart';
import 'package:ambutrack_web/core/widgets/dropdowns/app_dropdown.dart';
import 'package:ambutrack_web/features/cuadrante/excepciones_festivos/presentation/bloc/excepciones_festivos_bloc_exports.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';

/// Diálogo de formulario para crear/editar una Excepción/Festivo
class ExcepcionFestivoFormDialog extends StatefulWidget {
  const ExcepcionFestivoFormDialog({super.key, this.item});

  final ExcepcionFestivoEntity? item;

  @override
  State<ExcepcionFestivoFormDialog> createState() => _ExcepcionFestivoFormDialogState();
}

class _ExcepcionFestivoFormDialogState extends State<ExcepcionFestivoFormDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreController;
  late TextEditingController _descripcionController;

  DateTime _fecha = DateTime.now();
  String _tipo = ExcepcionFestivoEntity.tipoFestivo;
  bool _afectaDotaciones = true;
  bool _repetirAnualmente = false;
  bool _activo = true;

  bool get _isEditing => widget.item != null;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    final ExcepcionFestivoEntity? item = widget.item;

    _nombreController = TextEditingController(text: item?.nombre ?? '');
    _descripcionController = TextEditingController(text: item?.descripcion ?? '');

    if (item != null) {
      _fecha = item.fecha;
      _tipo = item.tipo;
      _afectaDotaciones = item.afectaDotaciones;
      _repetirAnualmente = item.repetirAnualmente;
      _activo = item.activo;
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppDialog(
      title: _isEditing ? 'Editar Excepción/Festivo' : 'Nueva Excepción/Festivo',
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _buildInfoSection(),
              const SizedBox(height: AppSizes.spacing),
              _buildFechaSection(),
              const SizedBox(height: AppSizes.spacing),
              _buildConfigSection(),
              const SizedBox(height: AppSizes.spacing),
              _buildEstadoSection(),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        AppButton(
          onPressed: () => Navigator.of(context).pop(),
          label: 'Cancelar',
          variant: AppButtonVariant.text,
        ),
        AppButton(
          onPressed: _onSave,
          label: _isEditing ? 'Actualizar' : 'Crear',
        ),
      ],
    );
  }

  Widget _buildInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Información Básica',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimaryLight,
          ),
        ),
        const SizedBox(height: AppSizes.spacingSmall),
        TextFormField(
          controller: _nombreController,
          textInputAction: TextInputAction.next,
          decoration: const InputDecoration(
            labelText: 'Nombre *',
            hintText: 'Ej: Navidad, Año Nuevo, Día del Trabajador',
            prefixIcon: Icon(Icons.label),
          ),
          validator: (String? value) {
            if (value == null || value.trim().isEmpty) {
              return 'El nombre es requerido';
            }
            return null;
          },
        ),
        const SizedBox(height: AppSizes.spacingSmall),
        TextFormField(
          controller: _descripcionController,
          textInputAction: TextInputAction.newline,
          maxLines: 2,
          decoration: const InputDecoration(
            labelText: 'Descripción',
            hintText: 'Información adicional sobre esta excepción/festivo',
            prefixIcon: Icon(Icons.description),
          ),
        ),
      ],
    );
  }

  Widget _buildFechaSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Fecha y Tipo',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimaryLight,
          ),
        ),
        const SizedBox(height: AppSizes.spacingSmall),
        InkWell(
          onTap: () => _selectFecha(context),
          child: InputDecorator(
            decoration: const InputDecoration(
              labelText: 'Fecha *',
              prefixIcon: Icon(Icons.calendar_today),
              border: OutlineInputBorder(),
            ),
            child: Text(
              '${_fecha.day.toString().padLeft(2, '0')}/${_fecha.month.toString().padLeft(2, '0')}/${_fecha.year}',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.textPrimaryLight,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSizes.spacingSmall),
        AppDropdown<String>(
          value: _tipo,
          label: 'Tipo *',
          hint: 'Selecciona el tipo',
          prefixIcon: Icons.category,
          items: ExcepcionFestivoEntity.tiposValidos
              .map(
                (String tipo) => AppDropdownItem<String>(
                  value: tipo,
                  label: tipo,
                  icon: Icons.label,
                  iconColor: _getTipoColor(tipo),
                ),
              )
              .toList(),
          onChanged: (String? value) {
            if (value != null) {
              setState(() => _tipo = value);
            }
          },
        ),
      ],
    );
  }

  Widget _buildConfigSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Configuración',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimaryLight,
          ),
        ),
        const SizedBox(height: AppSizes.spacingSmall),
        SwitchListTile(
          title: Text(
            'Repetir Anualmente',
            style: GoogleFonts.inter(fontSize: 14),
          ),
          subtitle: Text(
            'Se repetirá automáticamente cada año',
            style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondaryLight),
          ),
          value: _repetirAnualmente,
          onChanged: (bool value) {
            setState(() => _repetirAnualmente = value);
          },
          activeThumbColor: AppColors.primary,
        ),
      ],
    );
  }

  Widget _buildEstadoSection() {
    return Row(
      children: <Widget>[
        Text(
          'Estado',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimaryLight,
          ),
        ),
        const SizedBox(width: AppSizes.spacing),
        Expanded(
          child: SwitchListTile(
            title: Text(
              _activo ? 'Activa' : 'Inactiva',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: _activo ? AppColors.success : AppColors.error,
              ),
            ),
            value: _activo,
            onChanged: (bool value) {
              setState(() => _activo = value);
            },
            activeThumbColor: AppColors.success,
          ),
        ),
      ],
    );
  }

  Future<void> _selectFecha(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _fecha,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null && picked != _fecha) {
      setState(() => _fecha = picked);
    }
  }

  Color _getTipoColor(String tipo) {
    switch (tipo) {
      case 'FESTIVO':
        return AppColors.success;
      case 'EXCEPCION':
        return AppColors.warning;
      case 'ESPECIAL':
        return AppColors.info;
      default:
        return AppColors.gray400;
    }
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final ExcepcionFestivoEntity item = ExcepcionFestivoEntity(
      id: widget.item?.id ?? const Uuid().v4(),
      nombre: _nombreController.text.trim(),
      fecha: _fecha,
      tipo: _tipo,
      descripcion: _descripcionController.text.trim().isNotEmpty
          ? _descripcionController.text.trim()
          : null,
      afectaDotaciones: _afectaDotaciones,
      repetirAnualmente: _repetirAnualmente,
      activo: _activo,
      createdAt: widget.item?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
      createdBy: widget.item?.createdBy,
      updatedBy: widget.item?.updatedBy,
    );

    debugPrint('💾 Guardando excepción/festivo: ${item.nombre}');

    if (_isEditing) {
      context.read<ExcepcionesFestivosBloc>().add(ExcepcionFestivoUpdateRequested(item));
    } else {
      context.read<ExcepcionesFestivosBloc>().add(ExcepcionFestivoCreateRequested(item));
    }

    Navigator.of(context).pop();
  }
}
