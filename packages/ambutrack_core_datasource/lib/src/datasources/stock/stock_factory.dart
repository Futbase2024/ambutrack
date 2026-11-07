import 'implementations/supabase/supabase_stock_datasource.dart';
import 'stock_contract.dart';

/// Factory para crear instancias de StockDataSource
class StockDataSourceFactory {
  /// Crea una instancia de StockDataSource con implementación Supabase
  static StockDataSource createSupabase() {
    return SupabaseStockDataSource();
  }
}
