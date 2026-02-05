/// Flavors disponibles para la aplicación
enum Flavor {
  dev,
  prod,
}

/// Clase singleton para acceder al flavor actual
class F {
  static Flavor? appFlavor;

  static String get name => appFlavor?.name ?? '';

  static String get title {
    switch (appFlavor) {
      case Flavor.dev:
        return 'AmbuTrack Mobile DEV';
      case Flavor.prod:
        return 'AmbuTrack Mobile';
      default:
        return 'AmbuTrack Mobile';
    }
  }

  static bool get isDev => appFlavor == Flavor.dev;
  static bool get isProd => appFlavor == Flavor.prod;
}
