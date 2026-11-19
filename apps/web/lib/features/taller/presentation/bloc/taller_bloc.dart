import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/features/taller/domain/repositories/taller_repository.dart';
import 'package:ambutrack_web/features/taller/presentation/bloc/taller_event.dart';
import 'package:ambutrack_web/features/taller/presentation/bloc/taller_state.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

/// BLoC para gestión del catálogo de Talleres
@injectable
class TallerBloc extends Bloc<TallerEvent, TallerState> {
  TallerBloc(this._repository) : super(const TallerInitial()) {
    on<TallerLoadRequested>(_onLoadRequested);
    on<TallerCreateRequested>(_onCreateRequested);
    on<TallerUpdateRequested>(_onUpdateRequested);
    on<TallerDeleteRequested>(_onDeleteRequested);
  }

  final TallerRepository _repository;

  Future<void> _onLoadRequested(
    TallerLoadRequested event,
    Emitter<TallerState> emit,
  ) async {
    debugPrint('🔧 TallerBloc: Cargando talleres');
    emit(const TallerLoading());

    final Either<Exception, List<TallerEntity>> result =
        await _repository.getAll();

    result.fold(
      (Exception exception) {
        debugPrint('❌ TallerBloc Error: $exception');
        emit(TallerError(message: exception.toString()));
      },
      (List<TallerEntity> talleres) {
        debugPrint(
          '✅ TallerBloc: ${talleres.length} talleres cargados',
        );
        emit(TallerLoaded(talleres: talleres));
      },
    );
  }

  Future<void> _onCreateRequested(
    TallerCreateRequested event,
    Emitter<TallerState> emit,
  ) async {
    debugPrint('🔧 TallerBloc: Creando taller "${event.taller.nombre}"');
    emit(const TallerLoading());

    final Either<Exception, TallerEntity> result =
        await _repository.create(event.taller);

    result.fold(
      (Exception exception) {
        debugPrint('❌ TallerBloc Error: $exception');
        emit(TallerError(message: exception.toString()));
      },
      (TallerEntity taller) {
        debugPrint('✅ TallerBloc: Taller creado ID ${taller.id}');
        if (!isClosed) {
          add(const TallerLoadRequested());
        }
      },
    );
  }

  Future<void> _onUpdateRequested(
    TallerUpdateRequested event,
    Emitter<TallerState> emit,
  ) async {
    debugPrint('🔧 TallerBloc: Actualizando taller ${event.taller.id}');
    emit(const TallerLoading());

    final Either<Exception, TallerEntity> result =
        await _repository.update(event.taller);

    result.fold(
      (Exception exception) {
        debugPrint('❌ TallerBloc Error: $exception');
        emit(TallerError(message: exception.toString()));
      },
      (TallerEntity taller) {
        debugPrint('✅ TallerBloc: Taller actualizado');
        if (!isClosed) {
          add(const TallerLoadRequested());
        }
      },
    );
  }

  Future<void> _onDeleteRequested(
    TallerDeleteRequested event,
    Emitter<TallerState> emit,
  ) async {
    debugPrint('🔧 TallerBloc: Eliminando taller ${event.id}');
    emit(const TallerLoading());

    final Either<Exception, void> result = await _repository.delete(event.id);

    result.fold(
      (Exception exception) {
        debugPrint('❌ TallerBloc Error: $exception');
        emit(TallerError(message: exception.toString()));
      },
      (_) {
        debugPrint('✅ TallerBloc: Taller eliminado');
        if (!isClosed) {
          add(const TallerLoadRequested());
        }
      },
    );
  }
}
