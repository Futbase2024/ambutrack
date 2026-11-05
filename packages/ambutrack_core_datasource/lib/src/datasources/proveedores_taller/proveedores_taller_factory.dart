import 'package:supabase_flutter/supabase_flutter.dart';

import 'implementations/supabase/supabase_proveedores_taller_datasource.dart';
import 'proveedores_taller_contract.dart';

/// Factory para crear instancias del datasource de Proveedores de Taller
class ProveedoresTallerDataSourceFactory {
  static ProveedoresTallerDataSource createSupabase({
    SupabaseClient? supabase,
    String tableName = 'tproveedores_taller',
  }) {
    return SupabaseProveedoresTallerDataSource(
      supabase: supabase,
      tableName: tableName,
    );
  }
}
