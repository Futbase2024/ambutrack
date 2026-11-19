import 'package:supabase_flutter/supabase_flutter.dart';

import 'implementations/supabase/supabase_incidencia_vehiculo_datasource.dart';
import 'incidencia_vehiculo_contract.dart';

/// Factory para crear instancias de IncidenciaVehiculoDataSource
class IncidenciaVehiculoDataSourceFactory {
  /// Crea una instancia de Supabase DataSource
  static IncidenciaVehiculoDataSource createSupabase({
    SupabaseClient? supabaseClient,
  }) {
    return SupabaseIncidenciaVehiculoDataSource(
      supabaseClient: supabaseClient,
    );
  }
}
