import '../../../core/base_entity.dart';

/// Entidad que representa una categoría de vehículo
class CategoriaVehiculoEntity extends BaseEntity {
  const CategoriaVehiculoEntity({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    required this.nombre,
    this.descripcion,
    required this.activo,
    this.orden,
  });

  /// Nombre de la categoría
  final String nombre;

  /// Descripción detallada de la categoría
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
  CategoriaVehiculoEntity copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? nombre,
    String? descripcion,
    bool? activo,
    int? orden,
  }) {
    return CategoriaVehiculoEntity(
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
