import 'package:supabase_flutter/supabase_flutter.dart';

import 'motivo_cancelacion_contract.dart';
import 'implementations/supabase/supabase_motivo_cancelacion_datasource.dart';

/// Factory class para crear instancias de [MotivoCancelacionDataSource]
///
/// Este factory proporciona una forma centralizada de crear diferentes
/// implementaciones del datasource de motivos de cancelación.
class MotivoCancelacionDataSourceFactory {
  /// Crea un datasource de Supabase con configuración por defecto
  ///
  /// [supabase] - Cliente de Supabase (opcional, usa el cliente global por defecto)
  /// [tableName] - Nombre de la tabla en Supabase (por defecto 'tmotivos_cancelacion')
  static MotivoCancelacionDataSource createSupabase({
    SupabaseClient? supabase,
    String tableName = 'tmotivos_cancelacion',
  }) {
    return SupabaseMotivoCancelacionDataSource(
      supabase: supabase,
      tableName: tableName,
    );
  }
}
