import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/features/cuadrante/cuadrante_module/domain/entities/cuadrante_filter.dart';
import 'package:ambutrack_web/features/cuadrante/cuadrante_module/domain/entities/cuadrante_view_mode.dart';
import 'package:ambutrack_web/features/cuadrante/cuadrante_module/domain/entities/personal_con_turnos_entity.dart';
import 'package:ambutrack_web/features/cuadrante/cuadrante_module/domain/repositories/cuadrante_repository.dart';
import 'package:ambutrack_web/features/cuadrante/cuadrante_module/presentation/bloc/cuadrante_event.dart';
import 'package:ambutrack_web/features/cuadrante/cuadrante_module/presentation/bloc/cuadrante_state.dart';
import 'package:ambutrack_web/features/vehiculos/domain/repositories/vehiculo_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

/// BLoC para gestión del cuadrante de personal
@injectable
class CuadranteBloc extends Bloc<CuadranteEvent, CuadranteState> {
  CuadranteBloc(
    this._repository,
    this._vehiculoRepository,
  ) : super(const CuadranteInitial()) {
    on<CuadranteLoadRequested>(_onLoadRequested);
    on<CuadranteSemanaChanged>(_onSemanaChanged);
    on<CuadranteMesChanged>(_onMesChanged);
    on<CuadranteViewModeChanged>(_onViewModeChanged);
    on<CuadranteFilterChanged>(_onFilterChanged);
    on<CuadranteFilterCleared>(_onFilterCleared);
    on<CuadranteRefreshRequested>(_onRefreshRequested);
    on<CuadranteCopiarSemanaRequested>(_onCopiarSemanaRequested);
    on<CuadranteTurnoCreated>(_onTurnoCreated);
    on<CuadranteTurnoUpdated>(_onTurnoUpdated);
    on<CuadranteTurnoDeleted>(_onTurnoDeleted);
  }

  final CuadranteRepository _repository;
  final VehiculoRepository _vehiculoRepository;

  Future<void> _onLoadRequested(
    CuadranteLoadRequested event,
    Emitter<CuadranteState> emit,
  ) async {
    emit(const CuadranteLoading());

    try {
      debugPrint('🔄 CuadranteBloc: Cargando cuadrante inicial...');

      // Cargar cuadrante para la semana actual
      final DateTime ahora = DateTime.now();
      final int diasDesdeLunes = ahora.weekday - 1;
      final DateTime primerDiaSemana = ahora.subtract(Duration(days: diasDesdeLunes));

      // Cargar cuadrante y vehículos en paralelo
      final List<dynamic> results = await Future.wait(<Future<dynamic>>[
        _repository.getCuadranteSemanal(
          primerDiaSemana: primerDiaSemana,
          filter: const CuadranteFilter(),
        ),
        _vehiculoRepository.getAll(),
      ]);

      final List<PersonalConTurnosEntity> cuadrante = results[0] as List<PersonalConTurnosEntity>;
      final List<VehiculoEntity> vehiculos = results[1] as List<VehiculoEntity>;

      debugPrint('✅ CuadranteBloc: Cuadrante cargado - ${cuadrante.length} personas');
      debugPrint('✅ CuadranteBloc: Vehículos cargados - ${vehiculos.length} vehículos');

      emit(CuadranteLoaded(
        personalConTurnos: cuadrante,
        allPersonalConTurnos: cuadrante,
        viewMode: CuadranteViewMode.tabla,
        fechaActual: ahora,
        filter: const CuadranteFilter(),
        vehiculos: vehiculos,
      ));
    } catch (e) {
      debugPrint('❌ CuadranteBloc: Error al cargar cuadrante - $e');
      emit(CuadranteError('Error al cargar el cuadrante: $e'));
    }
  }

