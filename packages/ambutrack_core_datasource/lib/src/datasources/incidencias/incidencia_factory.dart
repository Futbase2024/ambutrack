import 'incidencia_contract.dart';
import 'implementations/supabase/supabase_incidencia_datasource.dart';

/// Factory para crear instancias del datasource de incidencias
class IncidenciaDataSourceFactory {
  /// Crea una instancia del datasource Supabase para incidencias
  static IncidenciaDataSource createSupabase() {
    return SupabaseIncidenciaDataSource();
  }
}
