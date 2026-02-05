import 'package:equatable/equatable.dart';

/// Configuración para la generación automática de cuadrantes
class ConfiguracionGeneracionEntity extends Equatable {
  const ConfiguracionGeneracionEntity({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.horasMaximasSemanales,
    required this.horasMaximasMensuales,
    required this.horasMinimasDescansoEntreTurnos,
    required this.diasDescansoSemanal,
    required this.rotacionEquitativa,
    required this.respetarPreferencias,
    required this.activo,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String nombre;
  final String? descripcion;
  final double horasMaximasSemanales; // Ej: 40
  final double horasMaximasMensuales; // Ej: 160
  final double horasMinimasDescansoEntreTurnos; // Ej: 12
  final int diasDescansoSemanal; // Ej: 1 o 2
  final bool rotacionEquitativa; // Distribuir turnos equitativamente
  final bool respetarPreferencias; // Considerar preferencias del personal
  final bool activo;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  @override
  List<Object?> get props => <Object?>[
        id,
        nombre,
        descripcion,
        horasMaximasSemanales,
        horasMaximasMensuales,
        horasMinimasDescansoEntreTurnos,
        diasDescansoSemanal,
        rotacionEquitativa,
        respetarPreferencias,
        activo,
        createdAt,
        updatedAt,
      ];

  ConfiguracionGeneracionEntity copyWith({
    String? id,
    String? nombre,
    String? descripcion,
    double? horasMaximasSemanales,
    double? horasMaximasMensuales,
    double? horasMinimasDescansoEntreTurnos,
    int? diasDescansoSemanal,
    bool? rotacionEquitativa,
    bool? respetarPreferencias,
    bool? activo,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ConfiguracionGeneracionEntity(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      horasMaximasSemanales: horasMaximasSemanales ?? this.horasMaximasSemanales,
      horasMaximasMensuales: horasMaximasMensuales ?? this.horasMaximasMensuales,
      horasMinimasDescansoEntreTurnos:
          horasMinimasDescansoEntreTurnos ?? this.horasMinimasDescansoEntreTurnos,
      diasDescansoSemanal: diasDescansoSemanal ?? this.diasDescansoSemanal,
      rotacionEquitativa: rotacionEquitativa ?? this.rotacionEquitativa,
      respetarPreferencias: respetarPreferencias ?? this.respetarPreferencias,
      activo: activo ?? this.activo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
