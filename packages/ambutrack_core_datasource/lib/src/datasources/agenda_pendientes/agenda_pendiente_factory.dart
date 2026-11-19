import 'package:supabase_flutter/supabase_flutter.dart';

import 'agenda_pendiente_contract.dart';
import 'implementations/supabase/supabase_agenda_pendiente_datasource.dart';

/// Factory class para crear instancias de [AgendaPendienteDataSource]
///
/// Proporciona una forma centralizada de crear diferentes
/// implementaciones del datasource de agenda de pendientes.
class AgendaPendienteDataSourceFactory {
  /// Crea un datasource de Supabase con configuración por defecto
  ///
  /// [supabase] - Cliente de Supabase (opcional, usa el global)
  /// [tableName] - Nombre de la tabla (por defecto 'tagenda_pendientes')
  static AgendaPendienteDataSource createSupabase({
    SupabaseClient? supabase,
    String tableName = 'tagenda_pendientes',
  }) {
    return SupabaseAgendaPendienteDataSource(
      supabase: supabase,
      tableName: tableName,
    );
  }
}
