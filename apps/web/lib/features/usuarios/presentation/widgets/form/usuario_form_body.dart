import 'package:ambutrack_web/core/widgets/gestion/form/gestion_form.dart';
import 'package:ambutrack_web/features/usuarios/presentation/widgets/form/password_form_field.dart';
import 'package:ambutrack_web/features/usuarios/presentation/widgets/form/usuario_form_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Campos del formulario de usuario
class UsuarioFormBody extends StatelessWidget {
  const UsuarioFormBody({
    required this.data,
    required this.isEditing,
    required this.roles,
    required this.empresas,
    required this.isLoadingRoles,
    required this.onGeneratePassword,
    required this.onChanged,
    super.key,
  });

  final UsuarioFormData data;
  final bool isEditing;
  final List<Map<String, dynamic>> roles;
  final List<Map<String, dynamic>> empresas;
  final bool isLoadingRoles;
  final VoidCallback onGeneratePassword;

  /// Notifica cambios para que el diálogo se reconstruya
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const GestionFormSection(title: 'Datos personales', first: true),
        GestionFormColumns(
          children: <Widget>[
            GestionFormRow(
              label: 'DNI',
              required: true,
              child: GestionTextField(
                controller: data.dni,
                hint: 'Ej: 12345678A',
                validator: UsuarioFormValidators.dni,
                inputFormatters: <TextInputFormatter>[_UpperCaseFormatter()],
              ),
            ),
            GestionFormRow(
              label: 'Nombre',
              required: true,
              child: GestionTextField(
                controller: data.nombre,
                hint: 'Ej: Juan',
                validator: UsuarioFormValidators.nombre,
              ),
            ),
          ],
        ),
        GestionFormRow(
          label: 'Apellidos',
          required: true,
          child: GestionTextField(
            controller: data.apellidos,
            hint: 'Ej: Pérez García',
            validator: UsuarioFormValidators.apellidos,
          ),
        ),
        const GestionFormSection(title: 'Contacto y acceso'),
        GestionFormColumns(
          children: <Widget>[
            GestionFormRow(
              label: 'Email',
              required: true,
              child: GestionTextField(
                controller: data.email,
                hint: 'usuario@ejemplo.com',
                keyboardType: TextInputType.emailAddress,
                validator: UsuarioFormValidators.email,
                enabled: !isEditing, // No se puede cambiar en edición
              ),
            ),
            GestionFormRow(
              label: 'Teléfono',
              child: GestionTextField(
                controller: data.telefono,
                hint: '+34 600 00 00 00',
                keyboardType: TextInputType.phone,
              ),
            ),
          ],
        ),
        if (!isEditing)
          GestionFormColumns(
            children: <Widget>[
              GestionFormRow(
                label: 'Contraseña',
                required: true,
                child: PasswordFormField(
                  controller: data.password,
                  hint: 'Mínimo 6 caracteres',
                  validator: UsuarioFormValidators.password,
                  visible: data.passwordVisible,
                  onVisibleChanged: (bool v) => _set(() => data.passwordVisible = v),
                  actions: <PasswordFieldAction>[
                    PasswordFieldAction(
                      icon: Icons.refresh,
                      tooltip: 'Generar contraseña',
                      onPressed: onGeneratePassword,
                    ),
                  ],
                ),
              ),
              const SizedBox.shrink(),
            ],
          ),
        const GestionFormSection(title: 'Permisos'),
        GestionFormColumns(
          children: <Widget>[
            GestionFormRow(
              label: 'Rol',
              required: true,
              child: _RolField(data: data, roles: roles, isLoading: isLoadingRoles, onChanged: onChanged),
            ),
            GestionFormRow(
              label: 'Empresa',
              child: _EmpresaField(data: data, empresas: empresas, onChanged: onChanged),
            ),
          ],
        ),
        GestionFormColumns(
          children: <Widget>[
            GestionFormRow(
              label: 'Estado',
              child: GestionSwitchField(
                value: data.activo,
                text: data.activo ? 'Activo' : 'Inactivo',
                onChanged: (bool v) => _set(() => data.activo = v),
              ),
            ),
            const SizedBox.shrink(),
          ],
        ),
      ],
    );
  }

  void _set(VoidCallback change) {
    change();
    onChanged();
  }
}

class _RolField extends StatelessWidget {
  const _RolField({required this.data, required this.roles, required this.isLoading, required this.onChanged});

  final UsuarioFormData data;
  final List<Map<String, dynamic>> roles;
  final bool isLoading;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const GestionFormReadOnly(value: 'Cargando roles…');
    }
    final List<GestionOption<String>> options = roles
        .map((Map<String, dynamic> r) => r['nombre'] as String)
        .map((String n) => GestionOption<String>(n, UsuarioFormValidators.rolLabel(n)))
        .toList();
    void onSelect(String? v) {
      data.rol = v;
      onChanged();
    }

    if (options.length > 10) {
      return GestionSearchField<String>(
        value: data.rol,
        options: options,
        required: true,
        hint: 'Seleccionar rol',
        onChanged: onSelect,
      );
    }
    final bool exists = options.any((GestionOption<String> o) => o.value == data.rol);
    return GestionDropdownField<String>(
      value: exists ? data.rol : null,
      options: options,
      required: true,
      hint: 'Seleccionar rol',
      onChanged: onSelect,
    );
  }
}

class _EmpresaField extends StatelessWidget {
  const _EmpresaField({required this.data, required this.empresas, required this.onChanged});

  final UsuarioFormData data;
  final List<Map<String, dynamic>> empresas;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    if (empresas.isEmpty) {
      return const GestionFormReadOnly(value: 'No hay empresas disponibles');
    }
    return GestionSearchField<String>(
      value: data.empresaId,
      hint: 'Seleccionar empresa',
      options: empresas
          .map((Map<String, dynamic> e) => GestionOption<String>(e['id'] as String, e['nombre'] as String))
          .toList(),
      onChanged: (String? v) {
        data.empresaId = v;
        onChanged();
      },
    );
  }
}

/// Convierte a mayúsculas lo que se escribe (DNI)
class _UpperCaseFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    return newValue.copyWith(text: newValue.text.toUpperCase());
  }
}
