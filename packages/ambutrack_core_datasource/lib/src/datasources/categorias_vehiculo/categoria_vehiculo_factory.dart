import 'categoria_vehiculo_contract.dart';
import 'implementations/supabase/supabase_categoria_vehiculo_datasource.dart';

/// Factory para crear instancias de CategoriaVehiculoDataSource
class CategoriaVehiculoDataSourceFactory {
  /// Crea una instancia de Supabase DataSource
  static CategoriaVehiculoDataSource createSupabase() {
    return SupabaseCategoriaVehiculoDataSource();
  }
}
