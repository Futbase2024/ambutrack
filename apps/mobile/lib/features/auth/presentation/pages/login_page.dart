import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/services/preferencias_dispositivo_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/dialogs/dialogs.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/login_form_card.dart';
import '../widgets/usuarios_recientes_selector.dart';

/// Página de Login para AmbuTrack Mobile
///
/// - Modo personal: DNI recordado y oferta de huella/Face ID tras el primer login
/// - Modo compartido: lista de usuarios recientes del dispositivo
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _dniController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _passwordFocus = FocusNode();
  final PreferenciasDispositivoService _prefs = getIt<PreferenciasDispositivoService>();
  late bool _recordarDni = _prefs.recordarDni;
  String? _dniEnviado;
  bool _procesandoLogin = false;

  @override
  void initState() {
    super.initState();
    _dniController.text = _prefs.dniRecordado ?? '';
  }

  @override
  void dispose() {
    _dniController.dispose();
    _passwordController.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  void _onLoginPressed() {
    if (_formKey.currentState?.validate() ?? false) {
      _dniEnviado = _dniController.text.trim().toUpperCase();
      context.read<AuthBloc>().add(
            AuthSignInWithDniRequested(dni: _dniEnviado!, password: _passwordController.text),
          );
    }
  }

  void _seleccionarReciente(UsuarioReciente usuario) {
    setState(() => _dniController.text = usuario.dni);
    _passwordController.clear();
    _passwordFocus.requestFocus();
  }

  Future<void> _onAutenticado(AuthAuthenticated state) async {
    // El AuthBloc puede emitir "autenticado" dos veces (login + cambio de sesión)
    if (_procesandoLogin) {
      return;
    }
    _procesandoLogin = true;
    final String? dni = _dniEnviado;
    _dniEnviado = null;
    _passwordController.clear();
    if (dni != null) {
      final String nombre = state.personal != null
          ? '${state.personal!.nombre} ${state.personal!.apellidos}'.trim().toUpperCase()
          : dni;
      await _prefs.registrarLogin(dni: dni, nombre: nombre, recordar: _recordarDni);
    }
    if (mounted) {
      context.go('/');
    }
  }

  void _mostrarError(String mensaje) {
    final bool credenciales = mensaje.contains('Invalid login') || mensaje.contains('invalid_credentials');
    showProfessionalResultDialog(
      context,
      title: 'No se pudo iniciar sesión',
      message: credenciales ? 'El DNI o la clave no son correctos.' : mensaje.replaceFirst('Exception: ', ''),
      icon: Icons.error_outline,
      iconColor: AppColors.error,
    );
  }

  void _olvideClave() {
    showProfessionalResultDialog(
      context,
      title: '¿Olvidaste tu clave?',
      message: 'Por seguridad, la clave la restablece coordinación. '
          'Contacta con tu coordinador para que te asigne una nueva clave de 6 dígitos.',
      icon: Icons.info_outline,
      iconColor: AppColors.info,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (BuildContext context, AuthState state) {
            if (state is AuthError) {
              _mostrarError(state.message);
            }
            if (state is AuthAuthenticated) {
              _onAutenticado(state);
            }
          },
          builder: (BuildContext context, AuthState state) {
            final bool isLoading = state is AuthLoading;
            final List<UsuarioReciente> recientes = _prefs.esCompartido ? _prefs.usuariosRecientes : <UsuarioReciente>[];

            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Image.asset('lib/assets/images/logo_emertrack.png', width: 140, height: 140, fit: BoxFit.contain),
                    const SizedBox(height: 16),
                    Text(
                      _prefs.esCompartido ? 'Dispositivo de ambulancia' : 'Personal de Campo',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                    const SizedBox(height: 32),
                    if (recientes.isNotEmpty) ...<Widget>[
                      UsuariosRecientesSelector(
                        usuarios: recientes,
                        dniSeleccionado: _dniController.text,
                        onSeleccionar: _seleccionarReciente,
                        onQuitar: (UsuarioReciente u) async {
                          await _prefs.quitarUsuarioReciente(u.dni);
                          setState(() {});
                        },
                      ),
                      const SizedBox(height: 20),
                    ],
                    LoginFormCard(
                      formKey: _formKey,
                      dniController: _dniController,
                      passwordController: _passwordController,
                      passwordFocus: _passwordFocus,
                      isLoading: isLoading,
                      onSubmit: _onLoginPressed,
                      onOlvideClave: _olvideClave,
                      recordarDni: _prefs.esCompartido ? null : _recordarDni,
                      onRecordarDniChanged: (bool v) => setState(() => _recordarDni = v),
                    ),
                    const SizedBox(height: 24),
                    const Text('v1.0.0 - DEV', style: TextStyle(fontSize: 12, color: AppColors.textSecondaryLight)),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
