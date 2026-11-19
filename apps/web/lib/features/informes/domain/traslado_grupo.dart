import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';

/// Agrupación de los estados de traslado para los informes
enum TrasladoGrupo {
  finalizado('Finalizados'),
  cancelado('Cancelados / anulados'),
  noRealizado('No realizados / suspendidos'),
  enCurso('En curso'),
  pendiente('Pendientes');

  const TrasladoGrupo(this.label);

  final String label;

  /// Grupo de un traslado según su estado
  static TrasladoGrupo de(TrasladoEntity t) {
    switch (t.estado) {
      case 'finalizado':
        return TrasladoGrupo.finalizado;
      case 'cancelado':
      case 'anulado':
        return TrasladoGrupo.cancelado;
      case 'no_realizado':
      case 'suspendido':
        return TrasladoGrupo.noRealizado;
      case 'pendiente':
      case null:
        return TrasladoGrupo.pendiente;
      default:
        return TrasladoGrupo.enCurso;
    }
  }
}

/// Etiquetas comunes de traslados
class TrasladoTextos {
  const TrasladoTextos._();

  static const String sinVehiculo = 'Sin vehículo';

  static String vehiculo(TrasladoEntity t) {
    final String? m = t.matriculaVehiculo;
    return m == null || m.trim().isEmpty ? sinVehiculo : m.trim();
  }

  static String estado(TrasladoEntity t) {
    final String? e = t.estado;
    if (e == null) {
      return 'Pendiente';
    }
    return EstadoTraslado.fromValue(e)?.label ?? e;
  }

  static String motivo(TrasladoEntity t) {
    final String? n = t.motivoTraslado?.nombre;
    return n == null || n.trim().isEmpty ? 'Sin motivo' : n.trim();
  }
}
