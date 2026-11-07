import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/features/taller/domain/repositories/orden_reparacion_repository.dart';
import 'package:ambutrack_web/features/taller/presentation/bloc/orden_reparacion_event.dart';
import 'package:ambutrack_web/features/taller/presentation/bloc/orden_reparacion_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

/// BLoC de Órdenes de Reparación
@injectable
class OrdenReparacionBloc extends Bloc<OrdenReparacionEvent, OrdenReparacionState> {
  OrdenReparacionBloc(this._repository) : super(const OrdenReparacionInitial()) {
    on<OrdenReparacionLoadRequested>(_onLoad);
    on<OrdenReparacionCreateRequested>(
      (OrdenReparacionCreateRequested e, Emitter<OrdenReparacionState> emit) =>
          _runOperation(emit, OrdenOperacion.crear, () => _repository.create(e.orden)),
    );
    on<OrdenReparacionUpdateRequested>(
      (OrdenReparacionUpdateRequested e, Emitter<OrdenReparacionState> emit) =>
          _runOperation(emit, OrdenOperacion.actualizar, () => _repository.update(e.orden)),
    );
    on<OrdenReparacionDeleteRequested>(
      (OrdenReparacionDeleteRequested e, Emitter<OrdenReparacionState> emit) =>
          _runOperation(emit, OrdenOperacion.eliminar, () => _repository.delete(e.id)),
    );
    on<OrdenReparacionEstadoChangeRequested>(
      (OrdenReparacionEstadoChangeRequested e, Emitter<OrdenReparacionState> emit) =>
          _runOperation(emit, OrdenOperacion.cambiarEstado, () => _repository.cambiarEstado(e.id, e.estado)),
    );
  }

  final OrdenReparacionRepository _repository;

  List<OrdenReparacionEntity> get _currentOrdenes {
    final OrdenReparacionState s = state;
    return s is OrdenReparacionLoaded ? s.ordenes : <OrdenReparacionEntity>[];
  }

  Future<void> _onLoad(OrdenReparacionLoadRequested event, Emitter<OrdenReparacionState> emit) async {
    debugPrint('🔧 OrdenReparacionBloc: Cargando órdenes (silent: ${event.silent})');
    if (!event.silent || state is! OrdenReparacionLoaded) {
      emit(const OrdenReparacionLoading());
    }
    try {
      final List<OrdenReparacionEntity> ordenes = await _repository.getAll();
      debugPrint('✅ OrdenReparacionBloc: ${ordenes.length} órdenes cargadas');
      emit(OrdenReparacionLoaded(ordenes: ordenes));
    } catch (e) {
      debugPrint('❌ OrdenReparacionBloc: Error al cargar: $e');
      emit(OrdenReparacionError(message: e.toString()));
    }
  }

  /// Ejecuta una operación y, si va bien, recarga el listado y emite éxito
  Future<void> _runOperation(
    Emitter<OrdenReparacionState> emit,
    OrdenOperacion operacion,
    Future<Object?> Function() action,
  ) async {
    debugPrint('🔧 OrdenReparacionBloc: Operación ${operacion.name}');
    try {
      await action();
      final List<OrdenReparacionEntity> ordenes = await _repository.getAll();
      debugPrint('✅ OrdenReparacionBloc: ${operacion.name} completada');
      emit(OrdenReparacionOperationSuccess(ordenes: ordenes, operacion: operacion));
    } catch (e) {
      debugPrint('❌ OrdenReparacionBloc: Error en ${operacion.name}: $e');
      emit(OrdenReparacionOperationFailure(ordenes: _currentOrdenes, operacion: operacion, message: e.toString()));
    }
  }
}
