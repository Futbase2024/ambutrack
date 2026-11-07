import 'package:equatable/equatable.dart';

/// Entidad de dominio para cursos de formación
class CursoEntity extends Equatable {
  const CursoEntity({
    required this.id,
    required this.nombre,
    this.descripcion,
    required this.tipo,
    required this.duracionHoras,
    required this.certificaciones,
    required this.activo,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String nombre; // 'Curso TES Avanzado 2024'
  final String? descripcion;
  final String tipo; // 'presencial', 'online', 'mixto'
  final int duracionHoras; // Duración en horas
  final List<String> certificaciones; // IDs de certificaciones que otorga
  final bool activo; // Si está activo
  final DateTime? createdAt;
  final DateTime? updatedAt;

  @override
  List<Object?> get props => [
        id,
        nombre,
        descripcion,
        tipo,
        duracionHoras,
        certificaciones,
        activo,
        createdAt,
        updatedAt,
      ];
}

/// Constantes para tipos de curso
class CursoTipo {
  const CursoTipo._();

  static const String presencial = 'presencial';
  static const String online = 'online';
  static const String mixto = 'mixto';
}
