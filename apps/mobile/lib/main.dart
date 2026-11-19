import 'main_android.dart' as prod;

/// Punto de entrada por defecto (iOS y `flutter build` sin `-t`).
///
/// Delega en el entry point de PRODUCCIÓN para que una build de tienda
/// nunca salga con el flavor dev ni sin inicializar Hive/locale.
/// Para desarrollo usar `lib/main_android_dev.dart`.
void main() => prod.main();
