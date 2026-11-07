import 'package:supabase_flutter/supabase_flutter.dart';

import 'especialidad_contract.dart';
import 'implementations/supabase/supabase_especialidad_datasource.dart';

/// Factory para crear instancias de EspecialidadDataSource
class EspecialidadDataSourceFactory {
  /// Crea un datasource de Supabase para especialidades médicas
  static EspecialidadDataSource createSupabase({
    SupabaseClient? supabase,
    String tableName = 'tespecialidades',
  }) {
    return SupabaseEspecialidadDataSource(
      supabase: supabase,
      tableName: tableName,
    );
  }
}
