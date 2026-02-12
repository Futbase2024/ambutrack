import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/features/cuadrante/dotaciones/domain/repositories/dotaciones_repository.dart';
import 'package:ambutrack_web/features/cuadrante/dotaciones/presentation/bloc/dotaciones_event.dart';
import 'package:ambutrack_web/features/cuadrante/dotaciones/presentation/bloc/dotaciones_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

/// BLoC para la gestión de Dotaciones
@injectable
class DotacionesBloc extends Bloc<DotacionesEvent, DotacionesState> {
  DotacionesBloc(this._dotacionesRepository) : super(const DotacionesInitial()) {
    on<DotacionesLoadRequested>(_onDotacionesLoadRequested);
    on<DotacionesActivasLoadRequested>(_onDotacionesActivasLoadRequested);
    on<DotacionCreateRequested>(_onDotacionCreateRequested);
    on<DotacionUpdateRequested>(_onDotacionUpdateRequested);
    on<DotacionDeleteRequested>(_onDotacionDeleteRequested);
    on<DotacionDeactivateRequested>(_onDotacionDeactivateRequested);
    on<DotacionReactivateRequested>(_onDotacionReactivateRequested);
    on<DotacionesFiltrarPorHospitalRequested>(_onDotacionesFiltrarPorHospitalRequested);
    on<DotacionesFiltrarPorBaseRequested>(_onDotacionesFiltrarPorBaseRequested);
    on<DotacionesFiltrarPorContratoRequested>(_onDotacionesFiltrarPorContratoRequested);
    on<DotacionesFiltrarPorTipoVehiculoRequested>(_onDotacionesFiltrarPorTipoVehiculoRequested);
    on<DotacionesVigentesEnFechaRequested>(_onDotacionesVigentesEnFechaRequested);
    on<DotacionUpdateCantidadUnidadesRequested>(_onDotacionUpdateCantidadUnidadesRequested);
    on<DotacionUpdatePrioridadRequested>(_onDotacionUpdatePrioridadRequested);
  }

  final DotacionesRepository _dotacionesRepository;

  /// Carga todas las dotaciones
  Future<void> _onDotacionesLoadRequested(
    DotacionesLoadRequested event,
    Emitter<DotacionesState> emit,
  ) async {
    debugPrint('🚀 DotacionesBloc: Cargando todas las dotaciones...');
    emit(const DotacionesLoading());

    try {
      final List<DotacionEntity> dotaciones = await _dotacionesRepository.getAll();
      debugPrint('✅ DotacionesBloc: ${dotaciones.length} dotaciones cargadas');
      emit(DotacionesLoaded(dotaciones));
    } catch (e) {
      debugPrint('❌ DotacionesBloc: Error al cargar dotaciones - $e');
      emit(DotacionesError('Error al cargar dotaciones: $e'));
    }
  }

  /// Carga solo las dotaciones activas
  Future<void> _onDotacionesActivasLoadRequested(
    DotacionesActivasLoadRequested event,
    Emitter<DotacionesState> emit,
  ) async {
    debugPrint('🚀 DotacionesBloc: Cargando dotaciones activas...');
    emit(const DotacionesLoading());

    try {
      final List<DotacionEntity> dotaciones = await _dotacionesRepository.getActivas();
      debugPrint('✅ DotacionesBloc: ${dotaciones.length} dotaciones activas cargadas');
      emit(DotacionesLoaded(dotaciones));
    } catch (e) {
      debugPrint('❌ DotacionesBloc: Error al cargar dotaciones activas - $e');
      emit(DotacionesError('Error al cargar dotaciones activas: $e'));
    }
  }

  /// Crea una nueva dotación
  Future<void> _onDotacionCreateRequested(
    DotacionCreateRequested event,
    Emitter<DotacionesState> emit,
  ) async {
    debugPrint('🚀 DotacionesBloc: Creando dotación ${event.dotacion.nombre}...');
    emit(const DotacionesLoading());

    try {
      await _dotacionesRepository.create(event.dotacion);
      debugPrint('✅ DotacionesBloc: Dotación ${event.dotacion.nombre} creada exitosamente');

      // Recargar todas las dotaciones
      final List<DotacionEntity> dotaciones = await _dotacionesRepository.getAll();
      emit(DotacionOperationSuccess(
        'Dotación "${event.dotacion.nombre}" creada exitosamente',
        dotaciones,
      ));
    } catch (e) {
      debugPrint('❌ DotacionesBloc: Error al crear dotación - $e');
      emit(DotacionesError('Error al crear dotación: $e'));
    }
  }

