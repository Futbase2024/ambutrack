import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:equatable/equatable.dart';

/// Preferencia de turnos de un trabajador
class PreferenciaPersonalEntity extends Equatable {
  const PreferenciaPersonalEntity({
    required this.id,
    required this.idPersonal,
    required this.tipoTurnoPreferido,
    required this.diasSemanaPreferidos,
    required this.horasMaximasSemanales,
    this.observaciones,
    required this.activo,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String idPersonal;
  final TipoTurno? tipoTurnoPreferido; // Mañana, Tarde, Noche, etc.
  final List<int> diasSemanaPreferidos; // 1=Lunes, 7=Domingo
  final double? horasMaximasSemanales; // Límite personal (puede ser menor que el legal)
  final String? observaciones;
  final bool activo;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  @override
  List<Object?> get props => <Object?>[
        id,
        idPersonal,
        tipoTurnoPreferido,
        diasSemanaPreferidos,
        horasMaximasSemanales,
        observaciones,
        activo,
        createdAt,
        updatedAt,
      ];

  PreferenciaPersonalEntity copyWith({
    String? id,
    String? idPersonal,
    TipoTurno? tipoTurnoPreferido,
    List<int>? diasSemanaPreferidos,
    double? horasMaximasSemanales,
    String? observaciones,
    bool? activo,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PreferenciaPersonalEntity(
      id: id ?? this.id,
      idPersonal: idPersonal ?? this.idPersonal,
      tipoTurnoPreferido: tipoTurnoPreferido ?? this.tipoTurnoPreferido,
      diasSemanaPreferidos: diasSemanaPreferidos ?? this.diasSemanaPreferidos,
      horasMaximasSemanales: horasMaximasSemanales ?? this.horasMaximasSemanales,
      observaciones: observaciones ?? this.observaciones,
      activo: activo ?? this.activo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
