import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../../features/auth/presentation/bloc/auth_event.dart';
import '../../../features/auth/presentation/bloc/auth_state.dart';
import '../../../features/registro_horario/domain/repositories/registro_horario_repository.dart';
import '../../di/injection.dart';
import '../../theme/app_colors.dart';

/// Opción elegida en el diálogo de cierre de sesión
enum _OpcionLogout { finalizarJornada, cerrarSesion }

/// Flujo único de cierre de sesión
///
/// - Sin jornada abierta → confirmación y salir
/// - Con jornada abierta → finalizar jornada (va a Registro horario),
///   salir sin finalizar (la jornada sigue abierta) o cancelar
Future<void> iniciarLogout(BuildContext context) async {
  final AuthBloc authBloc = context.read<AuthBloc>();
  final AuthState authState = authBloc.state;
  final String? personalId = authState is AuthAuthenticated ? authState.personal?.id : null;
  final bool jornadaAbierta = await _tieneJornadaAbierta(personalId);
  if (!context.mounted) {
    return;
  }

  final _OpcionLogout? opcion = await showDialog<_OpcionLogout>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _LogoutDialog(jornadaAbierta: jornadaAbierta),
  );
  if (!context.mounted || opcion == null) {
    return;
  }

  switch (opcion) {
    case _OpcionLogout.finalizarJornada:
      await context.push('/registro-horario');
    case _OpcionLogout.cerrarSesion:
      debugPrint('🚪 [Logout] Cerrando sesión (jornada abierta: $jornadaAbierta)');
      authBloc.add(const AuthSignOutRequested());
  }
}

Future<bool> _tieneJornadaAbierta(String? personalId) async {
  if (personalId == null) {
    return false;
  }
  try {
    final RegistroHorarioEntity? ultimo = await getIt<RegistroHorarioRepository>().obtenerUltimo(personalId);
    return ultimo?.tipo.toLowerCase() == 'entrada';
  } catch (e) {
    debugPrint('⚠️ [Logout] No se pudo comprobar la jornada: $e');
    return false;
  }
}

class _LogoutDialog extends StatelessWidget {
  const _LogoutDialog({required this.jornadaAbierta});

  final bool jornadaAbierta;

  @override
  Widget build(BuildContext context) {
    final Color color = jornadaAbierta ? AppColors.warning : AppColors.error;
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
                child: Icon(
                  jornadaAbierta ? Icons.warning_amber_rounded : Icons.logout_rounded,
                  size: 48,
                  color: color,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                jornadaAbierta ? 'Tienes la jornada abierta' : '¿Cerrar sesión?',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.gray900),
              ),
              const SizedBox(height: 12),
              Text(
                jornadaAbierta
                    ? 'Si sales sin finalizar, la jornada seguirá abierta y el vehículo seguirá en servicio. '
                        '¿Quieres finalizar la jornada antes de salir?'
                    : 'Tendrás que volver a introducir tu DNI y tu clave para entrar.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15, height: 1.4, color: AppColors.gray700),
              ),
              const SizedBox(height: 24),
              if (jornadaAbierta) ...<Widget>[
                _Boton(
                  texto: 'Finalizar jornada',
                  icono: Icons.stop_circle_outlined,
                  color: AppColors.primary,
                  onPressed: () => Navigator.of(context).pop(_OpcionLogout.finalizarJornada),
                ),
                const SizedBox(height: 10),
              ],
              _Boton(
                texto: jornadaAbierta ? 'Salir sin finalizar' : 'Cerrar sesión',
                icono: Icons.logout_rounded,
                color: AppColors.error,
                outlined: jornadaAbierta,
                onPressed: () => Navigator.of(context).pop(_OpcionLogout.cerrarSesion),
              ),
              const SizedBox(height: 4),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancelar', style: TextStyle(color: AppColors.gray600)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Boton extends StatelessWidget {
  const _Boton({
    required this.texto,
    required this.icono,
    required this.color,
    required this.onPressed,
    this.outlined = false,
  });

  final String texto;
  final IconData icono;
  final Color color;
  final VoidCallback onPressed;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    final RoundedRectangleBorder forma = RoundedRectangleBorder(borderRadius: BorderRadius.circular(10));
    const EdgeInsets padding = EdgeInsets.symmetric(vertical: 14);
    return SizedBox(
      width: double.infinity,
      child: outlined
          ? OutlinedButton.icon(
              onPressed: onPressed,
              icon: Icon(icono),
              label: Text(texto),
              style: OutlinedButton.styleFrom(
                foregroundColor: color,
                side: BorderSide(color: color),
                padding: padding,
                shape: forma,
              ),
            )
          : ElevatedButton.icon(
              onPressed: onPressed,
              icon: Icon(icono),
              label: Text(texto),
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: padding,
                shape: forma,
              ),
            ),
    );
  }
}
