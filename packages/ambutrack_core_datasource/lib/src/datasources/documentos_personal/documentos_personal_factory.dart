import 'package:supabase_flutter/supabase_flutter.dart';

import 'documentos_personal_contract.dart';
import 'implementations/supabase/supabase_documentos_personal_datasource.dart';

/// Factory para crear instancias del datasource de Documentación del Personal
class DocumentosPersonalDataSourceFactory {
  static DocumentosPersonalDataSource createSupabase({
    SupabaseClient? supabase,
    String tableName = 'tdocumentos_personal',
  }) {
    return SupabaseDocumentosPersonalDataSource(supabase: supabase, tableName: tableName);
  }
}
