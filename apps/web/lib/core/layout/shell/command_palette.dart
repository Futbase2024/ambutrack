import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/layout/shell/command_palette_rows.dart';
import 'package:ambutrack_web/core/layout/shell/shell_navigation.dart';
import 'package:ambutrack_web/core/layout/shell/shell_preferences.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_deep_link.dart';
import 'package:ambutrack_web/features/busqueda_global/domain/repositories/busqueda_global_repository.dart';
import 'package:ambutrack_web/features/busqueda_global/presentation/bloc/busqueda_global_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Pantalla que abre cada tipo de registro de la búsqueda global
const Map<TipoResultadoBusqueda, String> _rutaPorTipo = <TipoResultadoBusqueda, String>{
  TipoResultadoBusqueda.vehiculo: '/vehiculos',
  TipoResultadoBusqueda.paciente: '/servicios/pacientes',
  TipoResultadoBusqueda.personal: '/personal',
  TipoResultadoBusqueda.orden: '/taller/ordenes-reparacion',
};

/// Abre el buscador rápido (Ctrl+K): registros (matrícula, paciente, empleado,
/// orden…) y pantallas. Solo muestra registros de pantallas a las que el
/// usuario tiene acceso.
Future<void> showCommandPalette({
  required BuildContext context,
  required ShellNavigation navigation,
  required ValueChanged<String> onNavigate,
}) {
  return showDialog<void>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.25),
    builder: (BuildContext ctx) => BlocProvider<BusquedaGlobalCubit>(
      create: (BuildContext _) => BusquedaGlobalCubit(getIt<BusquedaGlobalRepository>()),
      child: _CommandPalette(
        destinos: navigation.destinos,
        onSelect: (String location) {
          Navigator.of(ctx).pop();
          onNavigate(location);
        },
      ),
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

  List<ShellDestino> get _pantallas {
    final String q = _norm(_query.text.trim());
    if (q.isEmpty) {
      // Sin texto: favoritos primero
      final List<String> favs = ShellPreferences.instance.favoritos;
      return List<ShellDestino>.of(widget.destinos)..sort(
        (ShellDestino a, ShellDestino b) => (favs.contains(b.route) ? 1 : 0).compareTo(favs.contains(a.route) ? 1 : 0),
      );
    }
    final List<String> palabras = q.split(RegExp(r'\s+'));
    return widget.destinos.where((ShellDestino d) => palabras.every(_norm(d.ruta).contains)).toList();
  }

  /// Registros de pantallas a las que el usuario tiene acceso
  List<ResultadoBusquedaEntity> _registros(List<ResultadoBusquedaEntity> todos) {
    final Set<String> permitidas = widget.destinos.map((ShellDestino d) => d.route).toSet();
    return todos.where((ResultadoBusquedaEntity r) => permitidas.contains(_rutaPorTipo[r.tipo])).toList();
  }

  void _abrir(PaletteEntrada e) {
    final ResultadoBusquedaEntity? r = e.registro;
    if (r != null) {
      widget.onSelect(GestionDeepLink.ruta(_rutaPorTipo[r.tipo]!, id: r.id, texto: r.titulo));
    } else {
      widget.onSelect(e.destino!.route);
    }
  }

  KeyEventResult _onKey(KeyEvent e, List<PaletteEntrada> items) {
    if (e is! KeyDownEvent && e is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final int ultimo = items.isEmpty ? 0 : items.length - 1;
    if (e.logicalKey == LogicalKeyboardKey.arrowDown) {
      setState(() => _index = (_index + 1).clamp(0, ultimo));
      return KeyEventResult.handled;
    }
    if (e.logicalKey == LogicalKeyboardKey.arrowUp) {
      setState(() => _index = (_index - 1).clamp(0, ultimo));
      return KeyEventResult.handled;
    }
    if (e.logicalKey == LogicalKeyboardKey.enter && items.isNotEmpty) {
      _abrir(items[_index.clamp(0, ultimo)]);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BusquedaGlobalCubit, BusquedaGlobalState>(
      builder: (BuildContext context, BusquedaGlobalState busqueda) {
        final List<ResultadoBusquedaEntity> registros = _registros(busqueda.resultados);
        final List<ShellDestino> pantallas = _pantallas;
        final List<PaletteEntrada> items = <PaletteEntrada>[
          for (final ResultadoBusquedaEntity r in registros) PaletteEntrada.registro(r),
          for (final ShellDestino d in pantallas) PaletteEntrada.pantalla(d),
        ];
        return Align(
          alignment: const Alignment(0, -0.55),
          child: Material(
            color: Colors.white,
            elevation: 12,
            borderRadius: BorderRadius.circular(10),
            clipBehavior: Clip.antiAlias,
            child: SafeArea(
              child: SizedBox(
                width: 600,
                child: Focus(
                  onKeyEvent: (FocusNode _, KeyEvent e) => _onKey(e, items),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      _PaletteSearchField(
                        controller: _query,
                        onChanged: (String v) {
                          setState(() => _index = 0);
                          context.read<BusquedaGlobalCubit>().cambiarTexto(v);
                        },
                      ),
                      const Divider(height: 1, color: AppColors.gray200),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 420),
                        child: PaletteResultList(
                          items: items,
                          numRegistros: registros.length,
                          selectedIndex: _index,
                          favoritos: ShellPreferences.instance.favoritos,
                          onTap: _abrir,
                        ),
                      ),
                      PaletteFooter(buscando: busqueda.buscando),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PaletteSearchField extends StatelessWidget {
  const _PaletteSearchField({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      child: TextField(
        controller: controller,
        autofocus: true,
        onChanged: onChanged,
        style: const TextStyle(fontSize: 15),
        decoration: const InputDecoration(
          isDense: true,
          border: InputBorder.none,
          icon: Icon(Icons.search, size: 20, color: AppColors.gray500),
          hintText: 'Buscar matrícula, paciente, empleado, orden… o ir a una pantalla',
          hintStyle: TextStyle(fontSize: 15, color: AppColors.gray400),
        ),
      ),
    );
  }
}
