import 'package:ambutrack_web/features/cuadrante/cuadrante_module/domain/entities/cuadrante_filter.dart';
import 'package:ambutrack_web/features/cuadrante/cuadrante_module/domain/entities/personal_con_turnos_entity.dart';

/// Repositorio para gestión del cuadrante de personal
abstract class CuadranteRepository {
  /// Obtiene el cuadrante de personal con turnos aplicando filtros
  ///
  /// [filter] - Filtros a aplicar (categoría, puesto, fechas, etc.)
  /// Returns lista de personal con sus turnos asignados
  Future<List<PersonalConTurnosEntity>> getCuadrante(CuadranteFilter filter);

  /// Obtiene el cuadrante para una semana específica
  ///
  /// [primerDiaSemana] - Primer día de la semana (normalmente lunes)
  /// [filter] - Filtros adicionales
  Future<List<PersonalConTurnosEntity>> getCuadranteSemanal({
    required DateTime primerDiaSemana,
    CuadranteFilter? filter,
  });

  /// Obtiene el cuadrante para un mes específico
  ///
  /// [mes] - Mes (1-12)
  /// [anio] - Año
  /// [filter] - Filtros adicionales
  Future<List<PersonalConTurnosEntity>> getCuadranteMensual({
    required int mes,
    required int anio,
    CuadranteFilter? filter,
  });

  /// Copia todos los turnos de una semana a otra
  ///
  /// [semanaOrigen] - Fecha de inicio de la semana origen
  /// [semanaDestino] - Fecha de inicio de la semana destino
  /// [idPersonal] - ID del personal a copiar (null = todos)
  Future<void> copiarSemanaTurnos({
    required DateTime semanaOrigen,
    required DateTime semanaDestino,
    List<String>? idPersonal, // null = todos, lista con IDs = selección específica
  });
}
