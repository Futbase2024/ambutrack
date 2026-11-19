import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:uuid/uuid.dart';

/// Construye los registros de fichaje (entrada/salida) y formatea duraciones
class RegistroHorarioBuilder {
  const RegistroHorarioBuilder._();

  static const Uuid _uuid = Uuid();

  static RegistroHorarioEntity nuevo({
    required String personalId,
    required String tipo,
    required double latitud,
    required double longitud,
    required double precisionGps,
    VehiculoEntity? vehiculo,
    String? vehiculoId,
    String? vehiculoMatricula,
    String? notas,
  }) {
    final DateTime ahora = DateTime.now();
    return RegistroHorarioEntity(
      id: _uuid.v4(),
      personalId: personalId,
      tipo: tipo,
      fechaHora: ahora,
      latitud: latitud,
      longitud: longitud,
      precisionGps: precisionGps,
      vehiculoId: vehiculo?.id ?? vehiculoId,
      vehiculoMatricula: vehiculo?.matricula ?? vehiculoMatricula,
      notas: notas,
      createdAt: ahora,
      updatedAt: ahora,
    );
  }

  /// Formato "8h 05m"
  static String duracion(Duration d) {
    final int m = d.inMinutes.remainder(60);
    return '${d.inHours}h ${m.toString().padLeft(2, '0')}m';
  }
}
