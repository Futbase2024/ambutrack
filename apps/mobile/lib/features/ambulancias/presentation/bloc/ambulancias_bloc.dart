import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/repositories/ambulancias_repository.dart';
import 'ambulancias_event.dart';
import 'ambulancias_state.dart';

/// BLoC para gestionar el estado de las ambulancias.
@injectable
class AmbulanciasBloc extends Bloc<AmbulanciasEvent, AmbulanciasState> {
  AmbulanciasBloc(this._repository) : super(const AmbulanciasInitial()) {
    on<AmbulanciasLoadRequested>(_onLoadRequested);
    on<AmbulanciasLoadByEmpresaRequested>(_onLoadByEmpresaRequested);
    on<AmbulanciasLoadByEstadoRequested>(_onLoadByEstadoRequested);
    on<AmbulanciasSearchByMatriculaRequested>(_onSearchByMatriculaRequested);
    on<AmbulanciaLoadByIdRequested>(_onLoadByIdRequested);
    on<AmbulanciaCreateRequested>(_onCreateRequested);
    on<AmbulanciaUpdateRequested>(_onUpdateRequested);
    on<AmbulanciaDeleteRequested>(_onDeleteRequested);
    on<TiposAmbulanciaLoadRequested>(_onTiposLoadRequested);
  }

  final AmbulanciasRepository _repository;

  Future<void> _onLoadRequested(
    AmbulanciasLoadRequested event,
    Emitter<AmbulanciasState> emit,
  ) async {
    debugPrint('🚑 AmbulanciasBloc: Cargando todas las ambulancias...');
    emit(const AmbulanciasLoading());

    try {
      final ambulancias = await _repository.getAll();
      debugPrint('🚑 AmbulanciasBloc: ✅ ${ambulancias.length} ambulancias cargadas');

      // Cargar también los tipos si no están cargados
      List<TipoAmbulanciaEntity> tipos = [];
      if (state is AmbulanciasLoaded) {
        tipos = (state as AmbulanciasLoaded).tipos;
      }
      if (tipos.isEmpty) {
        try {
          tipos = await _repository.getTiposAmbulancia();
          debugPrint('🚑 AmbulanciasBloc: ✅ ${tipos.length} tipos cargados');
        } catch (e) {
          debugPrint('🚑 AmbulanciasBloc: ⚠️ Error al cargar tipos: $e');
        }
      }

      emit(AmbulanciasLoaded(ambulancias: ambulancias, tipos: tipos));
    } catch (e) {
      debugPrint('🚑 AmbulanciasBloc: ❌ Error: $e');
      emit(AmbulanciasError(e.toString()));
    }
  }

  Future<void> _onLoadByEmpresaRequested(
    AmbulanciasLoadByEmpresaRequested event,
    Emitter<AmbulanciasState> emit,
  ) async {
    debugPrint('🚑 AmbulanciasBloc: Cargando ambulancias de empresa: ${event.empresaId}');
    emit(const AmbulanciasLoading());

    try {
      final ambulancias = await _repository.getAmbulanciasByEmpresa(
        event.empresaId,
        incluirTipo: event.incluirTipo,
      );
      debugPrint('🚑 AmbulanciasBloc: ✅ ${ambulancias.length} ambulancias cargadas');

      // Mantener tipos si ya están cargados
      List<TipoAmbulanciaEntity> tipos = [];
      if (state is AmbulanciasLoaded) {
        tipos = (state as AmbulanciasLoaded).tipos;
      }
      if (tipos.isEmpty) {
        try {
          tipos = await _repository.getTiposAmbulancia();
          debugPrint('🚑 AmbulanciasBloc: ✅ ${tipos.length} tipos cargados');
        } catch (e) {
          debugPrint('🚑 AmbulanciasBloc: ⚠️ Error al cargar tipos: $e');
        }
      }

      emit(AmbulanciasLoaded(ambulancias: ambulancias, tipos: tipos));
    } catch (e) {
      debugPrint('🚑 AmbulanciasBloc: ❌ Error: $e');
      emit(AmbulanciasError(e.toString()));
    }
  }

  Future<void> _onLoadByEstadoRequested(
    AmbulanciasLoadByEstadoRequested event,
    Emitter<AmbulanciasState> emit,
  ) async {
    debugPrint('🚑 AmbulanciasBloc: Cargando ambulancias por estado: ${event.estado.nombre}');
    emit(const AmbulanciasLoading());

    try {
      final ambulancias = await _repository.getAmbulanciasByEstado(event.estado);
      debugPrint('🚑 AmbulanciasBloc: ✅ ${ambulancias.length} ambulancias cargadas');

      // Mantener tipos
      List<TipoAmbulanciaEntity> tipos = [];
      if (state is AmbulanciasLoaded) {
        tipos = (state as AmbulanciasLoaded).tipos;
      }
      if (tipos.isEmpty) {
        try {
          tipos = await _repository.getTiposAmbulancia();
        } catch (e) {
          debugPrint('🚑 AmbulanciasBloc: ⚠️ Error al cargar tipos: $e');
        }
      }

      emit(AmbulanciasLoaded(ambulancias: ambulancias, tipos: tipos));
    } catch (e) {
      debugPrint('🚑 AmbulanciasBloc: ❌ Error: $e');
      emit(AmbulanciasError(e.toString()));
    }
  }

