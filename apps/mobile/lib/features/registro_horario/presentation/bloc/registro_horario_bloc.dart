import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../domain/repositories/registro_horario_repository.dart';
import '../../domain/repositories/turno_actual_repository.dart';
import 'registro_horario_event.dart';
import 'registro_horario_state.dart';

/// BLoC que maneja el estado de registros horarios
///
/// Gestiona los fichajes de entrada/salida con geolocalización y la
/// resolución del turno en curso (cuadrante o creado desde la app).
class RegistroHorarioBloc
    extends Bloc<RegistroHorarioEvent, RegistroHorarioState> {
  RegistroHorarioBloc({
    required RegistroHorarioRepository registroHorarioRepository,
    required TurnoActualRepository turnoActualRepository,
    required AuthBloc authBloc,
  })  : _registroRepository = registroHorarioRepository,
        _turnoRepository = turnoActualRepository,
        _authBloc = authBloc,
        super(const RegistroHorarioInitial()) {
    on<CargarRegistrosHorario>(_onCargarRegistrosHorario);
    on<FicharEntrada>(_onFicharEntrada);
    on<FicharSalida>(_onFicharSalida);
    on<RefrescarHistorial>(_onRefrescarHistorial);
    on<ObtenerContextoTurno>(_onObtenerContextoTurno);
    on<CambiarVehiculo>(_onCambiarVehiculo);
  }

  final RegistroHorarioRepository _registroRepository;
  final TurnoActualRepository _turnoRepository;
  final AuthBloc _authBloc;
  final Uuid _uuid = const Uuid();

  /// Personal autenticado
  TPersonalEntity? get _personal {
    final AuthState authState = _authBloc.state;
    return authState is AuthAuthenticated ? authState.personal : null;
  }

  Future<void> _onCargarRegistrosHorario(
    CargarRegistrosHorario event,
    Emitter<RegistroHorarioState> emit,
  ) async {
    // El contexto completo incluye registros + turno
    add(const ObtenerContextoTurno());
  }

  /// Inicio de turno: resuelve el turno (cuadrante o app) y ficha entrada
  Future<void> _onFicharEntrada(
    FicharEntrada event,
    Emitter<RegistroHorarioState> emit,
  ) async {
    final TPersonalEntity? personal = _personal;
    if (personal == null) {
      emit(const RegistroHorarioError('No hay sesión activa'));
      return;
    }

    try {
      emit(const RegistroHorarioFichando());
      final InicioTurnoSeleccion seleccion = event.seleccion;
      final TurnoEntity turno = await _resolverTurno(personal, seleccion);
      debugPrint('🕐 [RegistroHorarioBloc] Turno resuelto: ${turno.id} '
          '(${turno.origen.name}) vehículo ${seleccion.vehiculo.matricula}');

      await _registroRepository.crear(_nuevoRegistro(
        personalId: personal.id,
        tipo: 'entrada',
        latitud: event.latitud,
        longitud: event.longitud,
        precisionGps: event.precisionGps,
        vehiculo: seleccion.vehiculo,
        notas: event.observaciones,
      ));

      final String aviso = turno.pendienteValidacion
          ? '\n\nTu turno se ha creado desde la app y queda pendiente de validar por coordinación.'
          : '';
      emit(RegistroHorarioSuccess(
        'Turno iniciado con el vehículo ${seleccion.vehiculo.matricula}.$aviso',
      ));
      add(const ObtenerContextoTurno());
    } catch (e) {
      debugPrint('❌ [RegistroHorarioBloc] Error al iniciar turno: $e');
      emit(RegistroHorarioError('Error al iniciar turno: $e'));
    }
  }

  /// Devuelve el turno del cuadrante (actualizando vehículo si cambia)
  /// o crea uno nuevo desde la app pendiente de validar.
  Future<TurnoEntity> _resolverTurno(
    TPersonalEntity personal,
    InicioTurnoSeleccion seleccion,
  ) async {
    final TurnoEntity? existente = seleccion.turno;
    if (existente != null) {
      if (existente.idVehiculo == seleccion.vehiculo.id) {
        return existente;
      }
      return _turnoRepository.actualizarTurno(
        existente.copyWith(idVehiculo: seleccion.vehiculo.id),
      );
    }

    final PlantillaTurnoEntity? plantilla = seleccion.plantilla;
    if (plantilla == null) {
      throw StateError('Selecciona el tipo de turno');
    }
    return _turnoRepository.crearTurno(
      _nuevoTurnoApp(personal, plantilla, seleccion.vehiculo.id),
    );
  }

  /// Construye el turno creado desde la app a partir de una plantilla.
  ///
  /// Si el turno de hoy aún no ha empezado pero el de ayer sigue en curso
  /// (ej: noche 23:00-07:00 fichando a las 00:30) se usa el de ayer.
  TurnoEntity _nuevoTurnoApp(
    TPersonalEntity personal,
    PlantillaTurnoEntity plantilla,
    String idVehiculo,
  ) {
    final DateTime ahora = DateTime.now();
    final DateTime hoy = DateTime(ahora.year, ahora.month, ahora.day);
    final String nombre = '${personal.nombre} ${personal.apellidos}'.trim().toUpperCase();

    TurnoEntity turnoDel(DateTime dia) => TurnoEntity(
          id: _uuid.v4(),
          idPersonal: personal.id,
          nombrePersonal: nombre,
          tipoTurno: plantilla.tipoTurno,
          fechaInicio: dia,
          fechaFin: dia,
          horaInicio: plantilla.horaInicio,
          horaFin: plantilla.horaFin,
          idContrato: personal.contratoId,
          idBase: personal.baseId,
          categoriaPersonal: personal.categoria,
          idVehiculo: idVehiculo,
          idDotacion: personal.dotacionId,
          observaciones: 'Creado desde la app al iniciar turno (${plantilla.nombre})',
          origen: OrigenTurno.app,
          validado: false,
        );

    TurnoEntity turno = turnoDel(hoy);
    final TurnoEntity deAyer = turnoDel(hoy.subtract(const Duration(days: 1)));
    if (turno.inicioReal.subtract(const Duration(hours: 1)).isAfter(ahora) &&
        deAyer.finReal.isAfter(ahora)) {
      turno = deAyer;
    }
    return turno.copyWith(fechaInicio: turno.inicioReal, fechaFin: turno.finReal);
  }

  Future<void> _onFicharSalida(
    FicharSalida event,
    Emitter<RegistroHorarioState> emit,
  ) async {
    final TPersonalEntity? personal = _personal;
    if (personal == null) {
      emit(const RegistroHorarioError('No hay sesión activa'));
      return;
    }

    try {
      emit(const RegistroHorarioFichando());
      final VehiculoEntity? vehiculo = await _vehiculoDelTurno(personal.id);
      await _registroRepository.crear(_nuevoRegistro(
        personalId: personal.id,
        tipo: 'salida',
        latitud: event.latitud,
        longitud: event.longitud,
        precisionGps: event.precisionGps,
        vehiculo: vehiculo,
        notas: event.observaciones,
      ));
      emit(const RegistroHorarioSuccess('Salida fichada correctamente'));
      add(const ObtenerContextoTurno());
    } catch (e) {
      debugPrint('❌ [RegistroHorarioBloc] Error al fichar salida: $e');
      emit(RegistroHorarioError('Error al fichar salida: $e'));
    }
  }

  Future<void> _onRefrescarHistorial(
    RefrescarHistorial event,
    Emitter<RegistroHorarioState> emit,
  ) async {
    add(const ObtenerContextoTurno());
  }

  /// Cambio de vehículo en turno: salida con el actual, actualiza el
  /// turno y entrada con el nuevo.
  Future<void> _onCambiarVehiculo(
    CambiarVehiculo event,
    Emitter<RegistroHorarioState> emit,
  ) async {
    final TPersonalEntity? personal = _personal;
    if (personal == null) {
      emit(const RegistroHorarioError('No hay sesión activa'));
      return;
    }

    try {
      emit(const RegistroHorarioFichando());
      final TurnoEntity? turno = await _turnoRepository.obtenerTurnoVigente(personal.id);
      final VehiculoEntity? actual = await _vehiculoPorId(turno?.idVehiculo);
      final VehiculoEntity? nuevo = await _vehiculoPorId(event.nuevoVehiculoId);
      final String notas = event.observaciones ?? 'Cambio de vehículo';

      await _registroRepository.crear(_nuevoRegistro(
        personalId: personal.id,
        tipo: 'salida',
        latitud: event.latitud,
        longitud: event.longitud,
        precisionGps: event.precisionGps,
        vehiculo: actual,
        notas: notas,
      ));

      if (turno != null) {
        await _turnoRepository.actualizarTurno(
          turno.copyWith(idVehiculo: event.nuevoVehiculoId),
        );
      }

      await _registroRepository.crear(_nuevoRegistro(
        personalId: personal.id,
        tipo: 'entrada',
        latitud: event.latitud,
        longitud: event.longitud,
        precisionGps: event.precisionGps,
        vehiculo: nuevo,
        notas: notas,
      ));

      emit(RegistroHorarioSuccess(
        'Vehículo cambiado: ${actual?.matricula ?? 'N/A'} → ${nuevo?.matricula ?? 'N/A'}',
      ));
      add(const ObtenerContextoTurno());
    } catch (e) {
      debugPrint('❌ [RegistroHorarioBloc] Error al cambiar vehículo: $e');
      emit(RegistroHorarioError('Error al cambiar vehículo: $e'));
    }
  }

  /// Carga registros + vehículo, compañero y próximo turno
  Future<void> _onObtenerContextoTurno(
    ObtenerContextoTurno event,
    Emitter<RegistroHorarioState> emit,
  ) async {
    final TPersonalEntity? personal = _personal;
    if (personal == null) {
      emit(const RegistroHorarioError('No hay sesión activa'));
      return;
    }

    try {
      final RegistroHorarioEntity? ultimo = await _registroRepository.obtenerUltimo(personal.id);
      final List<RegistroHorarioEntity> historial =
          await _registroRepository.obtenerPorPersonal(personal.id, limit: 10);
      final VehiculoEntity? vehiculo = await _vehiculoDelTurno(personal.id);

      emit(RegistroHorarioLoadedWithContext(
        ultimoRegistro: ultimo,
        historial: historial,
        estadoActual: _estadoActual(ultimo),
        vehiculo: vehiculo,
        companero: await _companero(vehiculo, personal.id),
        proximoTurno: await _proximoTurno(personal.id),
      ));
    } catch (e) {
      debugPrint('❌ [RegistroHorarioBloc] Error al obtener contexto: $e');
      emit(RegistroHorarioError('Error al obtener contexto: $e'));
    }
  }

  EstadoFichaje _estadoActual(RegistroHorarioEntity? ultimo) {
    return ultimo?.tipo.toLowerCase() == 'entrada'
        ? EstadoFichaje.dentro
        : EstadoFichaje.fuera;
  }

  /// Vehículo del turno vigente (null si no hay turno o vehículo)
  Future<VehiculoEntity?> _vehiculoDelTurno(String personalId) async {
    try {
      final TurnoEntity? turno = await _turnoRepository.obtenerTurnoVigente(personalId);
      return await _vehiculoPorId(turno?.idVehiculo);
    } catch (e) {
      debugPrint('⚠️ [RegistroHorarioBloc] Sin vehículo de turno: $e');
      return null;
    }
  }

  Future<VehiculoEntity?> _vehiculoPorId(String? id) async {
    if (id == null || id.isEmpty) {
      return null;
    }
    return _turnoRepository.obtenerVehiculo(id);
  }

  Future<PersonalContexto?> _companero(VehiculoEntity? vehiculo, String personalId) async {
    if (vehiculo == null) {
      return null;
    }
    try {
      final List<TurnoEntity> companeros = await _turnoRepository.obtenerCompaneros(
        idVehiculo: vehiculo.id,
        idPersonalExcluido: personalId,
      );
      if (companeros.isEmpty) {
        return null;
      }
      final TurnoEntity c = companeros.first;
      return PersonalContexto(id: c.idPersonal, nombre: c.nombrePersonal, categoria: c.categoriaPersonal);
    } catch (e) {
      debugPrint('⚠️ [RegistroHorarioBloc] No se pudo obtener compañero: $e');
      return null;
    }
  }

  Future<TurnoContexto?> _proximoTurno(String personalId) async {
    try {
      final TurnoEntity? turno = await _turnoRepository.obtenerProximoTurno(personalId);
      return turno == null
          ? null
          : TurnoContexto(fecha: turno.inicioReal, turno: turno.tipoTurno.nombre);
    } catch (e) {
      debugPrint('⚠️ [RegistroHorarioBloc] No se pudo obtener próximo turno: $e');
      return null;
    }
  }

  RegistroHorarioEntity _nuevoRegistro({
    required String personalId,
    required String tipo,
    required double latitud,
    required double longitud,
    required double precisionGps,
    VehiculoEntity? vehiculo,
    String? notas,
  }) {
    final DateTime ahora = DateTime.now();
    return RegistroHorarioEntity(
      id: _uuid.v4(),
      personalId: personalId,
      tipo: tipo,
      fechaHora: ahora,
      latitud: latitud,
      longitud: longitud,
      precisionGps: precisionGps,
      vehiculoId: vehiculo?.id,
      vehiculoMatricula: vehiculo?.matricula,
      notas: notas,
      createdAt: ahora,
      updatedAt: ahora,
    );
  }
}
