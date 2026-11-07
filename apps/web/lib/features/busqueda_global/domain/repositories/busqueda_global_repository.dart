import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';

/// Búsqueda global de registros (Ctrl+K)
abstract class BusquedaGlobalRepository {
  /// Registros que contienen todas las palabras de [texto] (solo los visibles para el usuario)
  Future<List<ResultadoBusquedaEntity>> buscar(String texto, {int limitePorTipo = 6});
}
