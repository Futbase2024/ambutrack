import 'package:supabase_flutter/supabase_flutter.dart';

import 'producto_contract.dart';
import 'implementations/supabase/supabase_producto_datasource.dart';

/// Factory para crear instancias de ProductoDataSource
///
/// Proporciona métodos estáticos para crear datasources de productos
/// con diferentes backends (actualmente solo Supabase)
class ProductoDataSourceFactory {
  ProductoDataSourceFactory._();

  /// Crea un datasource de Producto usando Supabase
  ///
  /// Usa la instancia global de Supabase configurada en la app
  static ProductoDataSource createSupabase() {
    return SupabaseProductoDataSource(Supabase.instance.client);
  }

  /// Crea un datasource de Producto usando un cliente Supabase específico
  ///
  /// Útil para testing o múltiples clientes
  static ProductoDataSource createSupabaseWithClient(SupabaseClient client) {
    return SupabaseProductoDataSource(client);
  }
}
