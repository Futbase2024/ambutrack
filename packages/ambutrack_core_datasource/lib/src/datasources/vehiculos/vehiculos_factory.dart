import 'package:supabase_flutter/supabase_flutter.dart';

import 'vehiculos_contract.dart';
import 'implementations/supabase/supabase_vehiculo_datasource.dart';

/// Factory class para crear instancias de [VehiculoDataSource]
///
/// Este factory proporciona una forma centralizada de crear diferentes
/// implementaciones del datasource de vehículos basándose en la configuración
class VehiculoDataSourceFactory {
  /// Crea un datasource de Supabase con configuración por defecto
  ///
  /// [supabase] - Cliente de Supabase (opcional, usa el cliente global por defecto)
  /// [tableName] - Nombre de la tabla en Supabase (por defecto 'tvehiculos')
  static VehiculoDataSource createSupabase({
    SupabaseClient? supabase,
    String tableName = 'tvehiculos',
  }) {
    return SupabaseVehiculoDataSource(
      supabase: supabase,
      tableName: tableName,
    );
  }
}
