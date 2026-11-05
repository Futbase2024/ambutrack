import 'package:supabase_flutter/supabase_flutter.dart';

import 'generacion_traslados_contract.dart';
import 'implementations/supabase/supabase_generacion_traslados_datasource.dart';

/// Factory para crear instancias de GeneracionTrasladosDataSource
class GeneracionTrasladosDataSourceFactory {
  /// Crea una instancia usando Supabase
  static GeneracionTrasladosDataSource createSupabase() {
    return SupabaseGeneracionTrasladosDataSource(Supabase.instance.client);
  }
}
