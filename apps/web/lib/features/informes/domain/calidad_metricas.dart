import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/features/informes/domain/informe_calculos.dart';
import 'package:ambutrack_web/features/informes/domain/traslado_grupo.dart';

/// Tolerancia (min) para considerar puntual la llegada a origen
const int kToleranciaPuntualidad = 15;

/// Métricas de calidad acumuladas sobre un conjunto de traslados
class CalidadMetricas {
  CalidadMetricas(this.clave);

  final String clave;

  int servicios = 0;
  int finalizados = 0;
  int cancelados = 0;
  int noRealizados = 0;

  /// Retrasos (min) de llegada a origen respecto a la hora programada
  final List<int> retrasos = <int>[];

  /// Tiempos (min) entre el envío al conductor y su confirmación
  final List<int> aceptaciones = <int>[];

  /// Duraciones reales (min)
  final List<int> duraciones = <int>[];

  /// Duraciones estimadas (min) de los traslados con duración real
  final List<int> estimadas = <int>[];

  /// Servicios cerrados (finalizados, cancelados o no realizados)
  int get cerrados => finalizados + cancelados + noRealizados;

  int get puntuales => retrasos.where((int r) => r <= kToleranciaPuntualidad).length;

  /// Retraso medio (los adelantos cuentan como 0)
  double get retrasoMedio => InformeCalculos.media(retrasos.map((int r) => r < 0 ? 0 : r));

  double get aceptacionMedia => InformeCalculos.media(aceptaciones);

  double get duracionMedia => InformeCalculos.media(duraciones);

  double get estimadaMedia => InformeCalculos.media(estimadas);

  /// % de realización (0-100) o null si no hay servicios cerrados
  double? get tasaRealizacion => cerrados == 0 ? null : finalizados * 100 / cerrados;

  /// % de puntualidad (0-100) o null si no hay llegadas medidas
  double? get tasaPuntualidad => retrasos.isEmpty ? null : puntuales * 100 / retrasos.length;

  /// Acumula un traslado
  void add(TrasladoEntity t) {
    servicios++;
    switch (TrasladoGrupo.de(t)) {
      case TrasladoGrupo.finalizado:
        finalizados++;
      case TrasladoGrupo.cancelado:
        cancelados++;
      case TrasladoGrupo.noRealizado:
        noRealizados++;
      case TrasladoGrupo.enCurso:
      case TrasladoGrupo.pendiente:
        break;
    }
    final int? retraso = InformeCalculos.minutosEntre(
      InformeCalculos.fechaHora(t.fecha, t.horaProgramada),
      t.fechaEnOrigen,
    );
    if (retraso != null) {
      retrasos.add(retraso);
    }
    final int? aceptacion = InformeCalculos.minutosEntre(t.fechaEnviado, t.fechaRecibidoConductor);
    if (aceptacion != null && aceptacion >= 0) {
      aceptaciones.add(aceptacion);
    }
    final int duracion = t.duracionRealMinutos ?? InformeCalculos.minutosEntre(t.fechaEnOrigen, t.fechaFinalizado) ?? 0;
    if (duracion > 0) {
      duraciones.add(duracion);
      final int? estimada = t.duracionEstimadaMinutos;
      if (estimada != null && estimada > 0) {
        estimadas.add(estimada);
      }
    }
  }
}
