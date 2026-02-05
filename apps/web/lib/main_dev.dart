import 'package:ambutrack_web/app/app.dart';
import 'package:ambutrack_web/app/flavors.dart';
import 'package:ambutrack_web/core/providers/app_providers.dart';
import 'package:ambutrack_web/core/supabase/supabase_options.dart';
import 'package:ambutrack_web/features/personal/data/services/tablas_maestras_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  F.appFlavor = Flavor.dev;
  WidgetsFlutterBinding.ensureInitialized();

  // Workaround temporal para error de widget inspector en Flutter Web
  // https://github.com/flutter/flutter/issues/xxxxx
  if (kIsWeb && kDebugMode) {
    FlutterError.onError = (FlutterErrorDetails details) {
      // Ignorar errores específicos del inspector de widgets
      if (details.exception.toString().contains('DiagnosticsNode') ||
          details.exception.toString().contains('LegacyJavaScriptObject')) {
        debugPrint('⚠️ Widget inspector error ignorado (Flutter Web bug conocido)');
        return;
      }
      // Mostrar otros errores normalmente
      FlutterError.presentError(details);
    };
  }

  // Inicializar locale español para fechas
  await initializeDateFormatting('es_ES');

  // Inicializar Supabase
  await Supabase.initialize(
    url: SupabaseOptions.dev.url,
    anonKey: SupabaseOptions.dev.anonKey,
  );

  await initializeDependencies();

  // Pre-cargar tablas maestras en background (no bloquear el inicio)
  _preloadMasterTables();

  runApp(const App());
}

/// Pre-carga las tablas maestras más usadas en background
/// Esto mejora el rendimiento al abrir páginas que las necesitan
void _preloadMasterTables() {
  debugPrint('🚀 Pre-cargando tablas maestras en background...');

  final TablasMaestrasService service = TablasMaestrasService();

  // Cargar en paralelo sin esperar (no bloquear el inicio de la app)
  Future.wait(<Future<void>>[
    service.getCategorias().then((_) => debugPrint('✅ Categorías pre-cargadas')),
    service.getProvincias().then((_) => debugPrint('✅ Provincias pre-cargadas')),
    service.getPuestos().then((_) => debugPrint('✅ Puestos pre-cargados')),
    service.getContratos().then((_) => debugPrint('✅ Contratos pre-cargados')),
    service.getEmpresas().then((_) => debugPrint('✅ Empresas pre-cargadas')),
  ]).then((_) {
    debugPrint('🎉 Todas las tablas maestras pre-cargadas');
  }).catchError((Object error) {
    debugPrint('⚠️ Error al pre-cargar tablas maestras: $error');
  });
}
