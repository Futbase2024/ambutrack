import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/features/ausencias/domain/repositories/ausencia_repository.dart';
import 'package:ambutrack_web/features/ausencias/domain/repositories/tipo_ausencia_repository.dart';
import 'package:ambutrack_web/features/turnos/domain/services/turno_ausencias_checker.dart';
import 'package:ambutrack_web/features/vacaciones/domain/repositories/vacaciones_repository.dart';
import 'package:flutter/foundation.dart';

/// Carga los periodos de indisponibilidad (ausencias y vacaciones aprobadas)
/// reutilizando los repositorios existentes de ausencias y vacaciones.
class IndisponibilidadPersonalLoader {
  IndisponibilidadPersonalLoader({
    AusenciaRepository? ausenciaRepository,
    TipoAusenciaRepository? tipoAusenciaRepository,
    VacacionesRepository? vacacionesRepository,
  })  : _ausenciaRepository = ausenciaRepository,
        _tipoAusenciaRepository = tipoAusenciaRepository,
        _vacacionesRepository = vacacionesRepository;

  final AusenciaRepository? _ausenciaRepository;
  final TipoAusenciaRepository? _tipoAusenciaRepository;
  final VacacionesRepository? _vacacionesRepository;

  AusenciaRepository get _ausencias => _ausenciaRepository ?? getIt<AusenciaRepository>();
  TipoAusenciaRepository get _tipos => _tipoAusenciaRepository ?? getIt<TipoAusenciaRepository>();
  VacacionesRepository get _vacaciones => _vacacionesRepository ?? getIt<VacacionesRepository>();

  /// Periodos de una persona concreta
  Future<List<PeriodoIndisponibilidad>> cargarDePersonal(String idPersonal) async {
    final List<Object> datos = await Future.wait<Object>(<Future<Object>>[
      _ausencias.getByPersonal(idPersonal),
      _vacaciones.getByPersonalId(idPersonal),
      _nombresTipo(),
    ]);
    return _combinar(
      datos[0] as List<AusenciaEntity>,
      datos[1] as List<VacacionesEntity>,
      datos[2] as Map<String, String>,
    );
  }

  /// Periodos de todas las personas que se solapan con [desde]-[hasta]
  Future<List<PeriodoIndisponibilidad>> cargarEnRango({
    required DateTime desde,
    required DateTime hasta,
  }) async {
    final List<Object> datos = await Future.wait<Object>(<Future<Object>>[
      // getByRangoFechas solo devuelve ausencias contenidas en el rango;
      // se piden las aprobadas y se filtra por solapamiento aquí.
      _ausencias.getByEstado(EstadoAusencia.aprobada),
      _vacaciones.getAll(),
      _nombresTipo(),
    ]);
    final DateTime d = TurnoAusenciasChecker.soloFecha(desde);
    final DateTime h = TurnoAusenciasChecker.soloFecha(hasta);
    return _combinar(
      datos[0] as List<AusenciaEntity>,
      datos[1] as List<VacacionesEntity>,
      datos[2] as Map<String, String>,
    )
        .where(
          (PeriodoIndisponibilidad p) =>
              !TurnoAusenciasChecker.soloFecha(p.fechaFin).isBefore(d) &&
              !TurnoAusenciasChecker.soloFecha(p.fechaInicio).isAfter(h),
        )
        .toList();
  }

  List<PeriodoIndisponibilidad> _combinar(
    List<AusenciaEntity> ausencias,
    List<VacacionesEntity> vacaciones,
    Map<String, String> nombresTipo,
  ) {
    return <PeriodoIndisponibilidad>[
      ...TurnoAusenciasChecker.desdeAusencias(ausencias, nombresTipo: nombresTipo),
      ...TurnoAusenciasChecker.desdeVacaciones(vacaciones),
    ];
  }

  /// Nombres de tipos de ausencia; si fallan, el mensaje usa "ausencia"
  Future<Map<String, String>> _nombresTipo() async {
    try {
      final List<TipoAusenciaEntity> tipos = await _tipos.getAll();
      return <String, String>{for (final TipoAusenciaEntity t in tipos) t.id: t.nombre};
    } catch (e) {
      debugPrint('⚠️ IndisponibilidadPersonalLoader: no se pudieron cargar tipos de ausencia: $e');
      return <String, String>{};
    }
  }
}
