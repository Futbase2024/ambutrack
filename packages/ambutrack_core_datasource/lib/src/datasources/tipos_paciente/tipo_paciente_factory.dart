import 'package:supabase_flutter/supabase_flutter.dart';

import 'implementations/supabase/supabase_tipo_paciente_datasource.dart';
import 'tipo_paciente_contract.dart';

/// Factory para crear instancias de TipoPacienteDataSource
///
/// Proporciona métodos de creación para diferentes implementaciones
/// del datasource de tipos de paciente.
class TipoPacienteDataSourceFactory {
  /// Crea una instancia de datasource usando Supabase
  ///
  /// [supabase] - Cliente de Supabase (opcional, usa instancia global por defecto)
  /// [tableName] - Nombre de la tabla en Supabase (por defecto 'ttipos_paciente')
  static TipoPacienteDataSource createSupabase({
    SupabaseClient? supabase,
    String tableName = 'ttipos_paciente',
  }) {
    return SupabaseTipoPacienteDataSource(
      supabase: supabase,
      tableName: tableName,
    );
  }
}
