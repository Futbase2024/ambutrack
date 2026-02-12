import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/repositories/paciente_repository.dart';
import 'pacientes_event.dart';
import 'pacientes_state.dart';

/// BLoC para gestionar el estado de Pacientes
@injectable
class PacientesBloc extends Bloc<PacientesEvent, PacientesState> {
  PacientesBloc(this._repository) : super(const PacientesInitial()) {
    on<PacientesLoadRequested>(_onLoadRequested);
    on<PacientesSearchRequested>(_onSearchRequested);
    on<PacientesCreateRequested>(_onCreateRequested);
    on<PacientesUpdateRequested>(_onUpdateRequested);
    on<PacientesDeleteRequested>(_onDeleteRequested);
  }

  final PacienteRepository _repository;

  /// Cargar todos los pacientes
  Future<void> _onLoadRequested(
    PacientesLoadRequested event,
    Emitter<PacientesState> emit,
  ) async {
    try {
      debugPrint('🔵 PacientesBloc: Cargando pacientes...');
      emit(const PacientesLoading());

      final List<PacienteEntity> pacientes = await _repository.getAll();

      debugPrint('🔵 PacientesBloc: ✅ ${pacientes.length} pacientes cargados');
      emit(PacientesLoaded(pacientes));
    } catch (e) {
      debugPrint('🔵 PacientesBloc: ❌ Error: $e');
      emit(PacientesError(e.toString()));
    }
  }

  /// Buscar pacientes por query
  Future<void> _onSearchRequested(
    PacientesSearchRequested event,
    Emitter<PacientesState> emit,
  ) async {
    try {
      debugPrint('🔵 PacientesBloc: Buscando pacientes: "${event.query}"');
      emit(const PacientesLoading());

      final List<PacienteEntity> pacientes = await _repository.search(event.query);

      debugPrint('🔵 PacientesBloc: ✅ ${pacientes.length} pacientes encontrados');
      emit(PacientesLoaded(pacientes));
    } catch (e) {
      debugPrint('🔵 PacientesBloc: ❌ Error en búsqueda: $e');
      emit(PacientesError(e.toString()));
    }
  }

  /// Crear un nuevo paciente
  Future<void> _onCreateRequested(
    PacientesCreateRequested event,
    Emitter<PacientesState> emit,
  ) async {
    try {
      debugPrint('🔵 PacientesBloc: Creando paciente: ${event.paciente.nombreCompleto}');

      await _repository.create(event.paciente);

      debugPrint('🔵 PacientesBloc: ✅ Paciente creado, recargando lista...');

      // Recargar la lista después de crear
      final List<PacienteEntity> pacientes = await _repository.getAll();
      emit(PacientesLoaded(pacientes));
    } catch (e) {
      debugPrint('🔵 PacientesBloc: ❌ Error al crear: $e');
      emit(PacientesError(e.toString()));
    }
  }

  /// Actualizar un paciente existente
  Future<void> _onUpdateRequested(
    PacientesUpdateRequested event,
    Emitter<PacientesState> emit,
  ) async {
    try {
      debugPrint('🔵 PacientesBloc: Actualizando paciente: ${event.paciente.nombreCompleto}');

      await _repository.update(event.paciente);

      debugPrint('🔵 PacientesBloc: ✅ Paciente actualizado, recargando lista...');

      // Recargar la lista después de actualizar
      final List<PacienteEntity> pacientes = await _repository.getAll();
      emit(PacientesLoaded(pacientes));
    } catch (e) {
      debugPrint('🔵 PacientesBloc: ❌ Error al actualizar: $e');
      emit(PacientesError(e.toString()));
    }
  }

  /// Eliminar un paciente
  Future<void> _onDeleteRequested(
    PacientesDeleteRequested event,
    Emitter<PacientesState> emit,
  ) async {
    try {
      debugPrint('🔵 PacientesBloc: Eliminando paciente ID: ${event.id}');

      await _repository.delete(event.id);

      debugPrint('🔵 PacientesBloc: ✅ Paciente eliminado, recargando lista...');

      // Recargar la lista después de eliminar
      final List<PacienteEntity> pacientes = await _repository.getAll();
      emit(PacientesLoaded(pacientes));
    } catch (e) {
      debugPrint('🔵 PacientesBloc: ❌ Error al eliminar: $e');
      emit(PacientesError(e.toString()));
    }
  }
}
