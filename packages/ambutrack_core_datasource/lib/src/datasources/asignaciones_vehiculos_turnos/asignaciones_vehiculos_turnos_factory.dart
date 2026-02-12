import 'package:supabase_flutter/supabase_flutter.dart';

import 'asignaciones_vehiculos_turnos_contract.dart';
import 'implementations/supabase/supabase_asignaciones_vehiculos_turnos_datasource.dart';

/// Factory para crear instancias de AsignacionVehiculoTurnoDataSource
///
/// Proporciona métodos estáticos para crear datasources con diferentes backends
class AsignacionVehiculoTurnoDataSourceFactory {
  /// Crea una instancia de AsignacionVehiculoTurnoDataSource
  ///
  /// [type] - Tipo de datasource ('supabase', 'firebase', 'rest')
  /// [config] - Configuración adicional (opcional)
  ///
  /// Ejemplo:
  /// ```dart
  /// final dataSource = AsignacionVehiculoTurnoDataSourceFactory.create(
  ///   type: 'supabase',
  ///   config: {'table': 'asignaciones_vehiculos_turnos'},
  /// );
  /// ```
  static AsignacionVehiculoTurnoDataSource create({
    required String type,
    Map<String, dynamic>? config,
  }) {
    switch (type.toLowerCase()) {
      case 'supabase':
        return createSupabase(config: config);
      default:
        throw UnsupportedError('Tipo de datasource no soportado: $type');
    }
  }

  /// Crea una instancia de AsignacionVehiculoTurnoDataSource con backend Supabase
  ///
  /// [config] - Configuración opcional (table name, etc.)
  ///
  /// Ejemplo:
  /// ```dart
  /// final dataSource = AsignacionVehiculoTurnoDataSourceFactory.createSupabase(
  ///   config: {'table': 'asignaciones_vehiculos_turnos'},
  /// );
  /// ```
  static AsignacionVehiculoTurnoDataSource createSupabase(
      {Map<String, dynamic>? config}) {
    final SupabaseClient client = Supabase.instance.client;
    return SupabaseAsignacionVehiculoTurnoDataSource(client);
  }
}
