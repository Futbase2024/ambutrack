import 'package:ambutrack_core/ambutrack_core.dart';
import 'package:ambutrack_web/features/stock_vestuario/domain/repositories/stock_vestuario_repository.dart';
import 'package:ambutrack_web/features/stock_vestuario/presentation/bloc/stock_vestuario_event.dart';
import 'package:ambutrack_web/features/stock_vestuario/presentation/bloc/stock_vestuario_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

/// BLoC para gestión de Stock de Vestuario
@injectable
class StockVestuarioBloc extends Bloc<StockVestuarioEvent, StockVestuarioState> {
  StockVestuarioBloc(this._repository) : super(const StockVestuarioInitial()) {
    on<StockVestuarioLoadRequested>(_onLoadRequested);
    on<StockVestuarioCreateRequested>(_onCreateRequested);
    on<StockVestuarioUpdateRequested>(_onUpdateRequested);
    on<StockVestuarioDeleteRequested>(_onDeleteRequested);
    on<StockVestuarioLoadStockBajoRequested>(_onLoadStockBajoRequested);
    on<StockVestuarioLoadDisponiblesRequested>(_onLoadDisponiblesRequested);
    on<StockVestuarioIncrementarAsignadaRequested>(_onIncrementarAsignadaRequested);
    on<StockVestuarioDecrementarAsignadaRequested>(_onDecrementarAsignadaRequested);
  }

  final StockVestuarioRepository _repository;

  /// Cargar todos los items de stock
  Future<void> _onLoadRequested(
    StockVestuarioLoadRequested event,
    Emitter<StockVestuarioState> emit,
  ) async {
    debugPrint('📦 StockVestuarioBloc: Cargando todos los items...');
    emit(const StockVestuarioLoading());

    try {
      final List<StockVestuarioEntity> items = await _repository.getAll();
      debugPrint('📦 StockVestuarioBloc: ✅ ${items.length} items cargados');
      emit(StockVestuarioLoaded(items));
    } catch (e) {
      debugPrint('📦 StockVestuarioBloc: ❌ Error al cargar: $e');
      emit(StockVestuarioError(e.toString()));
    }
  }

  /// Crear nuevo item de stock
  Future<void> _onCreateRequested(
    StockVestuarioCreateRequested event,
    Emitter<StockVestuarioState> emit,
  ) async {
    debugPrint('📦 StockVestuarioBloc: Creando item: ${event.item.prenda}');

    try {
      await _repository.create(event.item);
      debugPrint('📦 StockVestuarioBloc: ✅ Item creado exitosamente');

      // Recargar lista completa
      final List<StockVestuarioEntity> items = await _repository.getAll();
      emit(StockVestuarioLoaded(items));
    } catch (e) {
      debugPrint('📦 StockVestuarioBloc: ❌ Error al crear: $e');
      emit(StockVestuarioError(e.toString()));
    }
  }

  /// Actualizar item de stock
  Future<void> _onUpdateRequested(
    StockVestuarioUpdateRequested event,
    Emitter<StockVestuarioState> emit,
  ) async {
    debugPrint('📦 StockVestuarioBloc: Actualizando item: ${event.item.id}');

    try {
      await _repository.update(event.item);
      debugPrint('📦 StockVestuarioBloc: ✅ Item actualizado exitosamente');

      // Recargar lista completa
      final List<StockVestuarioEntity> items = await _repository.getAll();
      emit(StockVestuarioLoaded(items));
    } catch (e) {
      debugPrint('📦 StockVestuarioBloc: ❌ Error al actualizar: $e');
      emit(StockVestuarioError(e.toString()));
    }
  }

  /// Eliminar item de stock
  Future<void> _onDeleteRequested(
    StockVestuarioDeleteRequested event,
    Emitter<StockVestuarioState> emit,
  ) async {
    debugPrint('📦 StockVestuarioBloc: Eliminando item: ${event.id}');

    try {
      await _repository.delete(event.id);
      debugPrint('📦 StockVestuarioBloc: ✅ Item eliminado exitosamente');

      // Recargar lista completa
      final List<StockVestuarioEntity> items = await _repository.getAll();
      emit(StockVestuarioLoaded(items));
    } catch (e) {
      debugPrint('📦 StockVestuarioBloc: ❌ Error al eliminar: $e');
      emit(StockVestuarioError(e.toString()));
    }
  }

  /// Cargar items con stock bajo
  Future<void> _onLoadStockBajoRequested(
    StockVestuarioLoadStockBajoRequested event,
    Emitter<StockVestuarioState> emit,
  ) async {
    debugPrint('📦 StockVestuarioBloc: Cargando items con stock bajo...');
    emit(const StockVestuarioLoading());

    try {
      final List<StockVestuarioEntity> items = await _repository.getStockBajo();
      debugPrint('📦 StockVestuarioBloc: ✅ ${items.length} items con stock bajo');
      emit(StockVestuarioLoaded(items));
    } catch (e) {
      debugPrint('📦 StockVestuarioBloc: ❌ Error: $e');
      emit(StockVestuarioError(e.toString()));
    }
  }

  /// Cargar items disponibles
  Future<void> _onLoadDisponiblesRequested(
    StockVestuarioLoadDisponiblesRequested event,
    Emitter<StockVestuarioState> emit,
  ) async {
    debugPrint('📦 StockVestuarioBloc: Cargando items disponibles...');
    emit(const StockVestuarioLoading());

    try {
      final List<StockVestuarioEntity> items = await _repository.getDisponibles();
      debugPrint('📦 StockVestuarioBloc: ✅ ${items.length} items disponibles');
      emit(StockVestuarioLoaded(items));
    } catch (e) {
      debugPrint('📦 StockVestuarioBloc: ❌ Error: $e');
      emit(StockVestuarioError(e.toString()));
    }
  }

  /// Incrementar cantidad asignada
  Future<void> _onIncrementarAsignadaRequested(
    StockVestuarioIncrementarAsignadaRequested event,
    Emitter<StockVestuarioState> emit,
  ) async {
    debugPrint('📦 StockVestuarioBloc: Incrementando asignada +${event.cantidad} en ${event.id}');

    try {
      await _repository.incrementarAsignada(event.id, event.cantidad);
      debugPrint('📦 StockVestuarioBloc: ✅ Cantidad incrementada');

      // Recargar lista completa
      final List<StockVestuarioEntity> items = await _repository.getAll();
      emit(StockVestuarioLoaded(items));
    } catch (e) {
      debugPrint('📦 StockVestuarioBloc: ❌ Error: $e');
      emit(StockVestuarioError(e.toString()));
    }
  }

  /// Decrementar cantidad asignada
  Future<void> _onDecrementarAsignadaRequested(
    StockVestuarioDecrementarAsignadaRequested event,
    Emitter<StockVestuarioState> emit,
  ) async {
    debugPrint('📦 StockVestuarioBloc: Decrementando asignada -${event.cantidad} en ${event.id}');

    try {
      await _repository.decrementarAsignada(event.id, event.cantidad);
      debugPrint('📦 StockVestuarioBloc: ✅ Cantidad decrementada');

      // Recargar lista completa
      final List<StockVestuarioEntity> items = await _repository.getAll();
      emit(StockVestuarioLoaded(items));
    } catch (e) {
      debugPrint('📦 StockVestuarioBloc: ❌ Error: $e');
      emit(StockVestuarioError(e.toString()));
    }
  }
}
