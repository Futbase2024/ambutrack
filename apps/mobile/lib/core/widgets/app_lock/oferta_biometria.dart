import 'package:flutter/material.dart';

import '../../di/injection.dart';
import '../../services/app_lock_service.dart';
import '../../services/preferencias_dispositivo_service.dart';
import '../../theme/app_colors.dart';
import '../dialogs/dialogs.dart';

/// Tras el primer login en modo personal ofrece activar huella / Face ID (una vez)
Future<void> ofrecerBiometriaTrasLogin(BuildContext context) async {
  final PreferenciasDispositivoService prefs = getIt<PreferenciasDispositivoService>();
  final AppLockService lock = getIt<AppLockService>();
  if (prefs.esCompartido || prefs.biometriaActiva || prefs.biometriaPreguntada) {
    return;
  }
  if (!await lock.biometriaDisponible() || !context.mounted) {
    return;
  }
  await prefs.marcarBiometriaPreguntada();
  if (!context.mounted) {
    return;
  }
  final bool? activar = await showProfessionalConfirmDialog(
    context,
    title: '¿Activar huella / Face ID?',
    message: 'Podrás volver a la app sin escribir tu clave. Puedes cambiarlo en Mi Perfil.',
    confirmLabel: 'Activar',
    cancelLabel: 'Ahora no',
    icon: Icons.fingerprint_rounded,
    iconColor: AppColors.primary,
  );
  if ((activar ?? false) && await lock.autenticarBiometria()) {
    await prefs.setBiometria(activa: true);
  }
}
