import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/features/personal/horarios/domain/repositories/registro_horario_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';

import 'registro_horario_event.dart';
import 'registro_horario_state.dart';

/// BLoC para gestionar el estado del registro horario
@injectable
class RegistroHorarioBloc extends Bloc<RegistroHorarioEvent, RegistroHorarioState> {
  RegistroHorarioBloc(this._repository) : super(const RegistroHorarioInitial()) {
    on<LoadRegistroHorarioData>(_onLoadRegistroHorarioData);
    on<ChangeSelectedPersonal>(_onChangeSelectedPersonal);
    on<RegisterEntrada>(_onRegisterEntrada);
    on<RegisterSalida>(_onRegisterSalida);
    on<RefreshRegistroHorarioData>(_onRefreshRegistroHorarioData);
    on<LoadRegistrosByDate>(_onLoadRegistrosByDate);
    on<LoadRegistrosByDateRange>(_onLoadRegistrosByDateRange);
    on<LoadEstadisticas>(_onLoadEstadisticas);
  }

  final RegistroHorarioRepository _repository;

  Future<void> _onLoadRegistroHorarioData(
    LoadRegistroHorarioData event,
    Emitter<RegistroHorarioState> emit,
  ) async {
    emit(const RegistroHorarioLoading());

    try {
      final DateTime hoy = DateTime.now();
      final DateTime inicioHoy = DateTime(hoy.year, hoy.month, hoy.day);
      final DateTime finHoy = inicioHoy.add(const Duration(days: 1));

      final List<RegistroHorarioEntity> registros =
          await _repository.getByPersonalIdAndDateRange(
        event.personalId,
        inicioHoy,
        finHoy,
      );

      final RegistroHorarioEntity? fichaje =
          await _repository.getFichajeActivo(event.personalId);

      final double horasTrabajadas =
          await _repository.getHorasTrabajadasPorFecha(event.personalId, hoy);

      emit(RegistroHorarioLoaded(
        personalId: event.personalId,
        nombrePersonal: 'Personal ${event.personalId}',
        registrosHoy: registros,
        fichajeActivo: fichaje,
        horasTrabajadasHoy: horasTrabajadas,
      ));
    } catch (e) {
      emit(RegistroHorarioError(message: 'Error al cargar datos: $e'));
    }
  }

  Future<void> _onChangeSelectedPersonal(
    ChangeSelectedPersonal event,
    Emitter<RegistroHorarioState> emit,
  ) async {
    emit(const RegistroHorarioLoading());

    try {
      final DateTime hoy = DateTime.now();
      final DateTime inicioHoy = DateTime(hoy.year, hoy.month, hoy.day);
      final DateTime finHoy = inicioHoy.add(const Duration(days: 1));

      final List<RegistroHorarioEntity> registros =
          await _repository.getByPersonalIdAndDateRange(
        event.personalId,
        inicioHoy,
        finHoy,
      );

      final RegistroHorarioEntity? fichaje =
          await _repository.getFichajeActivo(event.personalId);

      final double horasTrabajadas =
          await _repository.getHorasTrabajadasPorFecha(event.personalId, hoy);

      emit(RegistroHorarioLoaded(
        personalId: event.personalId,
        nombrePersonal: event.nombrePersonal,
        registrosHoy: registros,
        fichajeActivo: fichaje,
        horasTrabajadasHoy: horasTrabajadas,
      ));
    } catch (e) {
      emit(RegistroHorarioError(message: 'Error al cambiar personal: $e'));
    }
  }

