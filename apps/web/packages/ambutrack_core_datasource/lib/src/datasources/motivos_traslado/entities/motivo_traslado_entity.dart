import '../../../core/base_entity.dart';

/// Entidad de Motivo de Traslado que extiende BaseEntity
class MotivoTrasladoEntity extends BaseEntity {
  const MotivoTrasladoEntity({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    required this.nombre,
    required this.descripcion,
    required this.activo,
    this.tiempo = 0,
    this.vuelta = false,
  });

  final String nombre;
  final String descripcion;
  final bool activo;
  final int tiempo;
  final bool vuelta;

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'nombre': nombre,
      'descripcion': descripcion,
      'activo': activo,
      'tiempo': tiempo,
      'vuelta': vuelta,
    };
  }

  @override
  MotivoTrasladoEntity copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? nombre,
    String? descripcion,
    bool? activo,
    int? tiempo,
    bool? vuelta,
  }) {
    return MotivoTrasladoEntity(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      activo: activo ?? this.activo,
      tiempo: tiempo ?? this.tiempo,
      vuelta: vuelta ?? this.vuelta,
    );
  }
}
