import 'package:supabase_flutter/supabase_flutter.dart';

import 'auth_datasource_contract.dart';
import 'implementations/supabase_auth_datasource.dart';

/// Factory para crear instancias de AuthDataSource
///
/// Centraliza la creación del datasource y permite cambiar
/// la implementación fácilmente.
class AuthDataSourceFactory {
  /// Crea una instancia del datasource de Supabase
  static AuthDataSource createSupabase() {
    final client = Supabase.instance.client;
    return SupabaseAuthDataSource(client);
  }
}