  Future<void> _onSearchByMatriculaRequested(
    AmbulanciasSearchByMatriculaRequested event,
    Emitter<AmbulanciasState> emit,
  ) async {
    debugPrint('🚑 AmbulanciasBloc: Buscando por matrícula: ${event.matricula}');
    emit(const AmbulanciasLoading());

    try {
      final ambulancias = await _repository.searchByMatricula(event.matricula);
      debugPrint('🚑 AmbulanciasBloc: ✅ ${ambulancias.length} resultados encontrados');

      // Mantener tipos
      List<TipoAmbulanciaEntity> tipos = [];
      if (state is AmbulanciasLoaded) {
        tipos = (state as AmbulanciasLoaded).tipos;
      }
      if (tipos.isEmpty) {
        try {
          tipos = await _repository.getTiposAmbulancia();
        } catch (e) {
          debugPrint('🚑 AmbulanciasBloc: ⚠️ Error al cargar tipos: $e');
        }
      }

      emit(AmbulanciasLoaded(ambulancias: ambulancias, tipos: tipos));
    } catch (e) {
      debugPrint('🚑 AmbulanciasBloc: ❌ Error: $e');
      emit(AmbulanciasError(e.toString()));
    }
  }

  Future<void> _onLoadByIdRequested(
    AmbulanciaLoadByIdRequested event,
    Emitter<AmbulanciasState> emit,
  ) async {
    debugPrint('🚑 AmbulanciasBloc: Cargando ambulancia: ${event.id}');
    emit(const AmbulanciasLoading());

    try {
      final ambulancia = await _repository.getAmbulanciaWithRelations(
        event.id,
        incluirTipo: true,
      );

      if (ambulancia == null) {
        emit(const AmbulanciasError('Ambulancia no encontrada'));
        return;
      }

      debugPrint('🚑 AmbulanciasBloc: ✅ Ambulancia cargada: ${ambulancia.matricula}');
      emit(AmbulanciaDetailLoaded(ambulancia));
    } catch (e) {
      debugPrint('🚑 AmbulanciasBloc: ❌ Error: $e');
      emit(AmbulanciasError(e.toString()));
    }
  }

  Future<void> _onCreateRequested(
    AmbulanciaCreateRequested event,
    Emitter<AmbulanciasState> emit,
  ) async {
    debugPrint('🚑 AmbulanciasBloc: Creando ambulancia...');
    emit(const AmbulanciasLoading());

    try {
      final ambulancia = await _repository.create(event.ambulancia);
      debugPrint('🚑 AmbulanciasBloc: ✅ Ambulancia creada: ${ambulancia.matricula}');
      emit(AmbulanciaCreated(ambulancia));
    } catch (e) {
      debugPrint('🚑 AmbulanciasBloc: ❌ Error: $e');
      emit(AmbulanciasError(e.toString()));
    }
  }

  Future<void> _onUpdateRequested(
    AmbulanciaUpdateRequested event,
    Emitter<AmbulanciasState> emit,
  ) async {
    debugPrint('🚑 AmbulanciasBloc: Actualizando ambulancia: ${event.ambulancia.id}');
    emit(const AmbulanciasLoading());

    try {
      final ambulancia = await _repository.update(event.ambulancia);
      debugPrint('🚑 AmbulanciasBloc: ✅ Ambulancia actualizada');
      emit(AmbulanciaUpdated(ambulancia));
    } catch (e) {
      debugPrint('🚑 AmbulanciasBloc: ❌ Error: $e');
      emit(AmbulanciasError(e.toString()));
    }
  }

  Future<void> _onDeleteRequested(
    AmbulanciaDeleteRequested event,
    Emitter<AmbulanciasState> emit,
  ) async {
    debugPrint('🚑 AmbulanciasBloc: Eliminando ambulancia: ${event.id}');
    emit(const AmbulanciasLoading());

    try {
      await _repository.delete(event.id);
      debugPrint('🚑 AmbulanciasBloc: ✅ Ambulancia eliminada');
      emit(AmbulanciaDeleted(event.id));
    } catch (e) {
      debugPrint('🚑 AmbulanciasBloc: ❌ Error: $e');
      emit(AmbulanciasError(e.toString()));
    }
  }

  Future<void> _onTiposLoadRequested(
    TiposAmbulanciaLoadRequested event,
    Emitter<AmbulanciasState> emit,
  ) async {
    debugPrint('🚑 AmbulanciasBloc: Cargando tipos de ambulancia...');

    try {
      final tipos = await _repository.getTiposAmbulancia();
      debugPrint('🚑 AmbulanciasBloc: ✅ ${tipos.length} tipos cargados');
      emit(TiposAmbulanciaLoaded(tipos));
    } catch (e) {
      debugPrint('🚑 AmbulanciasBloc: ❌ Error: $e');
      emit(AmbulanciasError(e.toString()));
    }
  }
}
