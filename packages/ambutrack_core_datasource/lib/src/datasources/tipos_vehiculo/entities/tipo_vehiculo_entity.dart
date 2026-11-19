import '../../../core/base_entity.dart';

/// Entidad que representa un tipo de vehículo
class TipoVehiculoEntity extends BaseEntity {
  const TipoVehiculoEntity({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    required this.nombre,
    this.descripcion,
    required this.activo,
    this.orden,
  });

  /// Nombre del tipo de vehículo
  final String nombre;

  /// Descripción detallada del tipo
  final String? descripcion;

  /// Estado activo/inactivo
  final bool activo;

  /// Orden de visualización
  final int? orden;

  @override
  List<Object?> get props => <Object?>[
        id,
        createdAt,
        updatedAt,
        nombre,
        descripcion,
        activo,
        orden,
      ];

  @override
  TipoVehiculoEntity copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? nombre,
    String? descripcion,
    bool? activo,
    int? orden,
  }) {
    return TipoVehiculoEntity(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      activo: activo ?? this.activo,
      orden: orden ?? this.orden,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'nombre': nombre,
      'descripcion': descripcion,
      'activo': activo,
      'orden': orden,
    };
  }
}
