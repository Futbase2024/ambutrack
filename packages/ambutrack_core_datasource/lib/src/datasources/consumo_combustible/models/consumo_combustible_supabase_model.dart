import '../entities/consumo_combustible_entity.dart';

/// Modelo de Supabase para Consumo de Combustible
///
/// Mapea directamente desde/hacia la tabla PostgreSQL 'tconsumo_combustible'
class ConsumoCombustibleSupabaseModel {
  final String id;
  final String vehiculoId;
  final DateTime fecha;
  final double kmVehiculo;
  final String tipoCombustible;
  final double litros;
  final double costoTotal;
  final String empresaId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double? precioLitro;
  final String? estacion;
  final String? ubicacion;
  final double? kmRecorridosDesdeUltimo;
  final double? consumoL100km;
  final String? metodoPago;
  final String? numeroTarjetaCombustible;
  final String? numeroTicket;
  final String? conductorId;
  final String? conductorNombre;
  final String? ticketUrl;
  final String? createdBy;
  final String? updatedBy;

  const ConsumoCombustibleSupabaseModel({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.vehiculoId,
    required this.fecha,
    required this.kmVehiculo,
    required this.tipoCombustible,
    required this.litros,
    required this.costoTotal,
    required this.empresaId,
    this.precioLitro,
    this.estacion,
    this.ubicacion,
    this.kmRecorridosDesdeUltimo,
    this.consumoL100km,
    this.metodoPago,
    this.numeroTarjetaCombustible,
    this.numeroTicket,
    this.conductorId,
    this.conductorNombre,
    this.ticketUrl,
    this.createdBy,
    this.updatedBy,
  });

  /// Convierte desde JSON de Supabase (snake_case)
  factory ConsumoCombustibleSupabaseModel.fromJson(Map<String, dynamic> json) {
    final DateTime now = DateTime.now();

    return ConsumoCombustibleSupabaseModel(
      id: json['id'] as String? ?? '',
      createdAt: _parseDate(json['created_at']) ?? now,
      updatedAt: _parseDate(json['updated_at']) ?? now,
      vehiculoId: json['vehiculo_id'] as String? ?? '',
      fecha: _parseDate(json['fecha']) ?? now,
      kmVehiculo: _parseDouble(json['km_vehiculo']) ?? 0.0,
      tipoCombustible: json['tipo_combustible'] as String? ?? 'diesel',
      litros: _parseDouble(json['litros']) ?? 0.0,
      costoTotal: _parseDouble(json['costo_total']) ?? 0.0,
      empresaId: json['empresa_id'] as String? ?? '',
      precioLitro: _parseDouble(json['precio_litro']),
      estacion: json['estacion'] as String?,
      ubicacion: json['ubicacion'] as String?,
      kmRecorridosDesdeUltimo: _parseDouble(json['km_recorridos_desde_ultimo']),
      consumoL100km: _parseDouble(json['consumo_l100km']),
      metodoPago: json['metodo_pago'] as String?,
      numeroTarjetaCombustible: json['numero_tarjeta_combustible'] as String?,
      numeroTicket: json['numero_ticket'] as String?,
      conductorId: json['conductor_id'] as String?,
      conductorNombre: json['conductor_nombre'] as String?,
      ticketUrl: json['ticket_url'] as String?,
      createdBy: json['created_by'] as String?,
      updatedBy: json['updated_by'] as String?,
    );
  }

  /// Convierte a JSON para Supabase (snake_case)
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = {
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'vehiculo_id': vehiculoId,
      'fecha': fecha.toIso8601String(),
      'km_vehiculo': kmVehiculo,
      'tipo_combustible': tipoCombustible,
      'litros': litros,
      'costo_total': costoTotal,
      'empresa_id': empresaId,
      'precio_litro': precioLitro,
      'estacion': estacion,
      'ubicacion': ubicacion,
      'km_recorridos_desde_ultimo': kmRecorridosDesdeUltimo,
      'consumo_l100km': consumoL100km,
      'metodo_pago': metodoPago,
      'numero_tarjeta_combustible': numeroTarjetaCombustible,
      'numero_ticket': numeroTicket,
      'conductor_id': conductorId,
      'conductor_nombre': conductorNombre,
      'ticket_url': ticketUrl,
      'created_by': createdBy,
      'updated_by': updatedBy,
    };

    // Solo incluir el ID si no está vacío (para updates)
    if (id.isNotEmpty) {
      map['id'] = id;
    }

    return map;
  }

  /// Convierte el modelo a entidad de dominio
  ConsumoCombustibleEntity toEntity() {
    return ConsumoCombustibleEntity(
      id: id,
      createdAt: createdAt,
      updatedAt: updatedAt,
      vehiculoId: vehiculoId,
      fecha: fecha,
      kmVehiculo: kmVehiculo,
      tipoCombustible: tipoCombustible,
      litros: litros,
      costoTotal: costoTotal,
      empresaId: empresaId,
      precioLitro: precioLitro,
      estacion: estacion,
      ubicacion: ubicacion,
      kmRecorridosDesdeUltimo: kmRecorridosDesdeUltimo,
      consumoL100km: consumoL100km,
      metodoPago: metodoPago,
      numeroTarjetaCombustible: numeroTarjetaCombustible,
      numeroTicket: numeroTicket,
      conductorId: conductorId,
      conductorNombre: conductorNombre,
      ticketUrl: ticketUrl,
      createdBy: createdBy,
      updatedBy: updatedBy,
    );
  }

  /// Crea un modelo desde una entidad de dominio
  factory ConsumoCombustibleSupabaseModel.fromEntity(ConsumoCombustibleEntity entity) {
    return ConsumoCombustibleSupabaseModel(
      id: entity.id,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      vehiculoId: entity.vehiculoId,
      fecha: entity.fecha,
      kmVehiculo: entity.kmVehiculo,
      tipoCombustible: entity.tipoCombustible,
      litros: entity.litros,
      costoTotal: entity.costoTotal,
      empresaId: entity.empresaId,
      precioLitro: entity.precioLitro,
      estacion: entity.estacion,
      ubicacion: entity.ubicacion,
      kmRecorridosDesdeUltimo: entity.kmRecorridosDesdeUltimo,
      consumoL100km: entity.consumoL100km,
      metodoPago: entity.metodoPago,
      numeroTarjetaCombustible: entity.numeroTarjetaCombustible,
      numeroTicket: entity.numeroTicket,
      conductorId: entity.conductorId,
      conductorNombre: entity.conductorNombre,
      ticketUrl: entity.ticketUrl,
      createdBy: entity.createdBy,
      updatedBy: entity.updatedBy,
    );
  }

  /// Helper para parsear doubles de forma segura
  static double? _parseDouble(Object? value) {
    if (value == null) {
      return null;
    }
    if (value is double) {
      return value;
    }
    if (value is int) {
      return value.toDouble();
    }
    if (value is num) {
      return value.toDouble();
    }
    if (value is String && value.isNotEmpty) {
      return double.tryParse(value);
    }
    return null;
  }

  /// Helper para parsear fechas de forma segura
  static DateTime? _parseDate(Object? value) {
    if (value == null) {
      return null;
    }
    if (value is DateTime) {
      return value;
    }
    if (value is String && value.isNotEmpty) {
      try {
        return DateTime.parse(value);
      } catch (_) {
        return null;
      }
    }
    return null;
  }
}
