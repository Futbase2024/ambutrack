import 'package:ambutrack_web/core/auth/enums/user_role.dart';
import 'package:ambutrack_web/core/layout/shell/app_sidebar.dart';
import 'package:ambutrack_web/core/layout/shell/app_top_bar.dart';
import 'package:ambutrack_web/core/layout/shell/command_palette.dart';
import 'package:ambutrack_web/core/layout/shell/shell_navigation.dart';
import 'package:ambutrack_web/core/layout/shell/shell_preferences.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ambutrack_web/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// Ancho a partir del cual el menú lateral es fijo (por debajo, cajón)
const double kShellWideBreakpoint = 1100;

/// Estructura principal: menú lateral + barra superior + contenido.
///
/// Atajo global: Ctrl/⌘ + K abre el buscador de pantallas.
class AppShell extends StatefulWidget {
  const AppShell({required this.location, required this.child, super.key});

  final String location;
  final Widget child;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _paletteOpen = false;

  @override
  void initState() {
    super.initState();
    ShellPreferences.instance.load();
    HardwareKeyboard.instance.addHandler(_onKey);
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_onKey);
    super.dispose();
  }

  bool _onKey(KeyEvent e) {
    if (e is! KeyDownEvent || e.logicalKey != LogicalKeyboardKey.keyK) {
      return false;
    }
    final bool mod = HardwareKeyboard.instance.isControlPressed || HardwareKeyboard.instance.isMetaPressed;
    if (!mod || _paletteOpen || !mounted) {
      return false;
    }
    _openPalette();
    return true;
  }

  ShellNavigation _navigation(BuildContext context) {
    final AuthState auth = context.read<AuthBloc>().state;
    final UserRole role = auth is AuthAuthenticated ? UserRole.fromString(auth.user.rol) : UserRole.operador;
    return ShellNavigation(role);
  }

  void _go(String route) {
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      Navigator.of(context).pop();
    }
    context.go(route);
  }

  Future<void> _openPalette() async {
    _paletteOpen = true;
    await showCommandPalette(context: context, navigation: _navigation(context), onNavigate: _go);
    _paletteOpen = false;
  }

  @override
  Widget build(BuildContext context) {
    // Reconstruye al cambiar el usuario/rol
    context.watch<AuthBloc>();
    final ShellNavigation nav = _navigation(context);
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints c) {
        final bool wide = c.maxWidth >= kShellWideBreakpoint;
        final Widget content = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            AppTopBar(
              navigation: nav,
              path: widget.location,
              onSearch: _openPalette,
              onMenu: wide ? null : () => _scaffoldKey.currentState?.openDrawer(),
            ),
            Expanded(child: ColoredBox(color: AppColors.backgroundLight, child: widget.child)),
          ],
        );
        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: AppColors.backgroundLight,
          drawer: wide
              ? null
              : Drawer(
                  width: kSidebarWidth,
                  shape: const RoundedRectangleBorder(),
                  child: AppSidebar(navigation: nav, path: widget.location, onNavigate: _go, forceExpanded: true),
                ),
          body: SafeArea(
            child: wide
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      AppSidebar(navigation: nav, path: widget.location, onNavigate: _go),
                      Expanded(child: content),
                    ],
                  )
                : content,
          ),
        );
      },
    );
  }
}
