/// Entidad de dominio para revisiones mensuales de stock
///
/// Representa una revisión mensual de stock por día (1, 2 o 3)
class RevisionMensualEntity {
  /// Identificador único de la revisión
  final String id;

  /// ID del vehículo
  final String vehiculoId;

  /// Fecha de la revisión
  final DateTime fecha;

  /// Mes de la revisión (1-12)
  final int mes;

  /// Año de la revisión
  final int anio;

  /// Día de revisión (1, 2 o 3)
  final int diaRevision;

  /// ID del técnico que realizó la revisión
  final String? tecnicoId;

  /// Nombre del técnico
  final String? tecnicoNombre;

  /// Indica si la revisión está completada
  final bool completada;

  /// Firma digital en base64
  final String? firmaBase64;

  /// Observaciones generales de la revisión
  final String? observacionesGenerales;

  /// Fecha de creación del registro
  final DateTime createdAt;

  /// Fecha de finalización de la revisión
  final DateTime? completedAt;

  const RevisionMensualEntity({
    required this.id,
    required this.vehiculoId,
    required this.fecha,
    required this.mes,
    required this.anio,
    required this.diaRevision,
    this.tecnicoId,
    this.tecnicoNombre,
    this.completada = false,
    this.firmaBase64,
    this.observacionesGenerales,
    required this.createdAt,
    this.completedAt,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RevisionMensualEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          vehiculoId == other.vehiculoId &&
          fecha == other.fecha &&
          mes == other.mes &&
          anio == other.anio &&
          diaRevision == other.diaRevision &&
          tecnicoId == other.tecnicoId &&
          tecnicoNombre == other.tecnicoNombre &&
          completada == other.completada &&
          observacionesGenerales == other.observacionesGenerales;

  @override
  int get hashCode =>
      id.hashCode ^
      vehiculoId.hashCode ^
      fecha.hashCode ^
      mes.hashCode ^
      anio.hashCode ^
      diaRevision.hashCode ^
      tecnicoId.hashCode ^
      tecnicoNombre.hashCode ^
      completada.hashCode ^
      observacionesGenerales.hashCode;

  @override
  String toString() =>
      'RevisionMensualEntity(id: $id, mes: $mes/$anio, dia: $diaRevision, completada: $completada)';
}
