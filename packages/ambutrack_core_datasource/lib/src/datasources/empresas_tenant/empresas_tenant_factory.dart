import 'package:supabase_flutter/supabase_flutter.dart';

import 'empresas_tenant_contract.dart';
import 'implementations/supabase/supabase_empresas_tenant_datasource.dart';

/// Factory del datasource de empresas (multi-tenant)
class EmpresasTenantDataSourceFactory {
  static EmpresasTenantDataSource createSupabase({
    SupabaseClient? supabase,
    String tableName = 'empresas',
  }) {
    return SupabaseEmpresasTenantDataSource(
      supabase: supabase,
      tableName: tableName,
    );
  }
}
