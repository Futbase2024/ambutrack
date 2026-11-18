import 'dart:typed_data';

import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:equatable/equatable.dart';

/// Estado de carga de la hoja "Iniciar turno"
enum InicioTurnoStatus { cargando, listo, error }

/// Pasos del asistente "Iniciar turno"
enum PasoInicioTurno {
  turno('Turno'),
  vehiculo('Vehículo'),
  dotacion('Dotación'),
  estado('Km'),
  checklist('Revisión'),
  resumen('Confirmar');

  const PasoInicioTurno(this.label);

  final String label;
}

/// Estado del [InicioTurnoCubit]
///
/// Casos del turno:
/// - A: [turno] con vehículo → confirmar (o cambiar vehículo)
/// - B: [turno] sin vehículo → elegir vehículo
/// - C: sin [turno] → elegir tipo de turno + vehículo (se crea desde la app)
///
/// Las reglas (avisos, bloqueos, geocerca) están en `inicio_turno_reglas.dart`.
class InicioTurnoState extends Equatable {
  const InicioTurnoState({
    this.status = InicioTurnoStatus.cargando,
    this.paso = PasoInicioTurno.turno,
    this.personal,
    this.latitud,
    this.longitud,
    this.turno,
    this.vehiculos = const <VehiculoEntity>[],
    this.plantillas = const <PlantillaTurnoEntity>[],
    this.vehiculoSeleccionado,
    this.plantillaSeleccionada,
    this.cambiandoVehiculo = false,
    this.filtro = '',
    this.ubicacionBase,
    this.documentos = const <DocumentoPersonalEntity>[],
    this.personalActivo = const <TPersonalEntity>[],
    this.ocupantes = const <OcupanteVehiculoEntity>[],
    this.cargandoOcupacion = false,
    this.rol,
    this.companero,
    this.km,
    this.combustible,
    this.fotoKm,
    this.checklistNombres = const <String>[],
    this.respuestas = const <int, bool>{},
    this.observaciones = const <int, String>{},
    this.declaracion = false,
    this.motivoFueraBase = '',
    this.error,
  });

  final InicioTurnoStatus status;
  final PasoInicioTurno paso;
  final TPersonalEntity? personal;
  final double? latitud;
  final double? longitud;
  final TurnoEntity? turno;
  final List<VehiculoEntity> vehiculos;
  final List<PlantillaTurnoEntity> plantillas;
  final VehiculoEntity? vehiculoSeleccionado;
  final PlantillaTurnoEntity? plantillaSeleccionada;
  final bool cambiandoVehiculo;
  final String filtro;
  final UbicacionBaseEntity? ubicacionBase;
  final List<DocumentoPersonalEntity> documentos;
  final List<TPersonalEntity> personalActivo;
  final List<OcupanteVehiculoEntity> ocupantes;
  final bool cargandoOcupacion;
  final RolDotacion? rol;
  final TPersonalEntity? companero;
  final int? km;
  final NivelCombustible? combustible;
  final Uint8List? fotoKm;
  final List<String> checklistNombres;

  /// Índice del punto del checklist → correcto (true) / incidencia (false)
  final Map<int, bool> respuestas;
  final Map<int, String> observaciones;
  final bool declaracion;
  final String motivoFueraBase;
  final String? error;

  /// Caso A: turno planificado con vehículo asignado
  bool get tieneTurnoConVehiculo => turno?.idVehiculo?.isNotEmpty ?? false;

  /// Hay que mostrar la lista de vehículos
  bool get mostrarSelectorVehiculo => !tieneTurnoConVehiculo || cambiandoVehiculo;

  /// Vehículos filtrados por matrícula, nº interno o alias
  List<VehiculoEntity> get vehiculosFiltrados {
    final String q = filtro.trim().toUpperCase();
    if (q.isEmpty) {
      return vehiculos;
    }
    return vehiculos.where((VehiculoEntity v) {
      return v.matricula.toUpperCase().contains(q) ||
          (v.numeroInterno?.toUpperCase().contains(q) ?? false) ||
          (v.alias?.toUpperCase().contains(q) ?? false);
    }).toList();
  }

  InicioTurnoState copyWith({
    InicioTurnoStatus? status,
    PasoInicioTurno? paso,
    VehiculoEntity? vehiculoSeleccionado,
    PlantillaTurnoEntity? plantillaSeleccionada,
    bool? cambiandoVehiculo,
    String? filtro,
    List<OcupanteVehiculoEntity>? ocupantes,
    bool? cargandoOcupacion,
    RolDotacion? rol,
    TPersonalEntity? companero,
    bool limpiarCompanero = false,
    int? km,
    bool limpiarKm = false,
    NivelCombustible? combustible,
    Uint8List? fotoKm,
    bool limpiarFoto = false,
    Map<int, bool>? respuestas,
    Map<int, String>? observaciones,
    bool? declaracion,
    String? motivoFueraBase,
    String? error,
  }) {
    return InicioTurnoState(
      status: status ?? this.status,
      paso: paso ?? this.paso,
      personal: personal,
      latitud: latitud,
      longitud: longitud,
      turno: turno,
      vehiculos: vehiculos,
      plantillas: plantillas,
      vehiculoSeleccionado: vehiculoSeleccionado ?? this.vehiculoSeleccionado,
      plantillaSeleccionada: plantillaSeleccionada ?? this.plantillaSeleccionada,
      cambiandoVehiculo: cambiandoVehiculo ?? this.cambiandoVehiculo,
      filtro: filtro ?? this.filtro,
      ubicacionBase: ubicacionBase,
      documentos: documentos,
      personalActivo: personalActivo,
      ocupantes: ocupantes ?? this.ocupantes,
      cargandoOcupacion: cargandoOcupacion ?? this.cargandoOcupacion,
      rol: rol ?? this.rol,
      companero: limpiarCompanero ? null : companero ?? this.companero,
      km: limpiarKm ? null : km ?? this.km,
      combustible: combustible ?? this.combustible,
      fotoKm: limpiarFoto ? null : fotoKm ?? this.fotoKm,
      checklistNombres: checklistNombres,
      respuestas: respuestas ?? this.respuestas,
      observaciones: observaciones ?? this.observaciones,
      declaracion: declaracion ?? this.declaracion,
      motivoFueraBase: motivoFueraBase ?? this.motivoFueraBase,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => <Object?>[
        status,
        paso,
        personal,
        latitud,
        longitud,
        turno,
        vehiculos,
        plantillas,
        vehiculoSeleccionado,
        plantillaSeleccionada,
        cambiandoVehiculo,
        filtro,
        ubicacionBase,
        documentos,
        personalActivo,
        ocupantes,
        cargandoOcupacion,
        rol,
        companero,
        km,
        combustible,
        fotoKm,
        checklistNombres,
        respuestas,
        observaciones,
        declaracion,
        motivoFueraBase,
        error,
      ];
}
