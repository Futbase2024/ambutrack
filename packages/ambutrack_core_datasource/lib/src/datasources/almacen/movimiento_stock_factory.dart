import 'package:supabase_flutter/supabase_flutter.dart';

import 'movimiento_stock_contract.dart';
import 'implementations/supabase/supabase_movimiento_stock_datasource.dart';

/// Factory para crear instancias de MovimientoStockDataSource
///
/// Proporciona métodos estáticos para crear datasources de movimientos de stock
/// con diferentes backends (actualmente solo Supabase)
class MovimientoStockDataSourceFactory {
  MovimientoStockDataSourceFactory._();

  /// Crea un datasource de MovimientoStock usando Supabase
  ///
  /// Usa la instancia global de Supabase configurada en la app
  static MovimientoStockDataSource createSupabase() {
    return SupabaseMovimientoStockDataSource(Supabase.instance.client);
  }

  /// Crea un datasource de MovimientoStock usando un cliente Supabase específico
  ///
  /// Útil para testing o múltiples clientes
  static MovimientoStockDataSource createSupabaseWithClient(SupabaseClient client) {
    return SupabaseMovimientoStockDataSource(client);
  }
}
