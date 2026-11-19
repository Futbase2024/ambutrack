import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/widgets/dialogs/result_dialog.dart';
import 'package:ambutrack_web/core/widgets/gestion/form/gestion_form.dart';
import 'package:ambutrack_web/features/agenda_pendientes/presentation/bloc/agenda_pendiente_bloc.dart';
import 'package:ambutrack_web/features/agenda_pendientes/presentation/bloc/agenda_pendiente_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
    return GestionFormDialog(
      title: _isEditing ? 'Editar pendiente' : 'Nuevo pendiente',
      subtitle: _isEditing ? widget.pendiente!.nombreApellidos : null,
      icon: Icons.event_note_outlined,
      formKey: _formKey,
      isEditing: _isEditing,
      isSaving: _isSaving,
      onSave: _onSave,
      children: <Widget>[
        _FormContent(
          nombreController: _nombreController,
          domicilioController: _domicilioController,
          localidadController: _localidadController,
          descripcionController: _descripcionController,
          fechaSeleccionada: _fechaSeleccionada,
          onFechaChanged: (DateTime? fecha) {
            if (fecha != null) {
              setState(() => _fechaSeleccionada = fecha);
            }
          },
        ),
      ],
    );
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_fechaSeleccionada == null) {
      showResultDialog(
        context: context,
        title: 'Datos incompletos',
        message: 'La fecha es obligatoria',
        type: ResultType.warning,
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
    required this.nombreController,
    required this.domicilioController,
    required this.localidadController,
    required this.descripcionController,
    required this.fechaSeleccionada,
    required this.onFechaChanged,
  });

  final TextEditingController nombreController;
  final TextEditingController domicilioController;
  final TextEditingController localidadController;
  final TextEditingController descripcionController;
  final DateTime? fechaSeleccionada;
  final ValueChanged<DateTime?> onFechaChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const GestionFormSection(title: 'Contacto', first: true),
        GestionFormRow(
          label: 'Nombre',
          required: true,
          child: GestionTextField(
            controller: nombreController,
            hint: 'Nombre y apellidos del contacto',
            validator: GestionFormStyle.requerido,
          ),
        ),
        GestionFormColumns(
          children: <Widget>[
            GestionFormRow(
              label: 'Domicilio',
              child: GestionTextField(controller: domicilioController, hint: 'Dirección'),
            ),
            GestionFormRow(
              label: 'Localidad',
              child: GestionTextField(controller: localidadController, hint: 'Localidad'),
            ),
          ],
        ),
        const GestionFormSection(title: 'Servicio'),
        GestionFormColumns(
          children: <Widget>[
            GestionFormRow(
              label: 'Fecha',
              required: true,
              child: GestionDateField(
                value: fechaSeleccionada,
                required: true,
                firstDate: DateTime(2024),
                lastDate: DateTime(2030),
                onChanged: onFechaChanged,
              ),
            ),
            const SizedBox.shrink(),
          ],
        ),
        GestionFormRow(
          label: 'Descripción',
          required: true,
          multiline: true,
          child: GestionTextField(
            controller: descripcionController,
            hint: 'Describe el servicio pendiente',
            maxLines: 4,
            validator: GestionFormStyle.requerido,
          ),
        ),
      ],
    );
  }
}
