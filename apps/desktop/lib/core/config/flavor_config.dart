// Configuración de flavors compatible con flutter_flavorizr
// 
// Este archivo será complementado por el archivo flavors.dart generado
// automáticamente por flutter_flavorizr que contendrá la clase F.
// 
// Después de ejecutar flutter_flavorizr, podrás acceder al flavor actual
// usando F.appFlavor y F.title

enum Flavor { dev, prod }

/// Extensión para obtener información adicional del flavor
extension FlavorExtension on Flavor {
  String get displayName {
    switch (this) {
      case Flavor.dev:
        return 'Development';
      case Flavor.prod:
        return 'Production';
    }
  }
  
  String get apiUrl {
    switch (this) {
      case Flavor.dev:
        return 'https://api.dev.example.com';
      case Flavor.prod:
        return 'https://api.prod.example.com';
    }
  }
  
  bool get isProduction => this == Flavor.prod;
  bool get isDevelopment => this == Flavor.dev;
}
