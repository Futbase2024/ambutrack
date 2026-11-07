import 'package:supabase_flutter/supabase_flutter.dart';

import 'provincia_contract.dart';
import 'implementations/supabase/supabase_provincia_datasource.dart';

/// Factory class para crear instancias de [ProvinciaDataSource]
///
/// Este factory proporciona una forma centralizada de crear diferentes
/// implementaciones del datasource de provincias.
class ProvinciaDataSourceFactory {
  /// Crea un datasource de Supabase con configuración por defecto
  ///
  /// [supabase] - Cliente de Supabase (opcional, usa el cliente global por defecto)
  /// [tableName] - Nombre de la tabla en Supabase (por defecto 'tprovincias')
  static ProvinciaDataSource createSupabase({
    SupabaseClient? supabase,
    String tableName = 'tprovincias',
  }) {
    return SupabaseProvinciaDataSource(
      supabase: supabase,
      tableName: tableName,
    );
  }
}
