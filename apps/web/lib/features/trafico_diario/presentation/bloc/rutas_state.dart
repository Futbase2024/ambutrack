import 'package:freezed_annotation/freezed_annotation.dart';
import '../models/traslado_con_ruta_info.dart';

part 'rutas_state.freezed.dart';

/// Estados del RutasBloc
@freezed
class RutasState with _$RutasState {
  /// Estado inicial
  const factory RutasState.initial() = _Initial;

  /// Cargando datos
  const factory RutasState.loading() = _Loading;

  /// Ruta cargada con datos
  const factory RutasState.loaded({
    required String tecnicoId,
    required String tecnicoNombre,
    required String? vehiculoMatricula,
    required DateTime fecha,
    required String? turno,
    required List<TrasladoConRutaInfo> traslados,
    required RutaResumen resumen,
    @Default(false) bool isOptimizando,
    /// Resumen antes de optimizar (para comparativa)
    RutaResumen? resumenAnterior,
  }) = _Loaded;

  /// Sin traslados para el técnico seleccionado
  const factory RutasState.empty({
    String? mensaje,
    String? tecnicoNombre,
    DateTime? fecha,
  }) = _Empty;

  /// Error al cargar o procesar datos
  const factory RutasState.error({
    required String message,
    String? tecnicoId,
    DateTime? fecha,
  }) = _Error;
}
