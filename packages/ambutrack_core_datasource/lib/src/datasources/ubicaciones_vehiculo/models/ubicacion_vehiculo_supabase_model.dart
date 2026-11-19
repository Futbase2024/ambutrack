import '../entities/ubicacion_vehiculo_entity.dart';

/// Fila de `thistorial_ubicaciones` o de `fn_ultimas_ubicaciones`
class UbicacionVehiculoSupabaseModel {
  const UbicacionVehiculoSupabaseModel(this.json);

  final Map<String, dynamic> json;

  static double? _num(Object? v) => v == null ? null : (v is num ? v.toDouble() : double.tryParse(v.toString()));

  UbicacionVehiculoEntity toEntity() => UbicacionVehiculoEntity(
        vehiculoId: json['vehiculo_id'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String).toLocal(),
        latitud: _num(json['latitud']) ?? 0,
        longitud: _num(json['longitud']) ?? 0,
        matricula: json['matricula'] as String?,
        tipoVehiculo: json['tipo_vehiculo'] as String?,
        velocidadKmh: _num(json['velocidad_kmh']),
        enServicio: json['en_servicio'] as bool? ?? false,
      );
}
