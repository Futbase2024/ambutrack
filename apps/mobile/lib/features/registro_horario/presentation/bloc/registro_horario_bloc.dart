import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/datasources/registros_horarios/registros_horarios_datasource.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../domain/repositories/registro_horario_repository.dart';
import 'registro_horario_event.dart';
import 'registro_horario_state.dart';

/// BLoC que maneja el estado de registros horarios
///
/// Gestiona los fichajes de entrada/salida con geolocalización.
class RegistroHorarioBloc
    extends Bloc<RegistroHorarioEvent, RegistroHorarioState> {
  RegistroHorarioBloc({
    required RegistroHorarioRepository registroHorarioRepository,
    required AuthBloc authBloc,
  })  : _registroHorarioRepository = registroHorarioRepository,
        _authBloc = authBloc,
        super(const RegistroHorarioInitial()) {
    // Registrar handlers de eventos
    on<CargarRegistrosHorario>(_onCargarRegistrosHorario);
    on<FicharEntrada>(_onFicharEntrada);
    on<FicharSalida>(_onFicharSalida);
    on<RefrescarHistorial>(_onRefrescarHistorial);
  }

  final RegistroHorarioRepository _registroHorarioRepository;
  final AuthBloc _authBloc;
  final Uuid _uuid = const Uuid();

  /// Obtiene el ID del personal autenticado
  String? get _personalId {
    final authState = _authBloc.state;
    if (authState is AuthAuthenticated) {
      return authState.personal?.id;
    }
    return null;
  }

  /// Handler para cargar registros horarios
  Future<void> _onCargarRegistrosHorario(
    CargarRegistrosHorario event,
    Emitter<RegistroHorarioState> emit,
  ) async {
    try {
      debugPrint('🕐 [RegistroHorarioBloc] Cargando registros...');

      final personalId = _personalId;
      if (personalId == null) {
        debugPrint('❌ [RegistroHorarioBloc] No hay personal autenticado');
        emit(const RegistroHorarioError('No hay sesión activa'));
        return;
      }

      // Obtener el último registro para determinar el estado actual
      final ultimoRegistro =
          await _registroHorarioRepository.obtenerUltimo(personalId);

      // Determinar estado actual basado en el último fichaje
      final estadoActual = _determinarEstadoActual(ultimoRegistro);

      // Obtener historial (últimos 10 registros)
      final historial = await _registroHorarioRepository.obtenerPorPersonal(
        personalId,
        limit: 10,
      );

      debugPrint('✅ [RegistroHorarioBloc] Registros cargados: ${historial.length}');
      debugPrint('📍 [RegistroHorarioBloc] Estado actual: $estadoActual');

      emit(RegistroHorarioLoaded(
        ultimoRegistro: ultimoRegistro,
        historial: historial,
        estadoActual: estadoActual,
      ));
    } catch (e) {
      debugPrint('❌ [RegistroHorarioBloc] Error al cargar registros: $e');
      emit(RegistroHorarioError('Error al cargar registros: $e'));
    }
  }

  /// Handler para fichar entrada
  Future<void> _onFicharEntrada(
    FicharEntrada event,
    Emitter<RegistroHorarioState> emit,
  ) async {
    try {
      debugPrint('🕐 [RegistroHorarioBloc] Fichando entrada...');
      emit(const RegistroHorarioFichando());

      final personalId = _personalId;
      if (personalId == null) {
        debugPrint('❌ [RegistroHorarioBloc] No hay personal autenticado');
        emit(const RegistroHorarioError('No hay sesión activa'));
        return;
      }

      // Crear registro de entrada
      final registro = RegistroHorarioEntity(
        id: _uuid.v4(),
        personalId: personalId,
        tipoFichaje: TipoFichaje.entrada,
        fechaHora: DateTime.now(),
        latitud: event.latitud,
        longitud: event.longitud,
        precisionGps: event.precisionGps,
        observaciones: event.observaciones,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _registroHorarioRepository.crear(registro);

      debugPrint('✅ [RegistroHorarioBloc] Entrada fichada exitosamente');

      // Emitir success temporal
      emit(const RegistroHorarioSuccess('Entrada fichada correctamente'));

      // Recargar datos
      add(const CargarRegistrosHorario());
    } catch (e) {
      debugPrint('❌ [RegistroHorarioBloc] Error al fichar entrada: $e');
      emit(RegistroHorarioError('Error al fichar entrada: $e'));
    }
  }

  /// Handler para fichar salida
  Future<void> _onFicharSalida(
    FicharSalida event,
    Emitter<RegistroHorarioState> emit,
  ) async {
    try {
      debugPrint('🕐 [RegistroHorarioBloc] Fichando salida...');
      emit(const RegistroHorarioFichando());

      final personalId = _personalId;
      if (personalId == null) {
        debugPrint('❌ [RegistroHorarioBloc] No hay personal autenticado');
        emit(const RegistroHorarioError('No hay sesión activa'));
        return;
      }

      // Crear registro de salida
      final registro = RegistroHorarioEntity(
        id: _uuid.v4(),
        personalId: personalId,
        tipoFichaje: TipoFichaje.salida,
        fechaHora: DateTime.now(),
        latitud: event.latitud,
        longitud: event.longitud,
        precisionGps: event.precisionGps,
        observaciones: event.observaciones,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _registroHorarioRepository.crear(registro);

      debugPrint('✅ [RegistroHorarioBloc] Salida fichada exitosamente');

      // Emitir success temporal
      emit(const RegistroHorarioSuccess('Salida fichada correctamente'));

      // Recargar datos
      add(const CargarRegistrosHorario());
    } catch (e) {
      debugPrint('❌ [RegistroHorarioBloc] Error al fichar salida: $e');
      emit(RegistroHorarioError('Error al fichar salida: $e'));
    }
  }

  /// Handler para refrescar historial
  Future<void> _onRefrescarHistorial(
    RefrescarHistorial event,
    Emitter<RegistroHorarioState> emit,
  ) async {
    // Simplemente recarga los datos
    add(const CargarRegistrosHorario());
  }

  /// Determina el estado actual basado en el último fichaje
  EstadoFichaje _determinarEstadoActual(RegistroHorarioEntity? ultimoRegistro) {
    if (ultimoRegistro == null) {
      return EstadoFichaje.fuera;
    }

    return ultimoRegistro.tipoFichaje == TipoFichaje.entrada
        ? EstadoFichaje.dentro
        : EstadoFichaje.fuera;
  }
}
