import 'package:equatable/equatable.dart';

/// Plantilla de equipamiento y documentación obligatoria por tipo de vehículo
///
/// Tabla: `plantillas_equipamiento`.
/// Al crear/activar una plantilla, los triggers de Supabase generan las líneas
/// en `stock_vehiculo` para todos los vehículos de [tiposVehiculo].
class PlantillaEquipamientoEntity extends Equatable {
  const PlantillaEquipamientoEntity({
    required this.id,
    required this.nombre,
    this.descripcion,
    this.tiposVehiculo = const <String>[],
    this.fechaVersion,
    this.activo = true,
    this.empresaId,
    this.createdAt,
    this.updatedAt,
    this.numItems,
  });

  /// Identificador único
  final String id;

  /// Nombre de la plantilla (ej: "DOTACIÓN AMBULANCIA A1/A2")
  final String nombre;

  /// Descripción u origen del protocolo
  final String? descripcion;

  /// Tipos de vehículo a los que aplica (valores de `tvehiculos.tipo_vehiculo`, MAYÚSCULAS)
  final List<String> tiposVehiculo;

  /// Fecha de la versión del protocolo
  final DateTime? fechaVersion;

  /// Si la plantilla está activa (solo las activas se aplican)
  final bool activo;

  /// Empresa propietaria (null = global)
  final String? empresaId;

  /// Fecha de creación
  final DateTime? createdAt;

  /// Fecha de última actualización
  final DateTime? updatedAt;

  /// Número de items (solo lectura, calculado en la consulta)
  final int? numItems;

  PlantillaEquipamientoEntity copyWith({
    String? id,
    String? nombre,
    String? descripcion,
    List<String>? tiposVehiculo,
    DateTime? fechaVersion,
    bool? activo,
    String? empresaId,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? numItems,
  }) {
    return PlantillaEquipamientoEntity(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      tiposVehiculo: tiposVehiculo ?? this.tiposVehiculo,
      fechaVersion: fechaVersion ?? this.fechaVersion,
      activo: activo ?? this.activo,
      empresaId: empresaId ?? this.empresaId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      numItems: numItems ?? this.numItems,
    );
  }

  @override
  List<Object?> get props => <Object?>[
        id,
        nombre,
        descripcion,
        tiposVehiculo,
        fechaVersion,
        activo,
        empresaId,
        createdAt,
        updatedAt,
        numItems,
      ];
}