  Future<void> _onSemanaChanged(
    CuadranteSemanaChanged event,
    Emitter<CuadranteState> emit,
  ) async {
    if (state is! CuadranteLoaded) {
      return;
    }

    final CuadranteLoaded currentState = state as CuadranteLoaded;

    try {
      debugPrint('📅 CuadranteBloc: Cambiando semana (offset: ${event.offset})');

      // Calcular nueva fecha
      final DateTime nuevaFecha = currentState.fechaActual.add(Duration(days: 7 * event.offset));
      final int diasDesdeLunes = nuevaFecha.weekday - 1;
      final DateTime primerDiaSemana = nuevaFecha.subtract(Duration(days: diasDesdeLunes));

      final List<PersonalConTurnosEntity> cuadrante = await _repository.getCuadranteSemanal(
        primerDiaSemana: primerDiaSemana,
        filter: currentState.filter,
      );

      debugPrint('✅ CuadranteBloc: Nueva semana cargada - ${cuadrante.length} personas');

      // Aplicar filtros locales (searchQuery y soloConTurnos)
      List<PersonalConTurnosEntity> filtrados = cuadrante;

      // Filtrar por búsqueda
      if (currentState.filter.searchQuery.isNotEmpty) {
        final String searchLower = currentState.filter.searchQuery.toLowerCase();
        filtrados = filtrados.where((PersonalConTurnosEntity pc) {
          final String nombreCompleto = pc.personal.nombreCompleto.toLowerCase();
          return nombreCompleto.contains(searchLower);
        }).toList();
      }

      // Filtrar por solo con turnos
      if (currentState.filter.soloConTurnos) {
        filtrados = filtrados.where((PersonalConTurnosEntity pc) => pc.turnos.isNotEmpty).toList();
      }

      emit(currentState.copyWith(
        personalConTurnos: filtrados,
        allPersonalConTurnos: cuadrante,
        fechaActual: nuevaFecha,
        vehiculos: currentState.vehiculos,
      ));
    } catch (e) {
      debugPrint('❌ CuadranteBloc: Error al cambiar semana - $e');
      emit(CuadranteError('Error al cambiar de semana: $e'));
    }
  }

  Future<void> _onMesChanged(
    CuadranteMesChanged event,
    Emitter<CuadranteState> emit,
  ) async {
    if (state is! CuadranteLoaded) {
      return;
    }

    final CuadranteLoaded currentState = state as CuadranteLoaded;
    emit(const CuadranteLoading());

    try {
      debugPrint('📅 CuadranteBloc: Cambiando mes (offset: ${event.offset})');

      // Calcular nuevo mes
      final DateTime nuevaFecha = DateTime(
        currentState.fechaActual.year,
        currentState.fechaActual.month + event.offset,
      );

      final List<PersonalConTurnosEntity> cuadrante = await _repository.getCuadranteMensual(
        mes: nuevaFecha.month,
        anio: nuevaFecha.year,
        filter: currentState.filter,
      );

      debugPrint('✅ CuadranteBloc: Nuevo mes cargado - ${cuadrante.length} personas');

      emit(currentState.copyWith(
        personalConTurnos: cuadrante,
        allPersonalConTurnos: cuadrante,
        fechaActual: nuevaFecha,
        vehiculos: currentState.vehiculos,
      ));
    } catch (e) {
      debugPrint('❌ CuadranteBloc: Error al cambiar mes - $e');
      emit(CuadranteError('Error al cambiar de mes: $e'));
    }
  }

  void _onViewModeChanged(
    CuadranteViewModeChanged event,
    Emitter<CuadranteState> emit,
  ) {
    if (state is! CuadranteLoaded) {
      return;
    }

    final CuadranteLoaded currentState = state as CuadranteLoaded;
    debugPrint('🔄 CuadranteBloc: Cambiando modo de vista a ${event.mode.name}');

    emit(currentState.copyWith(viewMode: event.mode));
  }

