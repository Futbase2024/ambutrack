import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/features/stock_vestuario/domain/repositories/solicitudes_vestuario_repository.dart';
import 'package:ambutrack_web/features/stock_vestuario/presentation/cubit/solicitudes_vestuario_cubit.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Estado de las tallas registradas de un trabajador
class TallasPersonalState extends Equatable {
  const TallasPersonalState({this.tallas, this.cargado = false, this.guardando = false, this.error});

  /// null = sin tallas registradas (o aún sin cargar)
  final TallasPersonalEntity? tallas;
  final bool cargado;
  final bool guardando;

  /// Error de la última carga
  final String? error;

  @override
  List<Object?> get props => <Object?>[tallas, cargado, guardando, error];
}

/// Carga y guarda las tallas de un trabajador
class TallasPersonalCubit extends Cubit<TallasPersonalState> {
  TallasPersonalCubit(this._repository, {required this.personalId}) : super(const TallasPersonalState());

  final SolicitudesVestuarioRepository _repository;
  final String personalId;

  Future<void> cargar() async {
    emit(TallasPersonalState(tallas: state.tallas, cargado: state.cargado));
    try {
      final TallasPersonalEntity? tallas = await _repository.getTallas(personalId);
      if (!isClosed) {
        emit(TallasPersonalState(tallas: tallas, cargado: true));
      }
    } catch (e) {
      debugPrint('❌ TallasPersonalCubit.cargar: $e');
      if (!isClosed) {
        emit(TallasPersonalState(tallas: state.tallas, cargado: true, error: mensajeErrorVestuario(e)));
      }
    }
  }

  /// Guarda las tallas. Devuelve null si va bien o el mensaje de error.
  Future<String?> guardar(TallasPersonalEntity tallas) async {
    emit(TallasPersonalState(tallas: state.tallas, cargado: state.cargado, guardando: true));
    try {
      final TallasPersonalEntity guardadas = await _repository.guardarTallas(tallas);
      if (!isClosed) {
        emit(TallasPersonalState(tallas: guardadas, cargado: true));
      }
      return null;
    } catch (e) {
      debugPrint('❌ TallasPersonalCubit.guardar: $e');
      if (!isClosed) {
        emit(TallasPersonalState(tallas: state.tallas, cargado: state.cargado));
      }
      return mensajeErrorVestuario(e);
    }
  }
}
