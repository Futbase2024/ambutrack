import 'package:ambutrack_core/src/core/base_entity.dart';

/// Entidad de dominio para Excepciones y Festivos del cuadrante
class ExcepcionFestivoEntity extends BaseEntity {
  const ExcepcionFestivoEntity({
    required super.id,
    required this.nombre,
    required this.fecha,
    required this.tipo,
    this.descripcion,
    this.afectaDotaciones = true,
    this.repetirAnualmente = false,
    required this.activo,
    required super.createdAt,
    required super.updatedAt,
    this.createdBy,
    this.updatedBy,
  });

  /// Nombre del festivo o excepción (ej: "Navidad", "Día del Trabajador")
  final String nombre;

  /// Fecha de la excepción/festivo
  final DateTime fecha;

  /// Tipo de excepción (FESTIVO, EXCEPCION, ESPECIAL)
  final String tipo;

  /// Descripción adicional
  final String? descripcion;

  /// Si afecta a las dotaciones normales (modificar comportamiento)
  final bool afectaDotaciones;

  /// Si se repite automáticamente cada año
  final bool repetirAnualmente;

  /// Estado activo/inactivo
  final bool activo;

  /// ID del usuario que creó el registro
  final String? createdBy;

  /// ID del usuario que actualizó el registro
  final String? updatedBy;

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'nombre': nombre,
      'fecha': fecha.toIso8601String(),
      'tipo': tipo,
      'descripcion': descripcion,
      'afecta_dotaciones': afectaDotaciones,
      'repetir_anualmente': repetirAnualmente,
      'activo': activo,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'created_by': createdBy,
      'updated_by': updatedBy,
    };
  }

  @override
  List<Object?> get props => [
        id,
        nombre,
        fecha,
        tipo,
        descripcion,
        afectaDotaciones,
        repetirAnualmente,
        activo,
        createdAt,
        updatedAt,
        createdBy,
        updatedBy,
      ];

  /// Copia la entidad con los campos especificados
  @override
  ExcepcionFestivoEntity copyWith({
    String? id,
    String? nombre,
    DateTime? fecha,
    String? tipo,
    String? descripcion,
    bool? afectaDotaciones,
    bool? repetirAnualmente,
    bool? activo,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
  }) {
    return ExcepcionFestivoEntity(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      fecha: fecha ?? this.fecha,
      tipo: tipo ?? this.tipo,
      descripcion: descripcion ?? this.descripcion,
      afectaDotaciones: afectaDotaciones ?? this.afectaDotaciones,
      repetirAnualmente: repetirAnualmente ?? this.repetirAnualmente,
      activo: activo ?? this.activo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
    );
  }

  /// Tipos de excepción disponibles
  static const String tipoFestivo = 'FESTIVO';
  static const String tipoExcepcion = 'EXCEPCION';
  static const String tipoEspecial = 'ESPECIAL';

  /// Lista de tipos válidos
  static const List<String> tiposValidos = <String>[
    tipoFestivo,
    tipoExcepcion,
    tipoEspecial,
  ];
}
