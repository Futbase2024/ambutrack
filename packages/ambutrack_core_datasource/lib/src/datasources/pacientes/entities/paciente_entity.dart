import 'package:equatable/equatable.dart';

/// Entidad de dominio para Pacientes
/// Representa un paciente completo en el sistema AmbuTrack
class PacienteEntity extends Equatable {
  const PacienteEntity({
    required this.id,
    this.identificacion,
    required this.nombre,
    required this.primerApellido,
    this.segundoApellido,
    required this.tipoDocumento,
    required this.documento,
    this.seguridadSocial,
    this.numHistoria,
    required this.sexo,
    required this.fechaNacimiento,
    this.telefonoMovil,
    this.telefonoFijo,
    this.email,
    this.paisOrigen = 'España',
    this.profesion,
    this.recogidaLunes = false,
    this.recogidaMartes = false,
    this.recogidaMiercoles = false,
    this.recogidaJueves = false,
    this.recogidaViernes = false,
    this.recogidaSabado = false,
    this.recogidaDomingo = false,
    this.recogidaFestivos = false,
    this.recogidaPiso,
    this.recogidaPuerta,
    this.recogidaLatitud,
    this.recogidaLongitud,
    this.recogidaInformacionAdicional,
    this.domicilioPiso,
    this.domicilioPuerta,
    this.domicilioDireccion,
    this.domicilioLatitud,
    this.domicilioLongitud,
    this.provinciaId,
    this.localidadId,
    this.centroHospitalarioId,
    this.facultativoId,
    this.mutuaAseguradora,
    this.numPoliza,
    this.consentimientoInformado = false,
    this.consentimientoInformadoFecha,
    this.consentimientoRgpd = false,
    this.consentimientoRgpdFecha,
    this.observaciones,
    this.activo = true,
    this.createdAt,
    this.updatedAt,
    this.createdBy,
    this.updatedBy,
  });

  // IDENTIFICACIÓN ÚNICA
  final String id;
  final String? identificacion;

  // DATOS PERSONALES
  final String nombre;
  final String primerApellido;
  final String? segundoApellido;

  // DOCUMENTO
  final String tipoDocumento; // DNI, NIE, PASAPORTE, OTROS
  final String documento;
  final String? seguridadSocial;
  final String? numHistoria;

  // DATOS DEMOGRÁFICOS
  final String sexo; // HOMBRE, MUJER
  final DateTime fechaNacimiento;

  // CONTACTO
  final String? telefonoMovil;
  final String? telefonoFijo;
  final String? email;

  // ORIGEN Y PROFESIÓN
  final String? paisOrigen;
  final String? profesion;

  // DIRECCIÓN DE RECOGIDA - DÍAS
  final bool recogidaLunes;
  final bool recogidaMartes;
  final bool recogidaMiercoles;
  final bool recogidaJueves;
  final bool recogidaViernes;
  final bool recogidaSabado;
  final bool recogidaDomingo;
  final bool recogidaFestivos;

  // DIRECCIÓN DE RECOGIDA - UBICACIÓN
  final String? recogidaPiso;
  final String? recogidaPuerta;
  final double? recogidaLatitud;
  final double? recogidaLongitud;
  final String? recogidaInformacionAdicional;

  // DOMICILIO DEL PACIENTE
  final String? domicilioPiso;
  final String? domicilioPuerta;
  final String? domicilioDireccion;
  final double? domicilioLatitud;
  final double? domicilioLongitud;
  final String? provinciaId; // FK hacia tprovincias
  final String? localidadId; // FK hacia tlocalidades

  // DATOS ADMINISTRATIVOS (FK)
  final String? centroHospitalarioId;
  final String? facultativoId;
  final String? mutuaAseguradora;
  final String? numPoliza;

  // CONSENTIMIENTOS RGPD
  final bool consentimientoInformado;
  final DateTime? consentimientoInformadoFecha;
  final bool consentimientoRgpd;
  final DateTime? consentimientoRgpdFecha;

  // OBSERVACIONES
  final String? observaciones;

  // ESTADO
  final bool activo;

  // AUDITORÍA
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? createdBy;
  final String? updatedBy;

  /// Getter para nombre completo
  String get nombreCompleto {
    final parts = <String>[
      nombre,
      primerApellido,
      if (segundoApellido != null && segundoApellido!.isNotEmpty) segundoApellido!,
    ];
    return parts.join(' ');
  }

  /// Getter para edad calculada
  int get edad {
    final today = DateTime.now();
    int age = today.year - fechaNacimiento.year;
    if (today.month < fechaNacimiento.month ||
        (today.month == fechaNacimiento.month && today.day < fechaNacimiento.day)) {
      age--;
    }
    return age;
  }

  /// Getter para días de recogida formateados
  String get diasRecogidaFormateados {
    final dias = <String>[];
    if (recogidaLunes) dias.add('L');
    if (recogidaMartes) dias.add('M');
    if (recogidaMiercoles) dias.add('X');
    if (recogidaJueves) dias.add('J');
    if (recogidaViernes) dias.add('V');
    if (recogidaSabado) dias.add('S');
    if (recogidaDomingo) dias.add('D');
    return dias.isEmpty ? 'Sin días asignados' : dias.join(', ');
  }

