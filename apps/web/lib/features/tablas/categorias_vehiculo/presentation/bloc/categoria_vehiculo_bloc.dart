import 'package:ambutrack_core/ambutrack_core.dart';
import 'package:ambutrack_web/features/tablas/categorias_vehiculo/domain/repositories/categoria_vehiculo_repository.dart';
import 'package:ambutrack_web/features/tablas/categorias_vehiculo/presentation/bloc/categoria_vehiculo_event.dart';
import 'package:ambutrack_web/features/tablas/categorias_vehiculo/presentation/bloc/categoria_vehiculo_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

/// BLoC para gestión de categorías de vehículo
@injectable
class CategoriaVehiculoBloc extends Bloc<CategoriaVehiculoEvent, CategoriaVehiculoState> {
  CategoriaVehiculoBloc(this._repository) : super(const CategoriaVehiculoInitial()) {
    on<CategoriaVehiculoLoadAllRequested>(_onLoadAll);
    on<CategoriaVehiculoCreateRequested>(_onCreate);
    on<CategoriaVehiculoUpdateRequested>(_onUpdate);
    on<CategoriaVehiculoDeleteRequested>(_onDelete);
  }

  final CategoriaVehiculoRepository _repository;

  Future<void> _onLoadAll(
    CategoriaVehiculoLoadAllRequested event,
    Emitter<CategoriaVehiculoState> emit,
  ) async {
    debugPrint('🚀 CategoriaVehiculoBloc: Cargando todas las categorías...');
    emit(const CategoriaVehiculoLoading());

    try {
      final List<CategoriaVehiculoEntity> categorias = await _repository.getAll();
      debugPrint('✅ CategoriaVehiculoBloc: ${categorias.length} categorías cargadas');
      emit(CategoriaVehiculoLoaded(categorias));
    } catch (e) {
      debugPrint('❌ CategoriaVehiculoBloc: Error al cargar categorías: $e');
      emit(CategoriaVehiculoError(e.toString()));
    }
  }

  Future<void> _onCreate(
    CategoriaVehiculoCreateRequested event,
    Emitter<CategoriaVehiculoState> emit,
  ) async {
    debugPrint('🚀 CategoriaVehiculoBloc: Creando categoría...');

    try {
      await _repository.create(event.categoria);
      debugPrint('✅ CategoriaVehiculoBloc: Categoría creada');
      add(const CategoriaVehiculoLoadAllRequested());
    } catch (e) {
      debugPrint('❌ CategoriaVehiculoBloc: Error al crear categoría: $e');
      emit(CategoriaVehiculoError(e.toString()));
    }
  }

  Future<void> _onUpdate(
    CategoriaVehiculoUpdateRequested event,
    Emitter<CategoriaVehiculoState> emit,
  ) async {
    debugPrint('🚀 CategoriaVehiculoBloc: Actualizando categoría...');

    try {
      await _repository.update(event.categoria);
      debugPrint('✅ CategoriaVehiculoBloc: Categoría actualizada');
      add(const CategoriaVehiculoLoadAllRequested());
    } catch (e) {
      debugPrint('❌ CategoriaVehiculoBloc: Error al actualizar categoría: $e');
      emit(CategoriaVehiculoError(e.toString()));
    }
  }

  Future<void> _onDelete(
    CategoriaVehiculoDeleteRequested event,
    Emitter<CategoriaVehiculoState> emit,
  ) async {
    debugPrint('🚀 CategoriaVehiculoBloc: Eliminando categoría...');

    try {
      await _repository.delete(event.id);
      debugPrint('✅ CategoriaVehiculoBloc: Categoría eliminada');
      add(const CategoriaVehiculoLoadAllRequested());
    } catch (e) {
      debugPrint('❌ CategoriaVehiculoBloc: Error al eliminar categoría: $e');
      emit(CategoriaVehiculoError(e.toString()));
    }
  }
}
