import 'package:equatable/equatable.dart';

/// Entidad de dominio para registros de formación del personal
class FormacionPersonalEntity extends Equatable {
  const FormacionPersonalEntity({
    required this.id,
    required this.personalId,
    this.certificacionId,
    this.cursoId,
    required this.fechaInicio,
    required this.fechaFin,
    required this.fechaExpiracion,
    required this.horasAcumuladas,
    required this.estado,
    this.observaciones,
    this.certificadoUrl,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String personalId; // ID del empleado
  final String? certificacionId; // ID de la certificación (opcional si es curso)
  final String? cursoId; // ID del curso (opcional si es solo certificación)
  final DateTime fechaInicio; // Fecha de inicio de la formación
  final DateTime fechaFin; // Fecha de finalización
  final DateTime fechaExpiracion; // Fecha de vencimiento de la certificación
  final int horasAcumuladas; // Horas acumuladas
  final String estado; // 'vigente', 'proxima_vencer', 'vencida'
  final String? observaciones;
  final String? certificadoUrl; // URL del certificado digital (Storage)
  final DateTime? createdAt;
  final DateTime? updatedAt;

  /// Verifica si la formación está vigente
  bool get isVigente => estado == 'vigente';

  /// Verifica si la formación está próxima a vencer
  bool get isProximaVencer => estado == 'proxima_vencer';

  /// Verifica si la formación está vencida
  bool get isVencida => estado == 'vencida';

  /// Verifica si esta formación incluye una certificación
  bool get hasCertificacion => certificacionId != null;

  /// Verifica si esta formación es un curso
  bool get isCurso => cursoId != null;

  @override
  List<Object?> get props => [
        id,
        personalId,
        certificacionId,
        cursoId,
        fechaInicio,
        fechaFin,
        fechaExpiracion,
        horasAcumuladas,
        estado,
        observaciones,
        certificadoUrl,
        createdAt,
        updatedAt,
      ];
}

/// Constantes para estados de formación
class FormacionEstado {
  const FormacionEstado._();

  static const String vigente = 'vigente';
  static const String proximaVencer = 'proxima_vencer';
  static const String vencida = 'vencida';
}
