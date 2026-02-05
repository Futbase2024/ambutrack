import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/app.dart';
import 'app/flavors.dart';
import 'core/config/supabase_config.dart';
import 'core/di/injection.dart';

/// Punto de entrada principal de AmbuTrack Mobile
///
/// Inicializa:
/// - Supabase (autenticación y base de datos)
/// - Inyección de dependencias (GetIt)
/// - Flavor de desarrollo
Future<void> main() async {
  // Inicializar Flutter binding
  WidgetsFlutterBinding.ensureInitialized();

  // Configurar flavor (dev por defecto)
  F.appFlavor = Flavor.dev;

  // Inicializar Supabase
  await Supabase.initialize(
    url: SupabaseConfig.devUrl,
    anonKey: SupabaseConfig.devAnonKey,
  );

  debugPrint('✅ [Main] Supabase inicializado');

  // Configurar inyección de dependencias
  await configureDependencies();

  debugPrint('✅ [Main] Dependencias configuradas');

  // Ejecutar aplicación
  runApp(const App());
}
