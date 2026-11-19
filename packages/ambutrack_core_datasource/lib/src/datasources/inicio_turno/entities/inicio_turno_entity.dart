import 'package:equatable/equatable.dart';

/// Rol del trabajador dentro de la dotación (columna `rol` de inicios_turno)
enum RolDotacion {
  conductor('conductor', 'Conductor'),
  tes('tes', 'TES / Asistente'),
  enfermero('enfermero', 'Enfermero/a'),
  medico('medico', 'Médico/a');

  const RolDotacion(this.value, this.label);

  final String value;
  final String label;

  static RolDotacion? fromString(String? value) {
    for (final RolDotacion r in RolDotacion.values) {
      if (r.value == value) {
        return r;
      }
    }
    return null;
  }
}

/// Nivel de combustible al iniciar turno
enum NivelCombustible {
  cuarto('1/4', '¼'),
  medio('1/2', '½'),
  tresCuartos('3/4', '¾'),
  lleno('lleno', 'Lleno');

  const NivelCombustible(this.value, this.label);

  final String value;
  final String label;

  static NivelCombustible? fromString(String? value) {
    for (final NivelCombustible n in NivelCombustible.values) {
      if (n.value == value) {
        return n;
      }
    }
    return null;
  }
}

/// Estado de validación por coordinación (inicio fuera de base)
enum EstadoValidacionInicio {
  noRequiere('no_requiere', 'No requiere'),
  pendiente('pendiente', 'Pendiente'),
  aprobado('aprobado', 'Aprobado'),
  rechazado('rechazado', 'Rechazado');

  const EstadoValidacionInicio(this.value, this.label);

  final String value;
  final String label;

  static EstadoValidacionInicio fromString(String? value) {
    return EstadoValidacionInicio.values.firstWhere(
      (EstadoValidacionInicio e) => e.value == value,
      orElse: () => EstadoValidacionInicio.noRequiere,
    );
  }
}

/// Resultado de un punto del checklist corto de inicio de turno
class ChecklistInicioItem extends Equatable {
  const ChecklistInicioItem({
    required this.nombre,
    required this.correcto,
    this.observacion,
  });

  final String nombre;
  final bool correcto;
  final String? observacion;

  ChecklistInicioItem copyWith({bool? correcto, String? observacion}) {
    return ChecklistInicioItem(
      nombre: nombre,
      correcto: correcto ?? this.correcto,
      observacion: observacion ?? this.observacion,
    );
  }

  @override
  List<Object?> get props => <Object?>[nombre, correcto, observacion];
}

/// Entity: datos recogidos al entrar en turno (tabla `inicios_turno`)
///
/// `empresaId`, `estadoValidacion`, `validadoPor` y `validadoAt` los fija la BD
/// (triggers): fuera de base → pendiente de validar por coordinación.
class InicioTurnoEntity extends Equatable {
  const InicioTurnoEntity({
    required this.id,
    required this.personalId,
    this.empresaId,
    this.registroEntradaId,
    this.turnoId,
    this.personalNombre,
    this.vehiculoId,
    this.vehiculoMatricula,
    this.baseId,
    this.rol,
    this.companeroId,
    this.companeroNombre,
    this.kmInicial,
    this.combustible,
    this.fotoKmUrl,
    this.checklistItems = const <ChecklistInicioItem>[],
    this.declaracionAptitud = false,
    this.latitud,
    this.longitud,
    this.distanciaBaseM,
    this.fueraDeBase = false,
    this.motivoFueraBase,
    this.avisos = const <String>[],
    this.estadoValidacion = EstadoValidacionInicio.noRequiere,
    this.validadoPor,
    this.validadoAt,
    this.motivoRechazo,
    this.modoDispositivo,
    this.createdAt,
    this.kmFinal,
    this.fotoKmFinalUrl,
    this.numerosP10,
    this.finTurnoAt,
  });

  final String id;
  final String personalId;
  final String? empresaId;
  final String? registroEntradaId;
  final String? turnoId;
  final String? personalNombre;
  final String? vehiculoId;
  final String? vehiculoMatricula;
  final String? baseId;
  final RolDotacion? rol;
  final String? companeroId;
  final String? companeroNombre;
  final int? kmInicial;
  final NivelCombustible? combustible;
  final String? fotoKmUrl;
  final List<ChecklistInicioItem> checklistItems;
  final bool declaracionAptitud;
  final double? latitud;
  final double? longitud;
  final int? distanciaBaseM;
  final bool fueraDeBase;
  final String? motivoFueraBase;
  final List<String> avisos;
  final EstadoValidacionInicio estadoValidacion;
  final String? validadoPor;
  final DateTime? validadoAt;
  final String? motivoRechazo;
  final String? modoDispositivo;
  final DateTime? createdAt;

  /// Km del vehículo al cerrar el turno (null si aún no se ha cerrado)
  final int? kmFinal;
  final String? fotoKmFinalUrl;

  /// Números de justificantes P-10 entregados (opcional)
  final String? numerosP10;
  final DateTime? finTurnoAt;

  /// Km recorridos en el turno (null si falta algún km)
  int? get kmRecorridos {
    final int? ini = kmInicial;
    final int? fin = kmFinal;
    return ini == null || fin == null ? null : fin - ini;
  }

  /// Todos los puntos del checklist correctos
  bool get checklistOk => checklistItems.every((ChecklistInicioItem i) => i.correcto);

  @override
  List<Object?> get props => <Object?>[
        id,
        personalId,
        empresaId,
        registroEntradaId,
        turnoId,
        personalNombre,
        vehiculoId,
        vehiculoMatricula,
        baseId,
        rol,
        companeroId,
        companeroNombre,
        kmInicial,
        combustible,
        fotoKmUrl,
        checklistItems,
        declaracionAptitud,
        latitud,
        longitud,
        distanciaBaseM,
        fueraDeBase,
        motivoFueraBase,
        avisos,
        estadoValidacion,
        validadoPor,
        validadoAt,
        motivoRechazo,
        modoDispositivo,
        createdAt,
        kmFinal,
        fotoKmFinalUrl,
        numerosP10,
        finTurnoAt,
      ];
}

/// Persona con la jornada abierta en un vehículo (RPC `fn_ocupacion_vehiculo`)
class OcupanteVehiculoEntity extends Equatable {
  const OcupanteVehiculoEntity({
    required this.personalId,
    this.personalNombre,
    this.desde,
  });

  final String personalId;
  final String? personalNombre;
  final DateTime? desde;

  @override
  List<Object?> get props => <Object?>[personalId, personalNombre, desde];
}

/// Coordenadas de una base (para la geocerca)
class UbicacionBaseEntity extends Equatable {
  const UbicacionBaseEntity({
    required this.id,
    required this.nombre,
    required this.latitud,
    required this.longitud,
  });

  final String id;
  final String nombre;
  final double latitud;
  final double longitud;

  @override
  List<Object?> get props => <Object?>[id, nombre, latitud, longitud];
}
