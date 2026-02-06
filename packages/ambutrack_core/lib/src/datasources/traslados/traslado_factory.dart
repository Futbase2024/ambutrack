import 'package:supabase_flutter/supabase_flutter.dart';

import 'implementations/supabase/supabase_traslado_datasource.dart';
import 'traslado_contract.dart';

/// Factory para crear instancias de TrasladoDataSource
class TrasladoDataSourceFactory {
  /// Crea una instancia de TrasladoDataSource usando Supabase
  static TrasladoDataSource createSupabase() {
    return SupabaseTrasladosDataSource(Supabase.instance.client);
  }
}
