import 'package:supabase_flutter/supabase_flutter.dart';

import 'implementations/supabase/supabase_plantillas_equipamiento_datasource.dart';
import 'plantillas_equipamiento_contract.dart';

/// Factory para crear instancias de [PlantillasEquipamientoDataSource]
class PlantillasEquipamientoDataSourceFactory {
  /// Crea una instancia con implementación Supabase
  static PlantillasEquipamientoDataSource createSupabase({SupabaseClient? client}) {
    return SupabasePlantillasEquipamientoDataSource(client ?? Supabase.instance.client);
  }
}
