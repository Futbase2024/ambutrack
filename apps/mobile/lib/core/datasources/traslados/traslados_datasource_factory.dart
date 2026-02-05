import 'package:supabase_flutter/supabase_flutter.dart';

import 'implementations/supabase_traslados_datasource.dart';
import 'traslados_datasource_contract.dart';

/// Factory para crear instancias del datasource de traslados
class TrasladosDataSourceFactory {
  /// Crea una instancia del datasource usando Supabase
  static TrasladosDataSource createSupabase() {
    final client = Supabase.instance.client;
    return SupabaseTrasladosDataSource(client);
  }
}
