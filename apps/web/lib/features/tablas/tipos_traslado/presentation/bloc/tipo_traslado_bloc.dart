import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/features/tablas/tipos_traslado/domain/repositories/tipo_traslado_repository.dart';
import 'package:ambutrack_web/features/tablas/tipos_traslado/presentation/bloc/tipo_traslado_event.dart';
import 'package:ambutrack_web/features/tablas/tipos_traslado/presentation/bloc/tipo_traslado_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

/// BLoC para gestionar tipos de traslado
@injectable
class TipoTrasladoBloc extends Bloc<TipoTrasladoEvent, TipoTrasladoState> {
  TipoTrasladoBloc(this._repository) : super(const TipoTrasladoInitial()) {
    on<TipoTrasladoLoadRequested>(_onLoadRequested);
    on<TipoTrasladoCreateRequested>(_onCreateRequested);
    on<TipoTrasladoUpdateRequested>(_onUpdateRequested);
    on<TipoTrasladoDeleteRequested>(_onDeleteRequested);
  }

  final TipoTrasladoRepository _repository;

  Future<void> _onLoadRequested(
    TipoTrasladoLoadRequested event,
    Emitter<TipoTrasladoState> emit,
  ) async {
    try {
      debugPrint('🔄 TipoTrasladoBloc: Cargando tipos de traslado...');
      emit(const TipoTrasladoLoading());

      final List<TipoTrasladoEntity> tipos = await _repository.getAll();

      debugPrint('✅ TipoTrasladoBloc: ${tipos.length} tipos cargados');
      emit(TipoTrasladoLoaded(tipos));
    } catch (e, stackTrace) {
      debugPrint('❌ TipoTrasladoBloc: Error al cargar tipos: $e');
      debugPrint('Stack trace: $stackTrace');
      emit(TipoTrasladoError('Error al cargar tipos de traslado: $e'));
    }
  }

  Future<void> _onCreateRequested(
    TipoTrasladoCreateRequested event,
    Emitter<TipoTrasladoState> emit,
  ) async {
    try {
      debugPrint('🔄 TipoTrasladoBloc: Creando tipo: ${event.tipo.nombre}');

      await _repository.create(event.tipo);

      debugPrint('✅ TipoTrasladoBloc: Tipo creado, recargando lista...');
      add(const TipoTrasladoLoadRequested());
    } catch (e, stackTrace) {
      debugPrint('❌ TipoTrasladoBloc: Error al crear tipo: $e');
      debugPrint('Stack trace: $stackTrace');
      emit(TipoTrasladoError('Error al crear tipo de traslado: $e'));
    }
  }

  Future<void> _onUpdateRequested(
    TipoTrasladoUpdateRequested event,
    Emitter<TipoTrasladoState> emit,
  ) async {
    try {
      debugPrint('🔄 TipoTrasladoBloc: Actualizando tipo: ${event.tipo.nombre}');

      await _repository.update(event.tipo);

      debugPrint('✅ TipoTrasladoBloc: Tipo actualizado, recargando lista...');
      add(const TipoTrasladoLoadRequested());
    } catch (e, stackTrace) {
      debugPrint('❌ TipoTrasladoBloc: Error al actualizar tipo: $e');
      debugPrint('Stack trace: $stackTrace');
      emit(TipoTrasladoError('Error al actualizar tipo de traslado: $e'));
    }
  }

  Future<void> _onDeleteRequested(
    TipoTrasladoDeleteRequested event,
    Emitter<TipoTrasladoState> emit,
  ) async {
    try {
      debugPrint('🔄 TipoTrasladoBloc: Eliminando tipo con id=${event.id}');

      await _repository.delete(event.id);

      debugPrint('✅ TipoTrasladoBloc: Tipo eliminado, recargando lista...');
      add(const TipoTrasladoLoadRequested());
    } catch (e, stackTrace) {
      debugPrint('❌ TipoTrasladoBloc: Error al eliminar tipo: $e');
      debugPrint('Stack trace: $stackTrace');
      emit(TipoTrasladoError('Error al eliminar tipo de traslado: $e'));
    }
  }
}
