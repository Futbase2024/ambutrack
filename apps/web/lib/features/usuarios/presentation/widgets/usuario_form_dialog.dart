import 'dart:async';

import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/auth/enums/user_role.dart';
import 'package:ambutrack_web/core/auth/permissions/gestion_usuarios_permissions.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/form/gestion_form.dart';
import 'package:ambutrack_web/core/widgets/handlers/crud_operation_handler.dart';
import 'package:ambutrack_web/core/widgets/loading/app_loading_indicator.dart';
import 'package:ambutrack_web/features/usuarios/presentation/bloc/usuarios_bloc.dart';
import 'package:ambutrack_web/features/usuarios/presentation/bloc/usuarios_event.dart';
import 'package:ambutrack_web/features/usuarios/presentation/bloc/usuarios_state.dart';
import 'package:ambutrack_web/features/usuarios/presentation/widgets/form/usuario_form_body.dart';
import 'package:ambutrack_web/features/usuarios/presentation/widgets/form/usuario_form_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

/// Diálogo para crear/editar usuarios
class UsuarioFormDialog extends StatefulWidget {
  const UsuarioFormDialog({required this.rolActual, super.key, this.usuario});

  final UserEntity? usuario;

  /// Rol de quien crea/edita: limita los roles asignables y la empresa
  final UserRole rolActual;

  @override
  State<UsuarioFormDialog> createState() => _UsuarioFormDialogState();
}

