import 'formacion_personal_contract.dart';
import 'implementations/supabase/supabase_formacion_personal_datasource.dart';

/// Factory para crear instancias de FormacionPersonalDataSource
class FormacionPersonalDataSourceFactory {
  const FormacionPersonalDataSourceFactory._();

  /// Crea una instancia de Supabase DataSource
  static FormacionPersonalDataSource createSupabase() {
    return SupabaseFormacionPersonalDataSource();
  }
}
