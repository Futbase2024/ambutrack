import 'package:supabase_flutter/supabase_flutter.dart';

import 'implementations/supabase/supabase_protocolos_normativas_datasource.dart';
import 'protocolos_normativas_contract.dart';

/// Factory para crear instancias del datasource de Protocolos y Normativas
class ProtocolosNormativasDataSourceFactory {
  static ProtocolosNormativasDataSource createSupabase({
    SupabaseClient? supabase,
    String tableName = 'tprotocolos_normativas',
  }) {
    return SupabaseProtocolosNormativasDataSource(supabase: supabase, tableName: tableName);
  }
}