  /// Actualiza una dotación existente
  Future<void> _onDotacionUpdateRequested(
    DotacionUpdateRequested event,
    Emitter<DotacionesState> emit,
  ) async {
    debugPrint('🚀 DotacionesBloc: Actualizando dotación ${event.dotacion.nombre}...');
    emit(const DotacionesLoading());

    try {
      await _dotacionesRepository.update(event.dotacion);
      debugPrint('✅ DotacionesBloc: Dotación ${event.dotacion.nombre} actualizada exitosamente');

      // Recargar todas las dotaciones
      final List<DotacionEntity> dotaciones = await _dotacionesRepository.getAll();
      emit(DotacionOperationSuccess(
        'Dotación "${event.dotacion.nombre}" actualizada exitosamente',
        dotaciones,
      ));
    } catch (e) {
      debugPrint('❌ DotacionesBloc: Error al actualizar dotación - $e');
      emit(DotacionesError('Error al actualizar dotación: $e'));
    }
  }

  /// Elimina una dotación
  Future<void> _onDotacionDeleteRequested(
    DotacionDeleteRequested event,
    Emitter<DotacionesState> emit,
  ) async {
    debugPrint('🚀 DotacionesBloc: Eliminando dotación ${event.dotacionId}...');
    emit(const DotacionesLoading());

    try {
      await _dotacionesRepository.delete(event.dotacionId);
      debugPrint('✅ DotacionesBloc: Dotación ${event.dotacionId} eliminada exitosamente');

      // Recargar todas las dotaciones
      final List<DotacionEntity> dotaciones = await _dotacionesRepository.getAll();
      emit(DotacionOperationSuccess(
        'Dotación eliminada exitosamente',
        dotaciones,
      ));
    } catch (e) {
      debugPrint('❌ DotacionesBloc: Error al eliminar dotación - $e');
      emit(DotacionesError('Error al eliminar dotación: $e'));
    }
  }

  /// Desactiva una dotación (soft delete)
  Future<void> _onDotacionDeactivateRequested(
    DotacionDeactivateRequested event,
    Emitter<DotacionesState> emit,
  ) async {
    debugPrint('🚀 DotacionesBloc: Desactivando dotación ${event.dotacionId}...');
    emit(const DotacionesLoading());

    try {
      await _dotacionesRepository.deactivate(event.dotacionId);
      debugPrint('✅ DotacionesBloc: Dotación ${event.dotacionId} desactivada exitosamente');

      // Recargar todas las dotaciones
      final List<DotacionEntity> dotaciones = await _dotacionesRepository.getAll();
      emit(DotacionOperationSuccess(
        'Dotación desactivada exitosamente',
        dotaciones,
      ));
    } catch (e) {
      debugPrint('❌ DotacionesBloc: Error al desactivar dotación - $e');
      emit(DotacionesError('Error al desactivar dotación: $e'));
    }
  }

  /// Reactiva una dotación
  Future<void> _onDotacionReactivateRequested(
    DotacionReactivateRequested event,
    Emitter<DotacionesState> emit,
  ) async {
    debugPrint('🚀 DotacionesBloc: Reactivando dotación ${event.dotacionId}...');
    emit(const DotacionesLoading());

    try {
      await _dotacionesRepository.reactivate(event.dotacionId);
      debugPrint('✅ DotacionesBloc: Dotación ${event.dotacionId} reactivada exitosamente');

      // Recargar todas las dotaciones
      final List<DotacionEntity> dotaciones = await _dotacionesRepository.getAll();
      emit(DotacionOperationSuccess(
        'Dotación reactivada exitosamente',
        dotaciones,
      ));
    } catch (e) {
      debugPrint('❌ DotacionesBloc: Error al reactivar dotación - $e');
      emit(DotacionesError('Error al reactivar dotación: $e'));
    }
  }

  /// Filtra dotaciones por hospital
  Future<void> _onDotacionesFiltrarPorHospitalRequested(
    DotacionesFiltrarPorHospitalRequested event,
    Emitter<DotacionesState> emit,
  ) async {
    debugPrint('🚀 DotacionesBloc: Filtrando dotaciones por hospital ${event.hospitalId}...');
    emit(const DotacionesLoading());

    try {
      final List<DotacionEntity> dotaciones = await _dotacionesRepository.getByHospital(event.hospitalId);
      debugPrint('✅ DotacionesBloc: ${dotaciones.length} dotaciones encontradas para hospital');
      emit(DotacionesLoaded(dotaciones));
    } catch (e) {
      debugPrint('❌ DotacionesBloc: Error al filtrar dotaciones por hospital - $e');
      emit(DotacionesError('Error al filtrar dotaciones: $e'));
    }
  }

  /// Filtra dotaciones por base
  Future<void> _onDotacionesFiltrarPorBaseRequested(
    DotacionesFiltrarPorBaseRequested event,
    Emitter<DotacionesState> emit,
  ) async {
    debugPrint('🚀 DotacionesBloc: Filtrando dotaciones por base ${event.baseId}...');
    emit(const DotacionesLoading());

    try {
      final List<DotacionEntity> dotaciones = await _dotacionesRepository.getByBase(event.baseId);
      debugPrint('✅ DotacionesBloc: ${dotaciones.length} dotaciones encontradas para base');
      emit(DotacionesLoaded(dotaciones));
    } catch (e) {
      debugPrint('❌ DotacionesBloc: Error al filtrar dotaciones por base - $e');
      emit(DotacionesError('Error al filtrar dotaciones: $e'));
    }
  }

