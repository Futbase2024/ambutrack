import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/features/auth/domain/repositories/auth_repository.dart';
import 'package:ambutrack_web/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ambutrack_web/features/auth/presentation/bloc/auth_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Pantalla de cambio obligatorio de la clave provisional.
///
/// Para cualquier rol la clave es un PIN de 6 dígitos: es la misma con la que
/// se entra en la web y en la app móvil (cuyo login solo acepta 6 dígitos).
class CambioClaveObligatorioView extends StatefulWidget {
  const CambioClaveObligatorioView({required this.onCambiada, super.key});

  final VoidCallback onCambiada;

  @override
  State<CambioClaveObligatorioView> createState() => _CambioClaveObligatorioViewState();
}

class _CambioClaveObligatorioViewState extends State<CambioClaveObligatorioView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nueva = TextEditingController();
  final TextEditingController _repetida = TextEditingController();
  bool _guardando = false;
  bool _visible = false;
  String? _error;

  @override
  void dispose() {
    _nueva.dispose();
    _repetida.dispose();
    super.dispose();
  }

  static final List<TextInputFormatter> _formatoPin = <TextInputFormatter>[
    FilteringTextInputFormatter.digitsOnly,
    LengthLimitingTextInputFormatter(6),
  ];

  String? _validarNueva(String? v) {
    if (v == null || !RegExp(r'^\d{6}$').hasMatch(v)) {
      return 'El PIN debe tener exactamente 6 dígitos';
    }
    if (RegExp(r'^(\d)\1{5}$').hasMatch(v) || v == '123456' || v == '654321') {
      return 'PIN demasiado fácil de adivinar';
    }
    return null;
  }

  String? _validarRepetida(String? v) => v == _nueva.text ? null : 'Los PIN no coinciden';

  Future<void> _guardar() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    setState(() {
      _guardando = true;
      _error = null;
    });
    try {
      await getIt<AuthRepository>().cambiarMiClave(_nueva.text);
      widget.onCambiada();
    } catch (e) {
      if (mounted) {
        setState(() {
          _guardando = false;
          _error = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray100,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Card(
                elevation: 0,
                color: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        const _CabeceraCambioClave(),
                        const SizedBox(height: 24),
                        TextFormField(
                          controller: _nueva,
                          obscureText: !_visible,
                          textInputAction: TextInputAction.next,
                          validator: _validarNueva,
                          keyboardType: TextInputType.number,
                          inputFormatters: _formatoPin,
                          decoration: InputDecoration(
                            labelText: 'Nuevo PIN (6 dígitos)',
                            border: const OutlineInputBorder(),
                            suffixIcon: IconButton(
                              icon: Icon(_visible ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                              onPressed: () => setState(() => _visible = !_visible),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _repetida,
                          obscureText: !_visible,
                          textInputAction: TextInputAction.done,
                          validator: _validarRepetida,
                          onFieldSubmitted: (_) => _guardar(),
                          keyboardType: TextInputType.number,
                          inputFormatters: _formatoPin,
                          decoration: const InputDecoration(
                            labelText: 'Repite el PIN',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        if (_error != null) ...<Widget>[
                          const SizedBox(height: 12),
                          Text(_error!, style: const TextStyle(color: AppColors.error, fontSize: 13)),
                        ],
                        const SizedBox(height: 22),
                        FilledButton.icon(
                          onPressed: _guardando ? null : _guardar,
                          icon: _guardando
                              ? const SizedBox.square(
                                  dimension: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const Icon(Icons.check),
                          label: const Text('Guardar y continuar'),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: _guardando
                              ? null
                              : () => context.read<AuthBloc>().add(const AuthLogoutRequested()),
                          child: const Text('Cerrar sesión'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CabeceraCambioClave extends StatelessWidget {
  const _CabeceraCambioClave();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.warning.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.lock_reset, size: 48, color: AppColors.warning),
        ),
        const SizedBox(height: 20),
        const Text(
          'Elige tu PIN',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.gray900),
        ),
        const SizedBox(height: 12),
        const Text(
          'Has entrado con una clave provisional. Por seguridad, elige un PIN '
          'propio de 6 dígitos para continuar. Te servirá para entrar en la web '
          'y en la app móvil. Nadie más lo conocerá.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 15, height: 1.4, color: AppColors.gray700),
        ),
      ],
    );
  }
}
