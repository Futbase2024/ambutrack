import 'package:supabase_flutter/supabase_flutter.dart';

import 'facultativo_contract.dart';
import 'implementations/supabase/supabase_facultativo_datasource.dart';

/// Factory para crear instancias de FacultativoDataSource
///
/// Proporciona métodos de creación para diferentes implementaciones
/// del datasource de facultativos.
class FacultativoDataSourceFactory {
  /// Crea una instancia de datasource usando Supabase
  ///
  /// [supabase] - Cliente de Supabase (opcional, usa instancia global por defecto)
  /// [tableName] - Nombre de la tabla en Supabase (por defecto 'tfacultativos')
  static FacultativoDataSource createSupabase({
    SupabaseClient? supabase,
    String tableName = 'tfacultativos',
  }) {
    return SupabaseFacultativoDataSource(
      supabase: supabase,
      tableName: tableName,
    );
  }
}
