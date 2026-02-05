import 'package:equatable/equatable.dart';

/// Entidad para tipos de contrato laboral (Fijo, Temporal, Discontinuo, etc.)
class TipoContratoEntity extends Equatable {
  const TipoContratoEntity({
    required this.id,
    required this.nombre,
    this.descripcion,
    required this.createdAt,
  });

  /// Crea un TipoContratoEntity desde un Map (Supabase)
  factory TipoContratoEntity.fromMap(Map<String, dynamic> map) {
    return TipoContratoEntity(
      id: map['id']?.toString() ?? '',
      nombre: map['nombre']?.toString() ?? '',
      descripcion: map['descripcion']?.toString(),
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'].toString())
          : DateTime.now(),
    );
  }

  final String id;
  final String nombre;
  final String? descripcion;
  final DateTime createdAt;

  /// Convierte el TipoContratoEntity a un Map para Supabase
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => <Object?>[id, nombre, descripcion, createdAt];
}
