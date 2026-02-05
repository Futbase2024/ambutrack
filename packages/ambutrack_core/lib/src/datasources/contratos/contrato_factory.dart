import 'package:supabase_flutter/supabase_flutter.dart';

import 'contrato_contract.dart';
import 'implementations/supabase/supabase_contrato_datasource.dart';

/// Factory class para crear instancias de [ContratoDataSource]
class ContratoDataSourceFactory {
  /// Crea un datasource de Supabase con configuración por defecto
  static ContratoDataSource createSupabase({
    SupabaseClient? supabase,
    String tableName = 'contratos',
  }) {
    return SupabaseContratoDataSource(
      supabase: supabase,
      tableName: tableName,
    );
  }
}
