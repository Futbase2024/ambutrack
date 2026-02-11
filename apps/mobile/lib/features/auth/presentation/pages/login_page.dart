import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

/// Página de Login para AmbuTrack Mobile
///
/// Integra con AuthBloc para autenticación real con Supabase.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _dniController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _dniController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLoginPressed() {
    if (_formKey.currentState?.validate() ?? false) {
      final dni = _dniController.text.trim().toUpperCase();

      // Enviar evento de login con DNI
      context.read<AuthBloc>().add(
            AuthSignInWithDniRequested(
              dni: dni,
              password: _passwordController.text,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            // Mostrar errores
            if (state is AuthError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.error,
                ),
              );
            }

            // Navegar al home cuando se autentica
            if (state is AuthAuthenticated) {
              context.go('/');
            }
          },
          builder: (context, state) {
            final isLoading = state is AuthLoading;

            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      // Logo AmbuTrack
                      Image.asset(
                        'lib/assets/images/logonuevo.png',
                        width: 300,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 24),

                      const Text(
                        'Personal de Campo',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondaryLight,
                        ),
                      ),
                      const SizedBox(height: 48),

                      // Card con formulario
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              // DNI
                              TextFormField(
                                controller: _dniController,
                                enabled: !isLoading,
                                keyboardType: TextInputType.text,
                                textCapitalization: TextCapitalization.characters,
                                textInputAction: TextInputAction.next,
                                maxLength: 9,
                                decoration: const InputDecoration(
                                  labelText: 'DNI',
                                  prefixIcon: Icon(Icons.badge_outlined),
                                  hintText: '12345678Z',
                                  counterText: '',
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Por favor ingresa tu DNI';
                                  }
                                  final dniUpper = value.toUpperCase();
                                  if (dniUpper.length != 9) {
                                    return 'El DNI debe tener 8 dígitos y 1 letra';
                                  }
                                  if (!RegExp(r'^\d{8}[A-Z]$').hasMatch(dniUpper)) {
                                    return 'Formato inválido (ej: 12345678Z)';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),

                              // Clave
                              TextFormField(
                                controller: _passwordController,
                                enabled: !isLoading,
                                obscureText: _obscurePassword,
                                keyboardType: TextInputType.number,
                                textInputAction: TextInputAction.done,
                                maxLength: 6,
                                onFieldSubmitted: (_) => _onLoginPressed(),
                                style: const TextStyle(
                                  letterSpacing: 4,
                                ),
                                decoration: InputDecoration(
                                  labelText: 'Clave (6 dígitos)',
                                  prefixIcon: const Icon(Icons.lock),
                                  hintText: '••••••',
                                  counterText: '',
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
                                  ),
                                ),
                                validator: (value) {
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
                                },
                              ),
                              const SizedBox(height: 24),

                              // Botón Login
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: isLoading ? null : _onLoginPressed,
                                  child: isLoading
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Text('Iniciar Sesión'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Footer
                      const Text(
                        'v1.0.0 - DEV',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
