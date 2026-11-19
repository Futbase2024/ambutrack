import 'package:supabase_flutter/supabase_flutter.dart';

import 'dispositivos_push_contract.dart';
import 'implementations/supabase/supabase_dispositivos_push_datasource.dart';

/// Factory de [DispositivosPushDataSource]
class DispositivosPushDataSourceFactory {
  const DispositivosPushDataSourceFactory._();

  /// Datasource sobre Supabase (RPCs `fn_registrar_dispositivo_push` / `fn_eliminar_dispositivo_push`)
  static DispositivosPushDataSource createSupabase({SupabaseClient? supabase}) {
    return SupabaseDispositivosPushDataSource(supabase: supabase);
  }
}
