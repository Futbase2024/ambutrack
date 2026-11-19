import 'package:supabase_flutter/supabase_flutter.dart';

import 'dotaciones_contract.dart';
import 'implementations/supabase/supabase_dotaciones_datasource.dart';

/// Factory para crear instancias de DotacionesDataSource
///
/// Proporciona métodos estáticos para crear datasources con diferentes backends
class DotacionesDataSourceFactory {
  /// Crea una instancia de DotacionesDataSource
  ///
  /// [type] - Tipo de datasource ('supabase', 'firebase', 'rest')
  /// [config] - Configuración adicional (opcional)
  ///
  /// Ejemplo:
  /// ```dart
  /// final dataSource = DotacionesDataSourceFactory.create(
  ///   type: 'supabase',
  ///   config: {'table': 'dotaciones'},
  /// );
  /// ```
  static DotacionesDataSource create({
    required String type,
    Map<String, dynamic>? config,
  }) {
    switch (type.toLowerCase()) {
      case 'supabase':
        return createSupabase(config: config);
      default:
        throw UnsupportedError('Tipo de datasource no soportado: $type');
    }
  }

  /// Crea una instancia de DotacionesDataSource con backend Supabase
  ///
  /// [config] - Configuración opcional (table name, etc.)
  ///
  /// Ejemplo:
  /// ```dart
  /// final dataSource = DotacionesDataSourceFactory.createSupabase(
  ///   config: {'table': 'dotaciones'},
  /// );
  /// ```
  static DotacionesDataSource createSupabase({Map<String, dynamic>? config}) {
    final SupabaseClient client = Supabase.instance.client;
    return SupabaseDotacionesDataSource(client);
  }
}
