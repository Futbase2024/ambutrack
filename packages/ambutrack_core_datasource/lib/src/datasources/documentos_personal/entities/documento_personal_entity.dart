import 'package:equatable/equatable.dart';

/// Tipo de documento del personal (columna `tipo` de tdocumentos_personal)
enum TipoDocumentoPersonal {
  dni('dni', 'DNI / NIE'),
  carnetConducir('carnet_conducir', 'Carnet de conducir'),
  titulacion('titulacion', 'Titulación'),
  certificadoSanitario('certificado_sanitario', 'Certificado sanitario'),
  formacion('formacion', 'Formación'),
  contrato('contrato', 'Contrato'),
  reconocimientoMedico('reconocimiento_medico', 'Reconocimiento médico'),
  otro('otro', 'Otro');

  const TipoDocumentoPersonal(this.value, this.label);

  final String value;
  final String label;

  static TipoDocumentoPersonal fromString(String? value) {
    return TipoDocumentoPersonal.values.firstWhere(
      (TipoDocumentoPersonal t) => t.value == value,
      orElse: () => TipoDocumentoPersonal.otro,
    );
  }
}

/// Estado calculado de un documento según su fecha de caducidad
enum EstadoDocumentoPersonal {
  vigente('Vigente'),
  proximoACaducar('Próximo a caducar'),
  caducado('Caducado'),
  sinCaducidad('Sin caducidad');

  const EstadoDocumentoPersonal(this.label);

  final String label;

  /// Días de antelación con los que un documento se considera "próximo a caducar"
  static const int diasAviso = 30;

  /// Calcula el estado comparando solo fechas (sin hora).
  /// - Sin fecha de caducidad → [sinCaducidad]
  /// - Caducidad anterior a hoy → [caducado] (el día de caducidad aún es válido)
  /// - Caducidad dentro de los próximos [diasAviso] días → [proximoACaducar]
  /// - En otro caso → [vigente]
  static EstadoDocumentoPersonal calcular(DateTime? fechaCaducidad, DateTime hoy) {
    if (fechaCaducidad == null) {
      return EstadoDocumentoPersonal.sinCaducidad;
    }
    final DateTime cad = DateTime(fechaCaducidad.year, fechaCaducidad.month, fechaCaducidad.day);
    final DateTime ref = DateTime(hoy.year, hoy.month, hoy.day);
    if (cad.isBefore(ref)) {
      return EstadoDocumentoPersonal.caducado;
    }
    final DateTime limite = DateTime(ref.year, ref.month, ref.day + diasAviso);
    if (!cad.isAfter(limite)) {
      return EstadoDocumentoPersonal.proximoACaducar;
    }
    return EstadoDocumentoPersonal.vigente;
  }
}

/// Entity: Documento o certificación de un trabajador
///
/// `empresaId` vacío en creación → lo rellena un trigger en BD (empresa del trabajador).
/// `personalNombre` es de solo lectura (join con tpersonal).
class DocumentoPersonalEntity extends Equatable {
  const DocumentoPersonalEntity({
    required this.id,
    this.empresaId = '',
    required this.personalId,
    this.tipo = TipoDocumentoPersonal.otro,
    this.nombre,
    this.numero,
    this.fechaEmision,
    this.fechaCaducidad,
    this.observaciones,
    this.archivoUrl,
    this.createdAt,
    this.updatedAt,
    this.createdBy,
    this.personalNombre,
  });

  final String id;
  final String empresaId;
  final String personalId;
  final TipoDocumentoPersonal tipo;
  final String? nombre;
  final String? numero;
  final DateTime? fechaEmision;
  final DateTime? fechaCaducidad;
  final String? observaciones;
  final String? archivoUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? createdBy;

  // Solo lectura (join)
  final String? personalNombre;

  /// Estado del documento en la fecha [hoy] (por defecto, ahora)
  EstadoDocumentoPersonal estado([DateTime? hoy]) =>
      EstadoDocumentoPersonal.calcular(fechaCaducidad, hoy ?? DateTime.now());

  /// Días hasta la caducidad (negativo si ya caducó; null si no caduca)
  int? diasHastaCaducidad([DateTime? hoy]) {
    final DateTime? cad = fechaCaducidad;
    if (cad == null) {
      return null;
    }
    final DateTime h = hoy ?? DateTime.now();
    return DateTime.utc(cad.year, cad.month, cad.day)
        .difference(DateTime.utc(h.year, h.month, h.day))
        .inDays;
  }

  /// Texto descriptivo: nombre si existe, si no la etiqueta del tipo
  String get descripcion => (nombre?.trim().isNotEmpty ?? false) ? nombre!.trim() : tipo.label;

  @override
  List<Object?> get props => <Object?>[
        id,
        empresaId,
        personalId,
        tipo,
        nombre,
        numero,
        fechaEmision,
        fechaCaducidad,
        observaciones,
        archivoUrl,
        createdAt,
        updatedAt,
        createdBy,
        personalNombre,
      ];
}
