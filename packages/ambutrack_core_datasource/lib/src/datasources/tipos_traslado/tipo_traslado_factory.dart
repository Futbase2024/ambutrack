import 'package:supabase_flutter/supabase_flutter.dart';

import 'implementations/supabase/supabase_tipo_traslado_datasource.dart';
import 'tipo_traslado_contract.dart';

/// Factory para crear instancias de TipoTrasladoDataSource
class TipoTrasladoDataSourceFactory {
  /// Crea una instancia de TipoTrasladoDataSource usando Supabase
  static TipoTrasladoDataSource createSupabase() {
    return SupabaseTipoTrasladoDataSource(Supabase.instance.client);
  }
}
