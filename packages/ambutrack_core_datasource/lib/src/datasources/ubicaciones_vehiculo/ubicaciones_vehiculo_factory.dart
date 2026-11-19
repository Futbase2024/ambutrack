import 'package:supabase_flutter/supabase_flutter.dart';

import 'implementations/supabase/supabase_ubicaciones_vehiculo_datasource.dart';
import 'ubicaciones_vehiculo_contract.dart';

/// Factory del datasource de seguimiento GPS
class UbicacionesVehiculoDataSourceFactory {
  static UbicacionesVehiculoDataSource createSupabase({SupabaseClient? supabase}) {
    return SupabaseUbicacionesVehiculoDataSource(supabase: supabase);
  }
}