  Future<void> _onFilterChanged(
    CuadranteFilterChanged event,
    Emitter<CuadranteState> emit,
  ) async {
    if (state is! CuadranteLoaded) {
      return;
    }

    final CuadranteLoaded currentState = state as CuadranteLoaded;

    // Si solo cambió el searchQuery o soloConTurnos, filtrar localmente sin recargar
    final bool filtradoLocal = event.filter.categoriaServicio == currentState.filter.categoriaServicio &&
        event.filter.puestoId == currentState.filter.puestoId &&
        event.filter.fechaInicio == currentState.filter.fechaInicio &&
        event.filter.fechaFin == currentState.filter.fechaFin;

    if (filtradoLocal) {
      debugPrint('🔍 CuadranteBloc: Filtrando localmente (búsqueda: "${event.filter.searchQuery}", soloConTurnos: ${event.filter.soloConTurnos})');

      // Filtrar en memoria sin hacer loading
      List<PersonalConTurnosEntity> filtrados = currentState.allPersonalConTurnos;

      // Filtro por búsqueda
      if (event.filter.searchQuery.isNotEmpty) {
        final String searchLower = event.filter.searchQuery.toLowerCase();
        filtrados = filtrados.where((PersonalConTurnosEntity pc) {
          final String nombreCompleto = '${pc.personal.nombre} ${pc.personal.apellidos}'.toLowerCase();
          return nombreCompleto.contains(searchLower);
        }).toList();
      }

      // Filtro por solo con turnos
      if (event.filter.soloConTurnos) {
        filtrados = filtrados.where((PersonalConTurnosEntity pc) {
          return pc.turnos.isNotEmpty;
        }).toList();
      }

      debugPrint('✅ CuadranteBloc: Filtrado local - ${filtrados.length}/${currentState.allPersonalConTurnos.length} personas');

      emit(currentState.copyWith(
        personalConTurnos: filtrados,
        filter: event.filter,
      ));
      return;
    }

    // Si cambiaron otros filtros, recargar desde el servidor
    emit(const CuadranteLoading());

    try {
      debugPrint('🔍 CuadranteBloc: Aplicando filtros (recargando desde servidor)...');

      // Recargar con nuevos filtros
      List<PersonalConTurnosEntity> cuadrante;

      if (currentState.viewMode == CuadranteViewMode.tabla) {
        final int diasDesdeLunes = currentState.fechaActual.weekday - 1;
        final DateTime primerDiaSemana =
            currentState.fechaActual.subtract(Duration(days: diasDesdeLunes));

        cuadrante = await _repository.getCuadranteSemanal(
          primerDiaSemana: primerDiaSemana,
          filter: event.filter,
        );
      } else {
        cuadrante = await _repository.getCuadranteMensual(
          mes: currentState.fechaActual.month,
          anio: currentState.fechaActual.year,
          filter: event.filter,
        );
      }

      debugPrint('✅ CuadranteBloc: Filtros aplicados - ${cuadrante.length} personas');

      emit(currentState.copyWith(
        personalConTurnos: cuadrante,
        allPersonalConTurnos: cuadrante,
        filter: event.filter,
        vehiculos: currentState.vehiculos,
      ));
    } catch (e) {
      debugPrint('❌ CuadranteBloc: Error al aplicar filtros - $e');
      emit(CuadranteError('Error al aplicar filtros: $e'));
    }
  }

  Future<void> _onFilterCleared(
    CuadranteFilterCleared event,
    Emitter<CuadranteState> emit,
  ) async {
    if (state is! CuadranteLoaded) {
      return;
    }

    // Aplicar filtro vacío
    add(const CuadranteFilterChanged(CuadranteFilter()));
  }

  Future<void> _onRefreshRequested(
    CuadranteRefreshRequested event,
    Emitter<CuadranteState> emit,
  ) async {
    if (state is! CuadranteLoaded) {
      add(const CuadranteLoadRequested());
      return;
    }

    final CuadranteLoaded currentState = state as CuadranteLoaded;
    emit(const CuadranteLoading());

    try {
      debugPrint('🔄 CuadranteBloc: Refrescando cuadrante...');

      List<PersonalConTurnosEntity> cuadrante;

      if (currentState.viewMode == CuadranteViewMode.tabla) {
        final int diasDesdeLunes = currentState.fechaActual.weekday - 1;
        final DateTime primerDiaSemana =
            currentState.fechaActual.subtract(Duration(days: diasDesdeLunes));

        cuadrante = await _repository.getCuadranteSemanal(
          primerDiaSemana: primerDiaSemana,
          filter: currentState.filter,
        );
      } else {
        cuadrante = await _repository.getCuadranteMensual(
          mes: currentState.fechaActual.month,
          anio: currentState.fechaActual.year,
          filter: currentState.filter,
        );
      }

      debugPrint('✅ CuadranteBloc: Cuadrante refrescado - ${cuadrante.length} personas');

      emit(currentState.copyWith(
        personalConTurnos: cuadrante,
        allPersonalConTurnos: cuadrante,
        vehiculos: currentState.vehiculos,
      ));
    } catch (e) {
      debugPrint('❌ CuadranteBloc: Error al refrescar - $e');
      emit(CuadranteError('Error al refrescar el cuadrante: $e'));
    }
  }

