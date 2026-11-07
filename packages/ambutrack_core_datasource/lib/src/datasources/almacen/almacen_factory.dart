import 'package:supabase_flutter/supabase_flutter.dart';

import 'almacen_contract.dart';
import 'implementations/supabase/supabase_almacen_datasource.dart';

/// Factory para crear instancias de AlmacenDataSource
///
/// Proporciona métodos estáticos para crear datasources de almacén
/// con diferentes backends (actualmente solo Supabase)
class AlmacenDataSourceFactory {
  AlmacenDataSourceFactory._();

  /// Crea un datasource de Almacén usando Supabase
  ///
  /// Usa la instancia global de Supabase configurada en la app
  static AlmacenDataSource createSupabase() {
    return SupabaseAlmacenDataSource(Supabase.instance.client);
  }

  /// Crea un datasource de Almacén usando un cliente Supabase específico
  ///
  /// Útil para testing o múltiples clientes
  static AlmacenDataSource createSupabaseWithClient(SupabaseClient client) {
    return SupabaseAlmacenDataSource(client);
  }
}
