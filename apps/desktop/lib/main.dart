import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:window_manager/window_manager.dart';

// TODO(dev): Implementar estructura de app compartida con web
// import 'package:ambutrack_desktop/app/app.dart';
// import 'package:ambutrack_desktop/core/providers/app_providers.dart';
// import 'package:ambutrack_desktop/core/supabase/supabase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configuración específica de desktop
  await _initializeDesktop();

  // Inicializar locale español para fechas
  await initializeDateFormatting('es_ES');

  // TODO(dev): Descomentar cuando se configure Supabase
  // await Supabase.initialize(
  //   url: SupabaseOptions.prod.url,
  //   anonKey: SupabaseOptions.prod.anonKey,
  // );

  // TODO(dev): Descomentar cuando se configure DI
  // await initializeDependencies();

  runApp(const AmbuTrackDesktopApp());
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
    title: 'AmbuTrack Desktop',
  );

  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });
}

/// App principal de AmbuTrack Desktop
class AmbuTrackDesktopApp extends StatelessWidget {
  const AmbuTrackDesktopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AmbuTrack Desktop',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E40AF), // Azul médico
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const _PlaceholderHomePage(),
    );
  }
}

/// Placeholder temporal hasta que se copie la estructura de web
class _PlaceholderHomePage extends StatelessWidget {
  const _PlaceholderHomePage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AmbuTrack Desktop'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.local_hospital,
              size: 100,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              'AmbuTrack Desktop',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Text(
              'Aplicación de escritorio para Windows y macOS',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Plataforma: ${Platform.operatingSystem}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                  ),
            ),
            const SizedBox(height: 32),
            const Card(
              margin: EdgeInsets.symmetric(horizontal: 32),
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '🚧 En Desarrollo',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text('✅ Proyecto creado'),
                    Text('✅ pubspec.yaml configurado'),
                    Text('✅ Dependencias instaladas'),
                    Text('✅ Window manager configurado'),
                    SizedBox(height: 12),
                    Text('⏳ Pendiente: Copiar estructura de features desde web'),
                    Text('⏳ Pendiente: Configurar DI y routing'),
                    Text('⏳ Pendiente: Configurar Supabase'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
