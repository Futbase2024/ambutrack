import 'package:supabase_flutter/supabase_flutter.dart';

import 'tpersonal_contract.dart';
import 'implementations/supabase/supabase_tpersonal_datasource.dart';

/// Factory para crear instancias de TPersonalDataSource
class TPersonalDataSourceFactory {
  /// Crea un datasource de Supabase con configuración por defecto
  static TPersonalDataSource createSupabase({
    SupabaseClient? supabase,
    String tableName = 'tpersonal',
  }) {
    return SupabaseTPersonalDataSource(
      supabase: supabase,
      tableName: tableName,
    );
  }
}
