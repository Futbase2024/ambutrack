import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
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
    on<ObtenerContextoTurno>(_onObtenerContextoTurno);
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

      debugPrint('🔑 [RegistroHorarioBloc] Usando personalId: $personalId');

      // Crear registro de entrada
      final registro = RegistroHorarioEntity(
        id: _uuid.v4(),
        personalId: personalId,
        tipo: 'entrada',
        fechaHora: DateTime.now(),
        latitud: event.latitud,
        longitud: event.longitud,
        precisionGps: event.precisionGps,
        notas: event.observaciones,
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
        tipo: 'salida',
        fechaHora: DateTime.now(),
        latitud: event.latitud,
        longitud: event.longitud,
        precisionGps: event.precisionGps,
        notas: event.observaciones,
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

    return ultimoRegistro.tipo.toLowerCase() == 'entrada'
        ? EstadoFichaje.dentro
        : EstadoFichaje.fuera;
  }

  /// Handler para obtener contexto completo del turno
  Future<void> _onObtenerContextoTurno(
    ObtenerContextoTurno event,
    Emitter<RegistroHorarioState> emit,
  ) async {
    try {
      debugPrint('🕐 [RegistroHorarioBloc] Obteniendo contexto de turno...');

      final personalId = _personalId;
      if (personalId == null) {
        debugPrint('❌ [RegistroHorarioBloc] No hay personal autenticado');
        emit(const RegistroHorarioError('No hay sesión activa'));
        return;
      }

      // 1. Obtener registros básicos
      final ultimoRegistro =
          await _registroHorarioRepository.obtenerUltimo(personalId);
      final estadoActual = _determinarEstadoActual(ultimoRegistro);
      final historial = await _registroHorarioRepository.obtenerPorPersonal(
        personalId,
        limit: 10,
      );

      // 2. Obtener vehículo asignado
      VehiculoEntity? vehiculo;
      try {
        debugPrint('📍 [RegistroHorarioBloc] Buscando asignación para personalId: $personalId');
        final asignacionHoy = await _obtenerAsignacionHoy(personalId);
        debugPrint('📍 [RegistroHorarioBloc] Asignación encontrada: $asignacionHoy');

        if (asignacionHoy != null && asignacionHoy['id_vehiculo'] != null) {
          debugPrint('📍 [RegistroHorarioBloc] ID Vehículo: ${asignacionHoy['id_vehiculo']}');
          final vehiculoDs = VehiculoDataSourceFactory.createSupabase();
          vehiculo = await vehiculoDs.getById(asignacionHoy['id_vehiculo']);
          debugPrint('✅ [RegistroHorarioBloc] Vehículo obtenido: ${vehiculo?.matricula}');
        } else {
          debugPrint('⚠️ [RegistroHorarioBloc] No hay asignación o id_vehiculo es null');
        }
      } catch (e, stackTrace) {
        debugPrint('❌ [RegistroHorarioBloc] Error al obtener vehículo: $e');
        debugPrint('Stack trace: $stackTrace');
      }

      // 3. Obtener compañero
      PersonalContexto? companero;
      try {
        if (vehiculo != null) {
          final companeros =
              await _obtenerCompanerosPorVehiculo(vehiculo.id, personalId);
          if (companeros.isNotEmpty) {
            final comp = companeros.first;
            companero = PersonalContexto(
              id: comp['id_personal'] ?? '',
              nombre: comp['nombre_personal'] ?? 'Compañero',
              categoria: comp['categoria'],
            );
          }
        }
      } catch (e) {
        debugPrint('⚠️ [RegistroHorarioBloc] No se pudo obtener compañero: $e');
      }

      // 4. Obtener próximo turno
      TurnoContexto? proximoTurno;
      try {
        final proxTurno = await _obtenerProximoTurno(personalId);
        if (proxTurno != null && proxTurno['fecha'] != null) {
          proximoTurno = TurnoContexto(
            fecha: DateTime.parse(proxTurno['fecha']),
            turno: proxTurno['tipo_turno'],
          );
        }
      } catch (e) {
        debugPrint(
            '⚠️ [RegistroHorarioBloc] No se pudo obtener próximo turno: $e');
      }

      // Emitir estado con contexto
      emit(RegistroHorarioLoadedWithContext(
        ultimoRegistro: ultimoRegistro,
        historial: historial,
        estadoActual: estadoActual,
        vehiculo: vehiculo,
        companero: companero,
        proximoTurno: proximoTurno,
      ));

      debugPrint('✅ [RegistroHorarioBloc] Contexto de turno obtenido');
    } catch (e) {
      debugPrint('❌ [RegistroHorarioBloc] Error al obtener contexto: $e');
      emit(RegistroHorarioError('Error al obtener contexto: $e'));
    }
  }

  /// Obtiene la asignación de turno para hoy
  Future<Map<String, dynamic>?> _obtenerAsignacionHoy(
      String personalId) async {
    final supabase = Supabase.instance.client;
    final hoy = DateTime.now();
    final fechaHoy = DateTime(hoy.year, hoy.month, hoy.day);

    try {
      debugPrint('🔍 [RegistroHorarioBloc] Consultando tabla turnos');
      debugPrint('   - personalId: $personalId');
      debugPrint('   - fechaHoy: ${fechaHoy.toIso8601String()}');

      // Buscar en tabla turnos (igual que ChecklistVehiculoDataSource)
      final response = await supabase
          .from('turnos')
          .select('idVehiculo')
          .eq('idPersonal', personalId)
          .gte('fechaInicio', fechaHoy.toIso8601String())
          .lte('fechaFin', fechaHoy.add(const Duration(days: 1)).toIso8601String())
          .eq('activo', true)
          .maybeSingle();

      debugPrint('🔍 [RegistroHorarioBloc] Response: $response');

      if (response != null && response['idVehiculo'] != null) {
        // Convertir camelCase a snake_case para consistencia
        return {'id_vehiculo': response['idVehiculo']};
      }

      return null;
    } catch (e) {
      debugPrint(
          '❌ [RegistroHorarioBloc] Error al obtener asignación hoy: $e');
      return null;
    }
  }

  /// Obtiene los compañeros del mismo vehículo
  Future<List<Map<String, dynamic>>> _obtenerCompanerosPorVehiculo(
    String vehiculoId,
    String personalIdActual,
  ) async {
    final supabase = Supabase.instance.client;
    final hoy = DateTime.now();
    final fechaHoy = DateTime(hoy.year, hoy.month, hoy.day);

    try {
      final response = await supabase
          .from('turnos')
          .select('idPersonal, nombrePersonal, categoriaPersonal')
          .eq('idVehiculo', vehiculoId)
          .gte('fechaInicio', fechaHoy.toIso8601String())
          .lte('fechaFin', fechaHoy.add(const Duration(days: 1)).toIso8601String())
          .eq('activo', true)
          .neq('idPersonal', personalIdActual);

      // Convertir camelCase a snake_case para consistencia
      final companeros = (response as List).map((item) => {
        'id_personal': item['idPersonal'],
        'nombre_personal': item['nombrePersonal'],
        'categoria': item['categoriaPersonal'],
      }).toList();

      return companeros;
    } catch (e) {
      debugPrint(
          '⚠️ [RegistroHorarioBloc] Error al obtener compañeros: $e');
      return [];
    }
  }

  /// Obtiene el próximo turno del personal
  Future<Map<String, dynamic>?> _obtenerProximoTurno(String personalId) async {
    final supabase = Supabase.instance.client;
    final manana = DateTime.now().add(const Duration(days: 1));
    final fechaManana = DateTime(manana.year, manana.month, manana.day);

    try {
      final response = await supabase
          .from('turnos')
          .select('fechaInicio, fechaFin, tipoTurno')
          .eq('idPersonal', personalId)
          .gte('fechaInicio', fechaManana.toIso8601String())
          .eq('activo', true)
          .order('fechaInicio', ascending: true)
          .limit(1)
          .maybeSingle();

      if (response != null) {
        // Convertir camelCase a snake_case para consistencia
        return {
          'fecha': response['fechaInicio'],
          'tipo_turno': response['tipoTurno'],
        };
      }

      return null;
    } catch (e) {
      debugPrint(
          '⚠️ [RegistroHorarioBloc] Error al obtener próximo turno: $e');
      return null;
    }
  }
}
