import '../entities/tecnico_en_turno_entity.dart';

/// Modelo Supabase que combina una fila de `turnos`, los datos del personal
/// y su último fichaje de `registros_horarios`.
class TecnicoEnTurnoSupabaseModel {
  const TecnicoEnTurnoSupabaseModel({
    required this.turnoId,
    required this.personalId,
    required this.nombre,
    required this.categoria,
    required this.inicioTurno,
    required this.finTurno,
    this.tipoTurno,
    this.ultimoFichajeTipo,
    this.ultimoFichajeHora,
  });

  /// Construye el modelo a partir de las filas de cada tabla
  ///
  /// - [turno]: fila de `turnos` (columnas camelCase)
  /// - [personal]: fila de `tpersonal` (`nombre`, `apellidos`)
  /// - [categoria]: nombre de la categoría (`tcategorias.categoria`)
  /// - [fichaje]: último fichaje de `registros_horarios` (`tipo`, `fecha_hora`)
  factory TecnicoEnTurnoSupabaseModel.fromRows({
    required Map<String, dynamic> turno,
    required Map<String, dynamic> personal,
    required String categoria,
    Map<String, dynamic>? fichaje,
  }) {
    final String nombre = '${personal['nombre'] ?? ''} ${personal['apellidos'] ?? ''}'.trim();
    return TecnicoEnTurnoSupabaseModel(
      turnoId: turno['id'] as String,
      personalId: turno['idPersonal'] as String,
      nombre: nombre.isEmpty ? (turno['nombrePersonal'] as String? ?? '') : nombre,
      categoria: categoria,
      inicioTurno: DateTime.parse(turno['fechaInicio'] as String).toLocal(),
      finTurno: DateTime.parse(turno['fechaFin'] as String).toLocal(),
      tipoTurno: turno['tipoTurno'] as String?,
      ultimoFichajeTipo: fichaje?['tipo'] as String?,
      ultimoFichajeHora:
          fichaje?['fecha_hora'] != null ? DateTime.parse(fichaje!['fecha_hora'] as String).toLocal() : null,
    );
  }

  final String turnoId;
  final String personalId;
  final String nombre;
  final String categoria;
  final DateTime inicioTurno;
  final DateTime finTurno;
  final String? tipoTurno;
  final String? ultimoFichajeTipo;
  final DateTime? ultimoFichajeHora;

  /// Convierte el modelo a entidad de dominio
  TecnicoEnTurnoEntity toEntity() {
    return TecnicoEnTurnoEntity(
      turnoId: turnoId,
      personalId: personalId,
      nombre: nombre.toUpperCase(),
      categoria: categoria,
      inicioTurno: inicioTurno,
      finTurno: finTurno,
      tipoTurno: tipoTurno,
      ultimoFichajeTipo: ultimoFichajeTipo,
      ultimoFichajeHora: ultimoFichajeHora,
    );
  }
}
