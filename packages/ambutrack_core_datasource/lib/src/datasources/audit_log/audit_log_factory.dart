import 'package:supabase_flutter/supabase_flutter.dart';

import 'audit_log_contract.dart';
import 'implementations/supabase/supabase_audit_log_datasource.dart';

/// Factory del datasource de auditoría (tabla `audit_log`)
class AuditLogDataSourceFactory {
  static AuditLogDataSource createSupabase({
    SupabaseClient? supabase,
    String tableName = 'audit_log',
  }) {
    return SupabaseAuditLogDataSource(supabase: supabase, tableName: tableName);
  }
}
