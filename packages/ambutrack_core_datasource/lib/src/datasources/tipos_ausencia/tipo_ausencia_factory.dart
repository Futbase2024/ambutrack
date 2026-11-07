import 'implementations/supabase/supabase_tipo_ausencia_datasource.dart';
import 'tipo_ausencia_contract.dart';

/// Factory para crear instancias de TipoAusenciaDataSource
class TipoAusenciaDataSourceFactory {
  /// Crea una instancia de Supabase DataSource
  static TipoAusenciaDataSource createSupabase() {
    return SupabaseTipoAusenciaDataSource();
  }
}
