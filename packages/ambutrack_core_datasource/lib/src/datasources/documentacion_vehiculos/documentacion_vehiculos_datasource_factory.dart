import 'package:supabase_flutter/supabase_flutter.dart';

import 'implementations/supabase/supabase_documentacion_vehiculo_datasource.dart';
import 'implementations/supabase/supabase_tipo_documento_datasource.dart';
import 'tipo_documento_datasource_contract.dart';
import 'documentacion_vehiculo_datasource_contract.dart';

/// Factory para crear instancias de datasources de documentación de vehículos
class DocumentacionVehiculosDataSourceFactory {
  /// Crea una instancia de TipoDocumentoDataSource con Supabase
  static TipoDocumentoDataSource createTipoDocumento(
      {SupabaseClient? client}) {
    final supabaseClient = client ?? Supabase.instance.client;
    return SupabaseTipoDocumentoDataSource(supabaseClient);
  }

  /// Crea una instancia de DocumentacionVehiculoDataSource con Supabase
  static DocumentacionVehiculoDataSource createDocumentacionVehiculo(
      {SupabaseClient? client}) {
    final supabaseClient = client ?? Supabase.instance.client;
    return SupabaseDocumentacionVehiculoDataSource(supabaseClient);
  }
}
