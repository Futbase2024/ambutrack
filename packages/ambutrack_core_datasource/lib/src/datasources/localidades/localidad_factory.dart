import 'package:supabase_flutter/supabase_flutter.dart';

import 'implementations/supabase/supabase_localidad_datasource.dart';
import 'localidad_contract.dart';

/// Factory para crear instancias de LocalidadDataSource
class LocalidadDataSourceFactory {
  /// Crea una instancia de datasource usando Supabase
  static LocalidadDataSource createSupabase({
    SupabaseClient? supabase,
    String tableName = 'tpoblaciones',
  }) {
    return SupabaseLocalidadDataSource(
      supabase: supabase,
      tableName: tableName,
    );
  }
}
