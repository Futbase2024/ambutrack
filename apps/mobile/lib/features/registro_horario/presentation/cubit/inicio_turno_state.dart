import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:equatable/equatable.dart';

/// Estado de carga de la hoja "Iniciar turno"
enum InicioTurnoStatus { cargando, listo, error }

/// Estado del [InicioTurnoCubit]
///
/// Casos:
/// - A: [turno] con vehículo → solo confirmar (o cambiar vehículo)
/// - B: [turno] sin vehículo → elegir vehículo
/// - C: sin [turno] → elegir tipo de turno + vehículo (se crea desde la app)
class InicioTurnoState extends Equatable {
  const InicioTurnoState({
    this.status = InicioTurnoStatus.cargando,
    this.turno,
    this.vehiculos = const <VehiculoEntity>[],
    this.plantillas = const <PlantillaTurnoEntity>[],
    this.vehiculoSeleccionado,
    this.plantillaSeleccionada,
    this.cambiandoVehiculo = false,
    this.filtro = '',
    this.error,
  });

  final InicioTurnoStatus status;
  final TurnoEntity? turno;
  final List<VehiculoEntity> vehiculos;
  final List<PlantillaTurnoEntity> plantillas;
  final VehiculoEntity? vehiculoSeleccionado;
  final PlantillaTurnoEntity? plantillaSeleccionada;
  final bool cambiandoVehiculo;
  final String filtro;
  final String? error;

  /// Caso A: turno planificado con vehículo asignado
  bool get tieneTurnoConVehiculo => turno?.idVehiculo?.isNotEmpty ?? false;

  /// Hay que mostrar la lista de vehículos
  bool get mostrarSelectorVehiculo => !tieneTurnoConVehiculo || cambiandoVehiculo;

  /// Se puede pulsar "Iniciar turno"
  bool get puedeConfirmar =>
      vehiculoSeleccionado != null && (turno != null || plantillaSeleccionada != null);

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
    TurnoEntity? turno,
    List<VehiculoEntity>? vehiculos,
    List<PlantillaTurnoEntity>? plantillas,
    VehiculoEntity? vehiculoSeleccionado,
    PlantillaTurnoEntity? plantillaSeleccionada,
    bool? cambiandoVehiculo,
    String? filtro,
    String? error,
  }) {
    return InicioTurnoState(
      status: status ?? this.status,
      turno: turno ?? this.turno,
      vehiculos: vehiculos ?? this.vehiculos,
      plantillas: plantillas ?? this.plantillas,
      vehiculoSeleccionado: vehiculoSeleccionado ?? this.vehiculoSeleccionado,
      plantillaSeleccionada: plantillaSeleccionada ?? this.plantillaSeleccionada,
      cambiandoVehiculo: cambiandoVehiculo ?? this.cambiandoVehiculo,
      filtro: filtro ?? this.filtro,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => <Object?>[
        status,
        turno,
        vehiculos,
        plantillas,
        vehiculoSeleccionado,
        plantillaSeleccionada,
        cambiandoVehiculo,
        filtro,
        error,
      ];
}
