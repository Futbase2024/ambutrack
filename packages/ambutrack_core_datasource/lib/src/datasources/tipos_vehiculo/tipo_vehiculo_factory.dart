import 'implementations/supabase/supabase_tipo_vehiculo_datasource.dart';
import 'tipo_vehiculo_contract.dart';

/// Factory para crear instancias de TipoVehiculoDataSource
class TipoVehiculoDataSourceFactory {
  /// Crea una instancia de Supabase datasource
  static TipoVehiculoDataSource createSupabase() {
    return SupabaseTipoVehiculoDataSource();
  }
}
