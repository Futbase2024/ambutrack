import 'package:ambutrack_core_datasource/src/datasources/excepciones_festivos/excepciones_festivos_contract.dart';
import 'package:ambutrack_core_datasource/src/datasources/excepciones_festivos/implementations/supabase/supabase_excepciones_festivos_datasource.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Factory para crear instancias de ExcepcionesFestivosDataSource
class ExcepcionesFestivosDataSourceFactory {
  /// Crea una instancia de Supabase DataSource
  static ExcepcionesFestivosDataSource createSupabase() {
    return SupabaseExcepcionesFestivosDataSource(
      Supabase.instance.client,
    );
  }
}
