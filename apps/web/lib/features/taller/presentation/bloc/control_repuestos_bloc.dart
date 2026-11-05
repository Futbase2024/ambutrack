import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/features/taller/domain/repositories/orden_reparacion_repository.dart';
import 'package:ambutrack_web/features/taller/presentation/bloc/control_repuestos_event.dart';
import 'package:ambutrack_web/features/taller/presentation/bloc/control_repuestos_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

/// BLoC de consulta de todos los repuestos de las órdenes de reparación
@injectable
class ControlRepuestosBloc extends Bloc<ControlRepuestosEvent, ControlRepuestosState> {
  ControlRepuestosBloc(this._repository) : super(const ControlRepuestosInitial()) {
    on<ControlRepuestosLoadRequested>(_onLoadRequested);
  }

  final OrdenReparacionRepository _repository;

  Future<void> _onLoadRequested(
    ControlRepuestosLoadRequested event,
    Emitter<ControlRepuestosState> emit,
  ) async {
    debugPrint('🔧 ControlRepuestosBloc: Cargando repuestos');
    emit(const ControlRepuestosLoading());
    try {
      final List<Object> results = await Future.wait<Object>(<Future<Object>>[
        _repository.getAllRepuestos(),
        _repository.getAll(),
      ]);
      final List<RepuestoOrdenEntity> repuestos = results[0] as List<RepuestoOrdenEntity>;
      final Map<String, OrdenReparacionEntity> ordenes = <String, OrdenReparacionEntity>{
        for (final OrdenReparacionEntity o in results[1] as List<OrdenReparacionEntity>) o.id: o,
      };
      final List<RepuestoControlItem> items = repuestos
          .map((RepuestoOrdenEntity r) => RepuestoControlItem(repuesto: r, orden: ordenes[r.ordenId]))
          .toList();
      debugPrint('✅ ControlRepuestosBloc: ${items.length} repuestos cargados');
      emit(ControlRepuestosLoaded(items: items));
    } catch (e) {
      debugPrint('❌ ControlRepuestosBloc Error: $e');
      emit(ControlRepuestosError(message: e.toString()));
    }
  }
}
