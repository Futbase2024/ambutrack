import '../../../core/base_entity.dart';

/// Entidad de dominio para Registro Horario (Fichaje)
///
/// Esta entidad contiene toda la información esencial de un registro
/// de entrada/salida del personal y es agnóstica a la fuente de datos
class RegistroHorarioEntity extends BaseEntity {
  /// ID del personal que ficha
  final String personalId;

  /// Nombre del personal (opcional, puede obtenerse del ID)
  final String? nombrePersonal;

  /// Tipo de fichaje: 'entrada' o 'salida'
  final String tipo;

  /// Fecha y hora del fichaje
  final DateTime fechaHora;

  /// Ubicación donde se realizó el fichaje (GPS, Base, etc.)
  final String? ubicacion;

  /// Latitud GPS del fichaje
  final double? latitud;

  /// Longitud GPS del fichaje
  final double? longitud;

  /// Precisión GPS del fichaje (en metros)
  final double? precisionGps;

  /// Notas adicionales del fichaje
  final String? notas;

  /// Observaciones adicionales (alias de notas para compatibilidad)
  String? get observaciones => notas;

  /// Estado del fichaje: 'normal', 'tarde', 'temprano', 'festivo'
  final String estado;

  /// Si es un fichaje manual (realizado por administrador)
  final bool esManual;

  /// ID del usuario que realizó el fichaje manual (si aplica)
  final String? usuarioManualId;

  /// ID del vehículo/ambulancia asignado (si aplica)
  final String? vehiculoId;

  /// Turno al que pertenece este fichaje
  final String? turno;

  /// Horas trabajadas hasta este fichaje (calculado)
  final double? horasTrabajadas;

  /// Si el fichaje está activo en el sistema
  final bool activo;

  /// Crea una nueva instancia de [RegistroHorarioEntity]
  const RegistroHorarioEntity({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    required this.personalId,
    this.nombrePersonal,
    required this.tipo,
    required this.fechaHora,
    this.ubicacion,
    this.latitud,
    this.longitud,
    this.precisionGps,
    this.notas,
    this.estado = 'normal',
    this.esManual = false,
    this.usuarioManualId,
    this.vehiculoId,
    this.turno,
    this.horasTrabajadas,
    this.activo = true,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'personalId': personalId,
      'nombrePersonal': nombrePersonal,
      'tipo': tipo,
      'fechaHora': fechaHora.toIso8601String(),
      'ubicacion': ubicacion,
      'latitud': latitud,
      'longitud': longitud,
      'precisionGps': precisionGps,
      'notas': notas,
      'estado': estado,
      'esManual': esManual,
      'usuarioManualId': usuarioManualId,
      'vehiculoId': vehiculoId,
      'turno': turno,
      'horasTrabajadas': horasTrabajadas,
      'activo': activo,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Crea un [RegistroHorarioEntity] desde datos JSON
  factory RegistroHorarioEntity.fromJson(Map<String, dynamic> json) {
    return RegistroHorarioEntity(
      id: json['id'] as String,
      personalId: json['personalId'] as String,
      nombrePersonal: json['nombrePersonal'] as String?,
      tipo: json['tipo'] as String,
      fechaHora: _parseDateTime(json['fechaHora'])!,
      ubicacion: json['ubicacion'] as String?,
      latitud: json['latitud'] != null
          ? (json['latitud'] as num).toDouble()
          : null,
      longitud: json['longitud'] != null
          ? (json['longitud'] as num).toDouble()
          : null,
      precisionGps: json['precisionGps'] != null
          ? (json['precisionGps'] as num).toDouble()
          : null,
      notas: json['notas'] as String?,
      estado: json['estado'] as String? ?? 'normal',
      esManual: json['esManual'] as bool? ?? false,
      usuarioManualId: json['usuarioManualId'] as String?,
      vehiculoId: json['vehiculoId'] as String?,
      turno: json['turno'] as String?,
      horasTrabajadas: json['horasTrabajadas'] != null
          ? (json['horasTrabajadas'] as num).toDouble()
          : null,
      activo: json['activo'] as bool? ?? true,
      createdAt: _parseDateTime(json['createdAt']) ?? DateTime.now(),
      updatedAt: _parseDateTime(json['updatedAt']) ?? DateTime.now(),
    );
  }

  /// Parsea un DateTime desde JSON, manejando String y DateTime
  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is String) {
      return DateTime.parse(value);
    }
    if (value is DateTime) {
      return value;
    }
    // Si es un número (timestamp en milisegundos)
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    throw FormatException('Valor de fecha inválido: $value (tipo: ${value.runtimeType})');
  }

  @override
  RegistroHorarioEntity copyWith({
    String? id,
    String? personalId,
    String? nombrePersonal,
    String? tipo,
    DateTime? fechaHora,
    String? ubicacion,
    double? latitud,
    double? longitud,
    double? precisionGps,
    String? notas,
    String? estado,
    bool? esManual,
    String? usuarioManualId,
    String? vehiculoId,
    String? turno,
    double? horasTrabajadas,
    bool? activo,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RegistroHorarioEntity(
      id: id ?? this.id,
      personalId: personalId ?? this.personalId,
      nombrePersonal: nombrePersonal ?? this.nombrePersonal,
      tipo: tipo ?? this.tipo,
      fechaHora: fechaHora ?? this.fechaHora,
      ubicacion: ubicacion ?? this.ubicacion,
      latitud: latitud ?? this.latitud,
      longitud: longitud ?? this.longitud,
      precisionGps: precisionGps ?? this.precisionGps,
      notas: notas ?? this.notas,
      estado: estado ?? this.estado,
      esManual: esManual ?? this.esManual,
      usuarioManualId: usuarioManualId ?? this.usuarioManualId,
      vehiculoId: vehiculoId ?? this.vehiculoId,
      turno: turno ?? this.turno,
      horasTrabajadas: horasTrabajadas ?? this.horasTrabajadas,
      activo: activo ?? this.activo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        ...super.props,
        personalId,
        nombrePersonal,
        tipo,
        fechaHora,
        ubicacion,
        latitud,
        longitud,
        precisionGps,
        notas,
        estado,
        esManual,
        usuarioManualId,
        vehiculoId,
        turno,
        horasTrabajadas,
        activo,
      ];

  @override
  String toString() {
    return 'RegistroHorarioEntity('
        'id: $id, '
        'personalId: $personalId, '
        'tipo: $tipo, '
        'fechaHora: $fechaHora, '
        'estado: $estado, '
        'activo: $activo'
        ')';
  }
}
