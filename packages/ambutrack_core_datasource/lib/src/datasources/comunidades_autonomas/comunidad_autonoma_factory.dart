import 'package:supabase_flutter/supabase_flutter.dart';
import 'comunidad_autonoma_contract.dart';
import 'implementations/supabase/supabase_comunidad_autonoma_datasource.dart';

class ComunidadAutonomaDataSourceFactory {
  static ComunidadAutonomaDataSource createSupabase({
    SupabaseClient? supabase,
    String tableName = 'tcomunidades',
  }) {
    return SupabaseComunidadAutonomaDataSource(
      supabase: supabase,
      tableName: tableName,
    );
  }
}
