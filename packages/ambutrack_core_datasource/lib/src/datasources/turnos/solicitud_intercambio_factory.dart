import 'package:supabase_flutter/supabase_flutter.dart';

import 'implementations/supabase/supabase_solicitud_intercambio_datasource.dart';
import 'solicitud_intercambio_contract.dart';

/// Factory para crear instancias de SolicitudIntercambioDataSource
///
/// Proporciona métodos estáticos para crear datasources
/// de solicitudes de intercambio con diferentes backends.
class SolicitudIntercambioDataSourceFactory {
  /// Crea un datasource de solicitudes de intercambio usando Supabase
  ///
  /// [client]: Cliente de Supabase (opcional, usa instance global si no se provee)
  /// Returns: Instancia de SolicitudIntercambioDataSource configurada para Supabase
  static SolicitudIntercambioDataSource createSupabase([
    SupabaseClient? client,
  ]) {
    return SupabaseSolicitudIntercambioDataSource(
      client ?? Supabase.instance.client,
    );
  }
}
