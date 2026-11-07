import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/features/informes/domain/informe_models.dart';

/// Datos en bruto del informe de estadísticas de flota
class FlotaInformeRaw {
  const FlotaInformeRaw({
    required this.vehiculos,
    required this.traslados,
    required this.consumos,
    required this.incidencias,
    required this.ordenes,
  });

  final List<VehiculoEntity> vehiculos;
  final List<TrasladoEntity> traslados;
  final List<ConsumoCombustibleEntity> consumos;
  final List<IncidenciaVehiculoEntity> incidencias;
  final List<OrdenReparacionEntity> ordenes;
}

/// Fila del desglose por vehículo
class FlotaInformeFila {
  const FlotaInformeFila({
    required this.vehiculo,
    required this.servicios,
    required this.kmServicio,
    required this.litros,
    required this.kmRepostaje,
    required this.averias,
    required this.diasTaller,
  });

  final VehiculoEntity vehiculo;

  /// Servicios finalizados
  final int servicios;

  /// Km de los servicios finalizados
  final double kmServicio;

  /// Litros repostados
  final double litros;

  /// Km recorridos según los repostajes (para el consumo medio)
  final double kmRepostaje;

  /// Incidencias reportadas en el periodo
  final int averias;

  /// Días con orden de reparación abierta en el periodo
  final int diasTaller;

  /// Consumo medio L/100 km (null si no hay km de repostaje)
  double? get consumo100 => kmRepostaje > 0 ? litros * 100 / kmRepostaje : null;
}

/// Datos agregados del informe de estadísticas de flota
class FlotaInformeData {
  const FlotaInformeData({
    required this.kpis,
    required this.serviciosPorVehiculo,
    required this.estadoFlota,
    required this.filas,
    required this.categorias,
  });

  final List<InformeKpi> kpis;
  final List<InformeBarItem> serviciosPorVehiculo;
  final List<InformeBarItem> estadoFlota;
  final List<FlotaInformeFila> filas;
  final List<String> categorias;
}
