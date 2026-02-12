import 'package:ambutrack_core_datasource/src/datasources/cuadrante_asignaciones/cuadrante_asignacion_contract.dart';
import 'package:ambutrack_core_datasource/src/datasources/cuadrante_asignaciones/implementations/supabase/supabase_cuadrante_asignacion_datasource.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Factory para crear instancias de CuadranteAsignacionDataSource
class CuadranteAsignacionDataSourceFactory {
  /// Crea una instancia del datasource de Supabase
  static CuadranteAsignacionDataSource createSupabase() {
    return SupabaseCuadranteAsignacionDataSource(
      Supabase.instance.client,
    );
  }
}
