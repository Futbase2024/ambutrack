import 'package:flutter/material.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/services/app_lock_service.dart';
import '../../../../core/services/preferencias_dispositivo_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/repositories/ajustes_dispositivo_repository.dart';

/// Roles que pueden cambiar el modo del dispositivo
const Set<String> _rolesGestion = <String>{'admin', 'jefe_personal', 'jefe_trafico', 'coordinador'};

/// Tarjeta "Seguridad y dispositivo" del perfil
///
/// - Modo del dispositivo (personal / compartido): solo gestión
/// - Desbloqueo con huella / Face ID: solo modo personal
class AjustesDispositivoCard extends StatefulWidget {
  const AjustesDispositivoCard({super.key});

  @override
  State<AjustesDispositivoCard> createState() => _AjustesDispositivoCardState();
}

class _AjustesDispositivoCardState extends State<AjustesDispositivoCard> {
  final PreferenciasDispositivoService _prefs = getIt<PreferenciasDispositivoService>();
  final AppLockService _lock = getIt<AppLockService>();
  bool _biometriaDisponible = false;
  bool _puedeCambiarModo = false;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final bool disponible = await _lock.biometriaDisponible();
    String? rol;
    try {
      rol = await getIt<AjustesDispositivoRepository>().obtenerRolUsuario();
    } catch (e) {
      debugPrint('⚠️ [AjustesDispositivo] Rol no disponible: $e');
    }
    if (!mounted) {
      return;
    }
    setState(() {
      _biometriaDisponible = disponible;
      _puedeCambiarModo = rol != null && _rolesGestion.contains(rol);
    });
  }

  Future<void> _cambiarBiometria(bool activar) async {
    if (activar && !await _lock.autenticarBiometria()) {
      return;
    }
    await _prefs.setBiometria(activa: activar);
  }

  Future<void> _elegirModo() async {
    final ModoDispositivo? modo = await showModalBottomSheet<ModoDispositivo>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _SelectorModo(actual: _prefs.modo),
    );
    if (modo != null) {
      await _prefs.setModo(modo);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _prefs,
      builder: (BuildContext context, _) {
        return Card(
          child: Column(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.devices_rounded, color: AppColors.primary),
                title: const Text('Modo del dispositivo'),
                subtitle: Text(_prefs.modo.label),
                trailing: _puedeCambiarModo
                    ? const Icon(Icons.chevron_right_rounded)
                    : const Icon(Icons.lock_outline_rounded, size: 18, color: AppColors.gray400),
                onTap: _puedeCambiarModo ? _elegirModo : null,
              ),
              if (!_prefs.esCompartido && _biometriaDisponible) ...<Widget>[
                const Divider(height: 1),
                SwitchListTile(
                  secondary: const Icon(Icons.fingerprint_rounded, color: AppColors.primary),
                  title: const Text('Desbloqueo con huella / Face ID'),
                  subtitle: const Text('Para volver a la app sin escribir la clave'),
                  value: _prefs.biometriaActiva,
                  activeThumbColor: AppColors.primary,
                  onChanged: _cambiarBiometria,
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _SelectorModo extends StatelessWidget {
  const _SelectorModo({required this.actual});

  final ModoDispositivo actual;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const Text(
              'Modo del dispositivo',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.gray900),
            ),
            const SizedBox(height: 12),
            for (final ModoDispositivo modo in ModoDispositivo.values)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  modo == actual ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                  color: modo == actual ? AppColors.primary : AppColors.gray400,
                ),
                title: Text(modo.label, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(
                  modo == ModoDispositivo.personal
                      ? 'Recuerda el DNI y permite huella / Face ID. Bloqueo a los 15 min.'
                      : 'Varios técnicos: lista de usuarios recientes, bloqueo a los 5 min '
                          'y cierre de sesión al finalizar la jornada.',
                ),
                onTap: () => Navigator.of(context).pop(modo),
              ),
          ],
        ),
      ),
    );
  }
}
