import 'package:supabase_flutter/supabase_flutter.dart';

import 'implementations/supabase/supabase_tecnicos_en_turno_datasource.dart';
import 'tecnicos_en_turno_contract.dart';

/// Factory para crear instancias de [TecnicosEnTurnoDataSource]
class TecnicosEnTurnoDataSourceFactory {
  /// Crea un datasource de Supabase con configuración por defecto
  static TecnicosEnTurnoDataSource createSupabase({SupabaseClient? supabase}) {
    return SupabaseTecnicosEnTurnoDataSource(supabase: supabase);
  }
}
