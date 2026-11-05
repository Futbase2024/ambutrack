import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion_frame/gestion_frame.dart';
import 'package:ambutrack_web/features/usuarios/presentation/widgets/gestion/usuarios_gestion_columns.dart';
import 'package:flutter/material.dart';

/// Error de carga inicial con botón de reintento
class AdminLoadError extends StatelessWidget {
  const AdminLoadError({
    required this.title,
    required this.message,
    required this.onRetry,
    super.key,
  });

  final String title;
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(Icons.error_outline, size: 40, color: AppColors.error),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.error)),
            const SizedBox(height: 4),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12.5, color: AppColors.gray600),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Barra de progreso fina superpuesta durante las recargas
class AdminReloadingBar extends StatelessWidget {
  const AdminReloadingBar({super.key});

  @override
  Widget build(BuildContext context) {
    return const Positioned(
      left: 0,
      right: 0,
      top: 0,
      child: LinearProgressIndicator(minHeight: 2),
    );
  }
}

/// Lista compacta de usuarios para las fichas laterales
class AdminUsuariosList extends StatelessWidget {
  const AdminUsuariosList({
    required this.usuarios,
    this.emptyMessage = 'No hay usuarios',
    this.showRol = true,
    super.key,
  });

  final List<UserEntity> usuarios;
  final String emptyMessage;
  final bool showRol;

  @override
  Widget build(BuildContext context) {
    if (usuarios.isEmpty) {
      return GestionDetailEmpty(message: emptyMessage);
    }
    final List<UserEntity> ordenados = List<UserEntity>.of(usuarios)
      ..sort((UserEntity a, UserEntity b) =>
          usuarioNombre(a).toLowerCase().compareTo(usuarioNombre(b).toLowerCase()));
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 14),
      itemCount: ordenados.length,
      separatorBuilder: (BuildContext _, int __) => const Divider(height: 1, color: AppColors.gray100),
      itemBuilder: (BuildContext _, int i) => _UsuarioTile(usuario: ordenados[i], showRol: showRol),
    );
  }
}

class _UsuarioTile extends StatelessWidget {
  const _UsuarioTile({required this.usuario, required this.showRol});

  final UserEntity usuario;
  final bool showRol;

  @override
  Widget build(BuildContext context) {
    final bool activo = usuarioActivo(usuario);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: <Widget>[
          Icon(
            Icons.person_outline,
            size: 16,
            color: activo ? AppColors.primary : AppColors.gray400,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  usuarioNombre(usuario).toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                ),
                Text(
                  usuario.email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11.5, color: AppColors.gray500),
                ),
              ],
            ),
          ),
          if (showRol) UsuarioRolDot(rol: usuario.rol),
          if (!activo) ...<Widget>[
            const SizedBox(width: 8),
            const GestionDotLabel(label: 'Inactivo', color: AppColors.inactive, fontSize: 11.5),
          ],
        ],
      ),
    );
  }
}

/// Texto de celda que pinta el marcador de vacío en gris claro
class AdminCellText extends StatelessWidget {
  const AdminCellText(this.value, {this.bold = false, this.muted = false, super.key});

  final String value;
  final bool bold;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final bool empty = value == GestionFormatters.vacio;
    return Text(
      value,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontWeight: bold ? FontWeight.w600 : FontWeight.w400,
        color: empty ? AppColors.gray300 : (muted ? AppColors.gray500 : null),
      ),
    );
  }
}

/// Indicador "Solo lectura" para la barra de herramientas
class AdminSoloLecturaBadge extends StatelessWidget {
  const AdminSoloLecturaBadge({required this.tooltip, super.key});

  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: const GestionToolbarBadge(
        label: 'Solo lectura',
        color: AppColors.gray600,
        icon: Icons.lock_outline,
      ),
    );
  }
}
