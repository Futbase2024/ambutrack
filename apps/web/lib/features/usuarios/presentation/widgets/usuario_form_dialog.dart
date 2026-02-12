import 'dart:math';

import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/widgets/buttons/app_button.dart';
import 'package:ambutrack_web/core/widgets/dialogs/app_dialog.dart';
import 'package:ambutrack_web/core/widgets/dropdowns/app_dropdown.dart';
import 'package:ambutrack_web/core/widgets/dropdowns/app_searchable_dropdown.dart';
import 'package:ambutrack_web/core/widgets/handlers/crud_operation_handler.dart';
import 'package:ambutrack_web/core/widgets/loading/app_loading_indicator.dart';
import 'package:ambutrack_web/features/auth/domain/entities/user_entity.dart';
import 'package:ambutrack_web/features/usuarios/presentation/bloc/usuarios_bloc.dart';
import 'package:ambutrack_web/features/usuarios/presentation/bloc/usuarios_event.dart';
import 'package:ambutrack_web/features/usuarios/presentation/bloc/usuarios_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

/// Diálogo para crear/editar usuarios
class UsuarioFormDialog extends StatefulWidget {
  const UsuarioFormDialog({super.key, this.usuario});

  final UserEntity? usuario;

  @override
  State<UsuarioFormDialog> createState() => _UsuarioFormDialogState();
}

