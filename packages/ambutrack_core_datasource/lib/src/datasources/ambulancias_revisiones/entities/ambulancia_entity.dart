import 'tipo_ambulancia_entity.dart';

/// Entity para Ambulancia
class AmbulanciaEntity {
  const AmbulanciaEntity({
    required this.id,
    required this.empresaId,
    required this.tipoAmbulanciaId,
    required this.matricula,
    this.numeroIdentificacion,
    this.marca,
    this.modelo,
    required this.estado,
    this.fechaItv,
    this.fechaIts,
    this.fechaSeguro,
    this.numeroPolizaSeguro,
    required this.certificadoNormaUne,
    this.certificadoNica,
    required this.createdAt,
    required this.updatedAt,
    this.tipoAmbulancia,
  });

  final String id;
  final String empresaId;
  final String tipoAmbulanciaId;
  final String matricula;
  final String? numeroIdentificacion;
  final String? marca;
  final String? modelo;
  final EstadoAmbulancia estado;
  final DateTime? fechaItv;
  final DateTime? fechaIts;
  final DateTime? fechaSeguro;
  final String? numeroPolizaSeguro;
  final bool certificadoNormaUne;
  final String? certificadoNica;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Relaciones
  final TipoAmbulanciaEntity? tipoAmbulancia;

  /// Crea una copia con los campos modificados
  AmbulanciaEntity copyWith({
    String? id,
    String? empresaId,
    String? tipoAmbulanciaId,
    String? matricula,
    String? numeroIdentificacion,
    String? marca,
    String? modelo,
    EstadoAmbulancia? estado,
    DateTime? fechaItv,
    DateTime? fechaIts,
    DateTime? fechaSeguro,
    String? numeroPolizaSeguro,
    bool? certificadoNormaUne,
    String? certificadoNica,
    DateTime? createdAt,
    DateTime? updatedAt,
    TipoAmbulanciaEntity? tipoAmbulancia,
  }) {
    return AmbulanciaEntity(
      id: id ?? this.id,
      empresaId: empresaId ?? this.empresaId,
      tipoAmbulanciaId: tipoAmbulanciaId ?? this.tipoAmbulanciaId,
      matricula: matricula ?? this.matricula,
      numeroIdentificacion: numeroIdentificacion ?? this.numeroIdentificacion,
      marca: marca ?? this.marca,
      modelo: modelo ?? this.modelo,
      estado: estado ?? this.estado,
      fechaItv: fechaItv ?? this.fechaItv,
      fechaIts: fechaIts ?? this.fechaIts,
      fechaSeguro: fechaSeguro ?? this.fechaSeguro,
      numeroPolizaSeguro: numeroPolizaSeguro ?? this.numeroPolizaSeguro,
      certificadoNormaUne: certificadoNormaUne ?? this.certificadoNormaUne,
      certificadoNica: certificadoNica ?? this.certificadoNica,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      tipoAmbulancia: tipoAmbulancia ?? this.tipoAmbulancia,
    );
  }
}

/// Estados posibles de una ambulancia
enum EstadoAmbulancia {
  activa,
  mantenimiento,
  baja;

  String toSupabaseString() {
    switch (this) {
      case EstadoAmbulancia.activa:
        return 'activa';
      case EstadoAmbulancia.mantenimiento:
        return 'mantenimiento';
      case EstadoAmbulancia.baja:
        return 'baja';
    }
  }

  static EstadoAmbulancia fromString(String value) {
    switch (value.toLowerCase()) {
      case 'activa':
        return EstadoAmbulancia.activa;
      case 'mantenimiento':
        return EstadoAmbulancia.mantenimiento;
      case 'baja':
        return EstadoAmbulancia.baja;
      default:
        return EstadoAmbulancia.activa;
    }
  }

  String get nombre {
    switch (this) {
      case EstadoAmbulancia.activa:
        return 'Activa';
      case EstadoAmbulancia.mantenimiento:
        return 'Mantenimiento';
      case EstadoAmbulancia.baja:
        return 'Baja';
    }
  }
}
