import 'package:supabase_flutter/supabase_flutter.dart';

import 'implementations/supabase/supabase_paciente_datasource.dart';
import 'paciente_contract.dart';

/// Factory para crear instancias de PacienteDataSource
class PacienteDataSourceFactory {
  /// Crea una instancia de PacienteDataSource usando Supabase
  static PacienteDataSource createSupabase() {
    return SupabasePacienteDataSource(Supabase.instance.client);
  }
}
