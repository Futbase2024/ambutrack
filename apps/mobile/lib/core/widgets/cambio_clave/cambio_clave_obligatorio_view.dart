import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../features/auth/domain/repositories/auth_repository.dart';
import '../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../../features/auth/presentation/bloc/auth_event.dart';
import '../../di/injection.dart';
import '../../theme/app_colors.dart';

/// Pantalla de cambio obligatorio de la clave provisional (PIN de 6 dígitos)
class CambioClaveObligatorioView extends StatefulWidget {
  const CambioClaveObligatorioView({required this.onCambiada, super.key});

  final VoidCallback onCambiada;

  @override
  State<CambioClaveObligatorioView> createState() => _CambioClaveObligatorioViewState();
}

class _CambioClaveObligatorioViewState extends State<CambioClaveObligatorioView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nuevo = TextEditingController();
  final TextEditingController _repetido = TextEditingController();
  bool _guardando = false;
  String? _error;

  @override
  void dispose() {
    _nuevo.dispose();
    _repetido.dispose();
    super.dispose();
  }

  String? _validarNuevo(String? v) {
    if (v == null || !RegExp(r'^\d{6}$').hasMatch(v)) {
      return 'El PIN debe tener exactamente 6 dígitos';
    }
    if (RegExp(r'^(\d)\1{5}$').hasMatch(v) || v == '123456' || v == '654321') {
      return 'PIN demasiado fácil de adivinar';
    }
    return null;
  }

  String? _validarRepetido(String? v) => v == _nuevo.text ? null : 'Los PIN no coinciden';

  Future<void> _guardar() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() {
      _guardando = true;
      _error = null;
    });
    try {
      await getIt<AuthRepository>().cambiarMiClave(_nuevo.text);
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
      backgroundColor: AppColors.gray50,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  const _CabeceraCambioPin(),
                  const SizedBox(height: 28),
                  _CampoPin(controller: _nuevo, label: 'Nuevo PIN', validator: _validarNuevo),
                  const SizedBox(height: 14),
                  _CampoPin(
                    controller: _repetido,
                    label: 'Repite el PIN',
                    validator: _validarRepetido,
                    onSubmitted: _guardar,
                  ),
                  if (_error != null) ...<Widget>[
                    const SizedBox(height: 12),
                    Text(_error!, style: const TextStyle(color: AppColors.error, fontSize: 14)),
                  ],
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: _guardando ? null : _guardar,
                    icon: _guardando
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.check),
                    label: const Text('Guardar y continuar'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: _guardando ? null : () => context.read<AuthBloc>().add(const AuthSignOutRequested()),
                    child: const Text('Cerrar sesión'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CampoPin extends StatelessWidget {
  const _CampoPin({required this.controller, required this.label, required this.validator, this.onSubmitted});

  final TextEditingController controller;
  final String label;
  final FormFieldValidator<String> validator;
  final VoidCallback? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: true,
      keyboardType: TextInputType.number,
      textInputAction: onSubmitted == null ? TextInputAction.next : TextInputAction.done,
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(6),
      ],
      validator: validator,
      onFieldSubmitted: onSubmitted == null ? null : (_) => onSubmitted!(),
      style: const TextStyle(fontSize: 20, letterSpacing: 8),
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

class _CabeceraCambioPin extends StatelessWidget {
  const _CabeceraCambioPin();

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
          'Has entrado con un PIN provisional. Por seguridad, elige uno propio de '
          '6 dígitos para continuar. Nadie más lo conocerá.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 15, height: 1.4, color: AppColors.gray700),
        ),
      ],
    );
  }
}
