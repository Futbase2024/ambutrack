import 'equipamiento_personal_contract.dart';
import 'implementations/supabase/supabase_equipamiento_personal_datasource.dart';

/// Factory para crear instancias de EquipamientoPersonalDataSource
class EquipamientoPersonalDataSourceFactory {
  const EquipamientoPersonalDataSourceFactory._();

  /// Crea una instancia de Supabase DataSource
  static EquipamientoPersonalDataSource createSupabase() {
    return SupabaseEquipamientoPersonalDataSource();
  }
}
