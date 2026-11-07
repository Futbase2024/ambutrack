import 'package:supabase_flutter/supabase_flutter.dart';

import 'implementations/supabase/supabase_turno_datasource.dart';
import 'turno_contract.dart';

/// Factory para crear instancias de TurnoDataSource
///
/// Proporciona métodos estáticos para crear datasources
/// de turnos con diferentes backends.
class TurnoDataSourceFactory {
  /// Crea un datasource de turnos usando Supabase
  ///
  /// [client]: Cliente de Supabase (opcional, usa instance global si no se provee)
  /// Returns: Instancia de TurnoDataSource configurada para Supabase
  static TurnoDataSource createSupabase([SupabaseClient? client]) {
    return SupabaseTurnoDataSource(client ?? Supabase.instance.client);
  }
}
