import 'ausencia_contract.dart';
import 'implementations/supabase/supabase_ausencia_datasource.dart';

/// Factory para crear instancias de AusenciaDataSource
class AusenciaDataSourceFactory {
  /// Crea una instancia de Supabase DataSource
  static AusenciaDataSource createSupabase() {
    return SupabaseAusenciaDataSource();
  }
}
