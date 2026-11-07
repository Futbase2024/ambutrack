import 'curso_contract.dart';
import 'implementations/supabase/supabase_curso_datasource.dart';

/// Factory para crear instancias de CursoDataSource
class CursoDataSourceFactory {
  const CursoDataSourceFactory._();

  /// Crea una instancia de Supabase DataSource
  static CursoDataSource createSupabase() {
    return SupabaseCursoDataSource();
  }
}
