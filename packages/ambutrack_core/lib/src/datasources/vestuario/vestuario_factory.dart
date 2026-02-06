import 'package:ambutrack_core/src/datasources/vestuario/implementations/supabase/supabase_vestuario_datasource.dart';
import 'package:ambutrack_core/src/datasources/vestuario/vestuario_contract.dart';

/// Factory para crear instancias de VestuarioDataSource
class VestuarioDataSourceFactory {
  /// Crea un datasource de Vestuario para Supabase
  static VestuarioDataSource createSupabase() {
    return SupabaseVestuarioDataSource();
  }
}
