import '../../../core/base_entity.dart';

/// Entidad que representa un tipo de traslado
class TipoTrasladoEntity extends BaseEntity {
  const TipoTrasladoEntity({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    required this.nombre,
    this.descripcion,
    required this.activo,
  });

  /// Nombre del tipo de traslado
  final String nombre;

  /// Descripción detallada del tipo
  final String? descripcion;

  /// Estado activo/inactivo
  final bool activo;

  @override
  List<Object?> get props => <Object?>[
        id,
        createdAt,
        updatedAt,
        nombre,
        descripcion,
        activo,
      ];

  @override
  TipoTrasladoEntity copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? nombre,
    String? descripcion,
    bool? activo,
  }) {
    return TipoTrasladoEntity(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      activo: activo ?? this.activo,
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
    };
  }
}
