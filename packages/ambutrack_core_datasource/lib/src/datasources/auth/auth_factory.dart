import 'auth_contract.dart';
import 'implementations/supabase/supabase_auth_datasource.dart';

/// Factory para crear instancias de AuthDataSource
class AuthDataSourceFactory {
  /// Crea una instancia de AuthDataSource usando Supabase
  static AuthDataSource createSupabase() {
    return SupabaseAuthDataSource();
  }
}
