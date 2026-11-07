import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/app.dart';
import 'app/flavors.dart';
import 'core/config/supabase_config.dart';
import 'core/di/injection.dart';
import 'features/notificaciones/services/local_notifications_service.dart';

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

  // Inicializar servicio de notificaciones locales
  try {
    final notificationsService = getIt<LocalNotificationsService>();
    await notificationsService.initialize();

    // Solicitar permisos de notificaciones
    final permisosOtorgados = await notificationsService.solicitarPermisos();
    debugPrint('🔔 Permisos de notificaciones: ${permisosOtorgados ? "✅ Otorgados" : "❌ Denegados"}');
  } catch (e) {
    debugPrint('❌ Error al inicializar notificaciones: $e');
  }

  // Ejecutar app
  runApp(const App());
}
