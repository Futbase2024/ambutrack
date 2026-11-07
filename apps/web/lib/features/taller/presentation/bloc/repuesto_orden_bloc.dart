import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/features/taller/domain/repositories/orden_reparacion_repository.dart';
import 'package:ambutrack_web/features/taller/presentation/bloc/repuesto_orden_event.dart';
import 'package:ambutrack_web/features/taller/presentation/bloc/repuesto_orden_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

/// BLoC de repuestos de una orden de reparación
@injectable
class RepuestoOrdenBloc extends Bloc<RepuestoOrdenEvent, RepuestoOrdenState> {
  RepuestoOrdenBloc(this._repository) : super(const RepuestoOrdenInitial()) {
    on<RepuestoOrdenLoadRequested>(_onLoad);
    on<RepuestoOrdenCreateRequested>(
      (RepuestoOrdenCreateRequested e, Emitter<RepuestoOrdenState> emit) => _runOperation(
        emit,
        RepuestoOperacion.crear,
        e.repuesto.ordenId,
        () => _repository.createRepuesto(e.repuesto),
      ),
    );
    on<RepuestoOrdenUpdateRequested>(
      (RepuestoOrdenUpdateRequested e, Emitter<RepuestoOrdenState> emit) => _runOperation(
        emit,
        RepuestoOperacion.actualizar,
        e.repuesto.ordenId,
        () => _repository.updateRepuesto(e.repuesto),
      ),
    );
    on<RepuestoOrdenDeleteRequested>(
      (RepuestoOrdenDeleteRequested e, Emitter<RepuestoOrdenState> emit) => _runOperation(
        emit,
        RepuestoOperacion.eliminar,
        e.repuesto.ordenId,
        () => _repository.deleteRepuesto(e.repuesto.id),
      ),
    );
  }

  final OrdenReparacionRepository _repository;

  List<RepuestoOrdenEntity> get _current {
    final RepuestoOrdenState s = state;
    return s is RepuestoOrdenLoaded ? s.repuestos : <RepuestoOrdenEntity>[];
  }

  Future<void> _onLoad(RepuestoOrdenLoadRequested event, Emitter<RepuestoOrdenState> emit) async {
    debugPrint('🔩 RepuestoOrdenBloc: Cargando repuestos de ${event.ordenId}');
    emit(const RepuestoOrdenLoading());
    try {
      final List<RepuestoOrdenEntity> repuestos = await _repository.getRepuestos(event.ordenId);
      emit(RepuestoOrdenLoaded(repuestos: repuestos));
    } catch (e) {
      debugPrint('❌ RepuestoOrdenBloc: Error al cargar: $e');
      emit(RepuestoOrdenError(message: e.toString()));
    }
  }

  Future<void> _runOperation(
    Emitter<RepuestoOrdenState> emit,
    RepuestoOperacion operacion,
    String ordenId,
    Future<Object?> Function() action,
  ) async {
    debugPrint('🔩 RepuestoOrdenBloc: Operación ${operacion.name}');
    try {
      await action();
      final List<RepuestoOrdenEntity> repuestos = await _repository.getRepuestos(ordenId);
      emit(RepuestoOrdenOperationSuccess(repuestos: repuestos, operacion: operacion));
    } catch (e) {
      debugPrint('❌ RepuestoOrdenBloc: Error en ${operacion.name}: $e');
      emit(RepuestoOrdenOperationFailure(repuestos: _current, operacion: operacion, message: e.toString()));
    }
  }
}
