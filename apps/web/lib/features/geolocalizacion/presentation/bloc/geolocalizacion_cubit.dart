import 'dart:async';

import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/features/geolocalizacion/domain/repositories/geolocalizacion_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Estado del seguimiento GPS
class GeolocalizacionState extends Equatable {
  const GeolocalizacionState({
    this.cargando = true,
    this.error,
    this.ultimas = const <String, UbicacionVehiculoEntity>{},
    this.seleccionadoId,
    this.recorrido = const <UbicacionVehiculoEntity>[],
  });

  final bool cargando;
  final String? error;

  /// Última posición por vehículo
  final Map<String, UbicacionVehiculoEntity> ultimas;
  final String? seleccionadoId;

  /// Recorrido de hoy del vehículo seleccionado
  final List<UbicacionVehiculoEntity> recorrido;

  UbicacionVehiculoEntity? get seleccionado => seleccionadoId == null ? null : ultimas[seleccionadoId];

  GeolocalizacionState copyWith({
    bool? cargando,
    String? error,
    Map<String, UbicacionVehiculoEntity>? ultimas,
    String? seleccionadoId,
    bool limpiarSeleccion = false,
    List<UbicacionVehiculoEntity>? recorrido,
  }) {
    return GeolocalizacionState(
      cargando: cargando ?? this.cargando,
      error: error,
      ultimas: ultimas ?? this.ultimas,
      seleccionadoId: limpiarSeleccion ? null : (seleccionadoId ?? this.seleccionadoId),
      recorrido: recorrido ?? this.recorrido,
    );
  }

  @override
  List<Object?> get props => <Object?>[cargando, error, ultimas, seleccionadoId, recorrido];
}

/// Carga las últimas posiciones, escucha las nuevas en tiempo real y el recorrido del seleccionado
class GeolocalizacionCubit extends Cubit<GeolocalizacionState> {
  GeolocalizacionCubit(this._repository) : super(const GeolocalizacionState());

  final GeolocalizacionRepository _repository;
  StreamSubscription<UbicacionVehiculoEntity>? _sub;

  Future<void> iniciar() async {
    await cargar();
    _sub ??= _repository.watchNuevas().listen(_onNueva);
  }

  Future<void> cargar() async {
    emit(state.copyWith(cargando: true));
    try {
      final List<UbicacionVehiculoEntity> ultimas = await _repository.getUltimas();
      if (!isClosed) {
        emit(
          state.copyWith(
            cargando: false,
            ultimas: <String, UbicacionVehiculoEntity>{
              for (final UbicacionVehiculoEntity u in ultimas) u.vehiculoId: u,
            },
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ GeolocalizacionCubit: $e');
      if (!isClosed) {
        emit(state.copyWith(cargando: false, error: e.toString()));
      }
    }
  }

  Future<void> seleccionar(String? vehiculoId) async {
    if (vehiculoId == null || vehiculoId == state.seleccionadoId) {
      emit(state.copyWith(limpiarSeleccion: true, recorrido: const <UbicacionVehiculoEntity>[]));
      return;
    }
    emit(state.copyWith(seleccionadoId: vehiculoId, recorrido: const <UbicacionVehiculoEntity>[]));
    try {
      final DateTime hoy = _inicioDeHoy();
      final List<UbicacionVehiculoEntity> r = await _repository.getRecorrido(vehiculoId, desde: hoy);
      if (!isClosed && state.seleccionadoId == vehiculoId) {
        emit(state.copyWith(recorrido: r));
      }
    } catch (e) {
      debugPrint('❌ GeolocalizacionCubit recorrido: $e');
    }
  }

  void _onNueva(UbicacionVehiculoEntity u) {
    final UbicacionVehiculoEntity? previa = state.ultimas[u.vehiculoId];
    final Map<String, UbicacionVehiculoEntity> ultimas = Map<String, UbicacionVehiculoEntity>.of(state.ultimas)
      ..[u.vehiculoId] = previa == null ? u : previa.copyWithPosicion(u);
    final bool esDelSeleccionado = u.vehiculoId == state.seleccionadoId;
    emit(
      state.copyWith(
        ultimas: ultimas,
        recorrido: esDelSeleccionado ? <UbicacionVehiculoEntity>[...state.recorrido, u] : null,
      ),
    );
  }

  @override
  Future<void> close() async {
    await _sub?.cancel();
    return super.close();
  }
}

/// Medianoche de hoy (hora local)
DateTime _inicioDeHoy() {
  final DateTime n = DateTime.now();
  return DateTime(n.year, n.month, n.day);
}
