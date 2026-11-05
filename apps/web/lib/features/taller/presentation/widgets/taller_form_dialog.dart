import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
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
    return TallerFormDialogShell(
      formKey: _formKey,
      header: TallerFormHeader(
        icon: Icons.construction,
        color: AppColors.warning,
        title: _isEditing ? 'Editar Taller' : 'Nuevo Taller',
        subtitle: _isEditing ? 'Modifica los datos del taller' : 'Registra un nuevo taller mecánico',
      ),
      fields: _TallerFormFields(
        nombreController: _nombreController,
        nifController: _nifController,
        especialidadController: _especialidadController,
        contacto: _contacto,
        tipo: _tipo,
        activo: _activo,
        onTipoChanged: (TipoTaller value) => setState(() => _tipo = value),
        onActivoChanged: (bool value) => setState(() => _activo = value),
      ),
      actions: TallerFormActions(isSaving: _isSaving, isEditing: _isEditing, onSave: _onSave),
    );
  }
}

class _TallerFormFields extends StatelessWidget {
  const _TallerFormFields({
    required this.nombreController,
    required this.nifController,
    required this.especialidadController,
    required this.contacto,
    required this.tipo,
    required this.activo,
    required this.onTipoChanged,
    required this.onActivoChanged,
  });

  final TextEditingController nombreController;
  final TextEditingController nifController;
  final TextEditingController especialidadController;
  final DatosContactoControllers contacto;
  final TipoTaller tipo;
  final bool activo;
  final ValueChanged<TipoTaller> onTipoChanged;
  final ValueChanged<bool> onActivoChanged;

  static const SizedBox _hGap = SizedBox(width: AppSizes.spacingMedium);
  static const SizedBox _vGap = SizedBox(height: AppSizes.spacingMedium);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              flex: 3,
              child: TallerFormField(
                controller: nombreController,
                label: 'Nombre *',
                hint: 'Taller Mecánico García S.L.',
                icon: Icons.business,
                isRequired: true,
              ),
            ),
            _hGap,
            Expanded(
              flex: 2,
              child: TallerFormField(
                controller: nifController,
                label: 'NIF/CIF',
                hint: 'B12345678',
                icon: Icons.badge_outlined,
              ),
            ),
          ],
        ),
        _vGap,
        Row(
          children: <Widget>[
            Expanded(
              child: TallerTipoDropdown<TipoTaller>(
                label: 'Tipo de taller *',
                value: tipo,
                values: TipoTaller.values,
                labelOf: (TipoTaller t) => t.displayName,
                onChanged: onTipoChanged,
              ),
            ),
            _hGap,
            Expanded(
              child: TallerFormField(
                controller: especialidadController,
                label: 'Especialidad',
                hint: 'Mecánica general',
                icon: Icons.build_outlined,
              ),
            ),
          ],
        ),
        _vGap,
        DatosContactoFields(
          controllers: contacto,
          emailHint: 'taller@ejemplo.com',
          contactoHint: 'Juan García',
        ),
        _vGap,
        TallerActivoSwitch(
          value: activo,
          title: 'Taller activo',
          activeText: 'El taller está operativo',
          inactiveText: 'El taller está inactivo',
          onChanged: onActivoChanged,
        ),
      ],
    );
  }
}
