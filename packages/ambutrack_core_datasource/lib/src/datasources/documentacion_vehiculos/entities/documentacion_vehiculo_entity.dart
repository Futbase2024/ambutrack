import 'package:equatable/equatable.dart';

/// Entidad de dominio para Documentación de Vehículos
/// Representa los registros de documentación (pólizas, ITV, licencias) de un vehículo
class DocumentacionVehiculoEntity extends Equatable {
  const DocumentacionVehiculoEntity({
    required this.id,
    required this.vehiculoId,
    required this.tipoDocumentoId,
    required this.numeroPoliza,
    required this.compania,
    required this.fechaEmision,
    required this.fechaVencimiento,
    this.fechaProximoVencimiento,
    required this.estado,
    this.costeAnual,
    this.observaciones,
    this.documentoUrl,
    this.documentoUrl2,
    this.requiereRenovacion = false,
    this.diasAlerta = 30,
    this.createdAt,
    this.updatedAt,
    // Información del vehículo (opcional, viene del join)
    this.vehiculoMatricula,
    this.vehiculoMarca,
    this.vehiculoModelo,
    // Información del tipo de documento (opcional, viene del join)
    this.tipoDocumentoNombre,
    this.tipoDocumentoCodigo,
    this.tipoDocumentoCategoria,
  });

  // IDENTIFICACIÓN ÚNICA
  final String id;

  // VEHÍCULO Y TIPO
  final String vehiculoId; // FK hacia vehiculos
  final String tipoDocumentoId; // FK hacia tipos_documento_vehiculo

  // Información del vehículo (opcional, poblada cuando se hace join)
  final String? vehiculoMatricula;
  final String? vehiculoMarca;
  final String? vehiculoModelo;

  // Información del tipo de documento (opcional, poblada cuando se hace join)
  final String? tipoDocumentoNombre;
  final String? tipoDocumentoCodigo;
  final String? tipoDocumentoCategoria;

  // DATOS DEL DOCUMENTO
  final String numeroPoliza; // Número de póliza/licencia
  final String compania; // Compañía aseguradora o entidad emisora
  final DateTime fechaEmision; // Fecha de emisión del documento
  final DateTime fechaVencimiento; // Fecha de vencimiento
  final DateTime? fechaProximoVencimiento; // Próximo vencimiento (para renovaciones)

  // ESTADO
  final String estado; // 'vigente', 'proxima_vencer', 'vencida'

  // DATOS ADICIONALES
  final double? costeAnual; // Coste anual del seguro/permiso
  final String? observaciones; // Observaciones
  final String? documentoUrl; // URL del documento digital (Storage)
  final String? documentoUrl2; // URL del documento digital adicional (Storage)
  final bool requiereRenovacion; // Si requiere renovación automática
  final int diasAlerta; // Días antes del vencimiento para alertar (por defecto 30)

  // AUDITORÍA
  final DateTime? createdAt;
  final DateTime? updatedAt;

  /// Getter para verificar si está vencido
  bool get estaVencido => estado == 'vencida';

  /// Getter para verificar si está próxima a vencer
  bool get estaProximaAVencer => estado == 'proxima_vencer';

  /// Getter para verificar si está vigente
  bool get estaVigente => estado == 'vigente';

  /// Getter para días restantes hasta vencimiento
  int? get diasRestantes {
    if (fechaVencimiento.isBefore(DateTime.now())) {
      return 0;
    }
    return fechaVencimiento.difference(DateTime.now()).inDays;
  }

  /// Getter para estado formateado
  String get estadoFormateado {
    switch (estado) {
      case 'vigente':
        return 'Vigente';
      case 'proxima_vencer':
        return 'Próxima a vencer';
      case 'vencida':
        return 'Vencida';
      default:
        return estado;
    }
  }

  /// Método copyWith para crear copias inmutables
  DocumentacionVehiculoEntity copyWith({
    String? id,
    String? vehiculoId,
    String? tipoDocumentoId,
    String? numeroPoliza,
    String? compania,
    DateTime? fechaEmision,
    DateTime? fechaVencimiento,
    DateTime? fechaProximoVencimiento,
    String? estado,
    double? costeAnual,
    String? observaciones,
    String? documentoUrl,
    String? documentoUrl2,
    bool? requiereRenovacion,
    int? diasAlerta,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? vehiculoMatricula,
    String? vehiculoMarca,
    String? vehiculoModelo,
    String? tipoDocumentoNombre,
    String? tipoDocumentoCodigo,
    String? tipoDocumentoCategoria,
  }) {
    return DocumentacionVehiculoEntity(
      id: id ?? this.id,
      vehiculoId: vehiculoId ?? this.vehiculoId,
      tipoDocumentoId: tipoDocumentoId ?? this.tipoDocumentoId,
      numeroPoliza: numeroPoliza ?? this.numeroPoliza,
      compania: compania ?? this.compania,
      fechaEmision: fechaEmision ?? this.fechaEmision,
      fechaVencimiento: fechaVencimiento ?? this.fechaVencimiento,
      fechaProximoVencimiento: fechaProximoVencimiento ?? this.fechaProximoVencimiento,
      estado: estado ?? this.estado,
      costeAnual: costeAnual ?? this.costeAnual,
      observaciones: observaciones ?? this.observaciones,
      documentoUrl: documentoUrl ?? this.documentoUrl,
      documentoUrl2: documentoUrl2 ?? this.documentoUrl2,
      requiereRenovacion: requiereRenovacion ?? this.requiereRenovacion,
      diasAlerta: diasAlerta ?? this.diasAlerta,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      vehiculoMatricula: vehiculoMatricula ?? this.vehiculoMatricula,
      vehiculoMarca: vehiculoMarca ?? this.vehiculoMarca,
      vehiculoModelo: vehiculoModelo ?? this.vehiculoModelo,
      tipoDocumentoNombre: tipoDocumentoNombre ?? this.tipoDocumentoNombre,
      tipoDocumentoCodigo: tipoDocumentoCodigo ?? this.tipoDocumentoCodigo,
      tipoDocumentoCategoria: tipoDocumentoCategoria ?? this.tipoDocumentoCategoria,
    );
  }

  @override
  List<Object?> get props => [
        id,
        vehiculoId,
        tipoDocumentoId,
        numeroPoliza,
        compania,
        fechaEmision,
        fechaVencimiento,
        fechaProximoVencimiento,
        estado,
        costeAnual,
        observaciones,
        documentoUrl,
        documentoUrl2,
        requiereRenovacion,
        diasAlerta,
        createdAt,
        updatedAt,
        vehiculoMatricula,
        vehiculoMarca,
        vehiculoModelo,
        tipoDocumentoNombre,
        tipoDocumentoCodigo,
        tipoDocumentoCategoria,
      ];
}
