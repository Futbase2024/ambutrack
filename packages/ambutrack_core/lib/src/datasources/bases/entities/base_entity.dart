import '../../../core/base_entity.dart';

/// Entidad de dominio para Base/Centro Operativo
///
/// Esta entidad contiene toda la información esencial de una base
/// y es agnóstica a la fuente de datos
class BaseCentroEntity extends BaseEntity {
  /// Código único de la base (generado automáticamente por Supabase)
  final String? codigo;

  /// Nombre de la base
  final String nombre;

  /// Dirección física de la base (opcional)
  final String? direccion;

  /// ID de la población/localidad donde está ubicada (opcional)
  final String? poblacionId;

  /// Nombre de la población (campo calculado, no está en BD)
  final String? poblacionNombre;

  /// Tipo de base: 'Permanente' o 'Temporal'
  final String? tipo;

  /// Si la base está activa en el sistema
  final bool activo;

  /// Crea una nueva instancia de [BaseCentroEntity]
  const BaseCentroEntity({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    this.codigo,
    required this.nombre,
    this.direccion,
    this.poblacionId,
    this.poblacionNombre,
    this.tipo,
    this.activo = true,
  });

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      if (codigo != null) 'codigo': codigo,
      'nombre': nombre,
      'direccion': direccion,
      'poblacion_id': poblacionId,
      'tipo': tipo,
      'activo': activo,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Crea un [BaseCentroEntity] desde datos JSON
  factory BaseCentroEntity.fromJson(Map<String, dynamic> json) {
    return BaseCentroEntity(
      id: json['id'] as String,
      codigo: json['codigo'] as String?,
      nombre: json['nombre'] as String,
      direccion: json['direccion'] as String?,
      poblacionId: json['poblacion_id'] as String?,
      poblacionNombre: json['poblacion_nombre'] as String?,
      tipo: json['tipo'] as String?,
      activo: json['activo'] as bool? ?? true,
      createdAt: _parseDateTime(json['created_at']),
      updatedAt: _parseDateTime(json['updated_at']),
    );
  }

  /// Parsea un DateTime desde JSON, manejando String y DateTime
  static DateTime _parseDateTime(dynamic value) {
    if (value == null) {
      return DateTime.now();
    }
    if (value is String) {
      return DateTime.parse(value);
    }
    if (value is DateTime) {
      return value;
    }
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    throw FormatException('Valor de fecha inválido: $value (tipo: ${value.runtimeType})');
  }

  @override
  BaseCentroEntity copyWith({
    String? id,
    String? codigo,
    String? nombre,
    String? direccion,
    String? poblacionId,
    String? poblacionNombre,
    String? tipo,
    bool? activo,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BaseCentroEntity(
      id: id ?? this.id,
      codigo: codigo ?? this.codigo,
      nombre: nombre ?? this.nombre,
      direccion: direccion ?? this.direccion,
      poblacionId: poblacionId ?? this.poblacionId,
      poblacionNombre: poblacionNombre ?? this.poblacionNombre,
      tipo: tipo ?? this.tipo,
      activo: activo ?? this.activo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => <Object?>[
        ...super.props,
        codigo,
        nombre,
        direccion,
        poblacionId,
        poblacionNombre,
        tipo,
        activo,
      ];

  @override
  String toString() {
    return 'BaseCentroEntity('
        'id: $id, '
        'codigo: $codigo, '
        'nombre: $nombre, '
        'tipo: $tipo, '
        'activo: $activo'
        ')';
  }
}
