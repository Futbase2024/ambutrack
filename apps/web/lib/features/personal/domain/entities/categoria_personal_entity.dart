import 'package:equatable/equatable.dart';

/// Entidad de categoría de personal
class CategoriaPersonalEntity extends Equatable {
  const CategoriaPersonalEntity({
    required this.id,
    required this.nombre,
    required this.categoria,
    this.descripcion,
  });

  /// Crea una CategoriaPersonalEntity desde un Map (Supabase)
  factory CategoriaPersonalEntity.fromMap(Map<String, dynamic> map) {
    return CategoriaPersonalEntity(
      id: map['id']?.toString() ?? '',
      nombre: map['nombre']?.toString() ?? '',
      categoria: map['categoria']?.toString() ?? '',
      descripcion: map['descripcion']?.toString(),
    );
  }

  final String id;
  final String nombre; // Número de categoría (1, 2, 3, etc.)
  final String categoria; // Texto descriptivo (TES, CONDUCTOR, etc.)
  final String? descripcion;

  /// Convierte la CategoriaPersonalEntity a un Map para Supabase
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'nombre': nombre,
      'categoria': categoria,
      'descripcion': descripcion,
    };
  }

  @override
  List<Object?> get props => <Object?>[id, nombre, categoria, descripcion];
}
