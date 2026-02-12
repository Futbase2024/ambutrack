import 'notificaciones_contract.dart';
import 'implementations/supabase/supabase_notificaciones_datasource.dart';

/// Factory para crear instancias del datasource de notificaciones
class NotificacionesDataSourceFactory {
  /// Crea una instancia del datasource de notificaciones con Supabase
  static NotificacionesDataSource createSupabase({
    required String empresaId,
  }) {
    return SupabaseNotificacionesDataSource(empresaId: empresaId);
  }
}
