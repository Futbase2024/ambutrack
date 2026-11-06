import 'package:ambutrack_web/core/layout/shell/shell_navigation.dart';
import 'package:ambutrack_web/core/layout/shell/shell_preferences.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Abre el buscador rápido de pantallas (Ctrl+K)
Future<void> showCommandPalette({
  required BuildContext context,
  required ShellNavigation navigation,
  required ValueChanged<String> onNavigate,
}) {
  return showDialog<void>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.25),
    builder: (BuildContext ctx) => _CommandPalette(
      destinos: navigation.destinos,
      onSelect: (String route) {
        Navigator.of(ctx).pop();
        onNavigate(route);
      },
    ),
  );
}

class _CommandPalette extends StatefulWidget {
  const _CommandPalette({required this.destinos, required this.onSelect});

  final List<ShellDestino> destinos;
  final ValueChanged<String> onSelect;

  @override
  State<_CommandPalette> createState() => _CommandPaletteState();
}

class _CommandPaletteState extends State<_CommandPalette> {
  final TextEditingController _query = TextEditingController();
  int _index = 0;

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  static String _norm(String s) => s
      .toLowerCase()
      .replaceAll(RegExp('[áà]'), 'a')
      .replaceAll(RegExp('[éè]'), 'e')
      .replaceAll(RegExp('[íì]'), 'i')
      .replaceAll(RegExp('[óò]'), 'o')
      .replaceAll(RegExp('[úù]'), 'u');

  List<ShellDestino> get _resultados {
    final String q = _norm(_query.text.trim());
    if (q.isEmpty) {
      // Sin texto: favoritos primero
      final List<String> favs = ShellPreferences.instance.favoritos;
      final List<ShellDestino> list = List<ShellDestino>.of(widget.destinos)
        ..sort((ShellDestino a, ShellDestino b) =>
            (favs.contains(b.route) ? 1 : 0).compareTo(favs.contains(a.route) ? 1 : 0));
      return list;
    }
    final List<String> palabras = q.split(RegExp(r'\s+'));
    return widget.destinos.where((ShellDestino d) {
      final String t = _norm(d.ruta);
      return palabras.every(t.contains);
    }).toList();
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent e, List<ShellDestino> items) {
    if (e is! KeyDownEvent && e is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    if (e.logicalKey == LogicalKeyboardKey.arrowDown) {
      setState(() => _index = (_index + 1).clamp(0, items.isEmpty ? 0 : items.length - 1));
      return KeyEventResult.handled;
    }
    if (e.logicalKey == LogicalKeyboardKey.arrowUp) {
      setState(() => _index = (_index - 1).clamp(0, items.isEmpty ? 0 : items.length - 1));
      return KeyEventResult.handled;
    }
    if (e.logicalKey == LogicalKeyboardKey.enter && items.isNotEmpty) {
      widget.onSelect(items[_index.clamp(0, items.length - 1)].route);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final List<ShellDestino> items = _resultados;
    final List<String> favs = ShellPreferences.instance.favoritos;
    return Align(
      alignment: const Alignment(0, -0.55),
      child: Material(
        color: Colors.white,
        elevation: 12,
        borderRadius: BorderRadius.circular(10),
        clipBehavior: Clip.antiAlias,
        child: SafeArea(
          child: SizedBox(
            width: 560,
            child: Focus(
              onKeyEvent: (FocusNode n, KeyEvent e) => _onKey(n, e, items),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
                    child: TextField(
                      controller: _query,
                      autofocus: true,
                      onChanged: (_) => setState(() => _index = 0),
                      style: const TextStyle(fontSize: 15),
                      decoration: const InputDecoration(
                        isDense: true,
                        border: InputBorder.none,
                        icon: Icon(Icons.search, size: 20, color: AppColors.gray500),
                        hintText: 'Ir a… (vehículos, órdenes, ITV, personal…)',
                        hintStyle: TextStyle(fontSize: 15, color: AppColors.gray400),
                      ),
                    ),
                  ),
                  const Divider(height: 1, color: AppColors.gray200),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 380),
                    child: items.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.all(20),
                            child: Text('Sin resultados', style: TextStyle(color: AppColors.gray500)),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            itemCount: items.length,
                            itemExtent: 38,
                            itemBuilder: (BuildContext context, int i) => _ResultRow(
                              destino: items[i],
                              selected: i == _index,
                              favorito: favs.contains(items[i].route),
                              onTap: () => widget.onSelect(items[i].route),
                            ),
                          ),
                  ),
                  const _PaletteFooter(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  const _ResultRow({required this.destino, required this.selected, required this.favorito, required this.onTap});

  final ShellDestino destino;
  final bool selected;
  final bool favorito;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.primarySurface : Colors.white,
      child: InkWell(
        onTap: onTap,
        hoverColor: AppColors.gray100,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            children: <Widget>[
              Icon(destino.item.icon, size: 17, color: selected ? AppColors.primary : AppColors.gray500),
              const SizedBox(width: 12),
              Text(
                destino.label,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: selected ? AppColors.primary : AppColors.gray900,
                ),
              ),
              if (destino.parent != null) ...<Widget>[
                const SizedBox(width: 8),
                Text(destino.parent!.label, style: const TextStyle(fontSize: 12, color: AppColors.gray500)),
              ],
              const Spacer(),
              if (favorito) const Icon(Icons.star_rounded, size: 15, color: AppColors.warning),
              if (selected) const Icon(Icons.keyboard_return, size: 14, color: AppColors.gray400),
            ],
          ),
        ),
      ),
    );
  }
}

class _PaletteFooter extends StatelessWidget {
  const _PaletteFooter();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      alignment: Alignment.centerLeft,
      decoration: const BoxDecoration(
        color: AppColors.gray50,
        border: Border(top: BorderSide(color: AppColors.gray200)),
      ),
      child: const Text(
        '↑↓ moverse   ·   Intro abrir   ·   Esc cerrar',
        style: TextStyle(fontSize: 11.5, color: AppColors.gray500),
      ),
    );
  }
}
