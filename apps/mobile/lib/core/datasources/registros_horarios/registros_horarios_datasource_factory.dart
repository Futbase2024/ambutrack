import 'package:supabase_flutter/supabase_flutter.dart';

import 'implementations/supabase_registros_horarios_datasource.dart';
import 'registros_horarios_datasource_contract.dart';

/// Factory para crear instancias de RegistrosHorariosDataSource
///
/// Centraliza la creación de datasources siguiendo el patrón Factory.
class RegistrosHorariosDataSourceFactory {
  /// Crea una instancia de Supabase del datasource
  static RegistrosHorariosDataSource createSupabase() {
    final client = Supabase.instance.client;
    return SupabaseRegistrosHorariosDataSource(client);
  }
}
