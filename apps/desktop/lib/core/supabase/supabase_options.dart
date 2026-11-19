/// Configuración de Supabase para diferentes entornos
///
/// IMPORTANTE: Reemplazar estas credenciales con las de tu proyecto Supabase
/// Para producción, considerar usar variables de entorno
class SupabaseOptions {
  const SupabaseOptions._();

  /// Configuración para entorno de desarrollo
  static const SupabaseConfig dev = SupabaseConfig(
    url: 'https://ycmopmnrhrpnnzkvnihr.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InljbW9wbW5yaHJwbm56a3ZuaWhyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjM1MzQ4ODEsImV4cCI6MjA3OTExMDg4MX0.Ebeb5JO5-RGdUIRfhaLPrn2QBAFZTp5gjIbGqBMzLrc',
  );

  /// Configuración para entorno de producción
  static const SupabaseConfig prod = SupabaseConfig(
    url: 'https://ycmopmnrhrpnnzkvnihr.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InljbW9wbW5yaHJwbm56a3ZuaWhyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjM1MzQ4ODEsImV4cCI6MjA3OTExMDg4MX0.Ebeb5JO5-RGdUIRfhaLPrn2QBAFZTp5gjIbGqBMzLrc',
  );
}

/// Modelo de configuración de Supabase
class SupabaseConfig {
  const SupabaseConfig({
    required this.url,
    required this.anonKey,
  });

  /// URL del proyecto Supabase
  final String url;

  /// Clave anónima del proyecto
  final String anonKey;
}
