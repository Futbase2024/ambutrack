import 'package:flutter/material.dart';

/// Selector del tipo de clave provisional:
/// PIN de 6 dígitos (login de la app móvil) o contraseña web
class TipoClaveSelector extends StatelessWidget {
  const TipoClaveSelector({required this.pinMovil, required this.onChanged, super.key});

  /// true = PIN de 6 dígitos; false = contraseña web
  final bool pinMovil;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: SegmentedButton<bool>(
        segments: const <ButtonSegment<bool>>[
          ButtonSegment<bool>(
            value: true,
            label: Text('PIN app móvil (6 dígitos)'),
            icon: Icon(Icons.phone_android),
          ),
          ButtonSegment<bool>(value: false, label: Text('Contraseña web'), icon: Icon(Icons.computer)),
        ],
        selected: <bool>{pinMovil},
        onSelectionChanged: (Set<bool> v) => onChanged(v.first),
      ),
    );
  }
}
