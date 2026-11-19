import 'package:equatable/equatable.dart';

/// Entidad de dominio para certificaciones sanitarias
class CertificacionEntity extends Equatable {
  const CertificacionEntity({
    required this.id,
    required this.codigo,
    required this.nombre,
    this.descripcion,
    required this.vigenciaMeses,
    required this.horasRequeridas,
    required this.activa,
    this.fechaBaja,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String codigo; // 'SVA', 'ACLS', 'PHTLS', 'TES', 'SVB', 'DEA'
  final String nombre; // 'Soporte Vital Avanzado'
  final String? descripcion;
  final int vigenciaMeses; // Vigencia en meses (12, 24, 36, etc.)
  final int horasRequeridas; // Horas de formación requeridas
  final bool activa; // Si está activa en el sistema
  final DateTime? fechaBaja; // Fecha de baja (si aplica)
  final DateTime? createdAt;
  final DateTime? updatedAt;

  @override
  List<Object?> get props => [
        id,
        codigo,
        nombre,
        descripcion,
        vigenciaMeses,
        horasRequeridas,
        activa,
        fechaBaja,
        createdAt,
        updatedAt,
      ];
}

/// Constantes para códigos de certificación comunes
class CertificacionCodigo {
  const CertificacionCodigo._();

  static const String sva = 'SVA'; // Soporte Vital Avanzado
  static const String acls = 'ACLS'; // Advanced Cardiovascular Life Support
  static const String phtls = 'PHTLS'; // Prehospital Trauma Life Support
  static const String tes = 'TES'; // Técnico de Emergencias Sanitarias
  static const String svb = 'SVB'; // Soporte Vital Básico
  static const String dea = 'DEA'; // Desfibrilación Externa Automatizada
}
