import 'package:supabase_flutter/supabase_flutter.dart';
import 'implementations/supabase/supabase_mantenimiento_datasource.dart';
import 'mantenimiento_contract.dart';

/// Factory para crear instancias de MantenimientoDataSource
class MantenimientoDataSourceFactory {
  /// Crea una instancia de MantenimientoDataSource para Supabase
  static MantenimientoDataSource createSupabase({
    SupabaseClient? supabase,
    String tableName = 'tmantenimientos',
  }) {
    return SupabaseMantenimientoDataSource(
      supabase: supabase,
      tableName: tableName,
    );
  }
}
