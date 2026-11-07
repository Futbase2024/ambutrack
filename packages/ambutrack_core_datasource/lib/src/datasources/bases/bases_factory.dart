import 'package:supabase_flutter/supabase_flutter.dart';

import 'bases_contract.dart';
import '../../utils/typedefs/datasource_typedefs.dart';
import 'implementations/supabase/supabase_bases_datasource.dart';

/// Factory class para crear instancias de [BasesDataSource]
///
/// Este factory proporciona una forma centralizada de crear diferentes
/// implementaciones del datasource de bases basándose en la configuración
class BasesDataSourceFactory {
  /// Crea una instancia de [BasesDataSource] basándose en el tipo especificado
  ///
  /// [type] - El tipo de datasource a crear
  /// [config] - Parámetros de configuración específicos para cada tipo de datasource
  ///
  /// ## Configuración Supabase
  /// ```dart
  /// {
  ///   'supabase': SupabaseClient instance, // Opcional
  ///   'table': 'bases', // Opcional, por defecto 'bases'
  /// }
  /// ```
  static BasesDataSource create({
    required String type,
    DataSourceConfig? config,
  }) {
    final configMap = config ?? <String, dynamic>{};

    switch (type.toLowerCase()) {
      case 'supabase':
        return _createSupabaseDataSource(configMap);

      default:
        throw ArgumentError('Tipo de datasource no soportado: $type');
    }
  }

  /// Crea una instancia de datasource de Supabase
  static SupabaseBasesDataSource _createSupabaseDataSource(
    DataSourceConfig config,
  ) {
    final supabase = config['supabase'] as SupabaseClient? ?? Supabase.instance.client;
    final tableName = config['table'] as String? ?? 'bases';

    return SupabaseBasesDataSource(
      supabase: supabase,
      tableName: tableName,
    );
  }

  /// Crea un datasource de Supabase con configuración por defecto
  static BasesDataSource createSupabase({
    SupabaseClient? supabase,
    String tableName = 'bases',
  }) {
    return create(
      type: 'supabase',
      config: {
        'supabase': supabase,
        'table': tableName,
      },
    );
  }

  /// Crea un datasource basándose en la configuración del entorno
  ///
  /// Este método lee la configuración de variables de entorno
  /// o archivos de configuración para determinar qué datasource crear
  static BasesDataSource createFromEnvironment({
    Map<String, String>? environment,
  }) {
    final env = environment ?? const <String, String>{};

    // Verificar configuración de Supabase
    final useSupabase = env['DATASOURCE_TYPE']?.toLowerCase() == 'supabase' ||
        env['SUPABASE_URL'] != null;

    if (useSupabase) {
      return createSupabase(
        tableName: env['SUPABASE_BASES_TABLE'] ?? 'bases',
      );
    }

    // Por defecto usar Supabase
    return createSupabase();
  }

  /// Valida la configuración para un tipo específico de datasource
  static void validateConfig(String type, DataSourceConfig config) {
    switch (type.toLowerCase()) {
      case 'supabase':
        _validateSupabaseConfig(config);
        break;

      default:
        throw ArgumentError('Tipo de datasource no soportado: $type');
    }
  }

  /// Valida la configuración de Supabase
  static void _validateSupabaseConfig(DataSourceConfig config) {
    final tableName = config['table'] as String?;
    if (tableName != null && tableName.isEmpty) {
      throw ArgumentError('El nombre de la tabla de Supabase no puede estar vacío');
    }
  }

  /// Devuelve la configuración por defecto para Supabase
  static DataSourceConfig getDefaultConfig() {
    return {
      'table': 'bases',
    };
  }
}
