import 'package:ambutrack_web/app/app.dart';
import 'package:ambutrack_web/app/flavors.dart';
import 'package:ambutrack_web/core/monitoring/error_monitoring.dart';
import 'package:ambutrack_web/core/providers/app_providers.dart';
import 'package:ambutrack_web/core/supabase/supabase_options.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  F.appFlavor = Flavor.prod;
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar locale español para fechas
  await initializeDateFormatting('es_ES');

  // Inicializar Supabase
  await Supabase.initialize(
    url: SupabaseOptions.prod.url,
    anonKey: SupabaseOptions.prod.anonKey,
  );

  await initializeDependencies();

  // Monitor de errores: solo activo si se compila con --dart-define=SENTRY_DSN=...
  await ErrorMonitoring.run(environment: 'production', appRunner: () => runApp(const App()));
}
