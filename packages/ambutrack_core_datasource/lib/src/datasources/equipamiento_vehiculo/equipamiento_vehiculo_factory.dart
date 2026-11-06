import 'package:supabase_flutter/supabase_flutter.dart';

import 'equipamiento_vehiculo_contract.dart';
import 'implementations/supabase/supabase_equipamiento_vehiculo_datasource.dart';

/// Factory para crear instancias de [EquipamientoVehiculoDataSource]
class EquipamientoVehiculoDataSourceFactory {
  /// Crea una instancia con implementación Supabase
  static EquipamientoVehiculoDataSource createSupabase({SupabaseClient? client}) {
    return SupabaseEquipamientoVehiculoDataSource(client ?? Supabase.instance.client);
  }
}
