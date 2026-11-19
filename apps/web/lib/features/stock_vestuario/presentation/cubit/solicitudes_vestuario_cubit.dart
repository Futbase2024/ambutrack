import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/features/stock_vestuario/domain/repositories/solicitudes_vestuario_repository.dart';
import 'package:ambutrack_web/features/stock_vestuario/domain/repositories/stock_vestuario_repository.dart';
import 'package:ambutrack_web/features/stock_vestuario/presentation/cubit/solicitudes_vestuario_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Quita los prefijos "Exception: " que acumulan las capas inferiores
String mensajeErrorVestuario(Object e) => e.toString().replaceAll('Exception: ', '').trim();

/// Gestión de solicitudes de vestuario: carga, aprobación, rechazo y entrega
class SolicitudesVestuarioCubit extends Cubit<SolicitudesVestuarioState> {
  SolicitudesVestuarioCubit(this._repository, this._stockRepository) : super(const SolicitudesVestuarioState());

  final SolicitudesVestuarioRepository _repository;
  final StockVestuarioRepository _stockRepository;
  int _secuencia = 0;

  /// Carga (o recarga) todas las solicitudes y el stock de almacén
  Future<void> cargar() async {
    emit(state.copyWith(cargando: true, clearError: true));
    try {
      final List<Object> r = await Future.wait<Object>(<Future<Object>>[
        _repository.getAll(),
        _stockRepository.getAll(),
      ]);
      final List<SolicitudVestuarioEntity> solicitudes = r[0] as List<SolicitudVestuarioEntity>;
      debugPrint('✅ SolicitudesVestuarioCubit: ${solicitudes.length} solicitudes');
      if (!isClosed) {
        emit(
          state.copyWith(
            solicitudes: solicitudes,
            stock: r[1] as List<StockVestuarioEntity>,
            cargando: false,
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ SolicitudesVestuarioCubit.cargar: $e');
      if (!isClosed) {
        emit(state.copyWith(cargando: false, error: mensajeErrorVestuario(e)));
      }
    }
  }

  Future<void> aprobar(SolicitudVestuarioEntity s) =>
      _ejecutar(s, AccionSolicitudVestuario.aprobar, () => _repository.aprobar(s.id));

  Future<void> rechazar(SolicitudVestuarioEntity s, {required String motivo}) =>
      _ejecutar(s, AccionSolicitudVestuario.rechazar, () => _repository.rechazar(s.id, motivo: motivo));

  /// Entrega la prenda desde [stockId] (null en devoluciones) y recarga stock y solicitudes
  Future<void> entregar(SolicitudVestuarioEntity s, {String? stockId, bool? devolverAStock}) async {
    await _ejecutar(s, AccionSolicitudVestuario.entregar, () async {
      await _repository.entregar(s.id, stockId: stockId, devolverAStock: devolverAStock);
      return null;
    });
    if (state.resultado?.ok ?? false) {
      await cargar();
    }
  }

  /// Ejecuta una acción de gestión y publica su resultado.
  /// Si la acción devuelve la solicitud actualizada, la sustituye en la lista.
  Future<void> _ejecutar(
    SolicitudVestuarioEntity s,
    AccionSolicitudVestuario accion,
    Future<SolicitudVestuarioEntity?> Function() run,
  ) async {
    emit(state.copyWith(procesando: true));
    _secuencia++;
    try {
      final SolicitudVestuarioEntity? actualizada = await run();
      final List<SolicitudVestuarioEntity> lista = (state.solicitudes ?? const <SolicitudVestuarioEntity>[])
          .map((SolicitudVestuarioEntity o) => o.id == s.id && actualizada != null ? actualizada : o)
          .toList();
      if (!isClosed) {
        emit(
          state.copyWith(
            solicitudes: lista,
            procesando: false,
            resultado: SolicitudVestuarioResultado(secuencia: _secuencia, accion: accion, tipo: s.tipo),
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ SolicitudesVestuarioCubit.${accion.name}: $e');
      if (!isClosed) {
        emit(
          state.copyWith(
            procesando: false,
            resultado: SolicitudVestuarioResultado(
              secuencia: _secuencia,
              accion: accion,
              tipo: s.tipo,
              error: mensajeErrorVestuario(e),
            ),
          ),
        );
      }
    }
  }

  /// URL firmada temporal de la foto de la solicitud
  Future<String> urlFoto(String ruta) => _repository.getUrlFoto(ruta);
}
