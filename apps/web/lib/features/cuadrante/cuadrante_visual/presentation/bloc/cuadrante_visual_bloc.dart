import 'package:ambutrack_core/ambutrack_core.dart';
import 'package:ambutrack_web/features/cuadrante/asignaciones/domain/repositories/asignacion_vehiculo_turno_repository.dart';
import 'package:ambutrack_web/features/cuadrante/cuadrante_visual/domain/entities/cuadrante_slot_entity.dart';
import 'package:ambutrack_web/features/cuadrante/cuadrante_visual/presentation/bloc/cuadrante_visual_event.dart';
import 'package:ambutrack_web/features/cuadrante/cuadrante_visual/presentation/bloc/cuadrante_visual_state.dart';
import 'package:ambutrack_web/features/cuadrante/dotaciones/domain/repositories/dotaciones_repository.dart';
import 'package:ambutrack_web/features/personal/domain/entities/personal_entity.dart';
import 'package:ambutrack_web/features/personal/domain/repositories/personal_repository.dart';
import 'package:ambutrack_web/features/vehiculos/domain/repositories/vehiculo_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';

/// BLoC para gestionar el cuadrante visual con drag & drop
@injectable
class CuadranteVisualBloc
    extends Bloc<CuadranteVisualEvent, CuadranteVisualState> {
  CuadranteVisualBloc(
    this._dotacionRepository,
    this._asignacionRepository,
    this._personalRepository,
    this._vehiculoRepository,
  ) : super(const CuadranteVisualInitial()) {
    on<CuadranteLoadRequested>(_onLoadRequested);
    on<CuadrantePersonalAssigned>(_onPersonalAssigned);
    on<CuadranteVehiculoAssigned>(_onVehiculoAssigned);
    on<CuadrantePersonalRemoved>(_onPersonalRemoved);
    on<CuadranteVehiculoRemoved>(_onVehiculoRemoved);
    on<CuadranteSaveRequested>(_onSaveRequested);
    on<CuadranteClearRequested>(_onClearRequested);
  }

  final DotacionesRepository _dotacionRepository;
  final AsignacionVehiculoTurnoRepository _asignacionRepository;
  final PersonalRepository _personalRepository;
  final VehiculoRepository _vehiculoRepository;
  final Uuid _uuid = const Uuid();

  /// Cargar cuadrante para una fecha específica
  Future<void> _onLoadRequested(
    CuadranteLoadRequested event,
    Emitter<CuadranteVisualState> emit,
  ) async {
    try {
      debugPrint(
          '🔄 CuadranteVisualBloc: Cargando cuadrante para ${event.fecha}');
      emit(const CuadranteVisualLoading());

      // Cargar dotaciones activas
      final List<DotacionEntity> dotaciones = await _dotacionRepository.getAll();
      final List<DotacionEntity> dotacionesActivas = dotaciones
          .where((DotacionEntity d) => d.activo)
          .toList();

      debugPrint(
          '📦 CuadranteVisualBloc: ${dotacionesActivas.length} dotaciones activas');

      // Cargar asignaciones existentes para esa fecha
      final List<AsignacionVehiculoTurnoEntity> asignaciones = await _asignacionRepository.getByFecha(event.fecha);
      debugPrint(
          '📦 CuadranteVisualBloc: ${asignaciones.length} asignaciones existentes');

      // Cargar personal activo
      final List<PersonalEntity> personal = await _personalRepository.getAll();
      final List<PersonalEntity> personalActivo = personal
          .where((PersonalEntity p) => p.activo)
          .toList();
      debugPrint(
          '📦 CuadranteVisualBloc: ${personalActivo.length} personal activo');

      // Cargar vehículos activos
      final List<VehiculoEntity> vehiculos = await _vehiculoRepository.getAll();
      final List<VehiculoEntity> vehiculosActivos = vehiculos
          .where((VehiculoEntity v) => v.estado == VehiculoEstado.activo)
          .toList();
      debugPrint(
          '📦 CuadranteVisualBloc: ${vehiculosActivos.length} vehículos activos');

      // Crear slots vacíos basados en dotaciones
      final List<CuadranteSlotEntity> slots = <CuadranteSlotEntity>[];

      for (final DotacionEntity dotacion in dotacionesActivas) {
        final int numUnidades = dotacion.cantidadUnidades;

        // Crear un slot por cada unidad de la dotación
        for (int i = 1; i <= numUnidades; i++) {
          // Buscar si ya existe asignación para este slot
          final List<AsignacionVehiculoTurnoEntity> asignacionExistente = asignaciones.where((AsignacionVehiculoTurnoEntity a) {
            // TODO(lokisoft1): Necesitamos agregar campo numeroUnidad a AsignacionVehiculoTurnoEntity
            // Por ahora asumimos que cada asignación es para una unidad
            return a.dotacionId == dotacion.id;
          }).toList();

          // Si hay asignaciones, tomar la primera disponible para este numeroUnidad
          final AsignacionVehiculoTurnoEntity? asignacion = asignacionExistente.isNotEmpty &&
                  asignacionExistente.length >= i
              ? asignacionExistente[i - 1]
              : null;

          slots.add(
            CuadranteSlotEntity(
              dotacionId: dotacion.id,
              fecha: event.fecha,
              numeroUnidad: i,
              asignacionId: asignacion?.id,
              vehiculoId: asignacion?.vehiculoId,
              // TODO(lokisoft1): Agregar campos de personal cuando estén disponibles
              // personalId: asignacion?.personalId,
              // personalNombre: asignacion?.personalNombre,
              // rolPersonal: asignacion?.rolPersonal,
              // vehiculoMatricula: asignacion?.vehiculoMatricula,
            ),
          );
        }
      }

      debugPrint('✅ CuadranteVisualBloc: ${slots.length} slots creados');

      emit(
        CuadranteVisualLoaded(
          fecha: event.fecha,
          dotaciones: dotacionesActivas,
          slots: slots,
          personalList: personalActivo,
          vehiculosList: vehiculosActivos,
        ),
      );
    } catch (e, stackTrace) {
      debugPrint('❌ CuadranteVisualBloc: Error al cargar: $e');
      debugPrint('StackTrace: $stackTrace');
      emit(CuadranteVisualError('Error al cargar cuadrante: $e'));
    }
  }

  /// Asignar personal a un slot
  void _onPersonalAssigned(
    CuadrantePersonalAssigned event,
    Emitter<CuadranteVisualState> emit,
  ) {
    if (state is! CuadranteVisualLoaded) {
      return;
    }

    final CuadranteVisualLoaded currentState = state as CuadranteVisualLoaded;

    debugPrint(
        '👤 CuadranteVisualBloc: Asignando personal ${event.personalData.nombre} a slot ${event.dotacionId}-${event.numeroUnidad}');

    final List<CuadranteSlotEntity> updatedSlots = currentState.slots.map((CuadranteSlotEntity slot) {
      if (slot.dotacionId == event.dotacionId &&
          slot.numeroUnidad == event.numeroUnidad) {
        return CuadranteSlotEntity(
          dotacionId: slot.dotacionId,
          fecha: slot.fecha,
          numeroUnidad: slot.numeroUnidad,
          personalId: event.personalData.personalId,
          personalNombre: event.personalData.nombre,
          rolPersonal: event.personalData.rol,
          vehiculoId: slot.vehiculoId,
          vehiculoMatricula: slot.vehiculoMatricula,
          asignacionId: slot.asignacionId,
          notas: slot.notas,
        );
      }
      return slot;
    }).toList();

    emit(currentState.copyWith(
      slots: updatedSlots,
      hasUnsavedChanges: true,
    ));
  }

  /// Asignar vehículo a un slot
  void _onVehiculoAssigned(
    CuadranteVehiculoAssigned event,
    Emitter<CuadranteVisualState> emit,
  ) {
    if (state is! CuadranteVisualLoaded) {
      return;
    }

    final CuadranteVisualLoaded currentState = state as CuadranteVisualLoaded;

    debugPrint(
        '🚗 CuadranteVisualBloc: Asignando vehículo ${event.vehiculoData.matricula} a slot ${event.dotacionId}-${event.numeroUnidad}');

    final List<CuadranteSlotEntity> updatedSlots = currentState.slots.map((CuadranteSlotEntity slot) {
      if (slot.dotacionId == event.dotacionId &&
          slot.numeroUnidad == event.numeroUnidad) {
        return CuadranteSlotEntity(
          dotacionId: slot.dotacionId,
          fecha: slot.fecha,
          numeroUnidad: slot.numeroUnidad,
          personalId: slot.personalId,
          personalNombre: slot.personalNombre,
          rolPersonal: slot.rolPersonal,
          vehiculoId: event.vehiculoData.vehiculoId,
          vehiculoMatricula: event.vehiculoData.matricula,
          asignacionId: slot.asignacionId,
          notas: slot.notas,
        );
      }
      return slot;
    }).toList();

    emit(currentState.copyWith(
      slots: updatedSlots,
      hasUnsavedChanges: true,
    ));
  }

  /// Remover personal de un slot
  void _onPersonalRemoved(
    CuadrantePersonalRemoved event,
    Emitter<CuadranteVisualState> emit,
  ) {
    if (state is! CuadranteVisualLoaded) {
      return;
    }

    final CuadranteVisualLoaded currentState = state as CuadranteVisualLoaded;

    debugPrint(
        '🗑️ CuadranteVisualBloc: Removiendo personal de slot ${event.dotacionId}-${event.numeroUnidad}');

    final List<CuadranteSlotEntity> updatedSlots = currentState.slots.map((CuadranteSlotEntity slot) {
      if (slot.dotacionId == event.dotacionId &&
          slot.numeroUnidad == event.numeroUnidad) {
        return CuadranteSlotEntity(
          dotacionId: slot.dotacionId,
          fecha: slot.fecha,
          numeroUnidad: slot.numeroUnidad,
          vehiculoId: slot.vehiculoId,
          vehiculoMatricula: slot.vehiculoMatricula,
          asignacionId: slot.asignacionId,
          notas: slot.notas,
        );
      }
      return slot;
    }).toList();

    emit(currentState.copyWith(
      slots: updatedSlots,
      hasUnsavedChanges: true,
    ));
  }

  /// Remover vehículo de un slot
  void _onVehiculoRemoved(
    CuadranteVehiculoRemoved event,
    Emitter<CuadranteVisualState> emit,
  ) {
    if (state is! CuadranteVisualLoaded) {
      return;
    }

    final CuadranteVisualLoaded currentState = state as CuadranteVisualLoaded;

    debugPrint(
        '🗑️ CuadranteVisualBloc: Removiendo vehículo de slot ${event.dotacionId}-${event.numeroUnidad}');

    final List<CuadranteSlotEntity> updatedSlots = currentState.slots.map((CuadranteSlotEntity slot) {
      if (slot.dotacionId == event.dotacionId &&
          slot.numeroUnidad == event.numeroUnidad) {
        return CuadranteSlotEntity(
          dotacionId: slot.dotacionId,
          fecha: slot.fecha,
          numeroUnidad: slot.numeroUnidad,
          personalId: slot.personalId,
          personalNombre: slot.personalNombre,
          rolPersonal: slot.rolPersonal,
          asignacionId: slot.asignacionId,
          notas: slot.notas,
        );
      }
      return slot;
    }).toList();

    emit(currentState.copyWith(
      slots: updatedSlots,
      hasUnsavedChanges: true,
    ));
  }

  /// Guardar cuadrante (persistir a BD)
  Future<void> _onSaveRequested(
    CuadranteSaveRequested event,
    Emitter<CuadranteVisualState> emit,
  ) async {
    if (state is! CuadranteVisualLoaded) {
      return;
    }

    final CuadranteVisualLoaded currentState = state as CuadranteVisualLoaded;

    try {
      debugPrint('💾 CuadranteVisualBloc: Guardando cuadrante...');
      emit(const CuadranteVisualSaving());

      int savedCount = 0;

      // Guardar cada slot que tenga al menos vehículo asignado
      for (final CuadranteSlotEntity slot in currentState.slots) {
        if (slot.vehiculoId != null) {
          final AsignacionVehiculoTurnoEntity asignacion = AsignacionVehiculoTurnoEntity(
            id: slot.asignacionId ?? _uuid.v4(),
            fecha: slot.fecha,
            vehiculoId: slot.vehiculoId!,
            dotacionId: slot.dotacionId,
            // TODO(lokisoft1): Agregar campos de personal cuando estén disponibles
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );

          if (slot.asignacionId != null) {
            // Actualizar asignación existente
            await _asignacionRepository.update(asignacion);
          } else {
            // Crear nueva asignación
            await _asignacionRepository.create(asignacion);
          }

          savedCount++;
        }
      }

      debugPrint('✅ CuadranteVisualBloc: $savedCount asignaciones guardadas');

      emit(CuadranteVisualSaved(savedCount: savedCount));

      // Recargar cuadrante
      add(CuadranteLoadRequested(currentState.fecha));
    } catch (e, stackTrace) {
      debugPrint('❌ CuadranteVisualBloc: Error al guardar: $e');
      debugPrint('StackTrace: $stackTrace');
      emit(CuadranteVisualError('Error al guardar cuadrante: $e'));
    }
  }

  /// Limpiar cuadrante
  void _onClearRequested(
    CuadranteClearRequested event,
    Emitter<CuadranteVisualState> emit,
  ) {
    if (state is! CuadranteVisualLoaded) {
      return;
    }

    final CuadranteVisualLoaded currentState = state as CuadranteVisualLoaded;

    debugPrint('🧹 CuadranteVisualBloc: Limpiando cuadrante');

    final List<CuadranteSlotEntity> clearedSlots = currentState.slots.map((CuadranteSlotEntity slot) {
      return CuadranteSlotEntity(
        dotacionId: slot.dotacionId,
        fecha: slot.fecha,
        numeroUnidad: slot.numeroUnidad,
      );
    }).toList();

    emit(currentState.copyWith(
      slots: clearedSlots,
      hasUnsavedChanges: true,
    ));
  }
}
