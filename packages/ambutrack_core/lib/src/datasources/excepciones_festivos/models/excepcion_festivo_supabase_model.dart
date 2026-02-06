import 'package:ambutrack_core/src/datasources/excepciones_festivos/entities/excepcion_festivo_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'excepcion_festivo_supabase_model.g.dart';

/// Modelo de datos para Excepciones/Festivos en Supabase
@JsonSerializable()
class ExcepcionFestivoSupabaseModel {
  const ExcepcionFestivoSupabaseModel({
    required this.id,
    required this.nombre,
    required this.fecha,
    required this.tipo,
    required this.repetirAnualmente,
    required this.activo,
    required this.createdAt,
    this.createdBy,
  });

  final String id;
  @JsonKey(name: 'descripcion') // La columna real en la tabla
  final String nombre;
  final DateTime fecha;
  final String tipo;
  @JsonKey(name: 'repetir_anualmente')
  final bool repetirAnualmente;
  final bool activo;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'created_by')
  final String? createdBy;

  /// Crea una instancia desde JSON
  factory ExcepcionFestivoSupabaseModel.fromJson(Map<String, dynamic> json) =>
      _$ExcepcionFestivoSupabaseModelFromJson(json);

  /// Convierte a JSON
  Map<String, dynamic> toJson() => _$ExcepcionFestivoSupabaseModelToJson(this);

  /// Convierte el modelo a Entity
  ExcepcionFestivoEntity toEntity() {
    return ExcepcionFestivoEntity(
      id: id,
      nombre: nombre,
      fecha: fecha,
      tipo: tipo,
      descripcion: nombre, // Usar nombre también como descripción
      afectaDotaciones: true, // Valor por defecto (no existe en BD)
      repetirAnualmente: repetirAnualmente,
      activo: activo,
      createdAt: createdAt,
      updatedAt: createdAt, // Usar createdAt como updatedAt (no existe en BD)
      createdBy: createdBy,
      updatedBy: createdBy, // Usar createdBy como updatedBy (no existe en BD)
    );
  }

  /// Crea un modelo desde Entity
  factory ExcepcionFestivoSupabaseModel.fromEntity(ExcepcionFestivoEntity entity) {
    return ExcepcionFestivoSupabaseModel(
      id: entity.id,
      nombre: entity.nombre,
      fecha: entity.fecha,
      tipo: entity.tipo,
      repetirAnualmente: entity.repetirAnualmente,
      activo: entity.activo,
      createdAt: entity.createdAt,
      createdBy: entity.createdBy,
    );
  }
}
