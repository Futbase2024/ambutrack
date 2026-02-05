import 'package:supabase_flutter/supabase_flutter.dart';

import 'implementations/supabase_personal_datasource.dart';
import 'personal_datasource_contract.dart';

/// Factory para crear instancias de PersonalDataSource
///
/// Sigue el patrón obligatorio de AmbuTrack para datasources.
class PersonalDataSourceFactory {
  const PersonalDataSourceFactory._();

  /// Crea una instancia del datasource usando Supabase
  static PersonalDataSource createSupabase() {
    final client = Supabase.instance.client;
    return SupabasePersonalDataSource(client);
  }
}
