import 'package:supabase_flutter/supabase_flutter.dart';

import 'centro_hospitalario_contract.dart';
import 'implementations/supabase/supabase_centro_hospitalario_datasource.dart';

/// Factory class para crear instancias de [CentroHospitalarioDataSource]
class CentroHospitalarioDataSourceFactory {
  /// Crea un datasource de Supabase con configuración por defecto
  static CentroHospitalarioDataSource createSupabase({
    SupabaseClient? supabase,
    String tableName = 'tcentros_hospitalarios',
  }) {
    return SupabaseCentroHospitalarioDataSource(
      supabase: supabase,
      tableName: tableName,
    );
  }
}
