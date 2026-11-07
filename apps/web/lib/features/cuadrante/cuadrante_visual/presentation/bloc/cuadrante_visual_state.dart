import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/features/cuadrante/cuadrante_visual/domain/entities/cuadrante_slot_entity.dart';
import 'package:ambutrack_web/features/personal/domain/entities/personal_entity.dart';
import 'package:equatable/equatable.dart';

/// Estados del CuadranteVisualBloc
abstract class CuadranteVisualState extends Equatable {
  const CuadranteVisualState();

  @override
  List<Object?> get props => <Object?>[];
}

/// Estado inicial
class CuadranteVisualInitial extends CuadranteVisualState {
  const CuadranteVisualInitial();
}

/// Cargando cuadrante
class CuadranteVisualLoading extends CuadranteVisualState {
  const CuadranteVisualLoading();
}

/// Cuadrante cargado con slots
class CuadranteVisualLoaded extends CuadranteVisualState {
  const CuadranteVisualLoaded({
    required this.fecha,
    required this.dotaciones,
    required this.slots,
    required this.personalList,
    required this.vehiculosList,
    this.hasUnsavedChanges = false,
  });

  final DateTime fecha;
  final List<DotacionEntity> dotaciones;
  final List<CuadranteSlotEntity> slots;
  final List<PersonalEntity> personalList;
  final List<VehiculoEntity> vehiculosList;
  final bool hasUnsavedChanges;

  @override
  List<Object?> get props => <Object?>[fecha, dotaciones, slots, personalList, vehiculosList, hasUnsavedChanges];

  CuadranteVisualLoaded copyWith({
    DateTime? fecha,
    List<DotacionEntity>? dotaciones,
    List<CuadranteSlotEntity>? slots,
    List<PersonalEntity>? personalList,
    List<VehiculoEntity>? vehiculosList,
    bool? hasUnsavedChanges,
  }) {
    return CuadranteVisualLoaded(
      fecha: fecha ?? this.fecha,
      dotaciones: dotaciones ?? this.dotaciones,
      slots: slots ?? this.slots,
      personalList: personalList ?? this.personalList,
      vehiculosList: vehiculosList ?? this.vehiculosList,
      hasUnsavedChanges: hasUnsavedChanges ?? this.hasUnsavedChanges,
    );
  }
}

/// Guardando cuadrante
class CuadranteVisualSaving extends CuadranteVisualState {
  const CuadranteVisualSaving();
}

/// Cuadrante guardado exitosamente
class CuadranteVisualSaved extends CuadranteVisualState {
  const CuadranteVisualSaved({
    required this.savedCount,
  });

  final int savedCount;

  @override
  List<Object?> get props => <Object?>[savedCount];
}

/// Error
class CuadranteVisualError extends CuadranteVisualState {
  const CuadranteVisualError(this.message);

  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}
