import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:equatable/equatable.dart';

/// Estados para el BLoC de registro horario
abstract class RegistroHorarioState extends Equatable {
  const RegistroHorarioState();

  @override
  List<Object?> get props => <Object?>[];
}

/// Estado inicial
class RegistroHorarioInitial extends RegistroHorarioState {
  const RegistroHorarioInitial();
}

/// Estado de carga
class RegistroHorarioLoading extends RegistroHorarioState {
  const RegistroHorarioLoading();
}

/// Estado con datos cargados
class RegistroHorarioLoaded extends RegistroHorarioState {
  const RegistroHorarioLoaded({
    required this.personalId,
    required this.nombrePersonal,
    required this.registrosHoy,
    this.fichajeActivo,
    this.horasTrabajadasHoy = 0.0,
    this.estadisticas,
  });

  final String personalId;
  final String nombrePersonal;
  final List<RegistroHorarioEntity> registrosHoy;
  final RegistroHorarioEntity? fichajeActivo;
  final double horasTrabajadasHoy;
  final Map<String, dynamic>? estadisticas;

  @override
  List<Object?> get props => <Object?>[
        personalId,
        nombrePersonal,
        registrosHoy,
        fichajeActivo,
        horasTrabajadasHoy,
        estadisticas,
      ];

  RegistroHorarioLoaded copyWith({
    String? personalId,
    String? nombrePersonal,
    List<RegistroHorarioEntity>? registrosHoy,
    RegistroHorarioEntity? fichajeActivo,
    double? horasTrabajadasHoy,
    Map<String, dynamic>? estadisticas,
    bool clearFichajeActivo = false,
  }) {
    return RegistroHorarioLoaded(
      personalId: personalId ?? this.personalId,
      nombrePersonal: nombrePersonal ?? this.nombrePersonal,
      registrosHoy: registrosHoy ?? this.registrosHoy,
      fichajeActivo: clearFichajeActivo ? null : (fichajeActivo ?? this.fichajeActivo),
      horasTrabajadasHoy: horasTrabajadasHoy ?? this.horasTrabajadasHoy,
      estadisticas: estadisticas ?? this.estadisticas,
    );
  }
}

/// Estado de éxito en operación (entrada/salida registrada)
class RegistroHorarioSuccess extends RegistroHorarioState {
  const RegistroHorarioSuccess({
    required this.message,
    required this.previousState,
  });

  final String message;
  final RegistroHorarioLoaded previousState;

  @override
  List<Object?> get props => <Object?>[message, previousState];
}

/// Estado de error
class RegistroHorarioError extends RegistroHorarioState {
  const RegistroHorarioError({
    required this.message,
    this.previousState,
  });

  final String message;
  final RegistroHorarioLoaded? previousState;

  @override
  List<Object?> get props => <Object?>[message, previousState];
}

/// Estado de procesamiento (registrando entrada/salida)
class RegistroHorarioProcessing extends RegistroHorarioState {
  const RegistroHorarioProcessing({required this.previousState});

  final RegistroHorarioLoaded previousState;

  @override
  List<Object?> get props => <Object?>[previousState];
}

/// Estado para vista de fichajes globales (todos los personal)
/// Se usa en la página de fichajes con visualización de mapas GPS
class RegistroHorarioFichajesLoaded extends RegistroHorarioState {
  const RegistroHorarioFichajesLoaded({
    required this.registros,
    this.estadisticas,
  });

  final List<RegistroHorarioEntity> registros;
  final Map<String, dynamic>? estadisticas;

  @override
  List<Object?> get props => <Object?>[registros, estadisticas];

  RegistroHorarioFichajesLoaded copyWith({
    List<RegistroHorarioEntity>? registros,
    Map<String, dynamic>? estadisticas,
  }) {
    return RegistroHorarioFichajesLoaded(
      registros: registros ?? this.registros,
      estadisticas: estadisticas ?? this.estadisticas,
    );
  }
}