  /// Método copyWith para crear copias inmutables
  PacienteEntity copyWith({
    String? id,
    String? identificacion,
    String? nombre,
    String? primerApellido,
    String? segundoApellido,
    String? tipoDocumento,
    String? documento,
    String? seguridadSocial,
    String? numHistoria,
    String? sexo,
    DateTime? fechaNacimiento,
    String? telefonoMovil,
    String? telefonoFijo,
    String? email,
    String? paisOrigen,
    String? profesion,
    bool? recogidaLunes,
    bool? recogidaMartes,
    bool? recogidaMiercoles,
    bool? recogidaJueves,
    bool? recogidaViernes,
    bool? recogidaSabado,
    bool? recogidaDomingo,
    bool? recogidaFestivos,
    String? recogidaPiso,
    String? recogidaPuerta,
    double? recogidaLatitud,
    double? recogidaLongitud,
    String? recogidaInformacionAdicional,
    String? domicilioPiso,
    String? domicilioPuerta,
    String? domicilioDireccion,
    double? domicilioLatitud,
    double? domicilioLongitud,
    String? provinciaId,
    String? localidadId,
    String? centroHospitalarioId,
    String? facultativoId,
    String? mutuaAseguradora,
    String? numPoliza,
    bool? consentimientoInformado,
    DateTime? consentimientoInformadoFecha,
    bool? consentimientoRgpd,
    DateTime? consentimientoRgpdFecha,
    String? observaciones,
    bool? activo,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
  }) {
    return PacienteEntity(
      id: id ?? this.id,
      identificacion: identificacion ?? this.identificacion,
      nombre: nombre ?? this.nombre,
      primerApellido: primerApellido ?? this.primerApellido,
      segundoApellido: segundoApellido ?? this.segundoApellido,
      tipoDocumento: tipoDocumento ?? this.tipoDocumento,
      documento: documento ?? this.documento,
      seguridadSocial: seguridadSocial ?? this.seguridadSocial,
      numHistoria: numHistoria ?? this.numHistoria,
      sexo: sexo ?? this.sexo,
      fechaNacimiento: fechaNacimiento ?? this.fechaNacimiento,
      telefonoMovil: telefonoMovil ?? this.telefonoMovil,
      telefonoFijo: telefonoFijo ?? this.telefonoFijo,
      email: email ?? this.email,
      paisOrigen: paisOrigen ?? this.paisOrigen,
      profesion: profesion ?? this.profesion,
      recogidaLunes: recogidaLunes ?? this.recogidaLunes,
      recogidaMartes: recogidaMartes ?? this.recogidaMartes,
      recogidaMiercoles: recogidaMiercoles ?? this.recogidaMiercoles,
      recogidaJueves: recogidaJueves ?? this.recogidaJueves,
      recogidaViernes: recogidaViernes ?? this.recogidaViernes,
      recogidaSabado: recogidaSabado ?? this.recogidaSabado,
      recogidaDomingo: recogidaDomingo ?? this.recogidaDomingo,
      recogidaFestivos: recogidaFestivos ?? this.recogidaFestivos,
      recogidaPiso: recogidaPiso ?? this.recogidaPiso,
      recogidaPuerta: recogidaPuerta ?? this.recogidaPuerta,
      recogidaLatitud: recogidaLatitud ?? this.recogidaLatitud,
      recogidaLongitud: recogidaLongitud ?? this.recogidaLongitud,
      recogidaInformacionAdicional: recogidaInformacionAdicional ?? this.recogidaInformacionAdicional,
      domicilioPiso: domicilioPiso ?? this.domicilioPiso,
      domicilioPuerta: domicilioPuerta ?? this.domicilioPuerta,
      domicilioDireccion: domicilioDireccion ?? this.domicilioDireccion,
      domicilioLatitud: domicilioLatitud ?? this.domicilioLatitud,
      domicilioLongitud: domicilioLongitud ?? this.domicilioLongitud,
      provinciaId: provinciaId ?? this.provinciaId,
      localidadId: localidadId ?? this.localidadId,
      centroHospitalarioId: centroHospitalarioId ?? this.centroHospitalarioId,
      facultativoId: facultativoId ?? this.facultativoId,
      mutuaAseguradora: mutuaAseguradora ?? this.mutuaAseguradora,
      numPoliza: numPoliza ?? this.numPoliza,
      consentimientoInformado: consentimientoInformado ?? this.consentimientoInformado,
      consentimientoInformadoFecha: consentimientoInformadoFecha ?? this.consentimientoInformadoFecha,
      consentimientoRgpd: consentimientoRgpd ?? this.consentimientoRgpd,
      consentimientoRgpdFecha: consentimientoRgpdFecha ?? this.consentimientoRgpdFecha,
      observaciones: observaciones ?? this.observaciones,
      activo: activo ?? this.activo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
    );
  }

  @override
  List<Object?> get props => [
        id,
        identificacion,
        nombre,
        primerApellido,
        segundoApellido,
        tipoDocumento,
        documento,
        seguridadSocial,
        numHistoria,
        sexo,
        fechaNacimiento,
        telefonoMovil,
        telefonoFijo,
        email,
        paisOrigen,
        profesion,
        recogidaLunes,
        recogidaMartes,
        recogidaMiercoles,
        recogidaJueves,
        recogidaViernes,
        recogidaSabado,
        recogidaDomingo,
        recogidaFestivos,
        recogidaPiso,
        recogidaPuerta,
        recogidaLatitud,
        recogidaLongitud,
        recogidaInformacionAdicional,
        domicilioPiso,
        domicilioPuerta,
        domicilioDireccion,
        domicilioLatitud,
        domicilioLongitud,
        provinciaId,
        localidadId,
        centroHospitalarioId,
        facultativoId,
        mutuaAseguradora,
        numPoliza,
        consentimientoInformado,
        consentimientoInformadoFecha,
        consentimientoRgpd,
        consentimientoRgpdFecha,
        observaciones,
        activo,
        createdAt,
        updatedAt,
        createdBy,
        updatedBy,
      ];
}
