import '../../../core/base_entity.dart';

/// Entidad de dominio para Localidades
class LocalidadEntity extends BaseEntity {
  const LocalidadEntity({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    this.codigo,
    required this.nombre,
    this.provinciaId,
    this.provinciaNombre, // Campo calculado del JOIN con tprovincias
    this.codigoPostal,
  });

  final String? codigo;
  final String nombre;
  final String? provinciaId; // FK hacia tprovincias
  final String? provinciaNombre; // Nombre de la provincia (del JOIN)
  final String? codigoPostal;

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      if (codigo != null) 'codigo': codigo,
      'nombre': nombre,
      if (provinciaId != null) 'provincia_id': provinciaId,
      if (provinciaNombre != null) 'provincia_nombre': provinciaNombre,
      if (codigoPostal != null) 'codigo_postal': codigoPostal,
    };
  }

  @override
  LocalidadEntity copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? codigo,
    String? nombre,
    String? provinciaId,
    String? provinciaNombre,
    String? codigoPostal,
  }) {
    return LocalidadEntity(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      codigo: codigo ?? this.codigo,
      nombre: nombre ?? this.nombre,
      provinciaId: provinciaId ?? this.provinciaId,
      provinciaNombre: provinciaNombre ?? this.provinciaNombre,
      codigoPostal: codigoPostal ?? this.codigoPostal,
    );
  }

  @override
  List<Object?> get props => <Object?>[
        id,
        createdAt,
        updatedAt,
        codigo,
        nombre,
        provinciaId,
        provinciaNombre,
        codigoPostal,
      ];
}
