import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/features/cuadrante/bases/domain/repositories/bases_repository.dart';
import 'package:ambutrack_web/features/cuadrante/bases/presentation/bloc/bases_event.dart';
import 'package:ambutrack_web/features/cuadrante/bases/presentation/bloc/bases_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

/// BLoC para la gestión de Bases/Centros Operativos
@injectable
class BasesBloc extends Bloc<BasesEvent, BasesState> {
  BasesBloc(this._basesRepository) : super(const BasesInitial()) {
    on<BasesLoadRequested>(_onLoadRequested);
    on<BaseCreateRequested>(_onCreateRequested);
    on<BaseUpdateRequested>(_onUpdateRequested);
    on<BaseDeactivateRequested>(_onDeactivateRequested);
    on<BaseReactivateRequested>(_onReactivateRequested);
  }

  final BasesRepository _basesRepository;

  // ==================== CARGA ====================

  Future<void> _onLoadRequested(
    BasesLoadRequested event,
    Emitter<BasesState> emit,
  ) async {
    debugPrint('🚀 BasesBloc: Cargando bases...');
    emit(const BasesLoading());

    try {
      final List<BaseCentroEntity> bases = await _basesRepository.getAll();
      debugPrint('✅ BasesBloc: ${bases.length} bases cargadas');
      emit(BasesLoaded(bases));
    } catch (e) {
      debugPrint('❌ BasesBloc: Error al cargar bases - $e');
      emit(BasesError('Error al cargar bases: $e'));
    }
  }

  // ==================== CRUD ====================

  Future<void> _onCreateRequested(
    BaseCreateRequested event,
    Emitter<BasesState> emit,
  ) async {
    debugPrint('🚀 BasesBloc: Creando base "${event.base.nombre}"...');

    try {
      await _basesRepository.create(event.base);
      debugPrint('✅ BasesBloc: Base "${event.base.nombre}" creada');
      add(const BasesLoadRequested());
    } catch (e) {
      debugPrint('❌ BasesBloc: Error al crear base - $e');
      emit(BasesError('Error al crear base: $e'));
    }
  }

  Future<void> _onUpdateRequested(
    BaseUpdateRequested event,
    Emitter<BasesState> emit,
  ) async {
    debugPrint('🚀 BasesBloc: Actualizando base "${event.base.nombre}"...');

    try {
      await _basesRepository.update(event.base);
      debugPrint('✅ BasesBloc: Base "${event.base.nombre}" actualizada');
      add(const BasesLoadRequested());
    } catch (e) {
      debugPrint('❌ BasesBloc: Error al actualizar base - $e');
      emit(BasesError('Error al actualizar base: $e'));
    }
  }

  Future<void> _onDeactivateRequested(
    BaseDeactivateRequested event,
    Emitter<BasesState> emit,
  ) async {
    debugPrint('🚀 BasesBloc: Desactivando base ${event.baseId}...');

    try {
      await _basesRepository.deactivateBase(event.baseId);
      debugPrint('✅ BasesBloc: Base desactivada');
      add(const BasesLoadRequested());
    } catch (e) {
      debugPrint('❌ BasesBloc: Error al desactivar base - $e');
      emit(BasesError('Error al desactivar base: $e'));
    }
  }

  Future<void> _onReactivateRequested(
    BaseReactivateRequested event,
    Emitter<BasesState> emit,
  ) async {
    debugPrint('🚀 BasesBloc: Reactivando base ${event.baseId}...');

    try {
      await _basesRepository.reactivateBase(event.baseId);
      debugPrint('✅ BasesBloc: Base reactivada');
      add(const BasesLoadRequested());
    } catch (e) {
      debugPrint('❌ BasesBloc: Error al reactivar base - $e');
      emit(BasesError('Error al reactivar base: $e'));
    }
  }
}
