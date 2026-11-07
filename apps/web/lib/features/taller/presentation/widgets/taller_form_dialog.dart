import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/widgets/gestion/form/gestion_form.dart';
import 'package:ambutrack_web/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ambutrack_web/features/auth/presentation/bloc/auth_state.dart';
import 'package:ambutrack_web/features/taller/presentation/bloc/taller_bloc.dart';
import 'package:ambutrack_web/features/taller/presentation/bloc/taller_event.dart';
import 'package:ambutrack_web/features/taller/presentation/widgets/form/datos_contacto_fields.dart';
import 'package:ambutrack_web/features/taller/presentation/widgets/form/taller_form_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

/// Diálogo de formulario para crear/editar Taller
class TallerFormDialog extends StatefulWidget {
  const TallerFormDialog({super.key, this.taller});

  final TallerEntity? taller;

  @override
  State<TallerFormDialog> createState() => _TallerFormDialogState();
}

class _TallerFormDialogState extends State<TallerFormDialog> {
  static const String _empresaFallback = '00000000-0000-0000-0000-000000000001';

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _nifController = TextEditingController();
  final TextEditingController _especialidadController = TextEditingController();
  final DatosContactoControllers _contacto = DatosContactoControllers();

  TipoTaller _tipo = TipoTaller.propio;
  bool _activo = true;
  bool _isSaving = false;

  bool get _isEditing => widget.taller != null;

  @override
  void initState() {
    super.initState();
    final TallerEntity? taller = widget.taller;
    if (taller != null) {
      _nombreController.text = taller.nombre;
      _nifController.text = taller.nif ?? '';
      _especialidadController.text = taller.especialidad ?? '';
      _contacto.populate(
        direccion: taller.direccion,
        ciudad: taller.ciudad,
        provincia: taller.provincia,
        codigoPostal: taller.codigoPostal,
        telefono: taller.telefono,
        email: taller.email,
        contactoNombre: taller.contactoNombre,
        observaciones: taller.observaciones,
      );
      _tipo = taller.tipo;
      _activo = taller.activo;
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _nifController.dispose();
    _especialidadController.dispose();
    _contacto.dispose();
    super.dispose();
  }

  String _empresaId() {
    final AuthState authState = context.read<AuthBloc>().state;
    return authState is AuthAuthenticated
        ? (authState.user.empresaId ?? _empresaFallback)
        : _empresaFallback;
  }

  TallerEntity _buildEntity() {
    return TallerEntity(
      id: _isEditing ? widget.taller!.id : const Uuid().v4(),
      empresaId: _empresaId(),
      nombre: _nombreController.text.trim().toUpperCase(),
      nif: textOrNull(_nifController),
      direccion: textOrNull(_contacto.direccion),
      ciudad: textOrNull(_contacto.ciudad),
      provincia: textOrNull(_contacto.provincia),
      codigoPostal: textOrNull(_contacto.codigoPostal),
      telefono: textOrNull(_contacto.telefono),
      email: textOrNull(_contacto.email),
      contactoNombre: textOrNull(_contacto.contactoNombre),
      especialidad: textOrNull(_especialidadController),
      tipo: _tipo,
      activo: _activo,
      observaciones: textOrNull(_contacto.observaciones),
      createdAt: _isEditing ? widget.taller!.createdAt : DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() => _isSaving = true);

    final TallerEntity entity = _buildEntity();
    final TallerBloc bloc = context.read<TallerBloc>();
    if (_isEditing) {
      bloc.add(TallerUpdateRequested(taller: entity));
    } else {
      bloc.add(TallerCreateRequested(taller: entity));
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return GestionFormDialog(
      title: _isEditing ? 'Editar taller' : 'Nuevo taller',
      subtitle: _isEditing ? widget.taller!.nombre : null,
      icon: Icons.construction,
      formKey: _formKey,
      isEditing: _isEditing,
      isSaving: _isSaving,
      onSave: _onSave,
      children: <Widget>[
        const GestionFormSection(title: 'Datos generales', first: true),
        TallerDatosGeneralesFields<TipoTaller>(
          nombre: _nombreController,
          nombreHint: 'Taller Mecánico García S.L.',
          nif: _nifController,
          tipo: _tipo,
          tipos: gestionOptionsOf<TipoTaller>(TipoTaller.values, (TipoTaller t) => t.displayName),
          tipoLabel: 'Tipo',
          onTipoChanged: (TipoTaller value) => setState(() => _tipo = value),
          extra: _especialidadController,
          extraLabel: 'Especialidad',
          extraHint: 'Mecánica general',
          activo: _activo,
          activoText: 'Taller operativo',
          onActivoChanged: (bool value) => setState(() => _activo = value),
        ),
        DatosContactoFields(
          controllers: _contacto,
          emailHint: 'taller@ejemplo.com',
          contactoHint: 'Juan García',
        ),
      ],
    );
  }
}
