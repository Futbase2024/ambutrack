import 'package:supabase_flutter/supabase_flutter.dart';

import 'implementations/supabase/supabase_talleres_datasource.dart';
import 'talleres_contract.dart';

/// Factory para crear instancias del datasource de Talleres
class TalleresDataSourceFactory {
  static TalleresDataSource createSupabase({
    SupabaseClient? supabase,
    String tableName = 'ttalleres',
  }) {
    return SupabaseTalleresDataSource(
      supabase: supabase,
      tableName: tableName,
    );
  }
}
