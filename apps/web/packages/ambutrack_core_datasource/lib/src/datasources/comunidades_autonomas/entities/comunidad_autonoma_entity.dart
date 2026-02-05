import '../../../core/base_entity.dart';

/// Entidad de dominio para comunidades autónomas españolas
///
/// Representa una comunidad autónoma de España con su código y nombre.
/// Extiende [BaseEntity] para incluir campos comunes (id, createdAt, updatedAt).
class ComunidadAutonomaEntity extends BaseEntity {
  const ComunidadAutonomaEntity({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    required this.nombre,
    this.codigo,
  });

  /// Nombre de la comunidad autónoma
  final String nombre;

  /// Código de la comunidad autónoma (opcional)
  final String? codigo;

  @override
  List<Object?> get props => <Object?>[
        id,
        createdAt,
        updatedAt,
        nombre,
        codigo,
      ];

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'nombre': nombre,
      if (codigo != null) 'codigo': codigo,
    };
  }

  @override
  ComunidadAutonomaEntity copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? nombre,
    String? codigo,
  }) {
    return ComunidadAutonomaEntity(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      nombre: nombre ?? this.nombre,
      codigo: codigo ?? this.codigo,
    );
  }
}