class _UsuarioFormDialogState extends State<UsuarioFormDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late TextEditingController _dniController;
  late TextEditingController _nombreController;
  late TextEditingController _apellidosController;
  late TextEditingController _emailController;
  late TextEditingController _telefonoController;
  late TextEditingController _passwordController;

  late FocusNode _dniFocusNode;
  late FocusNode _nombreFocusNode;
  late FocusNode _apellidosFocusNode;
  late FocusNode _emailFocusNode;
  late FocusNode _telefonoFocusNode;
  late FocusNode _passwordFocusNode;

  String? _selectedRol;
  String? _selectedEmpresaId;
  bool _activo = true;
  bool _isSaving = false;
  bool _obscurePassword = true;
  bool _isLoadingEmpresas = false;

  List<Map<String, dynamic>> _empresas = <Map<String, dynamic>>[];

  bool get _isEditing => widget.usuario != null;

  // Roles disponibles
  static const List<Map<String, String>> _roles = <Map<String, String>>[
    <String, String>{'value': 'admin', 'label': 'Administrador'},
    <String, String>{'value': 'coordinador', 'label': 'Coordinador'},
    <String, String>{'value': 'conductor', 'label': 'Conductor'},
    <String, String>{'value': 'sanitario', 'label': 'Sanitario'},
    <String, String>{'value': 'jefe_personal', 'label': 'Jefe de Personal'},
    <String, String>{'value': 'gestor_flota', 'label': 'Gestor de Flota'},
  ];

  @override
  void initState() {
    super.initState();
    final UserEntity? user = widget.usuario;

    _dniController = TextEditingController(text: user?.dni ?? '');
    _nombreController = TextEditingController(text: _extractNombre(user?.displayName));
    _apellidosController = TextEditingController(text: _extractApellidos(user?.displayName));
    _emailController = TextEditingController(text: user?.email ?? '');
    _telefonoController = TextEditingController(text: user?.phoneNumber ?? '');
    _passwordController = TextEditingController();

    _dniFocusNode = FocusNode();
    _nombreFocusNode = FocusNode();
    _apellidosFocusNode = FocusNode();
    _emailFocusNode = FocusNode();
    _telefonoFocusNode = FocusNode();
    _passwordFocusNode = FocusNode();

    _selectedRol = user?.rol;
    _selectedEmpresaId = user?.empresaId;
    _activo = user?.activo ?? true;

    _loadEmpresas();
  }

  /// Extrae el nombre del displayName (primera palabra)
  String _extractNombre(String? displayName) {
    if (displayName == null || displayName.isEmpty) {
      return '';
    }
    final List<String> parts = displayName.split(' ');
    return parts.isNotEmpty ? parts[0] : '';
  }

  /// Extrae los apellidos del displayName (palabras después de la primera)
  String _extractApellidos(String? displayName) {
    if (displayName == null || displayName.isEmpty) {
      return '';
    }
    final List<String> parts = displayName.split(' ');
    return parts.length > 1 ? parts.sublist(1).join(' ') : '';
  }

  /// Carga las empresas desde Supabase
  Future<void> _loadEmpresas() async {
    setState(() => _isLoadingEmpresas = true);

    try {
      final SupabaseClient supabase = Supabase.instance.client;
      final List<dynamic> response = await supabase
          .from('empresas')
          .select('id, nombre')
          .eq('activo', true)
          .order('nombre');

      setState(() {
        _empresas = response.cast<Map<String, dynamic>>();
        _isLoadingEmpresas = false;
      });
    } catch (e) {
      debugPrint('❌ Error al cargar empresas: $e');
      setState(() => _isLoadingEmpresas = false);
    }
  }

  @override
  void dispose() {
    _dniController.dispose();
    _nombreController.dispose();
    _apellidosController.dispose();
    _emailController.dispose();
    _telefonoController.dispose();
    _passwordController.dispose();
    _dniFocusNode.dispose();
    _nombreFocusNode.dispose();
    _apellidosFocusNode.dispose();
    _emailFocusNode.dispose();
    _telefonoFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<UsuariosBloc, UsuariosState>(
      listener: (BuildContext context, UsuariosState state) {
        if (state is UsuariosCreated && _isSaving) {
          CrudOperationHandler.handleSuccess(
            context: context,
            isSaving: _isSaving,
            isEditing: _isEditing,
            entityName: 'Usuario',
            onClose: () {
              if (mounted) {
                setState(() => _isSaving = false);
              }
            },
          );
        } else if (state is UsuariosUpdated && _isSaving) {
          CrudOperationHandler.handleSuccess(
            context: context,
            isSaving: _isSaving,
            isEditing: _isEditing,
            entityName: 'Usuario',
            onClose: () {
              if (mounted) {
                setState(() => _isSaving = false);
              }
            },
          );
        } else if (state is UsuariosError && _isSaving) {
          CrudOperationHandler.handleError(
            context: context,
            isSaving: _isSaving,
            isEditing: _isEditing,
            entityName: 'Usuario',
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
        title: _isEditing ? 'Editar Usuario' : 'Nuevo Usuario',
        icon: _isEditing ? Icons.edit : Icons.person_add,
        type: _isEditing ? AppDialogType.edit : AppDialogType.create,
        maxWidth: 700,
        content: _isLoadingEmpresas
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(AppSizes.paddingXl),
                  child: AppLoadingIndicator(message: 'Cargando empresas...'),
                ),
              )
            : Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    // Fila 1: DNI y Nombre
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: _buildTextField(
                            controller: _dniController,
                            label: 'DNI *',
                            hint: 'Ej: 12345678A',
                            icon: Icons.badge,
                            focusNode: _dniFocusNode,
                            nextFocusNode: _nombreFocusNode,
                            validator: _validateDNI,
                            textCapitalization: TextCapitalization.characters,
                          ),
                        ),
                        const SizedBox(width: AppSizes.spacing),
                        Expanded(
                          child: _buildTextField(
                            controller: _nombreController,
                            label: 'Nombre *',
                            hint: 'Ej: Juan',
                            icon: Icons.person,
                            focusNode: _nombreFocusNode,
                            nextFocusNode: _apellidosFocusNode,
                            validator: (String? value) {
                              if (value == null || value.isEmpty) {
                                return 'El nombre es obligatorio';
                              }
                              return null;
                            },
                            textCapitalization: TextCapitalization.words,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSizes.spacing),

                    // Fila 2: Apellidos
                    _buildTextField(
                      controller: _apellidosController,
                      label: 'Apellidos *',
                      hint: 'Ej: Pérez García',
                      icon: Icons.person_outline,
                      focusNode: _apellidosFocusNode,
                      nextFocusNode: _emailFocusNode,
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return 'Los apellidos son obligatorios';
                        }
                        return null;
                      },
                      textCapitalization: TextCapitalization.words,
                    ),
                    const SizedBox(height: AppSizes.spacing),

                    // Fila 3: Email y Teléfono
                    Row(
                      children: <Widget>[
                        Expanded(
                          flex: 2,
                          child: _buildTextField(
                            controller: _emailController,
                            label: 'Email *',
                            hint: 'usuario@ejemplo.com',
                            icon: Icons.email,
                            focusNode: _emailFocusNode,
                            nextFocusNode: _telefonoFocusNode,
                            validator: _validateEmail,
                            keyboardType: TextInputType.emailAddress,
                            enabled: !_isEditing, // No se puede cambiar en edición
                          ),
                        ),
                        const SizedBox(width: AppSizes.spacing),
                        Expanded(
                          child: _buildTextField(
                            controller: _telefonoController,
                            label: 'Teléfono',
                            hint: '+34 600 00 00 00',
                            icon: Icons.phone,
                            focusNode: _telefonoFocusNode,
                            nextFocusNode: _isEditing ? null : _passwordFocusNode,
                            keyboardType: TextInputType.phone,
                            textInputAction: _isEditing ? TextInputAction.done : TextInputAction.next,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSizes.spacing),

                    // Contraseña (solo al crear)
                    if (!_isEditing) ...<Widget>[
                      _buildPasswordField(),
                      const SizedBox(height: AppSizes.spacing),
                    ],

                    // Fila 4: Rol y Empresa
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: _buildRolDropdown(),
                        ),
                        const SizedBox(width: AppSizes.spacing),
                        Expanded(
                          child: _buildEmpresaDropdown(),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSizes.spacing),

                    // Estado activo
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
    TextCapitalization? textCapitalization,
    bool enabled = true,
  }) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      textInputAction: textInputAction ?? TextInputAction.next,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization ?? TextCapitalization.none,
      enabled: enabled,
      onFieldSubmitted: (_) {
        if (nextFocusNode != null) {
          nextFocusNode.requestFocus();
        }
      },
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: enabled ? AppColors.primary : AppColors.gray400),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          borderSide: const BorderSide(color: AppColors.gray300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          borderSide: const BorderSide(color: AppColors.gray300),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          borderSide: const BorderSide(color: AppColors.gray200),
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
        fillColor: enabled ? Colors.white : AppColors.gray50,
      ),
      validator: validator,
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      focusNode: _passwordFocusNode,
      obscureText: _obscurePassword,
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(
        labelText: 'Contraseña *',
        hintText: 'Mínimo 6 caracteres',
        prefixIcon: const Icon(Icons.lock, color: AppColors.primary),
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility : Icons.visibility_off,
                color: AppColors.gray600,
              ),
              onPressed: () {
                setState(() => _obscurePassword = !_obscurePassword);
              },
              tooltip: _obscurePassword ? 'Mostrar contraseña' : 'Ocultar contraseña',
            ),
            IconButton(
              icon: const Icon(Icons.refresh, color: AppColors.primary),
              onPressed: _generatePassword,
              tooltip: 'Generar contraseña',
            ),
          ],
        ),
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
      validator: (String? value) {
        if (value == null || value.isEmpty) {
          return 'La contraseña es obligatoria';
        }
        if (value.length < 6) {
          return 'La contraseña debe tener al menos 6 caracteres';
        }
        return null;
      },
    );
  }

  Widget _buildRolDropdown() {
    return AppDropdown<String>(
      value: _selectedRol,
      label: 'Rol *',
      hint: 'Seleccionar rol',
      prefixIcon: Icons.admin_panel_settings,
      items: _roles
          .map((Map<String, String> rol) => AppDropdownItem<String>(
                value: rol['value']!,
                label: rol['label']!,
              ))
          .toList(),
      onChanged: (String? value) {
        setState(() => _selectedRol = value);
      },
    );
  }

  Widget _buildEmpresaDropdown() {
    if (_empresas.isEmpty) {
      return TextFormField(
        enabled: false,
        decoration: InputDecoration(
          labelText: 'Empresa',
          hintText: 'No hay empresas disponibles',
          prefixIcon: const Icon(Icons.business, color: AppColors.gray400),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          ),
          filled: true,
          fillColor: AppColors.gray50,
        ),
      );
    }

    return AppSearchableDropdown<String>(
      value: _selectedEmpresaId,
      label: 'Empresa',
      hint: 'Seleccionar empresa',
      prefixIcon: Icons.business,
      items: _empresas
          .map((Map<String, dynamic> empresa) => AppSearchableDropdownItem<String>(
                value: empresa['id'] as String,
                label: empresa['nombre'] as String,
              ))
          .toList(),
      onChanged: (String? value) {
        setState(() => _selectedEmpresaId = value);
      },
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

  /// Valida formato de email
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'El email es obligatorio';
    }
    final RegExp emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value)) {
      return 'Email inválido';
    }
    return null;
  }

  /// Valida formato de DNI español
  String? _validateDNI(String? value) {
    if (value == null || value.isEmpty) {
      return 'El DNI es obligatorio';
    }

    final String dniUpper = value.toUpperCase().trim();
    final RegExp dniRegex = RegExp(r'^\d{8}[A-Z]$');

    if (!dniRegex.hasMatch(dniUpper)) {
      return 'Formato de DNI inválido (8 dígitos + letra)';
    }

    // Validar letra del DNI
    const String letras = 'TRWAGMYFPDXBNJZSQVHLCKE';
    final int numero = int.parse(dniUpper.substring(0, 8));
    final String letra = dniUpper[8];

    if (letras[numero % 23] != letra) {
      return 'La letra del DNI no es correcta';
    }

    return null;
  }

  /// Genera una contraseña segura aleatoria
  void _generatePassword() {
    const String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#\$%^&*';
    final Random rnd = Random.secure();
    final String password = String.fromCharCodes(
      Iterable<int>.generate(12, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))),
    );

    setState(() {
      _passwordController.text = password;
      _obscurePassword = false; // Mostrar la contraseña generada
    });

    // Copiar al portapapeles
    Clipboard.setData(ClipboardData(text: password));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Contraseña generada y copiada al portapapeles'),
        backgroundColor: AppColors.success,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validar rol manualmente (AppDropdown no tiene validator)
    if (_selectedRol == null || _selectedRol!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El rol es obligatorio'),
          backgroundColor: AppColors.error,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final String displayName = '${_nombreController.text.trim()} ${_apellidosController.text.trim()}';

    if (_isEditing) {
      // Actualizar usuario existente
      final UserEntity updatedUser = UserEntity(
        uid: widget.usuario!.uid,
        email: widget.usuario!.email, // No se puede cambiar
        displayName: displayName,
        phoneNumber: _telefonoController.text.trim().isEmpty ? null : _telefonoController.text.trim(),
        emailVerified: widget.usuario!.emailVerified,
        createdAt: widget.usuario!.createdAt,
        lastLoginAt: widget.usuario!.lastLoginAt,
        empresaId: _selectedEmpresaId,
        empresaNombre: _empresas.firstWhere(
          (Map<String, dynamic> e) => e['id'] == _selectedEmpresaId,
          orElse: () => <String, dynamic>{'nombre': null},
        )['nombre'] as String?,
        rol: _selectedRol,
        activo: _activo,
        dni: _dniController.text.trim().toUpperCase(),
      );

      setState(() => _isSaving = true);

      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(AppSizes.paddingXl),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
              ),
              child: const AppLoadingIndicator(
                message: 'Actualizando usuario...',
                color: AppColors.secondary,
                icon: Icons.edit,
              ),
            ),
          );
        },
      );

      debugPrint('🔄 Actualizando usuario: ${updatedUser.email}');
      context.read<UsuariosBloc>().add(UsuariosUpdateRequested(updatedUser));
    } else {
      // Crear nuevo usuario
      final String password = _passwordController.text.trim();

      final UserEntity newUser = UserEntity(
        uid: const Uuid().v4(), // Temporal, se sobrescribirá con el UID de auth
        email: _emailController.text.trim(),
        displayName: displayName,
        phoneNumber: _telefonoController.text.trim().isEmpty ? null : _telefonoController.text.trim(),
        emailVerified: false,
        createdAt: DateTime.now(),
        empresaId: _selectedEmpresaId,
        empresaNombre: _selectedEmpresaId != null
            ? _empresas.firstWhere(
                (Map<String, dynamic> e) => e['id'] == _selectedEmpresaId,
                orElse: () => <String, dynamic>{'nombre': null},
              )['nombre'] as String?
            : null,
        rol: _selectedRol,
        activo: _activo,
        dni: _dniController.text.trim().toUpperCase(),
      );

      setState(() => _isSaving = true);

      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(AppSizes.paddingXl),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
              ),
              child: const AppLoadingIndicator(
                message: 'Creando usuario...',
                color: AppColors.primary,
                icon: Icons.person_add,
              ),
            ),
          );
        },
      );

      debugPrint('➕ Creando nuevo usuario: ${newUser.email}');
      context.read<UsuariosBloc>().add(UsuariosCreateRequested(newUser, password));
    }
  }
}
