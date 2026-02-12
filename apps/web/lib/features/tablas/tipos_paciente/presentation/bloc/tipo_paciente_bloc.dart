import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/features/tablas/tipos_paciente/domain/repositories/tipo_paciente_repository.dart';
import 'package:ambutrack_web/features/tablas/tipos_paciente/presentation/bloc/tipo_paciente_event.dart';
import 'package:ambutrack_web/features/tablas/tipos_paciente/presentation/bloc/tipo_paciente_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

/// BLoC para la gestión de tipos de paciente
@injectable
class TipoPacienteBloc extends Bloc<TipoPacienteEvent, TipoPacienteState> {
  /// Constructor
  TipoPacienteBloc(this._repository) : super(const TipoPacienteInitial()) {
    on<TipoPacienteLoadRequested>(_onLoadRequested);
    on<TipoPacienteCreateRequested>(_onCreateRequested);
    on<TipoPacienteUpdateRequested>(_onUpdateRequested);
    on<TipoPacienteDeleteRequested>(_onDeleteRequested);
  }

  final TipoPacienteRepository _repository;

  Future<void> _onLoadRequested(
    TipoPacienteLoadRequested event,
    Emitter<TipoPacienteState> emit,
  ) async {
    try {
      emit(const TipoPacienteLoading());
      final List<TipoPacienteEntity> tiposPaciente = await _repository.getAll();
      emit(TipoPacienteLoaded(tiposPaciente));
    } catch (e) {
      debugPrint('❌ Error al cargar tipos de paciente: $e');
      emit(TipoPacienteError('Error al cargar tipos de paciente: $e'));
    }
  }

  Future<void> _onCreateRequested(
    TipoPacienteCreateRequested event,
    Emitter<TipoPacienteState> emit,
  ) async {
    try {
      await _repository.create(event.tipoPaciente);
      debugPrint('✅ Tipo de paciente creado: ${event.tipoPaciente.nombre}');
      add(const TipoPacienteLoadRequested());
    } catch (e) {
      debugPrint('❌ Error al crear tipo de paciente: $e');
      emit(TipoPacienteError('Error al crear tipo de paciente: $e'));
    }
  }

  Future<void> _onUpdateRequested(
    TipoPacienteUpdateRequested event,
    Emitter<TipoPacienteState> emit,
  ) async {
    try {
      await _repository.update(event.tipoPaciente);
      debugPrint('✅ Tipo de paciente actualizado: ${event.tipoPaciente.nombre}');
      add(const TipoPacienteLoadRequested());
    } catch (e) {
      debugPrint('❌ Error al actualizar tipo de paciente: $e');
      emit(TipoPacienteError('Error al actualizar tipo de paciente: $e'));
    }
  }

  Future<void> _onDeleteRequested(
    TipoPacienteDeleteRequested event,
    Emitter<TipoPacienteState> emit,
  ) async {
    try {
      await _repository.delete(event.id);
      debugPrint('✅ Tipo de paciente eliminado: ${event.id}');
      add(const TipoPacienteLoadRequested());
    } catch (e) {
      debugPrint('❌ Error al eliminar tipo de paciente: $e');
      emit(TipoPacienteError('Error al eliminar tipo de paciente: $e'));
    }
  }
}
