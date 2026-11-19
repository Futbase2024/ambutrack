import 'package:supabase_flutter/supabase_flutter.dart';

import 'evaluaciones_desempeno_contract.dart';
import 'implementations/supabase/supabase_evaluaciones_desempeno_datasource.dart';

/// Factory para crear instancias del datasource de Evaluaciones de Desempeño
class EvaluacionesDesempenoDataSourceFactory {
  static EvaluacionesDesempenoDataSource createSupabase({
    SupabaseClient? supabase,
    String tableName = 'tevaluaciones_desempeno',
  }) {
    return SupabaseEvaluacionesDesempenoDataSource(supabase: supabase, tableName: tableName);
  }
}
