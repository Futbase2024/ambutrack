import 'package:ambutrack_desktop/app/app.dart';
import 'package:ambutrack_desktop/app/flavors.dart';
import 'package:ambutrack_desktop/core/di/locator.dart';
import 'package:ambutrack_desktop/core/supabase/supabase_options.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  F.appFlavor = Flavor.dev;
  WidgetsFlutterBinding.ensureInitialized();

  // Configuración específica de desktop
  await _initializeDesktop();

  // Inicializar locale español para fechas
  await initializeDateFormatting('es_ES');

  // Inicializar Supabase
  await Supabase.initialize(
    url: SupabaseOptions.dev.url,
    anonKey: SupabaseOptions.dev.anonKey,
  );

  // Inicializar DI
  await configureDependencies();

  runApp(const App());
}

/// Inicialización específica para plataformas desktop
Future<void> _initializeDesktop() async {
  // Configurar ventana nativa
  await windowManager.ensureInitialized();

  const windowOptions = WindowOptions(
    size: Size(1280, 800),
    minimumSize: Size(800, 600),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.normal,
    title: 'AmbuTrack Desktop [DEV]',
  );

  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });
}
