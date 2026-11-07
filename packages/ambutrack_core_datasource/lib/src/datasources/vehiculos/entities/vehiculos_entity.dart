import '../../../core/base_entity.dart';

/// Estado del vehículo
enum VehiculoEstado {
  /// Vehículo operativo y disponible
  activo,

  /// Vehículo en mantenimiento programado
  mantenimiento,

  /// Vehículo en reparación por avería
  reparacion,

  /// Vehículo dado de baja
  baja,
}

/// Entidad de dominio para Vehículos
///
/// Representa un vehículo de la flota (ambulancia, vehículo médico, etc.)
/// Mapea a la tabla `tvehiculos` en Supabase
class VehiculoEntity extends BaseEntity {
  /// Constructor de la entidad Vehiculo
  const VehiculoEntity({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    required this.matricula,
    required this.tipoVehiculo,
    required this.categoria,
    required this.marca,
    required this.modelo,
    required this.anioFabricacion,
    required this.numeroBastidor,
    required this.estado,
    required this.empresaId,
    required this.proximaItv,
    required this.fechaVencimientoSeguro,
    required this.homologacionSanitaria,
    required this.fechaVencimientoHomologacion,
    this.numeroInterno,
    this.alias,
    this.clasificacion,
    this.capacidadPasajeros,
    this.capacidadCamilla,
    this.equipamiento,
    this.fechaAdquisicion,
    this.kmActual,
    this.ubicacionActual,
    this.observaciones,
    this.ultimoMantenimiento,
    this.proximoMantenimiento,
    this.kmProximoMantenimiento,
    this.createdBy,
    this.updatedBy,
  });

  // ========== CAMPOS OBLIGATORIOS ==========
  // id, createdAt, updatedAt heredados de BaseEntity

  /// Matrícula del vehículo
  final String matricula;

  /// Tipo de vehículo (Ambulancia Tipo A, B, C, UVI Móvil, etc.)
  final String tipoVehiculo;

  /// Categoría del vehículo
  final String categoria;

  /// Marca del vehículo
  final String marca;

  /// Modelo del vehículo
  final String modelo;

  /// Año de fabricación
  final int anioFabricacion;

  /// Número de bastidor (VIN)
  final String numeroBastidor;

  /// Estado actual del vehículo
  final VehiculoEstado estado;

  /// ID de la empresa propietaria (UUID)
  final String empresaId;

  /// Fecha de la próxima ITV
  final DateTime proximaItv;

  /// Fecha de vencimiento del seguro
  final DateTime fechaVencimientoSeguro;

  /// Número de homologación sanitaria
  final String homologacionSanitaria;

  /// Fecha de vencimiento de la homologación sanitaria
  final DateTime fechaVencimientoHomologacion;

  // ========== CAMPOS OPCIONALES ==========

  /// Número interno de la empresa
  final String? numeroInterno;

  /// Alias o nombre personalizado del vehículo
  final String? alias;

  /// Clasificación adicional del vehículo
  final String? clasificacion;

  /// Capacidad de pasajeros
  final int? capacidadPasajeros;

  /// Capacidad de camillas
  final int? capacidadCamilla;

  /// Equipamiento médico del vehículo (JSON)
  final Map<String, dynamic>? equipamiento;

  /// Fecha de adquisición del vehículo
  final DateTime? fechaAdquisicion;

  /// Kilómetros actuales del vehículo
  final double? kmActual;

  /// Ubicación actual del vehículo
  final String? ubicacionActual;

  /// Observaciones sobre el vehículo
  final String? observaciones;

  /// Fecha del último mantenimiento realizado
  final DateTime? ultimoMantenimiento;

  /// Fecha del próximo mantenimiento programado
  final DateTime? proximoMantenimiento;

  /// Kilómetros en los que se debe realizar el próximo mantenimiento
  final int? kmProximoMantenimiento;

  /// ID del usuario que creó el registro (UUID)
  final String? createdBy;

  /// ID del usuario que actualizó el registro (UUID)
  final String? updatedBy;