  Future<void> _onCopiarSemanaRequested(
    CuadranteCopiarSemanaRequested event,
    Emitter<CuadranteState> emit,
  ) async {
    if (state is! CuadranteLoaded) {
      return;
    }

    try {
      debugPrint('📋 CuadranteBloc: Copiando semana...');
      debugPrint('   Origen: ${event.semanaOrigen}');
      debugPrint('   Destino: ${event.semanaDestino}');
      debugPrint('   Personal: ${event.idPersonal ?? "TODOS"}');

      await _repository.copiarSemanaTurnos(
        semanaOrigen: event.semanaOrigen,
        semanaDestino: event.semanaDestino,
        idPersonal: event.idPersonal,
      );

      final String mensaje = event.idPersonal == null
          ? 'Semana copiada exitosamente (todos los trabajadores)'
          : event.idPersonal!.length == 1
              ? 'Semana del trabajador copiada exitosamente'
              : 'Semana de ${event.idPersonal!.length} trabajadores copiada exitosamente';

      debugPrint('✅ CuadranteBloc: $mensaje');

      // Emitir estado de éxito
      emit(CuadranteCopiaExitosa(mensaje));

      // Refrescar cuadrante
      add(const CuadranteRefreshRequested());
    } catch (e) {
      debugPrint('❌ CuadranteBloc: Error al copiar semana - $e');
      emit(CuadranteError('Error al copiar la semana: $e'));
    }
  }

  void _onTurnoCreated(
    CuadranteTurnoCreated event,
    Emitter<CuadranteState> emit,
  ) {
    if (state is! CuadranteLoaded) {
      return;
    }

    final CuadranteLoaded currentState = state as CuadranteLoaded;
    debugPrint('➕ CuadranteBloc: Añadiendo turno creado al cuadrante');

    // Buscar el personal y añadir el turno
    final List<PersonalConTurnosEntity> updatedPersonal = currentState.personalConTurnos.map((PersonalConTurnosEntity p) {
      if (p.personal.id == event.turno.idPersonal) {
        // Añadir el nuevo turno a la lista de turnos del personal
        final List<TurnoEntity> updatedTurnos = <TurnoEntity>[
          ...p.turnos.whereType<TurnoEntity>(),
          event.turno,
        ];
        return PersonalConTurnosEntity(
          personal: p.personal,
          turnos: updatedTurnos,
        );
      }
      return p;
    }).toList();

    emit(currentState.copyWith(personalConTurnos: updatedPersonal));
  }

  void _onTurnoUpdated(
    CuadranteTurnoUpdated event,
    Emitter<CuadranteState> emit,
  ) {
    if (state is! CuadranteLoaded) {
      return;
    }

    final CuadranteLoaded currentState = state as CuadranteLoaded;
    debugPrint('✏️ CuadranteBloc: Actualizando turno en cuadrante');

    // Buscar el personal y actualizar el turno
    final List<PersonalConTurnosEntity> updatedPersonal = currentState.personalConTurnos.map((PersonalConTurnosEntity p) {
      if (p.personal.id == event.turno.idPersonal) {
        // Reemplazar el turno actualizado
        final List<TurnoEntity> updatedTurnos = p.turnos.whereType<TurnoEntity>().map((TurnoEntity t) {
          if (t.id == event.turno.id) {
            return event.turno;
          }
          return t;
        }).toList();

        return PersonalConTurnosEntity(
          personal: p.personal,
          turnos: updatedTurnos,
        );
      }
      return p;
    }).toList();

    emit(currentState.copyWith(personalConTurnos: updatedPersonal));
  }

  void _onTurnoDeleted(
    CuadranteTurnoDeleted event,
    Emitter<CuadranteState> emit,
  ) {
    if (state is! CuadranteLoaded) {
      return;
    }

    final CuadranteLoaded currentState = state as CuadranteLoaded;
    debugPrint('🗑️ CuadranteBloc: Eliminando turno del cuadrante');

    // Buscar el personal y eliminar el turno
    final List<PersonalConTurnosEntity> updatedPersonal = currentState.personalConTurnos.map((PersonalConTurnosEntity p) {
      // Filtrar el turno eliminado
      final List<TurnoEntity> updatedTurnos = p.turnos
          .whereType<TurnoEntity>()
          .where((TurnoEntity t) => t.id != event.turnoId)
          .toList();

      // Si se modificó la lista de turnos, crear nueva entidad
      final int originalCount = p.turnos.whereType<TurnoEntity>().length;
      if (updatedTurnos.length != originalCount) {
        return PersonalConTurnosEntity(
          personal: p.personal,
          turnos: updatedTurnos,
        );
      }

      return p;
    }).toList();

    emit(currentState.copyWith(personalConTurnos: updatedPersonal));
  }
}
