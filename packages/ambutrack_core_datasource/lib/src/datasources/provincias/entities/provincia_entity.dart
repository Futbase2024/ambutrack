import '../../../core/base_entity.dart';

/// Entidad de dominio para provincias españolas
///
/// Representa una provincia española con su código, nombre y relación
/// con su comunidad autónoma.
/// Extiende [BaseEntity] para incluir campos comunes (id, createdAt, updatedAt).
class ProvinciaEntity extends BaseEntity {
  const ProvinciaEntity({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    this.codigo,
    required this.nombre,
    this.comunidadId,
    this.comunidadAutonoma,
  });

  /// Código INE de la provincia (opcional)
  final String? codigo;

  /// Nombre de la provincia
  final String nombre;

  /// ID de la comunidad autónoma a la que pertenece (FK)
  final String? comunidadId;

  /// Nombre de la comunidad autónoma (campo calculado desde JOIN)
  final String? comunidadAutonoma;

  @override
  List<Object?> get props => <Object?>[
        id,
        createdAt,
        updatedAt,
        codigo,
        nombre,
        comunidadId,
        comunidadAutonoma,
      ];

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      if (codigo != null) 'codigo': codigo,
      'nombre': nombre,
      if (comunidadId != null) 'comunidad_id': comunidadId,
      if (comunidadAutonoma != null) 'comunidad_autonoma': comunidadAutonoma,
    };
  }

  @override
  ProvinciaEntity copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? codigo,
    String? nombre,
    String? comunidadId,
    String? comunidadAutonoma,
  }) {
    return ProvinciaEntity(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      codigo: codigo ?? this.codigo,
      nombre: nombre ?? this.nombre,
      comunidadId: comunidadId ?? this.comunidadId,
      comunidadAutonoma: comunidadAutonoma ?? this.comunidadAutonoma,
    );
  }
}
