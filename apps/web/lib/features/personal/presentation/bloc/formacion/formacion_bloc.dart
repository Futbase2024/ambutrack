import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/features/personal/domain/repositories/formacion_personal_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'formacion_event.dart';
import 'formacion_state.dart';

/// BLoC para gestionar el estado de formación personal
@injectable
class FormacionBloc extends Bloc<FormacionEvent, FormacionState> {
  FormacionBloc(this._repository) : super(const FormacionInitial()) {
    on<FormacionLoadRequested>(_onLoadRequested);
    on<FormacionLoadByPersonalRequested>(_onLoadByPersonalRequested);
    on<FormacionLoadVigentesRequested>(_onLoadVigentesRequested);
    on<FormacionLoadProximasVencerRequested>(_onLoadProximasVencerRequested);
    on<FormacionLoadVencidasRequested>(_onLoadVencidasRequested);
    on<FormacionLoadByEstadoRequested>(_onLoadByEstadoRequested);
    on<FormacionCreateRequested>(_onCreateRequested);
    on<FormacionUpdateRequested>(_onUpdateRequested);
    on<FormacionDeleteRequested>(_onDeleteRequested);
  }

  final FormacionPersonalRepository _repository;

  Future<void> _onLoadRequested(
    FormacionLoadRequested event,
    Emitter<FormacionState> emit,
  ) async {
    debugPrint('🎯 FormacionBloc: Cargando todos los registros...');
    emit(const FormacionLoading());

    try {
      final List<FormacionPersonalEntity> items = await _repository.getAll();
      debugPrint('🎯 FormacionBloc: ✅ ${items.length} items cargados');
      emit(FormacionLoaded(items));
    } catch (e) {
      debugPrint('🎯 FormacionBloc: ❌ Error al cargar: $e');
      emit(FormacionError(e.toString()));
    }
  }

  Future<void> _onLoadByPersonalRequested(
    FormacionLoadByPersonalRequested event,
    Emitter<FormacionState> emit,
  ) async {
    debugPrint('🎯 FormacionBloc: Cargando por personal: ${event.personalId}');
    emit(const FormacionLoading());

    try {
      final List<FormacionPersonalEntity> items =
          await _repository.getByPersonalId(event.personalId);
      debugPrint('🎯 FormacionBloc: ✅ ${items.length} items cargados');
      emit(FormacionLoaded(items));
    } catch (e) {
      debugPrint('🎯 FormacionBloc: ❌ Error: $e');
      emit(FormacionError(e.toString()));
    }
  }

  Future<void> _onLoadVigentesRequested(
    FormacionLoadVigentesRequested event,
    Emitter<FormacionState> emit,
  ) async {
    debugPrint('🎯 FormacionBloc: Cargando formación vigente...');
    emit(const FormacionLoading());

    try {
      final List<FormacionPersonalEntity> items = await _repository.getVigentes();
      debugPrint('🎯 FormacionBloc: ✅ ${items.length} items vigentes');
      emit(FormacionLoaded(items));
    } catch (e) {
      debugPrint('🎯 FormacionBloc: ❌ Error: $e');
      emit(FormacionError(e.toString()));
    }
  }

  Future<void> _onLoadProximasVencerRequested(
    FormacionLoadProximasVencerRequested event,
    Emitter<FormacionState> emit,
  ) async {
    debugPrint('🎯 FormacionBloc: Cargando formación próxima a vencer...');
    emit(const FormacionLoading());

    try {
      final List<FormacionPersonalEntity> items = await _repository.getProximasVencer();
      debugPrint('🎯 FormacionBloc: ✅ ${items.length} items próximos a vencer');
      emit(FormacionLoaded(items));
    } catch (e) {
      debugPrint('🎯 FormacionBloc: ❌ Error: $e');
      emit(FormacionError(e.toString()));
    }
  }

  Future<void> _onLoadVencidasRequested(
    FormacionLoadVencidasRequested event,
    Emitter<FormacionState> emit,
  ) async {
    debugPrint('🎯 FormacionBloc: Cargando formación vencida...');
    emit(const FormacionLoading());

    try {
      final List<FormacionPersonalEntity> items = await _repository.getVencidas();
      debugPrint('🎯 FormacionBloc: ✅ ${items.length} items vencidos');
      emit(FormacionLoaded(items));
    } catch (e) {
      debugPrint('🎯 FormacionBloc: ❌ Error: $e');
      emit(FormacionError(e.toString()));
    }
  }

  Future<void> _onLoadByEstadoRequested(
    FormacionLoadByEstadoRequested event,
    Emitter<FormacionState> emit,
  ) async {
    debugPrint('🎯 FormacionBloc: Cargando por estado: ${event.estado}');
    emit(const FormacionLoading());

    try {
      final List<FormacionPersonalEntity> items =
          await _repository.getByEstado(event.estado);
      debugPrint('🎯 FormacionBloc: ✅ ${items.length} items cargados');
      emit(FormacionLoaded(items));
    } catch (e) {
      debugPrint('🎯 FormacionBloc: ❌ Error: $e');
      emit(FormacionError(e.toString()));
    }
  }

  Future<void> _onCreateRequested(
    FormacionCreateRequested event,
    Emitter<FormacionState> emit,
  ) async {
    debugPrint('🎯 FormacionBloc: Creando registro...');
    emit(const FormacionLoading());

    try {
      final FormacionPersonalEntity item = await _repository.create(event.entity);
      debugPrint('🎯 FormacionBloc: ✅ Registro creado: ${item.id}');
      // Recargar todos después de crear
      add(const FormacionLoadRequested());
    } catch (e) {
      debugPrint('🎯 FormacionBloc: ❌ Error al crear: $e');
      emit(FormacionError(e.toString()));
    }
  }

  Future<void> _onUpdateRequested(
    FormacionUpdateRequested event,
    Emitter<FormacionState> emit,
  ) async {
    debugPrint('🎯 FormacionBloc: Actualizando registro...');
    emit(const FormacionLoading());

    try {
      final FormacionPersonalEntity item =
          await _repository.update(event.entity);
      debugPrint('🎯 FormacionBloc: ✅ Registro actualizado: ${item.id}');
      // Recargar todos después de actualizar
      add(const FormacionLoadRequested());
    } catch (e) {
      debugPrint('🎯 FormacionBloc: ❌ Error al actualizar: $e');
      emit(FormacionError(e.toString()));
    }
  }

  Future<void> _onDeleteRequested(
    FormacionDeleteRequested event,
    Emitter<FormacionState> emit,
  ) async {
    debugPrint('🎯 FormacionBloc: Eliminando registro: ${event.id}');
    emit(const FormacionLoading());

    try {
      await _repository.delete(event.id);
      debugPrint('🎯 FormacionBloc: ✅ Registro eliminado');
      // Recargar todos después de eliminar
      add(const FormacionLoadRequested());
    } catch (e) {
      debugPrint('🎯 FormacionBloc: ❌ Error al eliminar: $e');
      emit(FormacionError(e.toString()));
    }
  }
}
