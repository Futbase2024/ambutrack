import 'package:supabase_flutter/supabase_flutter.dart';

import 'busqueda_global_contract.dart';
import 'implementations/supabase/supabase_busqueda_global_datasource.dart';

/// Factory del datasource de búsqueda global
class BusquedaGlobalDataSourceFactory {
  static BusquedaGlobalDataSource createSupabase({SupabaseClient? supabase}) {
    return SupabaseBusquedaGlobalDataSource(supabase: supabase);
  }
}
