import 'package:equatable/equatable.dart';

/// Criterios evaluados (puntuación entera 1-5)
enum CriterioEvaluacion {
  puntualidad('puntualidad', 'Puntualidad'),
  tratoPaciente('trato_paciente', 'Trato al paciente'),
  trabajoEquipo('trabajo_equipo', 'Trabajo en equipo'),
  cumplimientoProtocolos('cumplimiento_protocolos', 'Cumplimiento de protocolos');

  const CriterioEvaluacion(this.column, this.label);

  final String column;
  final String label;
}

/// Entity: Evaluación de desempeño de un trabajador
///
/// `puntuacionMedia` la calcula la BD (columna generada); en cliente se usa
/// [calcularMedia] para la vista previa con la misma regla (redondeo a 2 decimales).
/// `empresaId` vacío en creación → lo rellena un trigger con la empresa del trabajador.
class EvaluacionDesempenoEntity extends Equatable {
  const EvaluacionDesempenoEntity({
    required this.id,
    this.empresaId = '',
    required this.personalId,
    required this.fecha,
    this.periodo,
    this.evaluadorId,
    this.evaluadorNombre,
    required this.puntualidad,
    required this.tratoPaciente,
    required this.trabajoEquipo,
    required this.cumplimientoProtocolos,
    double? puntuacionMedia,
    this.comentarios,
    this.createdAt,
    this.updatedAt,
    this.personalNombre,
  }) : _puntuacionMedia = puntuacionMedia;

  /// Puntuación mínima y máxima de cada criterio
  static const int minPuntuacion = 1;
  static const int maxPuntuacion = 5;

  final String id;
  final String empresaId;
  final String personalId;
  final DateTime fecha;
  final String? periodo;
  final String? evaluadorId;
  final String? evaluadorNombre;
  final int puntualidad;
  final int tratoPaciente;
  final int trabajoEquipo;
  final int cumplimientoProtocolos;
  final double? _puntuacionMedia;
  final String? comentarios;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Solo lectura (join)
  final String? personalNombre;

  /// Media de las puntuaciones redondeada a 2 decimales (0 si no hay ninguna)
  static double calcularMedia(List<int> puntuaciones) {
    if (puntuaciones.isEmpty) {
      return 0;
    }
    final int suma = puntuaciones.fold<int>(0, (int a, int b) => a + b);
    return (suma * 100 / puntuaciones.length).round() / 100;
  }

  /// ¿Puntuación dentro del rango permitido (1-5)?
  static bool puntuacionValida(int valor) => valor >= minPuntuacion && valor <= maxPuntuacion;

  /// Puntuaciones por criterio
  Map<CriterioEvaluacion, int> get puntuaciones => <CriterioEvaluacion, int>{
        CriterioEvaluacion.puntualidad: puntualidad,
        CriterioEvaluacion.tratoPaciente: tratoPaciente,
        CriterioEvaluacion.trabajoEquipo: trabajoEquipo,
        CriterioEvaluacion.cumplimientoProtocolos: cumplimientoProtocolos,
      };

  /// Media: la de la BD si existe, si no la calculada en cliente
  double get puntuacionMedia => _puntuacionMedia ?? calcularMedia(puntuaciones.values.toList());

  @override
  List<Object?> get props => <Object?>[
        id,
        empresaId,
        personalId,
        fecha,
        periodo,
        evaluadorId,
        evaluadorNombre,
        puntualidad,
        tratoPaciente,
        trabajoEquipo,
        cumplimientoProtocolos,
        _puntuacionMedia,
        comentarios,
        createdAt,
        updatedAt,
        personalNombre,
      ];
}
