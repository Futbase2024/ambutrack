/// Librería pública de Incidencias generales.
///
/// Expone `IncidenciaEntity` junto con sus enums `EstadoIncidencia` y
/// `PrioridadIncidencia`, que el barrel principal oculta para evitar
/// conflictos con los enums homónimos de `incidencias_vehiculo`.
library;

export 'src/datasources/incidencias/entities/incidencia_entity.dart';
