import 'historial_medico_contract.dart';
import 'implementations/supabase/supabase_historial_medico_datasource.dart';

/// Factory para crear instancias de HistorialMedicoDataSource
class HistorialMedicoDataSourceFactory {
  /// Crea una instancia de Supabase DataSource
  static HistorialMedicoDataSource createSupabase() {
    return SupabaseHistorialMedicoDataSource();
  }
}
