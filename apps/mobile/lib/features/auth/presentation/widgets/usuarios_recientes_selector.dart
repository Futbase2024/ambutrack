import 'package:flutter/material.dart';

import '../../../../core/services/preferencias_dispositivo_service.dart';
import '../../../../core/theme/app_colors.dart';

/// Usuarios que han entrado en este dispositivo (modo compartido)
///
/// Tocar uno rellena el DNI; mantener pulsado lo quita de la lista.
class UsuariosRecientesSelector extends StatelessWidget {
  const UsuariosRecientesSelector({
    required this.usuarios,
    required this.dniSeleccionado,
    required this.onSeleccionar,
    required this.onQuitar,
    super.key,
  });

  final List<UsuarioReciente> usuarios;
  final String? dniSeleccionado;
  final ValueChanged<UsuarioReciente> onSeleccionar;
  final ValueChanged<UsuarioReciente> onQuitar;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          '¿QUIÉN ERES?',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.gray600, letterSpacing: 0.8),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: <Widget>[
            for (final UsuarioReciente u in usuarios)
              _UsuarioChip(
                usuario: u,
                seleccionado: u.dni == dniSeleccionado,
                onTap: () => onSeleccionar(u),
                onLongPress: () => onQuitar(u),
              ),
          ],
        ),
        const SizedBox(height: 6),
        const Text(
          'Mantén pulsado para quitar de la lista',
          style: TextStyle(fontSize: 11, color: AppColors.gray500),
        ),
      ],
    );
  }
}

class _UsuarioChip extends StatelessWidget {
  const _UsuarioChip({
    required this.usuario,
    required this.seleccionado,
    required this.onTap,
    required this.onLongPress,
  });

  final UsuarioReciente usuario;
  final bool seleccionado;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  String get _iniciales {
    final List<String> partes = usuario.nombre.split(' ').where((String p) => p.isNotEmpty).toList();
    return partes.take(2).map((String p) => p[0]).join();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 96,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        decoration: BoxDecoration(
          color: seleccionado ? AppColors.primarySurface : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: seleccionado ? AppColors.primary : AppColors.gray300, width: seleccionado ? 2 : 1),
        ),
        child: Column(
          children: <Widget>[
            CircleAvatar(
              radius: 20,
              backgroundColor: seleccionado ? AppColors.primary : AppColors.gray200,
              child: Text(
                _iniciales,
                style: TextStyle(fontWeight: FontWeight.w700, color: seleccionado ? Colors.white : AppColors.gray700),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              usuario.nombre,
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.gray800),
            ),
          ],
        ),
      ),
    );
  }
}
