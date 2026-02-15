import 'package:supabase_flutter/supabase_flutter.dart';

import 'consumo_combustible_contract.dart';
import 'implementations/supabase/supabase_consumo_combustible_datasource.dart';

/// Factory class para crear instancias de [ConsumoCombustibleDataSource]
///
/// Este factory proporciona una forma centralizada de crear diferentes
/// implementaciones del datasource de consumo de combustible basándose en la configuración
class ConsumoCombustibleDataSourceFactory {
  /// Crea un datasource de Supabase con configuración por defecto
  ///
  /// [supabase] - Cliente de Supabase (opcional, usa el cliente global por defecto)
  /// [tableName] - Nombre de la tabla en Supabase (por defecto 'tconsumo_combustible')
  static ConsumoCombustibleDataSource createSupabase({
    SupabaseClient? supabase,
    String tableName = 'tconsumo_combustible',
  }) {
    return SupabaseConsumoCombustibleDataSource(
      supabase: supabase,
      tableName: tableName,
    );
  }
}