class _UsuarioFormDialogState extends State<UsuarioFormDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final UsuarioFormData _data = UsuarioFormData(original: widget.usuario);

  bool _isSaving = false;
  bool _isLoadingEmpresas = false;
  bool _isLoadingRoles = false;

  List<Map<String, dynamic>> _empresas = <Map<String, dynamic>>[];
  List<Map<String, dynamic>> _roles = <Map<String, dynamic>>[];

  bool get _isEditing => widget.usuario != null;

  @override
  void initState() {
    super.initState();
    _loadRoles();
    _loadEmpresas();
    if (!_isEditing) {
      // Clave provisional generada de inicio (PIN de 6 dígitos por defecto)
      _data.password.text = UsuarioFormData.generarPin();
      _data.passwordVisible = true;
    }
  }

  bool get _puedeElegirEmpresa => widget.rolActual == UserRole.admin;

  @override
  void dispose() {
    _data.dispose();
    super.dispose();
  }

  /// Carga las empresas desde Supabase
  Future<void> _loadEmpresas() async {
    setState(() => _isLoadingEmpresas = true);
    try {
      final List<dynamic> response = await Supabase.instance.client
          .from('empresas')
          .select('id, nombre')
          .eq('activo', true)
          .order('nombre');
      if (!mounted) {
        return;
      }
      setState(() {
        _empresas = response.cast<Map<String, dynamic>>();
        _isLoadingEmpresas = false;
      });
    } catch (e) {
      debugPrint('❌ Error al cargar empresas: $e');
      if (mounted) {
        setState(() => _isLoadingEmpresas = false);
      }
    }
  }

  /// Carga los roles desde la tabla 'roles' de Supabase
  Future<void> _loadRoles() async {
    setState(() => _isLoadingRoles = true);
    try {
      final List<dynamic> response =
          await Supabase.instance.client.from('roles').select('id, nombre, descripcion').order('nombre');
      if (!mounted) {
        return;
      }
      // Solo los roles que quien edita puede asignar
      final List<String> asignables = GestionUsuariosPermissions.rolesAsignables(
        widget.rolActual,
        response.cast<Map<String, dynamic>>().map((Map<String, dynamic> r) => r['nombre'] as String),
      );
      setState(() {
        _roles = response
            .cast<Map<String, dynamic>>()
            .where((Map<String, dynamic> r) => asignables.contains(r['nombre']))
            .toList();
        _isLoadingRoles = false;
      });
    } catch (e) {
      debugPrint('❌ Error al cargar roles: $e');
      if (mounted) {
        setState(() => _isLoadingRoles = false);
      }
    }
  }

  void _onBlocState(BuildContext context, UsuariosState state) {
    if (!_isSaving) {
      return;
    }
    void onClose() {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }

    if (state is UsuariosCreated || state is UsuariosUpdated) {
      CrudOperationHandler.handleSuccess(
        context: context,
        isSaving: _isSaving,
        isEditing: _isEditing,
        entityName: 'Usuario',
        onClose: onClose,
      );
    } else if (state is UsuariosError) {
      CrudOperationHandler.handleError(
        context: context,
        isSaving: _isSaving,
        isEditing: _isEditing,
        entityName: 'Usuario',
        errorMessage: state.message,
        onClose: onClose,
      );
    }
  }

  /// Genera un PIN o una contraseña segura, la muestra y la copia al portapapeles
  void _generatePassword() {
    final String password = _data.pinMovil ? UsuarioFormData.generarPin() : UsuarioFormData.generarPassword();
    setState(() {
      _data.password.text = password;
      _data.passwordVisible = true;
    });
    Clipboard.setData(ClipboardData(text: password));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Clave provisional generada y copiada al portapapeles'),
        backgroundColor: AppColors.success,
        duration: Duration(seconds: 2),
      ),
    );
  }

  String? get _empresaNombre {
    if (_data.empresaId == null) {
      return null;
    }
    return _empresas.firstWhere(
      (Map<String, dynamic> e) => e['id'] == _data.empresaId,
      orElse: () => <String, dynamic>{'nombre': null},
    )['nombre'] as String?;
  }

  Map<String, dynamic> get _metadata => <String, dynamic>{
        'nombre': _data.nombre.text.trim(),
        'apellidos': _data.apellidos.text.trim(),
        'empresaId': _puedeElegirEmpresa ? _data.empresaId : widget.usuario?.empresaId,
        'empresaNombre': _empresaNombre,
        'dni': _data.dni.text.trim().toUpperCase(),
      };

  void _showSavingOverlay() {
    unawaited(
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext _) => AppLoadingOverlay(
          message: _isEditing ? 'Actualizando usuario...' : 'Creando usuario...',
          color: _isEditing ? AppColors.secondary : AppColors.primary,
          icon: _isEditing ? Icons.edit : Icons.person_add,
        ),
      ),
    );
  }

  void _onSave() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    // El rol es obligatorio (también lo valida el propio campo)
    if (_data.rol == null || _data.rol!.isEmpty) {
      return;
    }
    final List<String> roles = <String>[_data.rol!];

    setState(() => _isSaving = true);
    _showSavingOverlay();

    if (_isEditing) {
      final UserEntity original = widget.usuario!;
      final UserEntity updatedUser = UserEntity(
        id: original.id,
        email: original.email, // No se puede cambiar
        displayName: _data.displayName,
        phoneNumber: _data.telefonoValue,
        isEmailVerified: original.isEmailVerified,
        createdAt: original.createdAt,
        updatedAt: DateTime.now(),
        isActive: _data.activo,
        roles: roles,
        metadata: _metadata,
      );
      debugPrint('🔄 Actualizando usuario: ${updatedUser.email}');
      context.read<UsuariosBloc>().add(UsuariosUpdateRequested(updatedUser));
    } else {
      final String password = _data.password.text.trim();
      final UserEntity newUser = UserEntity(
        id: const Uuid().v4(), // Temporal, se sobrescribirá con el ID de auth
        email: _data.email.text.trim(),
        displayName: _data.displayName,
        phoneNumber: _data.telefonoValue,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isActive: _data.activo,
        roles: roles,
        metadata: _metadata,
      );
      debugPrint('➕ Creando nuevo usuario: ${newUser.email}');
      context.read<UsuariosBloc>().add(UsuariosCreateRequested(newUser, password));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<UsuariosBloc, UsuariosState>(
      listener: _onBlocState,
      child: GestionFormDialog(
        title: _isEditing ? 'Editar usuario' : 'Nuevo usuario',
        subtitle: _isEditing ? (widget.usuario!.displayName ?? widget.usuario!.email) : null,
        icon: _isEditing ? Icons.manage_accounts_outlined : Icons.person_add_alt_1_outlined,
        formKey: _formKey,
        isEditing: _isEditing,
        isSaving: _isSaving,
        saveLabel: _isEditing ? 'Actualizar' : 'Crear',
        onSave: _onSave,
        children: <Widget>[
          if (_isLoadingEmpresas)
            const Padding(
              padding: EdgeInsets.all(32),
              child: AppLoadingIndicator(message: 'Cargando empresas...'),
            )
          else
            UsuarioFormBody(
              data: _data,
              isEditing: _isEditing,
              roles: _roles,
              empresas: _empresas,
              isLoadingRoles: _isLoadingRoles,
              puedeElegirEmpresa: _puedeElegirEmpresa,
              onGeneratePassword: _generatePassword,
              onChanged: () => setState(() {}),
            ),
        ],
      ),
    );
  }
}
