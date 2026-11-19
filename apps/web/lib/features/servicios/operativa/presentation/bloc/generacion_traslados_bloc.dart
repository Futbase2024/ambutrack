import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/features/servicios/operativa/domain/repositories/generacion_traslados_repository.dart';
import 'package:ambutrack_web/features/servicios/operativa/presentation/bloc/generacion_traslados_event.dart';
import 'package:ambutrack_web/features/servicios/operativa/presentation/bloc/generacion_traslados_state.dart';
import 'package:ambutrack_web/features/servicios/servicios/domain/repositories/servicio_recurrente_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

/// BLoC del panel "Generar servicios diarios": resumen del estado de la
/// generación y ejecución manual de `generar_traslados_periodo`
@injectable
class GeneracionTrasladosBloc extends Bloc<GeneracionTrasladosEvent, GeneracionTrasladosState> {
  GeneracionTrasladosBloc(this._generacionRepository, this._recurrenteRepository)
      : super(const GeneracionTrasladosState()) {
    on<GeneracionEstadoRequested>(_onEstadoRequested);
    on<GeneracionEjecutarRequested>(_onEjecutarRequested);
  }

  final GeneracionTrasladosRepository _generacionRepository;
  final ServicioRecurrenteRepository _recurrenteRepository;

  Future<void> _onEstadoRequested(
    GeneracionEstadoRequested event,
    Emitter<GeneracionTrasladosState> emit,
  ) async {
    debugPrint('🔄 GeneracionTrasladosBloc: Cargando estado de generación');
    emit(state.copyWith(status: GeneracionStatus.loading));
    try {
      final List<ServicioRecurrenteEntity> vigentes =
          await _recurrenteRepository.getActivos();
      emit(
        state.copyWith(
          status: GeneracionStatus.loaded,
          resumen: GeneracionResumen.desde(vigentes),
        ),
      );
    } catch (e) {
      debugPrint('❌ GeneracionTrasladosBloc Error: $e');
      emit(state.copyWith(status: GeneracionStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> _onEjecutarRequested(
    GeneracionEjecutarRequested event,
    Emitter<GeneracionTrasladosState> emit,
  ) async {
    final DateTime ahora = DateTime.now();
    final DateTime hoy = DateTime(ahora.year, ahora.month, ahora.day);
    final DateTime hasta = hoy.add(Duration(days: event.dias));
    debugPrint('🔄 GeneracionTrasladosBloc: Generando traslados hasta $hasta');
    emit(state.copyWith(generando: true, clearErrorGeneracion: true));
    try {
      final ResultadoGeneracionTrasladosEntity resultado =
          await _generacionRepository.generarPeriodo(desde: hoy, hasta: hasta);
      emit(state.copyWith(generando: false, ultimoResultado: resultado));
      add(const GeneracionEstadoRequested());
    } catch (e) {
      debugPrint('❌ GeneracionTrasladosBloc Error al generar: $e');
      emit(state.copyWith(generando: false, errorGeneracion: e.toString()));
    }
  }
}