  /// Crea una copia de la entidad con valores actualizados
  @override
  VehiculoEntity copyWith({
    String? id,
    String? matricula,
    String? tipoVehiculo,
    String? categoria,
    String? marca,
    String? modelo,
    int? anioFabricacion,
    String? numeroBastidor,
    VehiculoEstado? estado,
    String? empresaId,
    DateTime? proximaItv,
    DateTime? fechaVencimientoSeguro,
    String? homologacionSanitaria,
    DateTime? fechaVencimientoHomologacion,
    String? numeroInterno,
    String? alias,
    String? clasificacion,
    int? capacidadPasajeros,
    int? capacidadCamilla,
    Map<String, dynamic>? equipamiento,
    DateTime? fechaAdquisicion,
    double? kmActual,
    String? ubicacionActual,
    String? observaciones,
    DateTime? ultimoMantenimiento,
    DateTime? proximoMantenimiento,
    int? kmProximoMantenimiento,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
  }) {
    return VehiculoEntity(
      id: id ?? this.id,
      matricula: matricula ?? this.matricula,
      tipoVehiculo: tipoVehiculo ?? this.tipoVehiculo,
      categoria: categoria ?? this.categoria,
      marca: marca ?? this.marca,
      modelo: modelo ?? this.modelo,
      anioFabricacion: anioFabricacion ?? this.anioFabricacion,
      numeroBastidor: numeroBastidor ?? this.numeroBastidor,
      estado: estado ?? this.estado,
      empresaId: empresaId ?? this.empresaId,
      proximaItv: proximaItv ?? this.proximaItv,
      fechaVencimientoSeguro: fechaVencimientoSeguro ?? this.fechaVencimientoSeguro,
      homologacionSanitaria: homologacionSanitaria ?? this.homologacionSanitaria,
      fechaVencimientoHomologacion: fechaVencimientoHomologacion ?? this.fechaVencimientoHomologacion,
      numeroInterno: numeroInterno ?? this.numeroInterno,
      alias: alias ?? this.alias,
      clasificacion: clasificacion ?? this.clasificacion,
      capacidadPasajeros: capacidadPasajeros ?? this.capacidadPasajeros,
      capacidadCamilla: capacidadCamilla ?? this.capacidadCamilla,
      equipamiento: equipamiento ?? this.equipamiento,
      fechaAdquisicion: fechaAdquisicion ?? this.fechaAdquisicion,
      kmActual: kmActual ?? this.kmActual,
      ubicacionActual: ubicacionActual ?? this.ubicacionActual,
      observaciones: observaciones ?? this.observaciones,
      ultimoMantenimiento: ultimoMantenimiento ?? this.ultimoMantenimiento,
      proximoMantenimiento: proximoMantenimiento ?? this.proximoMantenimiento,
      kmProximoMantenimiento: kmProximoMantenimiento ?? this.kmProximoMantenimiento,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
    );
  }

  @override
  List<Object?> get props => <Object?>[
        id,
        matricula,
        tipoVehiculo,
        categoria,
        marca,
        modelo,
        anioFabricacion,
        numeroBastidor,
        estado,
        empresaId,
        proximaItv,
        fechaVencimientoSeguro,
        homologacionSanitaria,
        fechaVencimientoHomologacion,
        numeroInterno,
        alias,
        clasificacion,
        capacidadPasajeros,
        capacidadCamilla,
        equipamiento,
        fechaAdquisicion,
        kmActual,
        ubicacionActual,
        observaciones,
        ultimoMantenimiento,
        proximoMantenimiento,
        kmProximoMantenimiento,
        createdAt,
        updatedAt,
        createdBy,
        updatedBy,
      ];

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'matricula': matricula,
      'tipo_vehiculo': tipoVehiculo,
      'categoria': categoria,
      'marca': marca,
      'modelo': modelo,
      'anio_fabricacion': anioFabricacion,
      'numero_bastidor': numeroBastidor,
      'estado': estado.name,
      'empresa_id': empresaId,
      'proxima_itv': proximaItv.toIso8601String(),
      'fecha_vencimiento_seguro': fechaVencimientoSeguro.toIso8601String(),
      'homologacion_sanitaria': homologacionSanitaria,
      'fecha_vencimiento_homologacion': fechaVencimientoHomologacion.toIso8601String(),
      'numero_interno': numeroInterno,
      'alias': alias,
      'clasificacion': clasificacion,
      'capacidad_pasajeros': capacidadPasajeros,
      'capacidad_camilla': capacidadCamilla,
      'equipamiento': equipamiento,
      'fecha_adquisicion': fechaAdquisicion?.toIso8601String(),
      'km_actual': kmActual,
      'ubicacion_actual': ubicacionActual,
      'observaciones': observaciones,
      'ultimo_mantenimiento': ultimoMantenimiento?.toIso8601String(),
      'proximo_mantenimiento': proximoMantenimiento?.toIso8601String(),
      'km_proximo_mantenimiento': kmProximoMantenimiento,
      'created_by': createdBy,
      'updated_by': updatedBy,
    };
  }
}
