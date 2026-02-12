import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/features/cuadrante/cuadrante_module/domain/entities/cuadrante_filter.dart';
import 'package:ambutrack_web/features/cuadrante/cuadrante_module/domain/entities/cuadrante_view_mode.dart';
import 'package:ambutrack_web/features/cuadrante/cuadrante_module/domain/entities/personal_con_turnos_entity.dart';
import 'package:equatable/equatable.dart';

/// Estados del cuadrante
abstract class CuadranteState extends Equatable {
  const CuadranteState();

  @override
  List<Object?> get props => <Object?>[];
}

/// Estado inicial
class CuadranteInitial extends CuadranteState {
  const CuadranteInitial();
}

/// Cargando cuadrante
class CuadranteLoading extends CuadranteState {
  const CuadranteLoading();
}

/// Cuadrante cargado exitosamente
class CuadranteLoaded extends CuadranteState {
  const CuadranteLoaded({
    required this.personalConTurnos,
    required this.viewMode,
    required this.fechaActual,
    required this.filter,
    this.vehiculos = const <VehiculoEntity>[],
    List<PersonalConTurnosEntity>? allPersonalConTurnos,
  }) : allPersonalConTurnos = allPersonalConTurnos ?? personalConTurnos;

  /// Lista de personal con sus turnos (filtrada)
  final List<PersonalConTurnosEntity> personalConTurnos;

  /// Lista completa de personal sin filtrar (para búsqueda local)
  final List<PersonalConTurnosEntity> allPersonalConTurnos;

  /// Modo de vista actual (tabla/calendario)
  final CuadranteViewMode viewMode;

  /// Fecha actual (semana o mes)
  final DateTime fechaActual;

  /// Filtros aplicados
  final CuadranteFilter filter;

  /// Lista de vehículos (para mostrar matrículas en turnos)
  final List<VehiculoEntity> vehiculos;

  /// Primer día de la semana actual (lunes)
  DateTime get primerDiaSemana {
    final int diasDesdeLunes = fechaActual.weekday - 1;
    return fechaActual.subtract(Duration(days: diasDesdeLunes));
  }

  /// Último día de la semana actual (domingo)
  DateTime get ultimoDiaSemana => primerDiaSemana.add(const Duration(days: 6));

  /// Primer día del mes actual
  DateTime get primerDiaMes => DateTime(fechaActual.year, fechaActual.month);

  /// Último día del mes actual
  DateTime get ultimoDiaMes => DateTime(fechaActual.year, fechaActual.month + 1, 0);

  /// Total de personal en el cuadrante
  int get totalPersonal => personalConTurnos.length;

  /// Total de turnos asignados
  int get totalTurnos => personalConTurnos.fold<int>(
        0,
        (int sum, PersonalConTurnosEntity pc) => sum + pc.totalTurnos,
      );

  @override
  List<Object?> get props => <Object?>[
        personalConTurnos,
        allPersonalConTurnos,
        viewMode,
        fechaActual,
        filter,
        vehiculos,
      ];

  /// Copia con modificaciones
  CuadranteLoaded copyWith({
    List<PersonalConTurnosEntity>? personalConTurnos,
    List<PersonalConTurnosEntity>? allPersonalConTurnos,
    CuadranteViewMode? viewMode,
    DateTime? fechaActual,
    CuadranteFilter? filter,
    List<VehiculoEntity>? vehiculos,
  }) {
    return CuadranteLoaded(
      personalConTurnos: personalConTurnos ?? this.personalConTurnos,
      allPersonalConTurnos: allPersonalConTurnos ?? this.allPersonalConTurnos,
      viewMode: viewMode ?? this.viewMode,
      fechaActual: fechaActual ?? this.fechaActual,
      filter: filter ?? this.filter,
      vehiculos: vehiculos ?? this.vehiculos,
    );
  }
}

/// Error al cargar cuadrante
class CuadranteError extends CuadranteState {
  const CuadranteError(this.message);

  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}

/// Copia de semana exitosa
class CuadranteCopiaExitosa extends CuadranteState {
  const CuadranteCopiaExitosa(this.message);

  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}
