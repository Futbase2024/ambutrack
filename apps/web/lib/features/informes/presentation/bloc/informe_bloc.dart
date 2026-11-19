import 'package:ambutrack_web/features/informes/domain/informe_filtro.dart';
import 'package:ambutrack_web/features/informes/presentation/bloc/informe_event.dart';
import 'package:ambutrack_web/features/informes/presentation/bloc/informe_state.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

export 'informe_event.dart';
export 'informe_state.dart';

/// BLoC base de los informes.
///
/// - [R]: datos en bruto cargados para un rango de fechas
/// - [T]: datos agregados que pinta la vista
///
/// Los datos en bruto se cachean por rango: si solo cambian los filtros
/// secundarios (vehículo, categoría...) se recalcula sin consultar Supabase.
abstract class InformeBloc<R, T> extends Bloc<InformeEvent, InformeState<T>> {
  InformeBloc() : super(InformeState<T>(filtro: InformeFiltro.inicial())) {
    on<InformeEvent>(_onEvent, transformer: restartable());
  }

  R? _raw;
  InformeFiltro? _rawFiltro;

  /// Nombre para los logs
  String get nombre;

  /// Carga los datos en bruto del rango de [filtro]
  Future<R> cargar(InformeFiltro filtro);

  /// Calcula los agregados a partir de los datos en bruto
  T calcular(R raw, InformeFiltro filtro);

  Future<void> _onEvent(InformeEvent event, Emitter<InformeState<T>> emit) async {
    final InformeFiltro filtro = event is InformeFiltroChanged ? event.filtro : state.filtro;
    final R? cache = _raw;
    final InformeFiltro? cacheFiltro = _rawFiltro;
    final bool reutilizar = event is InformeFiltroChanged &&
        cache != null &&
        cacheFiltro != null &&
        cacheFiltro.mismoRango(filtro);

    if (reutilizar) {
      debugPrint('📊 $nombre: recalculando con filtros ${filtro.extras}');
      _emitirCalculo(emit, cache, filtro);
      return;
    }

    emit(state.copyWith(filtro: filtro, status: InformeStatus.loading));
    try {
      debugPrint('📊 $nombre: cargando ${filtro.etiqueta}');
      final R raw = await cargar(filtro);
      _raw = raw;
      _rawFiltro = filtro;
      _emitirCalculo(emit, raw, filtro);
    } catch (e) {
      debugPrint('❌ $nombre: error al cargar: $e');
      emit(state.copyWith(filtro: filtro, status: InformeStatus.error, message: e.toString()));
    }
  }

  void _emitirCalculo(Emitter<InformeState<T>> emit, R raw, InformeFiltro filtro) {
    try {
      final T data = calcular(raw, filtro);
      debugPrint('✅ $nombre: informe calculado');
      emit(InformeState<T>(filtro: filtro, status: InformeStatus.loaded, data: data));
    } catch (e) {
      debugPrint('❌ $nombre: error al calcular: $e');
      emit(state.copyWith(filtro: filtro, status: InformeStatus.error, message: e.toString()));
    }
  }
}
