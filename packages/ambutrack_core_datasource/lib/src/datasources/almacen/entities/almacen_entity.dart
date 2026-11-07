import 'package:equatable/equatable.dart';

/// Tipos de almacén en el sistema
enum TipoAlmacen {
  /// Almacén principal de la empresa
  baseCentral('BASE_CENTRAL', 'Base Central'),

  /// Almacén móvil (ambulancia)
  vehiculo('VEHICULO', 'Vehículo');

  const TipoAlmacen(this.code, this.label);

  final String code;
  final String label;

  static TipoAlmacen fromCode(String code) {
    return TipoAlmacen.values.firstWhere(
      (tipo) => tipo.code == code,
      orElse: () => TipoAlmacen.baseCentral,
    );
  }
}

/// Entidad de Almacén (físico)
///
/// Representa un lugar físico donde se guardan productos.
/// Puede ser:
/// - Base Central: Almacén principal
/// - Vehículo: Ambulancia (almacén móvil)
class AlmacenEntity extends Equatable {
  const AlmacenEntity({
    required this.id,
    required this.codigo,
    required this.nombre,
    required this.tipo,
    this.idVehiculo,
    this.direccion,
    this.capacidadMax,
    this.activo = true,
    this.createdAt,
    this.updatedAt,
  });

  /// ID único del almacén
  final String id;

  /// Código único del almacén (ej: BASE-001, VEH-AM001)
  final String codigo;

  /// Nombre descriptivo del almacén
  final String nombre;

  /// Tipo de almacén
  final TipoAlmacen tipo;

  /// ID del vehículo (solo si tipo = vehiculo)
  final String? idVehiculo;

  /// Dirección física del almacén
  final String? direccion;

  /// Capacidad máxima del almacén
  final double? capacidadMax;

  /// Estado activo/inactivo
  final bool activo;

  /// Fecha de creación
  final DateTime? createdAt;

  /// Fecha de última actualización
  final DateTime? updatedAt;

  /// Retorna true si es almacén Base Central
  bool get esBaseCentral => tipo == TipoAlmacen.baseCentral;

  /// Retorna true si es almacén de Vehículo
  bool get esVehiculo => tipo == TipoAlmacen.vehiculo;

  @override
  List<Object?> get props => [
        id,
        codigo,
        nombre,
        tipo,
        idVehiculo,
        direccion,
        capacidadMax,
        activo,
        createdAt,
        updatedAt,
      ];

  AlmacenEntity copyWith({
    String? id,
    String? codigo,
    String? nombre,
    TipoAlmacen? tipo,
    String? idVehiculo,
    String? direccion,
    double? capacidadMax,
    bool? activo,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AlmacenEntity(
      id: id ?? this.id,
      codigo: codigo ?? this.codigo,
      nombre: nombre ?? this.nombre,
      tipo: tipo ?? this.tipo,
      idVehiculo: idVehiculo ?? this.idVehiculo,
      direccion: direccion ?? this.direccion,
      capacidadMax: capacidadMax ?? this.capacidadMax,
      activo: activo ?? this.activo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
