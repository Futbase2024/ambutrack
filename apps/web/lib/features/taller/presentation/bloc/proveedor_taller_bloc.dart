import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/features/taller/domain/repositories/proveedor_taller_repository.dart';
import 'package:ambutrack_web/features/taller/presentation/bloc/proveedor_taller_event.dart';
import 'package:ambutrack_web/features/taller/presentation/bloc/proveedor_taller_state.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

/// BLoC para gestión del catálogo de Proveedores de Taller
@injectable
class ProveedorTallerBloc
    extends Bloc<ProveedorTallerEvent, ProveedorTallerState> {
  ProveedorTallerBloc(this._repository)
      : super(const ProveedorTallerInitial()) {
    on<ProveedorTallerLoadRequested>(_onLoadRequested);
    on<ProveedorTallerCreateRequested>(_onCreateRequested);
    on<ProveedorTallerUpdateRequested>(_onUpdateRequested);
    on<ProveedorTallerDeleteRequested>(_onDeleteRequested);
  }

  final ProveedorTallerRepository _repository;

  Future<void> _onLoadRequested(
    ProveedorTallerLoadRequested event,
    Emitter<ProveedorTallerState> emit,
  ) async {
    debugPrint('🔧 ProveedorTallerBloc: Cargando proveedores');
    emit(const ProveedorTallerLoading());

    final Either<Exception, List<ProveedorTallerEntity>> result =
        await _repository.getAll();

    result.fold(
      (Exception exception) {
        debugPrint('❌ ProveedorTallerBloc Error: $exception');
        emit(ProveedorTallerError(message: exception.toString()));
      },
      (List<ProveedorTallerEntity> proveedores) {
        debugPrint(
          '✅ ProveedorTallerBloc: ${proveedores.length} proveedores',
        );
        emit(ProveedorTallerLoaded(proveedores: proveedores));
      },
    );
  }

  Future<void> _onCreateRequested(
    ProveedorTallerCreateRequested event,
    Emitter<ProveedorTallerState> emit,
  ) async {
    debugPrint(
      '🔧 ProveedorTallerBloc: Creando "${event.proveedor.nombre}"',
    );
    emit(const ProveedorTallerLoading());

    final Either<Exception, ProveedorTallerEntity> result =
        await _repository.create(event.proveedor);

    result.fold(
      (Exception exception) {
        debugPrint('❌ ProveedorTallerBloc Error: $exception');
        emit(ProveedorTallerError(message: exception.toString()));
      },
      (ProveedorTallerEntity proveedor) {
        debugPrint('✅ ProveedorTallerBloc: Creado ID ${proveedor.id}');
        if (!isClosed) {
          add(const ProveedorTallerLoadRequested());
        }
      },
    );
  }

  Future<void> _onUpdateRequested(
    ProveedorTallerUpdateRequested event,
    Emitter<ProveedorTallerState> emit,
  ) async {
    debugPrint(
      '🔧 ProveedorTallerBloc: Actualizando ${event.proveedor.id}',
    );
    emit(const ProveedorTallerLoading());

    final Either<Exception, ProveedorTallerEntity> result =
        await _repository.update(event.proveedor);

    result.fold(
      (Exception exception) {
        debugPrint('❌ ProveedorTallerBloc Error: $exception');
        emit(ProveedorTallerError(message: exception.toString()));
      },
      (ProveedorTallerEntity proveedor) {
        debugPrint('✅ ProveedorTallerBloc: Actualizado');
        if (!isClosed) {
          add(const ProveedorTallerLoadRequested());
        }
      },
    );
  }

  Future<void> _onDeleteRequested(
    ProveedorTallerDeleteRequested event,
    Emitter<ProveedorTallerState> emit,
  ) async {
    debugPrint('🔧 ProveedorTallerBloc: Eliminando ${event.id}');
    emit(const ProveedorTallerLoading());

    final Either<Exception, void> result =
        await _repository.delete(event.id);

    result.fold(
      (Exception exception) {
        debugPrint('❌ ProveedorTallerBloc Error: $exception');
        emit(ProveedorTallerError(message: exception.toString()));
      },
      (_) {
        debugPrint('✅ ProveedorTallerBloc: Eliminado');
        if (!isClosed) {
          add(const ProveedorTallerLoadRequested());
        }
      },
    );
  }
}
