import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:equatable/equatable.dart';

/// Estado de carga de la programación recurrente
enum ProgramacionStatus { initial, loading, loaded, error }

/// Estado del ProgramacionRecurrenteBloc
class ProgramacionRecurrenteState extends Equatable {
  const ProgramacionRecurrenteState({
    this.status = ProgramacionStatus.initial,
    this.servicios = const <ServicioRecurrenteEntity>[],
    this.pacientes = const <String, String>{},
    this.motivos = const <String, String>{},
    this.trasladosServicioId,
    this.traslados = const <TrasladoEntity>[],
    this.cargandoTraslados = false,
    this.errorMessage,
  });

  final ProgramacionStatus status;
  final List<ServicioRecurrenteEntity> servicios;

  /// Nombre del paciente por ID
  final Map<String, String> pacientes;

  /// Nombre del motivo de traslado por ID
  final Map<String, String> motivos;

  /// Servicio recurrente cuyos traslados se han cargado
  final String? trasladosServicioId;
  final List<TrasladoEntity> traslados;
  final bool cargandoTraslados;
  final String? errorMessage;

  bool get hasData => status == ProgramacionStatus.loaded || servicios.isNotEmpty;

  ProgramacionRecurrenteState copyWith({
    ProgramacionStatus? status,
    List<ServicioRecurrenteEntity>? servicios,
    Map<String, String>? pacientes,
    Map<String, String>? motivos,
    String? trasladosServicioId,
    List<TrasladoEntity>? traslados,
    bool? cargandoTraslados,
    String? errorMessage,
  }) {
    return ProgramacionRecurrenteState(
      status: status ?? this.status,
      servicios: servicios ?? this.servicios,
      pacientes: pacientes ?? this.pacientes,
      motivos: motivos ?? this.motivos,
      trasladosServicioId: trasladosServicioId ?? this.trasladosServicioId,
      traslados: traslados ?? this.traslados,
      cargandoTraslados: cargandoTraslados ?? this.cargandoTraslados,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => <Object?>[
        status,
        servicios,
        pacientes,
        motivos,
        trasladosServicioId,
        traslados,
        cargandoTraslados,
        errorMessage,
      ];
}
