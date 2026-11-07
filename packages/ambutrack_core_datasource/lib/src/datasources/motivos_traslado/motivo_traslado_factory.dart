import 'package:supabase_flutter/supabase_flutter.dart';

import 'motivo_traslado_contract.dart';
import 'implementations/supabase/supabase_motivo_traslado_datasource.dart';

/// Factory class para crear instancias de [MotivoTrasladoDataSource]
class MotivoTrasladoDataSourceFactory {
  /// Crea un datasource de Supabase con configuración por defecto
  static MotivoTrasladoDataSource createSupabase({
    SupabaseClient? supabase,
    String tableName = 'tmotivos_traslado',
  }) {
    return SupabaseMotivoTrasladoDataSource(
      supabase: supabase,
      tableName: tableName,
    );
  }
}
