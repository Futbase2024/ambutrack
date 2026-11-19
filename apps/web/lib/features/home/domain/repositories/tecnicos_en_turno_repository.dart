import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';

/// Contrato del repositorio de técnicos en turno (dashboard)
abstract class TecnicosEnTurnoRepository {
  /// Técnicos (TES / conductor) con turno en curso o que empieza pronto,
  /// con su último fichaje
  Future<List<TecnicoEnTurnoEntity>> getTecnicosEnTurno({required DateTime ahora});
}
