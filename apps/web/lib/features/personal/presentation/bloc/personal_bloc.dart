import 'package:ambutrack_web/features/personal/domain/entities/personal_entity.dart';
import 'package:ambutrack_web/features/personal/domain/repositories/personal_repository.dart';
import 'package:ambutrack_web/features/personal/presentation/bloc/personal_event.dart';
import 'package:ambutrack_web/features/personal/presentation/bloc/personal_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

/// BLoC para gestionar el estado de personal
@injectable
class PersonalBloc extends Bloc<PersonalEvent, PersonalState> {
  PersonalBloc(this._personalRepository) : super(const PersonalInitial()) {
    on<PersonalLoadRequested>(_onLoadRequested);
    on<PersonalRefreshRequested>(_onRefreshRequested);
    on<PersonalCreateRequested>(_onCreateRequested);
    on<PersonalUpdateRequested>(_onUpdateRequested);
    on<PersonalDeleteRequested>(_onDeleteRequested);
  }

  final PersonalRepository _personalRepository;

  Future<void> _onLoadRequested(
    PersonalLoadRequested event,
    Emitter<PersonalState> emit,
  ) async {
    final DateTime startTime = DateTime.now();
    debugPrint('👥 PersonalBloc: Iniciando carga de personal...');

    emit(const PersonalLoading());

    try {
      final List<PersonalEntity> personal = await _personalRepository.getAll();

      final Duration elapsed = DateTime.now().difference(startTime);
      debugPrint('⏱️ Tiempo de carga BLoC: ${elapsed.inMilliseconds}ms');

      emit(PersonalLoaded(
        personal: personal,
        total: personal.length,
        enServicio: 0,
        disponibles: 0,
        ausentes: 0,
      ));
    } on Exception catch (e) {
      emit(PersonalError(message: e.toString()));
    }
  }

  Future<void> _onRefreshRequested(
    PersonalRefreshRequested event,
    Emitter<PersonalState> emit,
  ) async {
    try {
      final List<PersonalEntity> personal = await _personalRepository.getAll();

      emit(PersonalLoaded(
        personal: personal,
        total: personal.length,
        enServicio: 0,
        disponibles: 0,
        ausentes: 0,
      ));
    } on Exception catch (e) {
      emit(PersonalError(message: e.toString()));
    }
  }

  Future<void> _onCreateRequested(
    PersonalCreateRequested event,
    Emitter<PersonalState> emit,
  ) async {
    try {
      final DateTime startTime = DateTime.now();
      debugPrint('⏱️ PersonalBloc: Iniciando creación de personal...');

      final DateTime t1 = DateTime.now();
      await _personalRepository.create(event.persona);
      debugPrint('⏱️ PersonalBloc: Create completado en ${DateTime.now().difference(t1).inMilliseconds}ms');

      final DateTime t2 = DateTime.now();
      final List<PersonalEntity> personal = await _personalRepository.getAll();
      debugPrint('⏱️ PersonalBloc: GetAll completado en ${DateTime.now().difference(t2).inMilliseconds}ms');

      emit(PersonalLoaded(
        personal: personal,
        total: personal.length,
        enServicio: 0,
        disponibles: 0,
        ausentes: 0,
      ));

      final Duration totalTime = DateTime.now().difference(startTime);
      debugPrint('⏱️ PersonalBloc: ✅ TOTAL creación: ${totalTime.inMilliseconds}ms');
    } on Exception catch (e) {
      debugPrint('❌ PersonalBloc: Error al crear personal - $e');
      emit(PersonalError(message: e.toString()));
    }
  }

  Future<void> _onUpdateRequested(
    PersonalUpdateRequested event,
    Emitter<PersonalState> emit,
  ) async {
    try {
      final DateTime startTime = DateTime.now();
      debugPrint('⏱️ PersonalBloc: Iniciando actualización de personal...');

      final DateTime t1 = DateTime.now();
      await _personalRepository.update(event.persona);
      debugPrint('⏱️ PersonalBloc: Update completado en ${DateTime.now().difference(t1).inMilliseconds}ms');

      final DateTime t2 = DateTime.now();
      final List<PersonalEntity> personal = await _personalRepository.getAll();
      debugPrint('⏱️ PersonalBloc: GetAll completado en ${DateTime.now().difference(t2).inMilliseconds}ms');

      emit(PersonalLoaded(
        personal: personal,
        total: personal.length,
        enServicio: 0,
        disponibles: 0,
        ausentes: 0,
      ));

      final Duration totalTime = DateTime.now().difference(startTime);
      debugPrint('⏱️ PersonalBloc: ✅ TOTAL actualización: ${totalTime.inMilliseconds}ms');
    } on Exception catch (e) {
      debugPrint('❌ PersonalBloc: Error al actualizar personal - $e');
      emit(PersonalError(message: e.toString()));
    }
  }

  Future<void> _onDeleteRequested(
    PersonalDeleteRequested event,
    Emitter<PersonalState> emit,
  ) async {
    // NO emitir PersonalLoading para evitar que se desmonte el widget
    // El loading se maneja en la UI con un diálogo

    try {
      final DateTime startTime = DateTime.now();
      debugPrint('⏱️ PersonalBloc: Iniciando eliminación de personal...');

      final DateTime t1 = DateTime.now();
      await _personalRepository.delete(event.id);
      debugPrint('⏱️ PersonalBloc: Delete completado en ${DateTime.now().difference(t1).inMilliseconds}ms');

      final DateTime t2 = DateTime.now();
      final List<PersonalEntity> personal = await _personalRepository.getAll();
      debugPrint('⏱️ PersonalBloc: GetAll completado en ${DateTime.now().difference(t2).inMilliseconds}ms');

      emit(PersonalLoaded(
        personal: personal,
        total: personal.length,
        enServicio: 0,
        disponibles: 0,
        ausentes: 0,
      ));

      final Duration totalTime = DateTime.now().difference(startTime);
      debugPrint('⏱️ PersonalBloc: ✅ TOTAL eliminación: ${totalTime.inMilliseconds}ms');
    } on Exception catch (e) {
      debugPrint('❌ PersonalBloc: Error al eliminar personal - $e');
      emit(PersonalError(message: e.toString()));
    }
  }
}
