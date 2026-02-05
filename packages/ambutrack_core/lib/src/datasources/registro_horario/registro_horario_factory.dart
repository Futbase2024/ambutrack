import 'package:supabase_flutter/supabase_flutter.dart';

import '../../utils/typedefs/datasource_typedefs.dart';
import 'implementations/implementations.dart';
import 'registro_horario_contract.dart';

/// Factory para crear instancias de RegistroHorarioDataSource
///
/// Proporciona una forma centralizada de crear diferentes
/// implementaciones del datasource de registro horario
class RegistroHorarioDataSourceFactory {
  /// Crea una instancia de RegistroHorarioDataSource basándose en el tipo
  ///
  /// [type] - El tipo de datasource a crear ('supabase' o 'firebase')
  /// [config] - Parámetros de configuración específicos
  ///
  /// ## Configuración Supabase (recomendado)
  /// ```dart
  /// {
  ///   'supabase': SupabaseClient.instance.client, // Opcional
  ///   'tableName': 'registro_horarios', // Opcional
  /// }
  /// ```
  ///
  /// ## Configuración Firebase (legacy)
  /// ```dart
  /// {
  ///   'firestore': FirebaseFirestore.instance, // Opcional
  ///   'collection': 'registro_horarios', // Opcional
  /// }
  /// ```
  static RegistroHorarioDataSource create({
    required String type,
    DataSourceConfig? config,
  }) {
    final configMap = config ?? <String, dynamic>{};

    switch (type.toLowerCase()) {
      case 'supabase':
        return _createSupabaseDataSource(configMap);

      case 'firebase':
        return _createFirebaseDataSource(configMap);

      default:
        throw ArgumentError('Tipo de datasource no soportado: $type');
    }
  }

  /// Crea una instancia de datasource de Supabase
  static SupabaseRegistroHorarioDataSource _createSupabaseDataSource(
    DataSourceConfig config,
  ) {
    final supabase = config['supabase'] as SupabaseClient?;
    final tableName = config['tableName'] as String? ?? 'registro_horarios';

    return SupabaseRegistroHorarioDataSource(
      supabase: supabase,
      tableName: tableName,
    );
  }

  /// Crea una instancia de datasource de Firebase (legacy)
  static FirebaseRegistroHorarioDataSource _createFirebaseDataSource(
    DataSourceConfig config,
  ) {
    return FirebaseRegistroHorarioDataSource();
  }

  /// Crea un datasource de Supabase con configuración por defecto
  static RegistroHorarioDataSource createSupabase({
    SupabaseClient? supabase,
    String tableName = 'registro_horarios',
  }) {
    return create(
      type: 'supabase',
      config: {
        'supabase': supabase,
        'tableName': tableName,
      },
    );
  }

  /// Crea un datasource de Firebase con configuración por defecto (legacy)
  static RegistroHorarioDataSource createFirebase() {
    return create(type: 'firebase');
  }

  /// Crea un datasource basándose en la configuración del entorno
  ///
  /// Por defecto usa Supabase (migración de Firebase a Supabase)
  static RegistroHorarioDataSource createFromEnvironment({
    Map<String, String>? environment,
  }) {
    final env = environment ?? const <String, String>{};

    // Verificar configuración de Supabase (prioridad)
    final useSupabase = env['DATASOURCE_TYPE']?.toLowerCase() == 'supabase' ||
        env['SUPABASE_URL'] != null;

    if (useSupabase) {
      return createSupabase(
        tableName: env['SUPABASE_REGISTRO_HORARIOS_TABLE'] ?? 'registro_horarios',
      );
    }

    // Verificar configuración de Firebase (legacy)
    final useFirebase = env['DATASOURCE_TYPE']?.toLowerCase() == 'firebase' ||
        env['FIREBASE_PROJECT_ID'] != null;

    if (useFirebase) {
      return createFirebase();
    }

    // Por defecto usar Supabase (migración activa)
    return createSupabase();
  }

  /// Valida la configuración para un tipo específico de datasource
  static void validateConfig(String type, DataSourceConfig config) {
    switch (type.toLowerCase()) {
      case 'supabase':
        _validateSupabaseConfig(config);
        break;

      case 'firebase':
        _validateFirebaseConfig(config);
        break;

      default:
        throw ArgumentError('Tipo de datasource no soportado: $type');
    }
  }

  /// Valida la configuración de Supabase
  static void _validateSupabaseConfig(DataSourceConfig config) {
    final tableName = config['tableName'] as String?;
    if (tableName != null && tableName.isEmpty) {
      throw ArgumentError('El nombre de la tabla de Supabase no puede estar vacío');
    }
  }

  /// Valida la configuración de Firebase
  static void _validateFirebaseConfig(DataSourceConfig config) {
    // La configuración de Firebase es mayormente opcional
  }

  /// Devuelve la configuración por defecto para Supabase
  static DataSourceConfig getDefaultConfig() {
    return {
      'tableName': 'registro_horarios',
    };
  }
}
