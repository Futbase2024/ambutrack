import 'package:supabase_flutter/supabase_flutter.dart';

import 'implementations/supabase/supabase_usuarios_datasource.dart';
import 'usuarios_contract.dart';

/// Factory para crear instancias de [UsuarioDataSource]
///
/// Proporciona método estático para crear datasource de Supabase
class UsuarioDataSourceFactory {
  /// Crea una instancia de [SupabaseUsuarioDataSource]
  ///
  /// [supabase] - Cliente de Supabase (opcional, usa instancia global por defecto)
  /// [tableName] - Nombre de la tabla en Supabase (por defecto: 'usuarios')
  static UsuarioDataSource createSupabase({
    SupabaseClient? supabase,
    String tableName = 'usuarios',
  }) {
    return SupabaseUsuarioDataSource(
      supabase: supabase,
      tableName: tableName,
    );
  }
}
