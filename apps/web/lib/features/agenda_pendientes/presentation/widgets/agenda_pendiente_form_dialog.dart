import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/widgets/dialogs/app_dialog.dart';
import 'package:ambutrack_web/features/agenda_pendientes/presentation/bloc/agenda_pendiente_bloc.dart';
import 'package:ambutrack_web/features/agenda_pendientes/presentation/bloc/agenda_pendiente_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Muestra el diálogo de formulario para crear/editar un pendiente
Future<void> showAgendaPendienteFormDialog({
  required BuildContext context,
  required String empresaId,
  AgendaPendienteEntity? pendiente,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext dialogContext) {
      return BlocProvider<AgendaPendienteBloc>.value(
        value: context.read<AgendaPendienteBloc>(),
        child: _AgendaPendienteFormDialog(
          empresaId: empresaId,
          pendiente: pendiente,
        ),
      );
    },
  );
}

class _AgendaPendienteFormDialog extends StatefulWidget {
  const _AgendaPendienteFormDialog({
    required this.empresaId,
    this.pendiente,
  });

  final String empresaId;
  final AgendaPendienteEntity? pendiente;

  @override
  State<_AgendaPendienteFormDialog> createState() =>
      _AgendaPendienteFormDialogState();
}

class _AgendaPendienteFormDialogState
    extends State<_AgendaPendienteFormDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _nombreController;
  late final TextEditingController _domicilioController;
  late final TextEditingController _localidadController;
  late final TextEditingController _descripcionController;
  DateTime? _fechaSeleccionada;
  bool _isSaving = false;

  bool get _isEditing => widget.pendiente != null;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(
      text: widget.pendiente?.nombreApellidos ?? '',
    );
    _domicilioController = TextEditingController(
      text: widget.pendiente?.domicilio ?? '',
    );
    _localidadController = TextEditingController(
      text: widget.pendiente?.localidad ?? '',
    );
    _descripcionController = TextEditingController(
      text: widget.pendiente?.descripcion ?? '',
    );
    _fechaSeleccionada = widget.pendiente?.fecha;
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _domicilioController.dispose();
    _localidadController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppDialog(
      title: _isEditing ? 'Editar Pendiente' : 'Nuevo Pendiente',
      icon: Icons.event_note,
      type: _isEditing ? AppDialogType.edit : AppDialogType.create,
      content: _FormContent(
        formKey: _formKey,
        nombreController: _nombreController,
        domicilioController: _domicilioController,
        localidadController: _localidadController,
        descripcionController: _descripcionController,
        fechaSeleccionada: _fechaSeleccionada,
        onFechaTap: _seleccionarFecha,
      ),
      actions: <Widget>[
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
          child: Text(
            'Cancelar',
            style: GoogleFonts.inter(
              color: AppColors.gray600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: _isSaving ? null : _onSave,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: _isSaving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(
                  _isEditing ? 'Actualizar' : 'Guardar',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                ),
        ),
      ],
    );
  }

  Future<void> _seleccionarFecha() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _fechaSeleccionada ?? DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
      locale: const Locale('es', 'ES'),
    );

    if (picked != null) {
      setState(() {
        _fechaSeleccionada = picked;
      });
    }
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_fechaSeleccionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La fecha es obligatoria'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    final String userId =
        Supabase.instance.client.auth.currentUser?.id ?? '';

    final AgendaPendienteEntity pendiente = AgendaPendienteEntity(
      id: widget.pendiente?.id ?? '',
      createdAt: widget.pendiente?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
      empresaId: widget.empresaId,
      nombreApellidos: _nombreController.text.trim().toUpperCase(),
      domicilio: _domicilioController.text.trim().isNotEmpty
          ? _domicilioController.text.trim()
          : null,
      localidad: _localidadController.text.trim().isNotEmpty
          ? _localidadController.text.trim()
          : null,
      fecha: _fechaSeleccionada!,
      descripcion: _descripcionController.text.trim(),
      completado: widget.pendiente?.completado ?? false,
      createdBy: userId,
    );

    if (_isEditing) {
      context.read<AgendaPendienteBloc>().add(
            AgendaPendienteUpdateRequested(pendiente: pendiente),
          );
    } else {
      context.read<AgendaPendienteBloc>().add(
            AgendaPendienteCreateRequested(pendiente: pendiente),
          );
    }

    Navigator.of(context).pop();
  }
}

/// Contenido del formulario
class _FormContent extends StatelessWidget {
  const _FormContent({
    required this.formKey,
    required this.nombreController,
    required this.domicilioController,
    required this.localidadController,
    required this.descripcionController,
    required this.fechaSeleccionada,
    required this.onFechaTap,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController nombreController;
  final TextEditingController domicilioController;
  final TextEditingController localidadController;
  final TextEditingController descripcionController;
  final DateTime? fechaSeleccionada;
  final VoidCallback onFechaTap;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Nombre y Apellidos (obligatorio)
            const _FormLabel(label: 'Nombre y Apellidos *'),
            const SizedBox(height: 4),
            TextFormField(
              controller: nombreController,
              textInputAction: TextInputAction.next,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.person_outline, size: 20),
                hintText: 'Nombre y apellidos del contacto',
              ),
              validator: (String? v) =>
                  (v == null || v.trim().isEmpty) ? 'Campo obligatorio' : null,
            ),
            const SizedBox(height: AppSizes.spacing),

            // Domicilio (opcional)
            const _FormLabel(label: 'Domicilio'),
            const SizedBox(height: 4),
            TextFormField(
              controller: domicilioController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.home_outlined, size: 20),
                hintText: 'Dirección (opcional)',
              ),
            ),
            const SizedBox(height: AppSizes.spacing),

            // Localidad (opcional)
            const _FormLabel(label: 'Localidad'),
            const SizedBox(height: 4),
            TextFormField(
              controller: localidadController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.location_city_outlined, size: 20),
                hintText: 'Localidad (opcional)',
              ),
            ),
            const SizedBox(height: AppSizes.spacing),

            // Fecha (obligatorio)
            const _FormLabel(label: 'Fecha del servicio *'),
            const SizedBox(height: 4),
            TextFormField(
              readOnly: true,
              onTap: onFechaTap,
              decoration: InputDecoration(
                prefixIcon:
                    const Icon(Icons.calendar_today_outlined, size: 20),
                hintText: 'Selecciona una fecha',
                suffixIcon: fechaSeleccionada != null
                    ? const Icon(Icons.check_circle, color: AppColors.success)
                    : null,
              ),
              controller: TextEditingController(
                text: fechaSeleccionada != null
                    ? _formatDate(fechaSeleccionada!)
                    : '',
              ),
            ),
            const SizedBox(height: AppSizes.spacing),

            // Descripción (obligatorio)
            const _FormLabel(label: 'Descripción *'),
            const SizedBox(height: 4),
            TextFormField(
              controller: descripcionController,
              textInputAction: TextInputAction.newline,
              minLines: 4,
              maxLines: 8,
              decoration: const InputDecoration(
                prefixIcon:
                    Padding(
                      padding: EdgeInsets.only(bottom: 24),
                      child: Icon(Icons.description_outlined, size: 20),
                    ),
                hintText: 'Describe el servicio pendiente...',
                alignLabelWithHint: true,
              ),
              validator: (String? v) =>
                  (v == null || v.trim().isEmpty) ? 'Campo obligatorio' : null,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}

/// Label de formulario con estilo consistente
class _FormLabel extends StatelessWidget {
  const _FormLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.gray700,
      ),
    );
  }
}
