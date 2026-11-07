import 'package:supabase_flutter/supabase_flutter.dart';

import 'implementations/supabase/supabase_ordenes_reparacion_datasource.dart';
import 'ordenes_reparacion_contract.dart';

/// Factory para crear instancias del datasource de Órdenes de Reparación
class OrdenesReparacionDataSourceFactory {
  static OrdenesReparacionDataSource createSupabase({
    SupabaseClient? supabase,
    String ordenesTable = 'tordenes_reparacion',
    String repuestosTable = 'trepuestos_orden',
  }) {
    return SupabaseOrdenesReparacionDataSource(
      supabase: supabase,
      ordenesTable: ordenesTable,
      repuestosTable: repuestosTable,
    );
  }
}
