import 'entities/resultado_busqueda_entity.dart';

/// Búsqueda global de registros (vehículos, pacientes, personal, órdenes).
///
/// Se resuelve en servidor con `fn_buscar_global` (SECURITY INVOKER): solo
/// devuelve lo que el usuario puede ver según sus reglas de acceso.
abstract class BusquedaGlobalDataSource {
  /// Hasta [limitePorTipo] resultados de cada tipo que contengan todas las palabras de [texto]
  Future<List<ResultadoBusquedaEntity>> buscar(String texto, {int limitePorTipo = 6});
}