  Future<void> _onRegisterEntrada(
    RegisterEntrada event,
    Emitter<RegistroHorarioState> emit,
  ) async {
    if (state is! RegistroHorarioLoaded) {
      return;
    }

    final RegistroHorarioLoaded currentState = state as RegistroHorarioLoaded;
    emit(RegistroHorarioProcessing(previousState: currentState));

    try {
      await _repository.registrarEntrada(
        personalId: event.personalId,
        nombrePersonal: event.nombrePersonal,
        ubicacion: event.ubicacion,
        latitud: event.latitud,
        longitud: event.longitud,
        vehiculoId: event.vehiculoId,
        turno: event.turno,
        notas: event.notas,
      );

      // Recargar datos
      final DateTime hoy = DateTime.now();
      final DateTime inicioHoy = DateTime(hoy.year, hoy.month, hoy.day);
      final DateTime finHoy = inicioHoy.add(const Duration(days: 1));

      final List<RegistroHorarioEntity> registros =
          await _repository.getByPersonalIdAndDateRange(
        event.personalId,
        inicioHoy,
        finHoy,
      );

      final RegistroHorarioEntity? fichaje =
          await _repository.getFichajeActivo(event.personalId);

      final double horasTrabajadas =
          await _repository.getHorasTrabajadasPorFecha(event.personalId, hoy);

      final RegistroHorarioLoaded newState = RegistroHorarioLoaded(
        personalId: event.personalId,
        nombrePersonal: event.nombrePersonal,
        registrosHoy: registros,
        fichajeActivo: fichaje,
        horasTrabajadasHoy: horasTrabajadas,
      );

      emit(RegistroHorarioSuccess(
        message: 'Entrada registrada correctamente',
        previousState: newState,
      ));

      // Volver al estado loaded después de un momento
      await Future<void>.delayed(const Duration(milliseconds: 500));
      emit(newState);
    } catch (e) {
      emit(RegistroHorarioError(
        message: 'Error al registrar entrada: $e',
        previousState: currentState,
      ));

      // Volver al estado anterior después de un momento
      await Future<void>.delayed(const Duration(seconds: 2));
      emit(currentState);
    }
  }

  Future<void> _onRegisterSalida(
    RegisterSalida event,
    Emitter<RegistroHorarioState> emit,
  ) async {
    if (state is! RegistroHorarioLoaded) {
      return;
    }

    final RegistroHorarioLoaded currentState = state as RegistroHorarioLoaded;
    emit(RegistroHorarioProcessing(previousState: currentState));

    try {
      await _repository.registrarSalida(
        personalId: event.personalId,
        nombrePersonal: event.nombrePersonal,
        ubicacion: event.ubicacion,
        latitud: event.latitud,
        longitud: event.longitud,
        notas: event.notas,
      );

      // Recargar datos
      final DateTime hoy = DateTime.now();
      final DateTime inicioHoy = DateTime(hoy.year, hoy.month, hoy.day);
      final DateTime finHoy = inicioHoy.add(const Duration(days: 1));

      final List<RegistroHorarioEntity> registros =
          await _repository.getByPersonalIdAndDateRange(
        event.personalId,
        inicioHoy,
        finHoy,
      );

      final RegistroHorarioEntity? fichaje =
          await _repository.getFichajeActivo(event.personalId);

      final double horasTrabajadas =
          await _repository.getHorasTrabajadasPorFecha(event.personalId, hoy);

      final RegistroHorarioLoaded newState = RegistroHorarioLoaded(
        personalId: event.personalId,
        nombrePersonal: event.nombrePersonal,
        registrosHoy: registros,
        fichajeActivo: fichaje,
        horasTrabajadasHoy: horasTrabajadas,
      );

      emit(RegistroHorarioSuccess(
        message: 'Salida registrada correctamente',
        previousState: newState,
      ));

      // Volver al estado loaded después de un momento
      await Future<void>.delayed(const Duration(milliseconds: 500));
      emit(newState);
    } catch (e) {
      emit(RegistroHorarioError(
        message: 'Error al registrar salida: $e',
        previousState: currentState,
      ));

      // Volver al estado anterior después de un momento
      await Future<void>.delayed(const Duration(seconds: 2));
      emit(currentState);
    }
  }

