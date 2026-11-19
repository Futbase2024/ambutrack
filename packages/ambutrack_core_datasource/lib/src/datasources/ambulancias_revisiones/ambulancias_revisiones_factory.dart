import 'package:supabase_flutter/supabase_flutter.dart';

import 'ambulancias_revisiones_contract.dart';
import 'implementations/supabase/supabase_ambulancias_datasource.dart';

/// Factory class para crear instancias de [AmbulanciasRevisionesDataSource]
///
/// Este factory proporciona una forma centralizada de crear diferentes
/// implementaciones del datasource de ambulancias y revisiones basándose en la configuración
class AmbulanciasRevisionesDataSourceFactory {
  /// Crea un datasource de Supabase con configuración por defecto
  ///
  /// [supabaseClient] - Cliente de Supabase (opcional, usa el cliente global por defecto)
  /// [tableName] - Nombre de la tabla principal de ambulancias (por defecto 'amb_ambulancias')
  /// [tiposTableName] - Nombre de la tabla de tipos de ambulancia (por defecto 'amb_tipos_ambulancia')
  /// [revisionesTableName] - Nombre de la tabla de revisiones (por defecto 'amb_revisiones')
  /// [itemsTableName] - Nombre de la tabla de items de revisión (por defecto 'amb_items_revision')
  static AmbulanciasRevisionesDataSource createSupabase({
    SupabaseClient? supabaseClient,
    String tableName = 'amb_ambulancias',
    String tiposTableName = 'amb_tipos_ambulancia',
    String revisionesTableName = 'amb_revisiones',
    String itemsTableName = 'amb_items_revision',
  }) {
    return SupabaseAmbulanciasDataSource(
      supabaseClient: supabaseClient,
      tableName: tableName,
      tiposTableName: tiposTableName,
      revisionesTableName: revisionesTableName,
      itemsTableName: itemsTableName,
    );
  }
}
