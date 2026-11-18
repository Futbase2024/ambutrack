import 'package:ambutrack_web/app/flavors.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/dialogs/result_dialog.dart';
import 'package:ambutrack_web/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ambutrack_web/features/auth/presentation/bloc/auth_event.dart';
import 'package:ambutrack_web/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

/// Página de inicio de sesión
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();

    // 🚀 Autologin automático desactivado para evitar re-login después de logout
    // Si necesitas autologin en DEV, descomenta el siguiente código:
    /*
    if (F.appFlavor == Flavor.dev) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          debugPrint('🔐 [DEV] Autologin automático con algonclagu@gmail.com');

          context.read<AuthBloc>().add(
                const AuthLoginRequested(
                  email: 'algonclagu@gmail.com',
                  password: '123456',
                ),
              );
        }
      });
    }
    */
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      final String identifier = _emailController.text.trim();

      // Detectar si es DNI (solo dígitos y opcionalmente una letra al final) o Email
      final bool isDni = _isDniFormat(identifier);

      if (isDni) {
        debugPrint('🔐 LoginPage: Login con DNI detectado');
        context.read<AuthBloc>().add(
              AuthDniLoginRequested(
                dni: identifier,
                password: _passwordController.text,
              ),
            );
      } else {
        debugPrint('🔐 LoginPage: Login con Email detectado');
        context.read<AuthBloc>().add(
              AuthLoginRequested(
                email: identifier,
                password: _passwordController.text,
              ),
            );
      }
    }
  }

  /// Verifica si el identificador tiene formato de DNI español
  /// Acepta: 12345678A, 12345678 (sin letra), etc.
  bool _isDniFormat(String text) {
    // DNI español: 8 dígitos + opcionalmente 1 letra
    final RegExp dniRegex = RegExp(r'^\d{8}[A-Za-z]?$');
    return dniRegex.hasMatch(text);
  }

  @override
  Widget build(BuildContext context) {
    final bool isWideScreen = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (BuildContext context, AuthState state) {
            debugPrint('🎯 LoginPage BlocListener: State = ${state.runtimeType}');

            if (state is AuthAuthenticated) {
              debugPrint('✅ LoginPage: Usuario autenticado, redirigiendo a /');
              context.go('/');
            } else if (state is AuthError) {
              debugPrint('❌ LoginPage: Error de autenticación - ${state.message}');
              showResultDialog(
                context: context,
                title: 'Error de Autenticación',
                message: state.message,
                type: ResultType.error,
              );
            } else if (state is AuthLoading) {
              debugPrint('⏳ LoginPage: Cargando...');
            }
          },
          builder: (BuildContext context, AuthState state) {
            final bool isLoading = state is AuthLoading;

            return DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[
                    AppColors.primary,
                    AppColors.primaryDark,
                  ],
                ),
              ),
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: isWideScreen ? 500 : double.infinity,
                    ),
                    child: Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            // Logo y título
                            _buildHeader(),
                            const SizedBox(height: 32),

                            // Formulario
                            Form(
                              key: _formKey,
                              child: Column(
                                children: <Widget>[
                                  _buildEmailField(),
                                  const SizedBox(height: 16),
                                  _buildPasswordField(),
                                  const SizedBox(height: 24),
                                  _buildLoginButton(isLoading),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: <Widget>[
        Image.asset(
          'lib/core/assets/logo_emertrack.png',
          width: 150,
          height: 150,
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Gestión Integral de Ambulancias',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.textSecondaryLight,
              ),
            ),
            if (F.appFlavor == Flavor.dev) ...<Widget>[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: AppColors.warning,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'DEV',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
        labelText: 'DNI o Correo electrónico',
        hintText: '12345678A o usuario@ejemplo.com',
        prefixIcon: const Icon(Icons.person_outline),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      validator: (String? value) {
        if (value == null || value.isEmpty) {
          return 'Por favor ingresa tu DNI o correo';
        }
        // Validar que sea DNI o Email válido
        final bool isDni = _isDniFormat(value);
        final bool isEmail = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value);

        if (!isDni && !isEmail) {
          return 'Ingresa un DNI o correo electrónico válido';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      decoration: InputDecoration(
        labelText: 'Contraseña',
        hintText: '••••••••',
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          ),
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      validator: (String? value) {
        if (value == null || value.isEmpty) {
          return 'Por favor ingresa tu contraseña';
        }
        if (value.length < 6) {
          return 'La contraseña debe tener al menos 6 caracteres';
        }
        return null;
      },
      onFieldSubmitted: (_) => _handleLogin(),
    );
  }

  Widget _buildLoginButton(bool isLoading) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: isLoading ? null : _handleLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                'Iniciar Sesión',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}