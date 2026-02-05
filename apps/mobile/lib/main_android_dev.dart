import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/app.dart';
import 'app/flavors.dart';
import 'core/config/supabase_config.dart';
import 'core/di/injection.dart';

/// Entry point para Android en modo DESARROLLO
void main() async {
  // Configurar flavor
  F.appFlavor = Flavor.dev;

  // Inicialización básica
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar locale español para fechas
  await initializeDateFormatting('es_ES');

  // Inicializar Hive (offline storage)
  await Hive.initFlutter();

  // Inicializar Supabase
  await Supabase.initialize(
    url: SupabaseConfig.devUrl,
    anonKey: SupabaseConfig.devAnonKey,
  );

  // Inicializar Dependency Injection (GetIt + Injectable)
  await configureDependencies();

  // Ejecutar app
  runApp(const App());
}
