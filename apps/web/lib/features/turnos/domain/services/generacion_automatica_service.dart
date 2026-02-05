import 'package:ambutrack_core/ambutrack_core.dart';
import 'package:ambutrack_web/features/personal/domain/entities/personal_entity.dart';
import 'package:ambutrack_web/features/turnos/domain/entities/configuracion_generacion_entity.dart';
import 'package:ambutrack_web/features/turnos/domain/entities/preferencia_personal_entity.dart';
import 'package:ambutrack_web/features/turnos/domain/entities/resultado_generacion_entity.dart';

/// Servicio para la generación automática de cuadrantes
abstract class GeneracionAutomaticaService {
  /// Genera turnos automáticamente según configuración y restricciones
  Future<ResultadoGeneracionEntity> generarCuadrante({
    required DateTime fechaInicio,
    required DateTime fechaFin,
    required List<PersonalEntity> personal,
    required ConfiguracionGeneracionEntity configuracion,
    List<PreferenciaPersonalEntity>? preferencias,
    List<TurnoEntity>? turnosExistentes,
  });

  /// Valida si un turno cumple con las restricciones legales
  bool validarRestriccionesLegales({
    required TurnoEntity turnoNuevo,
    required List<TurnoEntity> turnosExistentesPersonal,
    required ConfiguracionGeneracionEntity configuracion,
  });

  /// Calcula las horas trabajadas por un personal en un período
  double calcularHorasTrabajadas({
    required String idPersonal,
    required DateTime fechaInicio,
    required DateTime fechaFin,
    required List<TurnoEntity> turnos,
  });

  /// Distribuye turnos equitativamente entre el personal
  Map<String, int> distribuirTurnosEquitativamente({
    required int totalTurnosNecesarios,
    required List<PersonalEntity> personal,
  });
}
