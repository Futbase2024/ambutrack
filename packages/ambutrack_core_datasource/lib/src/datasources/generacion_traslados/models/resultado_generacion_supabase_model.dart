import '../entities/resultado_generacion_traslados_entity.dart';

/// DTO de la respuesta de la función RPC `generar_traslados_periodo`.
///
/// La función devuelve `RETURNS TABLE(...)`, por lo que PostgREST responde
/// con una lista de una fila; también se acepta un objeto suelto.
/// Serialización manual (sin codegen).
class ResultadoGeneracionSupabaseModel {
  const ResultadoGeneracionSupabaseModel({
    required this.serviciosProcesados,
    required this.trasladosGenerados,
    required this.trasladosIda,
    required this.trasladosVuelta,
    required this.serviciosConError,
    required this.errores,
  });

  /// Construye el modelo a partir de la respuesta cruda del RPC
  factory ResultadoGeneracionSupabaseModel.fromResponse(Object? response) {
    Object? row = response;
    if (response is List) {
      row = response.isEmpty ? null : response.first;
    }
    if (row is! Map) {
      return const ResultadoGeneracionSupabaseModel(
        serviciosProcesados: 0,
        trasladosGenerados: 0,
        trasladosIda: 0,
        trasladosVuelta: 0,
        serviciosConError: 0,
        errores: <String>[],
      );
    }
    return ResultadoGeneracionSupabaseModel.fromJson(
      Map<String, dynamic>.from(row),
    );
  }

  /// Deserializa una fila del resultado
  factory ResultadoGeneracionSupabaseModel.fromJson(Map<String, dynamic> json) {
    final Object? rawErrores = json['errores'];
    return ResultadoGeneracionSupabaseModel(
      serviciosProcesados: _toInt(json['servicios_procesados']),
      trasladosGenerados: _toInt(json['traslados_generados']),
      trasladosIda: _toInt(json['traslados_ida']),
      trasladosVuelta: _toInt(json['traslados_vuelta']),
      serviciosConError: _toInt(json['servicios_con_error']),
      errores: rawErrores is List
          ? rawErrores.whereType<Object>().map((Object e) => e.toString()).toList()
          : const <String>[],
    );
  }

  final int serviciosProcesados;
  final int trasladosGenerados;
  final int trasladosIda;
  final int trasladosVuelta;
  final int serviciosConError;
  final List<String> errores;

  static int _toInt(Object? value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  /// Convierte el DTO a entidad de dominio
  ResultadoGeneracionTrasladosEntity toEntity({
    required DateTime fechaDesde,
    required DateTime fechaHasta,
    required DateTime ejecutadoEn,
  }) {
    return ResultadoGeneracionTrasladosEntity(
      fechaDesde: fechaDesde,
      fechaHasta: fechaHasta,
      ejecutadoEn: ejecutadoEn,
      serviciosProcesados: serviciosProcesados,
      trasladosGenerados: trasladosGenerados,
      trasladosIda: trasladosIda,
      trasladosVuelta: trasladosVuelta,
      serviciosConError: serviciosConError,
      errores: errores,
    );
  }
}
