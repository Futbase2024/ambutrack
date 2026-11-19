import 'entities/tecnico_en_turno_entity.dart';

/// Categorías de personal consideradas "técnicos" por defecto
const List<String> kCategoriasTecnicos = <String>['TES', 'CONDUCTOR'];

/// Contrato del datasource de técnicos en turno (solo lectura)
abstract class TecnicosEnTurnoDataSource {
  /// Devuelve los técnicos con turno activo en [ahora] o que empieza
  /// antes de `ahora + margenProximos`, con su último fichaje.
  ///
  /// Solo incluye personal activo cuya categoría esté en [categorias].
  /// Si un técnico tiene varios turnos solapados, se devuelve el que
  /// empieza antes.
  Future<List<TecnicoEnTurnoEntity>> getTecnicosEnTurno({
    required DateTime ahora,
    Duration margenProximos = const Duration(hours: 2),
    List<String> categorias = kCategoriasTecnicos,
  });
}
