import 'package:ambutrack_web/core/layout/shell/shell_navigation.dart';
import 'package:ambutrack_web/core/layout/shell/shell_preferences.dart';
import 'package:ambutrack_web/core/layout/shell/top_bar_actions.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Barra superior fina: ruta de la pantalla, favorito, buscador, notificaciones y usuario
class AppTopBar extends StatelessWidget {
  const AppTopBar({
    required this.navigation,
    required this.path,
    required this.onSearch,
    this.onMenu,
    super.key,
  });

  final ShellNavigation navigation;
  final String path;
  final VoidCallback onSearch;

  /// Solo en pantallas estrechas: abre el menú lateral como cajón
  final VoidCallback? onMenu;

  @override
  Widget build(BuildContext context) {
    final ShellDestino? destino = navigation.destinoDe(path);
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.gray200)),
      ),
      child: Row(
        children: <Widget>[
          if (onMenu != null) ...<Widget>[
            TopBarIconButton(icon: Icons.menu, tooltip: 'Menú', onTap: onMenu!),
            const SizedBox(width: 6),
          ],
          Expanded(child: _Breadcrumb(destino: destino, path: path)),
          _SearchButton(onTap: onSearch),
          const SizedBox(width: 10),
          const TopBarNotificaciones(),
          const SizedBox(width: 4),
          const _Separator(),
          const TopBarUsuario(),
        ],
      ),
    );
  }
}

class _Breadcrumb extends StatelessWidget {
  const _Breadcrumb({required this.destino, required this.path});

  final ShellDestino? destino;
  final String path;

  @override
  Widget build(BuildContext context) {
    final ShellDestino? d = destino;
    final String titulo = d?.label ?? (path == '/' ? 'Dashboard' : _tituloDesdeRuta(path));
    return Row(
      children: <Widget>[
        if (d?.parent != null) ...<Widget>[
          Text(d!.parent!.label, style: const TextStyle(fontSize: 13, color: AppColors.gray500)),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 6),
            child: Icon(Icons.chevron_right, size: 16, color: AppColors.gray400),
          ),
        ],
        Flexible(
          child: Text(
            titulo,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.gray900),
          ),
        ),
        if (d != null && d.route != '/') _FavoritoToggle(route: d.route),
      ],
    );
  }

  /// "/taller/ordenes-reparacion" → "Ordenes reparacion" (pantallas fuera del menú)
  static String _tituloDesdeRuta(String path) {
    final String last = path.split('/').where((String s) => s.isNotEmpty).lastOrNull ?? '';
    if (last.isEmpty) {
      return '';
    }
    final String t = last.replaceAll('-', ' ').replaceAll('_', ' ');
    return '${t[0].toUpperCase()}${t.substring(1)}';
  }
}

class _FavoritoToggle extends StatelessWidget {
  const _FavoritoToggle({required this.route});

  final String route;

  @override
  Widget build(BuildContext context) {
    final ShellPreferences prefs = ShellPreferences.instance;
    return ListenableBuilder(
      listenable: prefs,
      builder: (BuildContext context, Widget? _) {
        final bool fav = prefs.isFavorito(route);
        return Padding(
          padding: const EdgeInsets.only(left: 4),
          child: TopBarIconButton(
            icon: fav ? Icons.star_rounded : Icons.star_outline_rounded,
            color: fav ? AppColors.warning : AppColors.gray400,
            tooltip: fav ? 'Quitar de favoritos' : 'Añadir a favoritos',
            onTap: () => prefs.toggleFavorito(route),
          ),
        );
      },
    );
  }
}

class _SearchButton extends StatelessWidget {
  const _SearchButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: 240,
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: AppColors.gray50,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.gray200),
        ),
        child: Row(
          children: <Widget>[
            const Icon(Icons.search, size: 16, color: AppColors.gray500),
            const SizedBox(width: 8),
            const Expanded(
              child: Text('Buscar pantalla…', style: TextStyle(fontSize: 12.5, color: AppColors.gray400)),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: AppColors.gray300),
              ),
              child: const Text('Ctrl K', style: TextStyle(fontSize: 10.5, color: AppColors.gray500)),
            ),
          ],
        ),
      ),
    );
  }
}

class _Separator extends StatelessWidget {
  const _Separator();

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 22, margin: const EdgeInsets.symmetric(horizontal: 8), color: AppColors.gray200);
  }
}
