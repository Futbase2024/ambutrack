import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/features/taller/domain/repositories/orden_reparacion_repository.dart';
import 'package:ambutrack_web/features/taller/presentation/bloc/historial_reparaciones_event.dart';
import 'package:ambutrack_web/features/taller/presentation/bloc/historial_reparaciones_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

/// BLoC de consulta del historial de reparaciones (órdenes ya terminadas)
@injectable
class HistorialReparacionesBloc extends Bloc<HistorialReparacionesEvent, HistorialReparacionesState> {
  HistorialReparacionesBloc(this._repository) : super(const HistorialReparacionesInitial()) {
    on<HistorialReparacionesLoadRequested>(_onLoadRequested);
  }

  final OrdenReparacionRepository _repository;

  Future<void> _onLoadRequested(
    HistorialReparacionesLoadRequested event,
    Emitter<HistorialReparacionesState> emit,
  ) async {
    debugPrint('🔧 HistorialReparacionesBloc: Cargando historial');
    emit(const HistorialReparacionesLoading());
    try {
      final List<OrdenReparacionEntity> todas = await _repository.getAll();
      final List<OrdenReparacionEntity> terminadas =
          todas.where((OrdenReparacionEntity o) => !o.estado.isActiva).toList();
      debugPrint('✅ HistorialReparacionesBloc: ${terminadas.length} órdenes en historial');
      emit(HistorialReparacionesLoaded(ordenes: terminadas));
    } catch (e) {
      debugPrint('❌ HistorialReparacionesBloc Error: $e');
      emit(HistorialReparacionesError(message: e.toString()));
    }
  }
}
