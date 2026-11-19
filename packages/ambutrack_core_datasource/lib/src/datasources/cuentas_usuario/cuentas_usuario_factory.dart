import 'package:supabase_flutter/supabase_flutter.dart';

import 'cuentas_usuario_contract.dart';
import 'implementations/supabase/supabase_cuentas_usuario_datasource.dart';

/// Factory de [CuentasUsuarioDataSource]
class CuentasUsuarioDataSourceFactory {
  const CuentasUsuarioDataSourceFactory._();

  /// Datasource sobre la Edge Function `admin-users`
  static CuentasUsuarioDataSource createSupabase({SupabaseClient? supabase}) {
    return SupabaseCuentasUsuarioDataSource(supabase: supabase);
  }
}
