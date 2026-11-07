import '../entities/vehiculos_entity.dart';

/// Modelo de Supabase para Vehículos
///
/// Mapea directamente desde/hacia la tabla PostgreSQL 'tvehiculos'
class VehiculoSupabaseModel {
  final String id;
  final String matricula;
  final String tipoVehiculo;
  final String categoria;
  final String marca;
  final String modelo;
  final int anioFabricacion;
  final String numeroBastidor;
  final VehiculoEstado estado;
  final String empresaId;
  final DateTime proximaItv;
  final DateTime fechaVencimientoSeguro;
  final String homologacionSanitaria;
  final DateTime fechaVencimientoHomologacion;
  final String? numeroInterno;
  final String? alias;
  final String? clasificacion;
  final int? capacidadPasajeros;
  final int? capacidadCamilla;
  final Map<String, dynamic>? equipamiento;
  final DateTime? fechaAdquisicion;
  final double? kmActual;
  final String? ubicacionActual;
  final String? observaciones;
  final DateTime? ultimoMantenimiento;
  final DateTime? proximoMantenimiento;
  final int? kmProximoMantenimiento;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? createdBy;
  final String? updatedBy;

  const VehiculoSupabaseModel({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
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

  /// Convierte desde JSON de Supabase (snake_case)
  factory VehiculoSupabaseModel.fromJson(Map<String, dynamic> json) {
    final DateTime now = DateTime.now();
    final DateTime defaultFutureDate = now.add(const Duration(days: 365));

    return VehiculoSupabaseModel(
      id: json['id'] as String? ?? '',
      createdAt: _parseDate(json['created_at']) ?? now,
      updatedAt: _parseDate(json['updated_at']) ?? now,
      matricula: json['matricula'] as String? ?? '',
      tipoVehiculo: json['tipo_vehiculo'] as String? ?? '',
      categoria: json['categoria'] as String? ?? '',
      marca: json['marca'] as String? ?? '',
      modelo: json['modelo'] as String? ?? '',
      anioFabricacion: json['anio_fabricacion'] as int? ?? now.year,
      numeroBastidor: json['numero_bastidor'] as String? ?? '',
      estado: _estadoFromString(json['estado'] as String?),
      empresaId: json['empresa_id'] as String? ?? '',
      proximaItv: _parseDate(json['proxima_itv']) ?? defaultFutureDate,
      fechaVencimientoSeguro: _parseDate(json['fecha_vencimiento_seguro']) ?? defaultFutureDate,
      homologacionSanitaria: json['homologacion_sanitaria'] as String? ?? '',
      fechaVencimientoHomologacion: _parseDate(json['fecha_vencimiento_homologacion']) ?? defaultFutureDate,
      numeroInterno: json['numero_interno'] as String?,
      alias: json['alias'] as String?,
      clasificacion: json['clasificacion'] as String?,
      capacidadPasajeros: json['capacidad_pasajeros'] as int?,
      capacidadCamilla: json['capacidad_camilla'] as int?,
      equipamiento: json['equipamiento'] as Map<String, dynamic>?,
      fechaAdquisicion: _parseDate(json['fecha_adquisicion']),
      kmActual: json['km_actual'] != null ? (json['km_actual'] as num).toDouble() : null,
      ubicacionActual: json['ubicacion_actual'] as String?,
      observaciones: json['observaciones'] as String?,
      ultimoMantenimiento: _parseDate(json['ultimo_mantenimiento']),
      proximoMantenimiento: _parseDate(json['proximo_mantenimiento']),
      kmProximoMantenimiento: json['km_proximo_mantenimiento'] as int?,
      createdBy: json['created_by'] as String?,
      updatedBy: json['updated_by'] as String?,
    );
  }

  /// Convierte a JSON para Supabase (snake_case)
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = {
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'matricula': matricula,
      'tipo_vehiculo': tipoVehiculo,
      'categoria': categoria,
      'marca': marca,
      'modelo': modelo,
      'anio_fabricacion': anioFabricacion,
      'numero_bastidor': numeroBastidor,
      'estado': _estadoToString(estado),
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
      'km_actual': kmActual ?? 0,
      'ubicacion_actual': ubicacionActual,
      'observaciones': observaciones,
      'ultimo_mantenimiento': ultimoMantenimiento?.toIso8601String(),
      'proximo_mantenimiento': proximoMantenimiento?.toIso8601String(),
      'km_proximo_mantenimiento': kmProximoMantenimiento,
      'created_by': createdBy,
      'updated_by': updatedBy,
    };

    // Solo incluir el ID si no está vacío (para updates)
    if (id.isNotEmpty) {
      map['id'] = id;
    }

    return map;
  }

  /// Convierte el modelo a entidad de dominio
  VehiculoEntity toEntity() {
    return VehiculoEntity(
      id: id,
      createdAt: createdAt,
      updatedAt: updatedAt,
      matricula: matricula,
      tipoVehiculo: tipoVehiculo,
      categoria: categoria,
      marca: marca,
      modelo: modelo,
      anioFabricacion: anioFabricacion,
      numeroBastidor: numeroBastidor,
      estado: estado,
      empresaId: empresaId,
      proximaItv: proximaItv,
      fechaVencimientoSeguro: fechaVencimientoSeguro,
      homologacionSanitaria: homologacionSanitaria,
      fechaVencimientoHomologacion: fechaVencimientoHomologacion,
      numeroInterno: numeroInterno,
      alias: alias,
      clasificacion: clasificacion,
      capacidadPasajeros: capacidadPasajeros,
      capacidadCamilla: capacidadCamilla,
      equipamiento: equipamiento,
      fechaAdquisicion: fechaAdquisicion,
      kmActual: kmActual,
      ubicacionActual: ubicacionActual,
      observaciones: observaciones,
      ultimoMantenimiento: ultimoMantenimiento,
      proximoMantenimiento: proximoMantenimiento,
      kmProximoMantenimiento: kmProximoMantenimiento,
      createdBy: createdBy,
      updatedBy: updatedBy,
    );
  }

  /// Crea un modelo desde una entidad de dominio
  factory VehiculoSupabaseModel.fromEntity(VehiculoEntity entity) {
    return VehiculoSupabaseModel(
      id: entity.id,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      matricula: entity.matricula,
      tipoVehiculo: entity.tipoVehiculo,
      categoria: entity.categoria,
      marca: entity.marca,
      modelo: entity.modelo,
      anioFabricacion: entity.anioFabricacion,
      numeroBastidor: entity.numeroBastidor,
      estado: entity.estado,
      empresaId: entity.empresaId,
      proximaItv: entity.proximaItv,
      fechaVencimientoSeguro: entity.fechaVencimientoSeguro,
      homologacionSanitaria: entity.homologacionSanitaria,
      fechaVencimientoHomologacion: entity.fechaVencimientoHomologacion,
      numeroInterno: entity.numeroInterno,
      alias: entity.alias,
      clasificacion: entity.clasificacion,
      capacidadPasajeros: entity.capacidadPasajeros,
      capacidadCamilla: entity.capacidadCamilla,
      equipamiento: entity.equipamiento,
      fechaAdquisicion: entity.fechaAdquisicion,
      kmActual: entity.kmActual,
      ubicacionActual: entity.ubicacionActual,
      observaciones: entity.observaciones,
      ultimoMantenimiento: entity.ultimoMantenimiento,
      proximoMantenimiento: entity.proximoMantenimiento,
      kmProximoMantenimiento: entity.kmProximoMantenimiento,
      createdBy: entity.createdBy,
      updatedBy: entity.updatedBy,
    );
  }

  /// Helper para parsear fechas de forma segura
  static DateTime? _parseDate(Object? value) {
    if (value == null) {
      return null;
    }
    if (value is DateTime) {
      return value;
    }
    if (value is String && value.isNotEmpty) {
      try {
        return DateTime.parse(value);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  /// Convierte string a VehiculoEstado
  static VehiculoEstado _estadoFromString(String? estado) {
    switch (estado) {
      case 'activo':
        return VehiculoEstado.activo;
      case 'mantenimiento':
        return VehiculoEstado.mantenimiento;
      case 'reparacion':
        return VehiculoEstado.reparacion;
      case 'baja':
        return VehiculoEstado.baja;
      default:
        return VehiculoEstado.activo;
    }
  }

  /// Convierte VehiculoEstado a string
  static String _estadoToString(VehiculoEstado estado) {
    switch (estado) {
      case VehiculoEstado.activo:
        return 'activo';
      case VehiculoEstado.mantenimiento:
        return 'mantenimiento';
      case VehiculoEstado.reparacion:
        return 'reparacion';
      case VehiculoEstado.baja:
        return 'baja';
    }
  }
}
