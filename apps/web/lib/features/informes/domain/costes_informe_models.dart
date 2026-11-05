import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/features/informes/domain/informe_models.dart';

/// Conceptos de coste operativo
enum CosteConcepto {
  combustible('Combustible'),
  reparaciones('Reparaciones (taller)'),
  mantenimiento('Mantenimiento'),
  itv('ITV y revisiones'),
  averias('Averías sin orden');

  const CosteConcepto(this.label);

  final String label;
}

/// Apunte de coste normalizado (un repostaje, una orden, una ITV...)
class CosteApunte {
  const CosteApunte({
    required this.vehiculoId,
    required this.concepto,
    required this.fecha,
    required this.importe,
  });

  final String vehiculoId;
  final CosteConcepto concepto;
  final DateTime fecha;
  final double importe;
}

/// Datos en bruto del informe de costes
class CostesInformeRaw {
  const CostesInformeRaw({
    required this.vehiculos,
    required this.apuntes,
    required this.traslados,
  });

  final List<VehiculoEntity> vehiculos;

  /// Apuntes de coste ya dentro del periodo
  final List<CosteApunte> apuntes;
  final List<TrasladoEntity> traslados;
}

/// Fila del desglose de costes por vehículo
class CostesInformeFila {
  const CostesInformeFila({
    required this.vehiculoId,
    required this.matricula,
    required this.importes,
    required this.servicios,
    required this.km,
  });

  final String vehiculoId;
  final String matricula;
  final Map<CosteConcepto, double> importes;

  /// Servicios finalizados
  final int servicios;

  /// Km de servicios finalizados
  final double km;

  double importe(CosteConcepto c) => importes[c] ?? 0;

  double get total => importes.values.fold<double>(0, (double a, double b) => a + b);

  double? get porServicio => servicios > 0 ? total / servicios : null;

  double? get porKm => km > 0 ? total / km : null;
}

/// Datos agregados del informe de costes operativos
class CostesInformeData {
  const CostesInformeData({
    required this.kpis,
    required this.porConcepto,
    required this.porMes,
    required this.filas,
    required this.vehiculos,
    required this.total,
  });

  final List<InformeKpi> kpis;
  final List<InformeBarItem> porConcepto;
  final List<InformeBarItem> porMes;
  final List<CostesInformeFila> filas;

  /// id → matrícula (opciones de filtro)
  final Map<String, String> vehiculos;
  final double total;
}
