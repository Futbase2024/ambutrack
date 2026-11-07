import 'package:supabase_flutter/supabase_flutter.dart';

import 'itv_revision_contract.dart';
import 'implementations/supabase/supabase_itv_revision_datasource.dart';

/// Factory class para crear instancias de [ItvRevisionDataSource]
///
/// Este factory proporciona una forma centralizada de crear diferentes
/// implementaciones del datasource de ITV/Revisiones basándose en la configuración
class ItvRevisionDataSourceFactory {
  /// Crea un datasource de Supabase con configuración por defecto
  ///
  /// [supabase] - Cliente de Supabase (opcional, usa el cliente global por defecto)
  /// [tableName] - Nombre de la tabla en Supabase (por defecto 'titv_revisiones')
  static ItvRevisionDataSource createSupabase({
    SupabaseClient? supabase,
    String tableName = 'titv_revisiones',
  }) {
    return SupabaseItvRevisionDataSource(
      supabase: supabase,
      tableName: tableName,
    );
  }
}
