import 'package:supabase_flutter/supabase_flutter.dart';

import 'checklist_vehiculo_contract.dart';
import 'implementations/supabase/supabase_checklist_vehiculo_datasource.dart';

/// Factory para crear instancias de ChecklistVehiculoDataSource
class ChecklistVehiculoDataSourceFactory {
  /// Crea una instancia de Supabase DataSource
  static ChecklistVehiculoDataSource createSupabase({
    SupabaseClient? supabaseClient,
  }) {
    return SupabaseChecklistVehiculoDataSource(
      supabaseClient: supabaseClient,
    );
  }
}
