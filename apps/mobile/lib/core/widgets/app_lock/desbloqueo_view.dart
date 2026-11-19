import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../features/auth/domain/repositories/auth_repository.dart';
import '../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../../features/auth/presentation/bloc/auth_event.dart';
import '../../../features/auth/presentation/bloc/auth_state.dart';
import '../../di/injection.dart';
import '../../services/app_lock_service.dart';
import '../../services/preferencias_dispositivo_service.dart';
import '../../theme/app_colors.dart';

/// Pantalla de desbloqueo tras inactividad
///
/// La sesión sigue abierta: se verifica la identidad con huella/Face ID
/// (modo personal) o con la clave de 6 dígitos.
class DesbloqueoView extends StatefulWidget {
  const DesbloqueoView({super.key});

  @override
  State<DesbloqueoView> createState() => _DesbloqueoViewState();
}

class _DesbloqueoViewState extends State<DesbloqueoView> {
  final AppLockService _lock = getIt<AppLockService>();
  final PreferenciasDispositivoService _prefs = getIt<PreferenciasDispositivoService>();
  final TextEditingController _pin = TextEditingController();
  bool _verificando = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (_prefs.biometriaActiva) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _usarBiometria());
    }
  }

  @override
  void dispose() {
    _pin.dispose();
    super.dispose();
  }

  Future<void> _usarBiometria() async {
    if (await _lock.autenticarBiometria()) {
      _lock.desbloquear();
    }
  }

  Future<void> _verificarPin() async {
    final AuthState state = context.read<AuthBloc>().state;
    if (state is! AuthAuthenticated || _pin.text.length != 6) {
      setState(() => _error = 'Introduce tu clave de 6 dígitos');
      return;
    }
    setState(() {
      _verificando = true;
      _error = null;
    });
    try {
      await getIt<AuthRepository>().signInWithEmailAndPassword(email: state.user.email, password: _pin.text);
      _lock.desbloquear();
    } catch (e) {
      debugPrint('⚠️ [Desbloqueo] Clave incorrecta: $e');
      if (mounted) {
        setState(() => _error = 'Clave incorrecta');
      }
    } finally {
      _pin.clear();
      if (mounted) {
        setState(() => _verificando = false);
      }
    }
  }

  void _cambiarUsuario() {
    _lock.setSesionActiva(value: false);
    context.read<AuthBloc>().add(const AuthSignOutRequested());
  }

  @override
  Widget build(BuildContext context) {
    final AuthState state = context.watch<AuthBloc>().state;
    final String nombre = state is AuthAuthenticated && state.personal != null
        ? '${state.personal!.nombre} ${state.personal!.apellidos}'.trim().toUpperCase()
        : '';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(color: AppColors.primarySurface, shape: BoxShape.circle),
                  child: const Icon(Icons.lock_rounded, size: 48, color: AppColors.primary),
                ),
                const SizedBox(height: 20),
                const Text('App bloqueada', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
                if (nombre.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 6),
                  Text(nombre, style: const TextStyle(fontSize: 15, color: AppColors.gray700)),
                ],
                const SizedBox(height: 28),
                if (_prefs.biometriaActiva) ...<Widget>[
                  _BotonBiometria(onPressed: _usarBiometria),
                  const SizedBox(height: 20),
                  const Text('o con tu clave', style: TextStyle(color: AppColors.gray600)),
                  const SizedBox(height: 12),
                ],
                _CampoPin(
                  controller: _pin,
                  error: _error,
                  enabled: !_verificando,
                  onSubmit: _verificarPin,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _verificando ? null : _verificarPin,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: _verificando
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Desbloquear'),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: _verificando ? null : _cambiarUsuario,
                  icon: const Icon(Icons.switch_account_rounded),
                  label: Text(_prefs.esCompartido ? 'Cambiar de usuario' : '¿No eres tú? Cerrar sesión'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BotonBiometria extends StatelessWidget {
  const _BotonBiometria({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.fingerprint_rounded, size: 32),
      label: const Text('Huella / Face ID', style: TextStyle(fontSize: 16)),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

class _CampoPin extends StatelessWidget {
  const _CampoPin({
    required this.controller,
    required this.error,
    required this.enabled,
    required this.onSubmit,
  });

  final TextEditingController controller;
  final String? error;
  final bool enabled;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      enabled: enabled,
      obscureText: true,
      maxLength: 6,
      keyboardType: TextInputType.number,
      textAlign: TextAlign.center,
      textInputAction: TextInputAction.done,
      onSubmitted: (_) => onSubmit(),
      style: const TextStyle(fontSize: 22, letterSpacing: 10),
      decoration: InputDecoration(
        hintText: '••••••',
        counterText: '',
        errorText: error,
        prefixIcon: const Icon(Icons.pin_outlined),
      ),
    );
  }
}