  Future<void> _onRefreshRegistroHorarioData(
    RefreshRegistroHorarioData event,
    Emitter<RegistroHorarioState> emit,
  ) async {
    if (state is! RegistroHorarioLoaded) {
      return;
    }

    final RegistroHorarioLoaded currentState = state as RegistroHorarioLoaded;

    try {
      final DateTime hoy = DateTime.now();
      final DateTime inicioHoy = DateTime(hoy.year, hoy.month, hoy.day);
      final DateTime finHoy = inicioHoy.add(const Duration(days: 1));

      final List<RegistroHorarioEntity> registros =
          await _repository.getByPersonalIdAndDateRange(
        event.personalId,
        inicioHoy,
        finHoy,
      );

      final RegistroHorarioEntity? fichaje =
          await _repository.getFichajeActivo(event.personalId);

      final double horasTrabajadas =
          await _repository.getHorasTrabajadasPorFecha(event.personalId, hoy);

      emit(currentState.copyWith(
        registrosHoy: registros,
        fichajeActivo: fichaje,
        horasTrabajadasHoy: horasTrabajadas,
        clearFichajeActivo: fichaje == null,
      ));
    } catch (e) {
      emit(RegistroHorarioError(
        message: 'Error al refrescar datos: $e',
        previousState: currentState,
      ));

      await Future<void>.delayed(const Duration(seconds: 2));
      emit(currentState);
    }
  }

  Future<void> _onLoadRegistrosByDate(
    LoadRegistrosByDate event,
    Emitter<RegistroHorarioState> emit,
  ) async {
    if (state is! RegistroHorarioLoaded) {
      return;
    }

    final RegistroHorarioLoaded currentState = state as RegistroHorarioLoaded;

    try {
      final DateTime inicioFecha = DateTime(event.fecha.year, event.fecha.month, event.fecha.day);
      final DateTime finFecha = inicioFecha.add(const Duration(days: 1));

      final List<RegistroHorarioEntity> registros =
          await _repository.getByPersonalIdAndDateRange(
        event.personalId,
        inicioFecha,
        finFecha,
      );

      final double horasTrabajadas =
          await _repository.getHorasTrabajadasPorFecha(event.personalId, event.fecha);

      emit(currentState.copyWith(
        registrosHoy: registros,
        horasTrabajadasHoy: horasTrabajadas,
      ));
    } catch (e) {
      emit(RegistroHorarioError(
        message: 'Error al cargar registros por fecha: $e',
        previousState: currentState,
      ));

      await Future<void>.delayed(const Duration(seconds: 2));
      emit(currentState);
    }
  }

  Future<void> _onLoadRegistrosByDateRange(
    LoadRegistrosByDateRange event,
    Emitter<RegistroHorarioState> emit,
  ) async {
    if (state is! RegistroHorarioLoaded) {
      return;
    }

    final RegistroHorarioLoaded currentState = state as RegistroHorarioLoaded;

    try {
      final List<RegistroHorarioEntity> registros =
          await _repository.getByPersonalIdAndDateRange(
        event.personalId,
        event.fechaInicio,
        event.fechaFin,
      );

      final double horasTrabajadas = await _repository.getHorasTrabajadasPorRango(
        event.personalId,
        event.fechaInicio,
        event.fechaFin,
      );

      emit(currentState.copyWith(
        registrosHoy: registros,
        horasTrabajadasHoy: horasTrabajadas,
      ));
    } catch (e) {
      emit(RegistroHorarioError(
        message: 'Error al cargar registros por rango: $e',
        previousState: currentState,
      ));

      await Future<void>.delayed(const Duration(seconds: 2));
      emit(currentState);
    }
  }

  Future<void> _onLoadEstadisticas(
    LoadEstadisticas event,
    Emitter<RegistroHorarioState> emit,
  ) async {
    if (state is! RegistroHorarioLoaded) {
      return;
    }

    final RegistroHorarioLoaded currentState = state as RegistroHorarioLoaded;

    try {
      final Map<String, dynamic> estadisticas = await _repository.getEstadisticas(
        fechaInicio: event.fechaInicio,
        fechaFin: event.fechaFin,
      );

      emit(currentState.copyWith(estadisticas: estadisticas));
    } catch (e) {
      emit(RegistroHorarioError(
        message: 'Error al cargar estadísticas: $e',
        previousState: currentState,
      ));

      await Future<void>.delayed(const Duration(seconds: 2));
      emit(currentState);
    }
  }
}
