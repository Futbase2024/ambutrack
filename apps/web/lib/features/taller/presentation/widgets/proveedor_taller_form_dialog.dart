import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/widgets/gestion/form/gestion_form.dart';
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
    return GestionFormDialog(
      title: _isEditing ? 'Editar proveedor' : 'Nuevo proveedor',
      subtitle: _isEditing ? widget.proveedor!.nombre : null,
      icon: Icons.local_shipping_outlined,
      formKey: _formKey,
      isEditing: _isEditing,
      isSaving: _isSaving,
      onSave: _onSave,
      children: <Widget>[
        const GestionFormSection(title: 'Datos generales', first: true),
        TallerDatosGeneralesFields<TipoProveedor>(
          nombre: _nombreController,
          nombreHint: 'Recambios López S.L.',
          nif: _nifController,
          tipo: _tipo,
          tipos: gestionOptionsOf<TipoProveedor>(TipoProveedor.values, (TipoProveedor t) => t.displayName),
          tipoLabel: 'Tipo',
          onTipoChanged: (TipoProveedor value) => setState(() => _tipo = value),
          extra: _formaPagoController,
          extraLabel: 'Forma de pago',
          extraHint: 'Transferencia 30 días',
          activo: _activo,
          activoText: 'Proveedor operativo',
          onActivoChanged: (bool value) => setState(() => _activo = value),
        ),
        DatosContactoFields(
          controllers: _contacto,
          emailHint: 'proveedor@ejemplo.com',
          contactoHint: 'María López',
        ),
      ],
    );
  }
}
