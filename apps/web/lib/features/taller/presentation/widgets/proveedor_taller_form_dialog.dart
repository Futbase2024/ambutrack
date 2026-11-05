import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ambutrack_web/features/auth/presentation/bloc/auth_state.dart';
import 'package:ambutrack_web/features/taller/presentation/bloc/proveedor_taller_bloc.dart';
import 'package:ambutrack_web/features/taller/presentation/bloc/proveedor_taller_event.dart';
import 'package:ambutrack_web/features/taller/presentation/widgets/form/datos_contacto_fields.dart';
import 'package:ambutrack_web/features/taller/presentation/widgets/form/taller_form_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

/// Diálogo de formulario para crear/editar Proveedor de Taller
class ProveedorTallerFormDialog extends StatefulWidget {
  const ProveedorTallerFormDialog({super.key, this.proveedor});

  final ProveedorTallerEntity? proveedor;

  @override
  State<ProveedorTallerFormDialog> createState() => _ProveedorTallerFormDialogState();
}

class _ProveedorTallerFormDialogState extends State<ProveedorTallerFormDialog> {
  static const String _empresaFallback = '00000000-0000-0000-0000-000000000001';

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _nifController = TextEditingController();
  final TextEditingController _formaPagoController = TextEditingController();
  final DatosContactoControllers _contacto = DatosContactoControllers();

  TipoProveedor _tipo = TipoProveedor.repuestos;
  bool _activo = true;
  bool _isSaving = false;

  bool get _isEditing => widget.proveedor != null;

  @override
  void initState() {
    super.initState();
    final ProveedorTallerEntity? proveedor = widget.proveedor;
    if (proveedor != null) {
      _nombreController.text = proveedor.nombre;
      _nifController.text = proveedor.nif ?? '';
      _formaPagoController.text = proveedor.formaPago ?? '';
      _contacto.populate(
        direccion: proveedor.direccion,
        ciudad: proveedor.ciudad,
        provincia: proveedor.provincia,
        codigoPostal: proveedor.codigoPostal,
        telefono: proveedor.telefono,
        email: proveedor.email,
        contactoNombre: proveedor.contactoNombre,
        observaciones: proveedor.observaciones,
      );
      _tipo = proveedor.tipo;
      _activo = proveedor.activo;
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _nifController.dispose();
    _formaPagoController.dispose();
    _contacto.dispose();
    super.dispose();
  }

  String _empresaId() {
    final AuthState authState = context.read<AuthBloc>().state;
    return authState is AuthAuthenticated
        ? (authState.user.empresaId ?? _empresaFallback)
        : _empresaFallback;
  }

  ProveedorTallerEntity _buildEntity() {
    return ProveedorTallerEntity(
      id: _isEditing ? widget.proveedor!.id : const Uuid().v4(),
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
      tipo: _tipo,
      formaPago: textOrNull(_formaPagoController),
      activo: _activo,
      observaciones: textOrNull(_contacto.observaciones),
      createdAt: _isEditing ? widget.proveedor!.createdAt : DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() => _isSaving = true);

    final ProveedorTallerEntity entity = _buildEntity();
    final ProveedorTallerBloc bloc = context.read<ProveedorTallerBloc>();
    if (_isEditing) {
      bloc.add(ProveedorTallerUpdateRequested(proveedor: entity));
    } else {
      bloc.add(ProveedorTallerCreateRequested(proveedor: entity));
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return TallerFormDialogShell(
      formKey: _formKey,
      header: TallerFormHeader(
        icon: Icons.local_shipping,
        color: AppColors.info,
        title: _isEditing ? 'Editar Proveedor' : 'Nuevo Proveedor',
        subtitle: _isEditing
            ? 'Modifica los datos del proveedor'
            : 'Registra un nuevo proveedor de repuestos o servicios',
      ),
      fields: _ProveedorFormFields(
        nombreController: _nombreController,
        nifController: _nifController,
        formaPagoController: _formaPagoController,
        contacto: _contacto,
        tipo: _tipo,
        activo: _activo,
        onTipoChanged: (TipoProveedor value) => setState(() => _tipo = value),
        onActivoChanged: (bool value) => setState(() => _activo = value),
      ),
      actions: TallerFormActions(isSaving: _isSaving, isEditing: _isEditing, onSave: _onSave),
    );
  }
}

class _ProveedorFormFields extends StatelessWidget {
  const _ProveedorFormFields({
    required this.nombreController,
    required this.nifController,
    required this.formaPagoController,
    required this.contacto,
    required this.tipo,
    required this.activo,
    required this.onTipoChanged,
    required this.onActivoChanged,
  });

  final TextEditingController nombreController;
  final TextEditingController nifController;
  final TextEditingController formaPagoController;
  final DatosContactoControllers contacto;
  final TipoProveedor tipo;
  final bool activo;
  final ValueChanged<TipoProveedor> onTipoChanged;
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
                hint: 'Recambios López S.L.',
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
              child: TallerTipoDropdown<TipoProveedor>(
                label: 'Tipo de proveedor *',
                value: tipo,
                values: TipoProveedor.values,
                labelOf: (TipoProveedor t) => t.displayName,
                onChanged: onTipoChanged,
              ),
            ),
            _hGap,
            Expanded(
              child: TallerFormField(
                controller: formaPagoController,
                label: 'Forma de Pago',
                hint: 'Transferencia 30 días',
                icon: Icons.payment_outlined,
              ),
            ),
          ],
        ),
        _vGap,
        DatosContactoFields(
          controllers: contacto,
          emailHint: 'proveedor@ejemplo.com',
          contactoHint: 'María López',
        ),
        _vGap,
        TallerActivoSwitch(
          value: activo,
          title: 'Proveedor activo',
          activeText: 'El proveedor está operativo',
          inactiveText: 'El proveedor está inactivo',
          onChanged: onActivoChanged,
        ),
      ],
    );
  }
}
