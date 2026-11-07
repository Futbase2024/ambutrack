import 'certificacion_contract.dart';
import 'implementations/supabase/supabase_certificacion_datasource.dart';

/// Factory para crear instancias de CertificacionDataSource
class CertificacionDataSourceFactory {
  const CertificacionDataSourceFactory._();

  /// Crea una instancia de Supabase DataSource
  static CertificacionDataSource createSupabase() {
    return SupabaseCertificacionDataSource();
  }
}
