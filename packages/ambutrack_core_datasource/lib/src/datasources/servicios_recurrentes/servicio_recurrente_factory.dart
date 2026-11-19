import 'package:supabase_flutter/supabase_flutter.dart';

import 'implementations/supabase/supabase_servicio_recurrente_datasource.dart';
import 'servicio_recurrente_contract.dart';

/// Factory para crear instancias de ServicioRecurrenteDataSource
class ServicioRecurrenteDataSourceFactory {
  /// Crea una instancia de ServicioRecurrenteDataSource usando Supabase
  static ServicioRecurrenteDataSource createSupabase() {
    return SupabaseServicioRecurrenteDataSource(Supabase.instance.client);
  }
}
