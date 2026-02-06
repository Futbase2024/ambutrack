import 'package:ambutrack_core/src/datasources/vacaciones/implementations/supabase/supabase_vacaciones_datasource.dart';
import 'package:ambutrack_core/src/datasources/vacaciones/vacaciones_contract.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Factory para crear instancias de VacacionesDataSource
class VacacionesDataSourceFactory {
  /// Crea datasource usando Supabase
  static VacacionesDataSource createSupabase() {
    return SupabaseVacacionesDataSource(Supabase.instance.client);
  }
}
