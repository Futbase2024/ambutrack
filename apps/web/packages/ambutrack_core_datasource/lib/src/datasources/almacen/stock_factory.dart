import 'package:supabase_flutter/supabase_flutter.dart';

import 'stock_contract.dart';
import 'implementations/supabase/supabase_stock_datasource.dart';

/// Factory para crear instancias de StockDataSource
///
/// Proporciona métodos estáticos para crear datasources de stock
/// con diferentes backends (actualmente solo Supabase)
class StockDataSourceFactory {
  StockDataSourceFactory._();

  /// Crea un datasource de Stock usando Supabase
  ///
  /// Usa la instancia global de Supabase configurada en la app
  static StockDataSource createSupabase() {
    return SupabaseStockDataSource(Supabase.instance.client);
  }

  /// Crea un datasource de Stock usando un cliente Supabase específico
  ///
  /// Útil para testing o múltiples clientes
  static StockDataSource createSupabaseWithClient(SupabaseClient client) {
    return SupabaseStockDataSource(client);
  }
}
