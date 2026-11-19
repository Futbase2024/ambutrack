import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/rol_label.dart';

/// Cabecera de la home: datos del usuario y estado de su turno
class HomeUserHeader extends StatelessWidget {
  const HomeUserHeader({
    super.key,
    required this.user,
    required this.personal,
    required this.turnoActivo,
  });

  final UserEntity user;
  final TPersonalEntity? personal;
  final bool turnoActivo;

  @override
  Widget build(BuildContext context) {
    final String nombre = (personal?.nombreCompleto ?? user.nombreCompleto ?? 'Usuario').toUpperCase();
    final String puesto = _puesto();
    final String? dni = personal?.dni;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: <Color>[AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              _Avatar(inicial: nombre.isNotEmpty ? nombre[0] : 'U'),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      _saludo(),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      nombre,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(height: 1, color: Colors.white.withValues(alpha: 0.15)),
          const SizedBox(height: 14),
          Wrap(
            spacing: 12,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[
              _TurnoChip(activo: turnoActivo),
              _Dato(icon: Icons.badge_outlined, texto: puesto),
              if (dni != null && dni.isNotEmpty) _Dato(icon: Icons.credit_card_rounded, texto: dni),
            ],
          ),
        ],
      ),
    );
  }

  String _puesto() {
    final String? categoria = personal?.categoria;
    if (categoria != null && categoria.trim().isNotEmpty) {
      return categoria;
    }
    return rolLabel(user.rol) ?? 'Sin puesto asignado';
  }

  static String _saludo() {
    final int hora = DateTime.now().hour;
    if (hora < 14) {
      return 'Buenos días';
    }
    if (hora < 21) {
      return 'Buenas tardes';
    }
    return 'Buenas noches';
  }
}

/// Avatar circular con la inicial del usuario
class _Avatar extends StatelessWidget {
  const _Avatar({required this.inicial});

  final String inicial;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withValues(alpha: 0.35), width: 1.5),
      ),
      child: Text(
        inicial,
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white),
      ),
    );
  }
}

/// Estado del turno: en servicio / fuera de turno
class _TurnoChip extends StatelessWidget {
  const _TurnoChip({required this.activo});

  final bool activo;

  @override
  Widget build(BuildContext context) {
    final Color color = activo ? AppColors.success : AppColors.gray400;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            activo ? 'En servicio' : 'Fuera de turno',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.gray800),
          ),
        ],
      ),
    );
  }
}

/// Dato secundario con icono
class _Dato extends StatelessWidget {
  const _Dato({required this.icon, required this.texto});

  final IconData icon;
  final String texto;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(icon, size: 16, color: Colors.white.withValues(alpha: 0.8)),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            texto,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
        ),
      ],
    );
  }
}
