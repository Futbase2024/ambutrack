import 'package:ambutrack_core_datasource/src/datasources/almacen/implementations/supabase/supabase_proveedor_datasource.dart';
import 'package:ambutrack_core_datasource/src/datasources/almacen/proveedor_contract.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Factory para crear instancias de ProveedorDataSource
class ProveedorDataSourceFactory {
  ProveedorDataSourceFactory._();

  /// Crea una instancia de ProveedorDataSource usando Supabase como backend
  static ProveedorDataSource createSupabase() {
    return SupabaseProveedorDataSource(Supabase.instance.client);
  }

  /// Crea una instancia de ProveedorDataSource usando un cliente Supabase específico
  static ProveedorDataSource createSupabaseWithClient(SupabaseClient client) {
    return SupabaseProveedorDataSource(client);
  }
}
