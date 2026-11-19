import 'package:supabase_flutter/supabase_flutter.dart';

import 'implementations/supabase/supabase_plantilla_turno_datasource.dart';
import 'plantilla_turno_contract.dart';

/// Factory para crear instancias de PlantillaTurnoDataSource
///
/// Proporciona métodos estáticos para crear datasources
/// de plantillas de turno con diferentes backends.
class PlantillaTurnoDataSourceFactory {
  /// Crea un datasource de plantillas de turno usando Supabase
  ///
  /// [client]: Cliente de Supabase (opcional, usa instance global si no se provee)
  /// Returns: Instancia de PlantillaTurnoDataSource configurada para Supabase
  static PlantillaTurnoDataSource createSupabase([SupabaseClient? client]) {
    return SupabasePlantillaTurnoDataSource(
      client ?? Supabase.instance.client,
    );
  }
}
