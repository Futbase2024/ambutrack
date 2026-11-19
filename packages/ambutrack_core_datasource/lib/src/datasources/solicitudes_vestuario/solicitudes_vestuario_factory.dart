import 'package:supabase_flutter/supabase_flutter.dart';

import 'implementations/supabase/supabase_solicitudes_vestuario_datasource.dart';
import 'solicitudes_vestuario_contract.dart';

/// Factory del datasource de solicitudes de vestuario
class SolicitudesVestuarioDataSourceFactory {
  static SolicitudesVestuarioDataSource createSupabase({SupabaseClient? supabase}) {
    return SupabaseSolicitudesVestuarioDataSource(supabase: supabase);
  }
}
