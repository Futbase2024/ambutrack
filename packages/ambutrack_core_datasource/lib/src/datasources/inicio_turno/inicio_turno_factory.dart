import 'package:supabase_flutter/supabase_flutter.dart';

import 'implementations/supabase/supabase_inicio_turno_datasource.dart';
import 'inicio_turno_contract.dart';

/// Factory del datasource de entrada en turno
class InicioTurnoDataSourceFactory {
  static InicioTurnoDataSource createSupabase({SupabaseClient? supabase}) {
    return SupabaseInicioTurnoDataSource(supabase: supabase);
  }
}
