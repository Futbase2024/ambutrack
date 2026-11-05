import 'package:equatable/equatable.dart';

/// Severidad de una alerta de mantenimiento
enum SeveridadAlerta {
  critica('Crítica'),
  aviso('Aviso'),
  info('Información');

  const SeveridadAlerta(this.displayName);

  final String displayName;
}

/// Tipo de alerta y pantalla relacionada a la que navegar
enum TipoAlertaMantenimiento {
  itv('ITV', '/flota/itv-revisiones', 'ITV y revisiones'),
  seguro('Seguro', '/flota/documentacion', 'Documentación'),
  homologacion('Homologación', '/flota/documentacion', 'Documentación'),
  mantenimientoVehiculo('Mantenimiento vehículo', '/flota/mantenimiento-preventivo', 'Mantenimiento preventivo'),
  mantenimientoProgramado('Mantenimiento programado', '/flota/mantenimiento-preventivo', 'Mantenimiento preventivo'),
  ordenAbierta('Orden en taller', '/taller/ordenes-reparacion', 'Órdenes de reparación'),
  repuestoPendiente('Repuesto pendiente', '/taller/control-repuestos', 'Control de repuestos');

  const TipoAlertaMantenimiento(this.displayName, this.route, this.pantalla);

  final String displayName;

  /// Ruta GoRouter de la pantalla relacionada
  final String route;

  /// Nombre visible de la pantalla relacionada
  final String pantalla;
}

/// Alerta calculada a partir de datos existentes (vehículos, órdenes, repuestos, mantenimientos)
class AlertaMantenimiento extends Equatable {
  const AlertaMantenimiento({
    required this.id,
    required this.tipo,
    required this.severidad,
    required this.detalle,
    required this.dias,
    required this.esPlazo,
    this.vehiculoId,
    this.vehiculoMatricula,
    this.fechaLimite,
    this.datos = const <String, String>{},
  });

  final String id;
  final TipoAlertaMantenimiento tipo;
  final SeveridadAlerta severidad;
  final String detalle;

  /// Si [esPlazo]: días hasta la fecha límite (negativo = vencida).
  /// Si no: días transcurridos (en taller, esperando...).
  final int dias;
  final bool esPlazo;
  final String? vehiculoId;
  final String? vehiculoMatricula;
  final DateTime? fechaLimite;

  /// Datos adicionales para la ficha lateral (etiqueta → valor)
  final Map<String, String> datos;

  /// Texto de días: "Vencida hace 3 d", "Vence hoy", "En 12 d", "9 d"
  String get diasTexto {
    if (!esPlazo) {
      return '$dias d';
    }
    if (dias < 0) {
      return 'Vencida hace ${-dias} d';
    }
    return dias == 0 ? 'Vence hoy' : 'En $dias d';
  }

  /// Valor de orden por urgencia (menor = más urgente)
  int get urgencia => esPlazo ? dias : -dias;

  @override
  List<Object?> get props => <Object?>[id, tipo, severidad, detalle, dias, esPlazo, fechaLimite, datos];
}
