import 'package:supabase_flutter/supabase_flutter.dart';

import 'alertas_caducidad_contract.dart';
import 'implementations/supabase/supabase_alertas_caducidad_datasource.dart';

/// Factory class para crear instancias de [AlertasCaducidadDataSource]
///
/// Este factory proporciona una forma centralizada de crear diferentes
/// implementaciones del datasource de alertas de caducidad
class AlertasCaducidadDataSourceFactory {
  /// Crea un datasource de Supabase con configuración por defecto
  ///
  /// [supabase] - Cliente de Supabase (opcional, usa el cliente global por defecto)
  /// [viewName] - Nombre de la vista materializada en Supabase (por defecto 'vw_alertas_caducidad_activas')
  static AlertasCaducidadDataSource createSupabase({
    SupabaseClient? supabase,
    String viewName = 'vw_alertas_caducidad_activas',
  }) {
    return SupabaseAlertasCaducidadDataSource(
      supabase: supabase,
      viewName: viewName,
    );
  }
}
