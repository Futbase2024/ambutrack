import 'package:supabase_flutter/supabase_flutter.dart';

import 'mantenimiento_electromedicina_contract.dart';
import 'implementations/supabase/supabase_mantenimiento_electromedicina_datasource.dart';

/// Factory para crear instancias de MantenimientoElectromedicinaDataSource
///
/// Proporciona métodos estáticos para crear datasources de mantenimiento
/// de electromedicina con diferentes backends (actualmente solo Supabase)
class MantenimientoElectromedicinaDataSourceFactory {
  MantenimientoElectromedicinaDataSourceFactory._();

  /// Crea un datasource de MantenimientoElectromedicina usando Supabase
  ///
  /// Usa la instancia global de Supabase configurada en la app
  static MantenimientoElectromedicinaDataSource createSupabase() {
    return SupabaseMantenimientoElectromedicinaDataSource(Supabase.instance.client);
  }

  /// Crea un datasource de MantenimientoElectromedicina usando un cliente Supabase específico
  ///
  /// Útil para testing o múltiples clientes
  static MantenimientoElectromedicinaDataSource createSupabaseWithClient(SupabaseClient client) {
    return SupabaseMantenimientoElectromedicinaDataSource(client);
  }
}
