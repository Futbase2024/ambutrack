import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Tarjeta con el formulario DNI + clave de 6 dígitos
class LoginFormCard extends StatefulWidget {
  const LoginFormCard({
    required this.formKey,
    required this.dniController,
    required this.passwordController,
    required this.passwordFocus,
    required this.isLoading,
    required this.onSubmit,
    required this.onOlvideClave,
    this.recordarDni,
    this.onRecordarDniChanged,
    super.key,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController dniController;
  final TextEditingController passwordController;
  final FocusNode passwordFocus;
  final bool isLoading;
  final VoidCallback onSubmit;
  final VoidCallback onOlvideClave;

  /// null = no se muestra la casilla (modo compartido)
  final bool? recordarDni;
  final ValueChanged<bool>? onRecordarDniChanged;

  @override
  State<LoginFormCard> createState() => _LoginFormCardState();
}

class _LoginFormCardState extends State<LoginFormCard> {
  bool _obscure = true;

  static String? _validarDni(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa tu DNI';
    }
    final String dni = value.toUpperCase();
    if (dni.length != 9) {
      return 'El DNI debe tener 8 dígitos y 1 letra';
    }
    if (!RegExp(r'^\d{8}[A-Z]$').hasMatch(dni)) {
      return 'Formato inválido (ej: 12345678Z)';
    }
    return null;
  }

  static String? _validarClave(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa tu clave';
    }
    if (value.length != 6) {
      return 'La clave debe tener exactamente 6 dígitos';
    }
    if (!RegExp(r'^\d+$').hasMatch(value)) {
      return 'La clave solo puede contener números';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: widget.formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextFormField(
                controller: widget.dniController,
                enabled: !widget.isLoading,
                textCapitalization: TextCapitalization.characters,
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) => widget.passwordFocus.requestFocus(),
                maxLength: 9,
                decoration: const InputDecoration(
                  labelText: 'DNI',
                  prefixIcon: Icon(Icons.badge_outlined),
                  hintText: '12345678Z',
                  counterText: '',
                ),
                validator: _validarDni,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: widget.passwordController,
                focusNode: widget.passwordFocus,
                enabled: !widget.isLoading,
                obscureText: _obscure,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                maxLength: 6,
                onFieldSubmitted: (_) => widget.onSubmit(),
                style: const TextStyle(letterSpacing: 4),
                decoration: InputDecoration(
                  labelText: 'Clave (6 dígitos)',
                  prefixIcon: const Icon(Icons.lock),
                  hintText: '••••••',
                  counterText: '',
                  suffixIcon: IconButton(
                    icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
                validator: _validarClave,
              ),
              if (widget.recordarDni != null)
                CheckboxListTile(
                  value: widget.recordarDni,
                  onChanged: widget.isLoading ? null : (bool? v) => widget.onRecordarDniChanged?.call(v ?? false),
                  title: const Text('Recordar mi DNI', style: TextStyle(fontSize: 14)),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  activeColor: AppColors.primary,
                )
              else
                const SizedBox(height: 16),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: widget.isLoading ? null : widget.onSubmit,
                  child: widget.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Iniciar Sesión'),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: widget.isLoading ? null : widget.onOlvideClave,
                child: const Text('¿Olvidaste tu clave?'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
