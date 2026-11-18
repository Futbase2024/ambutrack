import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

/// Opción de un menú de la app (lista agrupada estilo corporativo)
class AppMenuOpcion {
  const AppMenuOpcion({
    required this.icon,
    required this.color,
    required this.titulo,
    required this.descripcion,
    required this.onTap,
    this.enabled = true,
    this.descripcionDeshabilitada,
    this.badge,
    this.badgeColor,
  });

  final IconData icon;
  final Color color;
  final String titulo;
  final String descripcion;
  final VoidCallback onTap;

  /// Si es false la fila se muestra atenuada, con candado y sin acción
  final bool enabled;

  /// Texto que sustituye a [descripcion] cuando la opción está deshabilitada
  final String? descripcionDeshabilitada;

  /// Etiqueta de estado opcional junto al título (ej. "En servicio")
  final String? badge;
  final Color? badgeColor;
}

/// Título de sección del menú (mayúsculas, gris)
class AppMenuSeccion extends StatelessWidget {
  const AppMenuSeccion(this.texto, {super.key});

  final String texto;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        texto.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.1,
          color: AppColors.gray500,
        ),
      ),
    );
  }
}

/// Grupo de opciones en una tarjeta blanca con separadores
class AppMenuGrupo extends StatelessWidget {
  const AppMenuGrupo({super.key, required this.opciones});

  final List<AppMenuOpcion> opciones;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gray200),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: <Widget>[
          for (int i = 0; i < opciones.length; i++) ...<Widget>[
            if (i > 0) const Divider(height: 1, indent: 72, color: AppColors.gray100),
            AppMenuTile(opcion: opciones[i]),
          ],
        ],
      ),
    );
  }
}

/// Fila de una opción: icono con fondo suave, título, descripción y flecha
class AppMenuTile extends StatelessWidget {
  const AppMenuTile({super.key, required this.opcion});

  final AppMenuOpcion opcion;

  @override
  Widget build(BuildContext context) {
    final bool enabled = opcion.enabled;
    final Color color = enabled ? opcion.color : AppColors.gray400;
    final String descripcion =
        enabled ? opcion.descripcion : (opcion.descripcionDeshabilitada ?? opcion.descripcion);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? opcion.onTap : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: <Widget>[
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(opcion.icon, size: 22, color: color),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _TituloConBadge(opcion: opcion, enabled: enabled),
                    const SizedBox(height: 2),
                    Text(
                      descripcion,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color: enabled ? AppColors.gray500 : AppColors.gray400,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                enabled ? Icons.chevron_right_rounded : Icons.lock_outline_rounded,
                size: enabled ? 24 : 18,
                color: AppColors.gray400,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Título de la fila con la etiqueta de estado opcional
class _TituloConBadge extends StatelessWidget {
  const _TituloConBadge({required this.opcion, required this.enabled});

  final AppMenuOpcion opcion;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final String? badge = opcion.badge;
    final Color badgeColor = opcion.badgeColor ?? opcion.color;

    return Wrap(
      spacing: 8,
      runSpacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[
        Text(
          opcion.titulo,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: enabled ? AppColors.gray900 : AppColors.gray500,
          ),
        ),
        if (badge != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: badgeColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              badge,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: badgeColor),
            ),
          ),
      ],
    );
  }
}
