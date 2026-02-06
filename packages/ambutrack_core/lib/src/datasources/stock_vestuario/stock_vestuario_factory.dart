import 'package:ambutrack_core/src/datasources/stock_vestuario/implementations/supabase/supabase_stock_vestuario_datasource.dart';
import 'package:ambutrack_core/src/datasources/stock_vestuario/stock_vestuario_contract.dart';

/// Factory para crear instancias de StockVestuarioDataSource
class StockVestuarioDataSourceFactory {
  /// Crea una instancia de Supabase DataSource
  static StockVestuarioDataSource createSupabase() {
    return SupabaseStockVestuarioDataSource();
  }
}
