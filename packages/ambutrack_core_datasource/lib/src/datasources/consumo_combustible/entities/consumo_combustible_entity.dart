import '../../../core/base_entity.dart';

/// Tipo de combustible
enum TipoCombustible {
  /// Gasolina 95
  gasolina95,
  /// Gasolina 98
  gasolina98,
  /// Diesel
  diesel,
  /// Eléctrico
  electrico,
  /// Híbrido
  hibrido,
  /// Gas Licuado de Petróleo (GLP)
  glp,
  /// Gas Natural Comprimido (GNC)
  gnc,
  /// Gas Natural Licuado (GNL)
  gnl,
}

/// Método de pago
enum MetodoPago {
  /// Efectivo
  efectivo,
  /// Tarjeta de crédito/débito
  tarjeta,
  /// Tarjeta de combustible
  tarjetaCombustible,
  /// Pago pendiente
  pendiente,
}

/// Entity de dominio para Consumo de Combustible
///
/// Representa un registro de consumo de combustible (repostaje)
/// Mapea a la tabla `tconsumo_combustible` en Supabase
class ConsumoCombustibleEntity extends BaseEntity {
  /// Constructor de la entidad ConsumoCombustible
  const ConsumoCombustibleEntity({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
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

  // ========== CAMPOS OBLIGATORIOS ==========
  // id, createdAt, updatedAt heredados de BaseEntity

  /// ID del vehículo (UUID)
  final String vehiculoId;

  /// Fecha y hora del repostaje
  final DateTime fecha;

  /// Kilometraje del vehículo al momento del repostaje
  final double kmVehiculo;

  /// Tipo de combustible
  final String tipoCombustible;

  /// Litros repostados
  final double litros;

  /// Costo total del repostaje (€)
  final double costoTotal;

  /// ID de la empresa (UUID)
  final String empresaId;

  // ========== CAMPOS OPCIONALES ==========

  /// Precio por litro (€/L)
  final double? precioLitro;

  /// Nombre de la estación de servicio
  final String? estacion;

  /// Ubicación de la estación de servicio
  final String? ubicacion;

  /// Kilómetros recorridos desde el último repostaje
  final double? kmRecorridosDesdeUltimo;

  /// Consumo calculado (L/100km)
  final double? consumoL100km;

  /// Método de pago
  final String? metodoPago;

  /// Número de tarjeta de combustible
  final String? numeroTarjetaCombustible;

  /// Número de ticket
  final String? numeroTicket;

  /// ID del conductor que repostó (UUID)
  final String? conductorId;

  /// Nombre del conductor
  final String? conductorNombre;

  /// URL del ticket escaneado (Storage)
  final String? ticketUrl;

  /// ID del usuario que creó el registro (UUID)
  final String? createdBy;

  /// ID del usuario que actualizó el registro (UUID)
  final String? updatedBy;

  /// Crea una copia de la entidad con valores actualizados
  @override
  ConsumoCombustibleEntity copyWith({
    String? id,
    String? vehiculoId,
    DateTime? fecha,
    double? kmVehiculo,
    String? tipoCombustible,
    double? litros,
    double? costoTotal,
    String? empresaId,
    double? precioLitro,
    String? estacion,
    String? ubicacion,
    double? kmRecorridosDesdeUltimo,
    double? consumoL100km,
    String? metodoPago,
    String? numeroTarjetaCombustible,
    String? numeroTicket,
    String? conductorId,
    String? conductorNombre,
    String? ticketUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
  }) {
    return ConsumoCombustibleEntity(
      id: id ?? this.id,
      vehiculoId: vehiculoId ?? this.vehiculoId,
      fecha: fecha ?? this.fecha,
      kmVehiculo: kmVehiculo ?? this.kmVehiculo,
      tipoCombustible: tipoCombustible ?? this.tipoCombustible,
      litros: litros ?? this.litros,
      costoTotal: costoTotal ?? this.costoTotal,
      empresaId: empresaId ?? this.empresaId,
      precioLitro: precioLitro ?? this.precioLitro,
      estacion: estacion ?? this.estacion,
      ubicacion: ubicacion ?? this.ubicacion,
      kmRecorridosDesdeUltimo: kmRecorridosDesdeUltimo ?? this.kmRecorridosDesdeUltimo,
      consumoL100km: consumoL100km ?? this.consumoL100km,
      metodoPago: metodoPago ?? this.metodoPago,
      numeroTarjetaCombustible: numeroTarjetaCombustible ?? this.numeroTarjetaCombustible,
      numeroTicket: numeroTicket ?? this.numeroTicket,
      conductorId: conductorId ?? this.conductorId,
      conductorNombre: conductorNombre ?? this.conductorNombre,
      ticketUrl: ticketUrl ?? this.ticketUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
    );
  }

  @override
  List<Object?> get props => <Object?>[
        id,
        vehiculoId,
        fecha,
        kmVehiculo,
        tipoCombustible,
        litros,
        costoTotal,
        empresaId,
        precioLitro,
        estacion,
        ubicacion,
        kmRecorridosDesdeUltimo,
        consumoL100km,
        metodoPago,
        numeroTarjetaCombustible,
        numeroTicket,
        conductorId,
        conductorNombre,
        ticketUrl,
        createdAt,
        updatedAt,
        createdBy,
        updatedBy,
      ];

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
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
  }
}
