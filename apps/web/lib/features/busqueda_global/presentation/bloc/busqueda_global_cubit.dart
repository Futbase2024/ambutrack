import 'dart:async';

import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/features/busqueda_global/domain/repositories/busqueda_global_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Mínimo de caracteres para buscar registros
const int kBusquedaMinCaracteres = 2;

/// Estado de la búsqueda global de registros
class BusquedaGlobalState extends Equatable {
  const BusquedaGlobalState({
    this.texto = '',
    this.buscando = false,
    this.resultados = const <ResultadoBusquedaEntity>[],
  });

  final String texto;
  final bool buscando;
  final List<ResultadoBusquedaEntity> resultados;

  @override
  List<Object?> get props => <Object?>[texto, buscando, resultados];
}

/// Busca registros con espera de 250 ms entre pulsaciones y descarta respuestas antiguas
class BusquedaGlobalCubit extends Cubit<BusquedaGlobalState> {
  BusquedaGlobalCubit(this._repository) : super(const BusquedaGlobalState());

  final BusquedaGlobalRepository _repository;
  Timer? _espera;

  void cambiarTexto(String texto) {
    _espera?.cancel();
    final String t = texto.trim();
    if (t.length < kBusquedaMinCaracteres) {
      emit(BusquedaGlobalState(texto: t));
      return;
    }
    emit(BusquedaGlobalState(texto: t, buscando: true, resultados: state.resultados));
    _espera = Timer(const Duration(milliseconds: 250), () => _buscar(t));
  }

  Future<void> _buscar(String texto) async {
    try {
      final List<ResultadoBusquedaEntity> r = await _repository.buscar(texto);
      if (!isClosed && state.texto == texto) {
        emit(BusquedaGlobalState(texto: texto, resultados: r));
      }
    } catch (e) {
      debugPrint('❌ BusquedaGlobalCubit: $e');
      if (!isClosed && state.texto == texto) {
        emit(BusquedaGlobalState(texto: texto));
      }
    }
  }

  @override
  Future<void> close() {
    _espera?.cancel();
    return super.close();
  }
}