  /// Filtra dotaciones por contrato
  Future<void> _onDotacionesFiltrarPorContratoRequested(
    DotacionesFiltrarPorContratoRequested event,
    Emitter<DotacionesState> emit,
  ) async {
    debugPrint('🚀 DotacionesBloc: Filtrando dotaciones por contrato ${event.contratoId}...');
    emit(const DotacionesLoading());

    try {
      final List<DotacionEntity> dotaciones = await _dotacionesRepository.getByContrato(event.contratoId);
      debugPrint('✅ DotacionesBloc: ${dotaciones.length} dotaciones encontradas para contrato');
      emit(DotacionesLoaded(dotaciones));
    } catch (e) {
      debugPrint('❌ DotacionesBloc: Error al filtrar dotaciones por contrato - $e');
      emit(DotacionesError('Error al filtrar dotaciones: $e'));
    }
  }

  /// Filtra dotaciones por tipo de vehículo
  Future<void> _onDotacionesFiltrarPorTipoVehiculoRequested(
    DotacionesFiltrarPorTipoVehiculoRequested event,
    Emitter<DotacionesState> emit,
  ) async {
    debugPrint('🚀 DotacionesBloc: Filtrando dotaciones por tipo de vehículo ${event.tipoVehiculoId}...');
    emit(const DotacionesLoading());

    try {
      final List<DotacionEntity> dotaciones = await _dotacionesRepository.getByTipoVehiculo(event.tipoVehiculoId);
      debugPrint('✅ DotacionesBloc: ${dotaciones.length} dotaciones encontradas para tipo de vehículo');
      emit(DotacionesLoaded(dotaciones));
    } catch (e) {
      debugPrint('❌ DotacionesBloc: Error al filtrar dotaciones por tipo de vehículo - $e');
      emit(DotacionesError('Error al filtrar dotaciones: $e'));
    }
  }

  /// Obtiene dotaciones vigentes en una fecha
  Future<void> _onDotacionesVigentesEnFechaRequested(
    DotacionesVigentesEnFechaRequested event,
    Emitter<DotacionesState> emit,
  ) async {
    debugPrint('🚀 DotacionesBloc: Obteniendo dotaciones vigentes en ${event.fecha}...');
    emit(const DotacionesLoading());

    try {
      final List<DotacionEntity> dotaciones = await _dotacionesRepository.getVigentesEn(event.fecha);
      debugPrint('✅ DotacionesBloc: ${dotaciones.length} dotaciones vigentes en la fecha');
      emit(DotacionesLoaded(dotaciones));
    } catch (e) {
      debugPrint('❌ DotacionesBloc: Error al obtener dotaciones vigentes - $e');
      emit(DotacionesError('Error al obtener dotaciones vigentes: $e'));
    }
  }

  /// Actualiza la cantidad de unidades de una dotación
  Future<void> _onDotacionUpdateCantidadUnidadesRequested(
    DotacionUpdateCantidadUnidadesRequested event,
    Emitter<DotacionesState> emit,
  ) async {
    debugPrint('🚀 DotacionesBloc: Actualizando cantidad de unidades de dotación ${event.dotacionId} a ${event.nuevaCantidad}...');
    emit(const DotacionesLoading());

    try {
      await _dotacionesRepository.updateCantidadUnidades(event.dotacionId, event.nuevaCantidad);
      debugPrint('✅ DotacionesBloc: Cantidad de unidades actualizada exitosamente');

      // Recargar todas las dotaciones
      final List<DotacionEntity> dotaciones = await _dotacionesRepository.getAll();
      emit(DotacionOperationSuccess(
        'Cantidad de unidades actualizada exitosamente',
        dotaciones,
      ));
    } catch (e) {
      debugPrint('❌ DotacionesBloc: Error al actualizar cantidad de unidades - $e');
      emit(DotacionesError('Error al actualizar cantidad de unidades: $e'));
    }
  }

  /// Actualiza la prioridad de una dotación
  Future<void> _onDotacionUpdatePrioridadRequested(
    DotacionUpdatePrioridadRequested event,
    Emitter<DotacionesState> emit,
  ) async {
    debugPrint('🚀 DotacionesBloc: Actualizando prioridad de dotación ${event.dotacionId} a ${event.nuevaPrioridad}...');
    emit(const DotacionesLoading());

    try {
      await _dotacionesRepository.updatePrioridad(event.dotacionId, event.nuevaPrioridad);
      debugPrint('✅ DotacionesBloc: Prioridad actualizada exitosamente');

      // Recargar todas las dotaciones
      final List<DotacionEntity> dotaciones = await _dotacionesRepository.getAll();
      emit(DotacionOperationSuccess(
        'Prioridad actualizada exitosamente',
        dotaciones,
      ));
    } catch (e) {
      debugPrint('❌ DotacionesBloc: Error al actualizar prioridad - $e');
      emit(DotacionesError('Error al actualizar prioridad: $e'));
    }
  }
}
