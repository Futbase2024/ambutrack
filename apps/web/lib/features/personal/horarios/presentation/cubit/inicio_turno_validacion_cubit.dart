import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/features/personal/horarios/domain/repositories/inicio_turno_validacion_repository.dart';
import 'package:ambutrack_web/features/personal/horarios/presentation/cubit/inicio_turno_validacion_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Carga los inicios de turno de los últimos 30 días y permite validarlos
class InicioTurnoValidacionCubit extends Cubit<InicioTurnoValidacionState> {
  InicioTurnoValidacionCubit(this._repository) : super(const InicioTurnoValidacionState());

  final InicioTurnoValidacionRepository _repository;
  int _secuencia = 0;

  /// Carga (o recarga) los inicios de turno de los últimos 30 días
  Future<void> cargar() async {
    emit(state.copyWith(cargando: true, clearError: true));
    try {
      final DateTime hoy = DateTime.now();
      final List<InicioTurnoEntity> inicios = await _repository.getByRango(
        desde: hoy.subtract(const Duration(days: 30)),
        hasta: hoy.add(const Duration(days: 1)),
      );
      debugPrint('✅ InicioTurnoValidacionCubit: ${inicios.length} inicios de turno');
      if (!isClosed) {
        emit(state.copyWith(inicios: inicios, cargando: false));
      }
    } catch (e) {
      debugPrint('❌ InicioTurnoValidacionCubit.cargar: $e');
      if (!isClosed) {
        emit(state.copyWith(cargando: false, error: e.toString()));
      }
    }
  }

  /// Aprueba o rechaza un inicio de turno pendiente
  Future<void> validar({required String id, required bool aprobado, String? motivoRechazo}) async {
    emit(state.copyWith(validando: true));
    _secuencia++;
    try {
      final InicioTurnoEntity actualizado = await _repository.validar(
        id: id,
        aprobado: aprobado,
        motivoRechazo: motivoRechazo,
      );
      final List<InicioTurnoEntity> inicios = (state.inicios ?? const <InicioTurnoEntity>[])
          .map((InicioTurnoEntity i) => i.id == id ? actualizado : i)
          .toList();
      if (!isClosed) {
        emit(
          state.copyWith(
            inicios: inicios,
            validando: false,
            resultado: InicioTurnoValidacionResultado(secuencia: _secuencia, aprobado: aprobado),
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ InicioTurnoValidacionCubit.validar: $e');
      if (!isClosed) {
        emit(
          state.copyWith(
            validando: false,
            resultado: InicioTurnoValidacionResultado(secuencia: _secuencia, aprobado: aprobado, error: e.toString()),
          ),
        );
      }
    }
  }

  /// URL firmada temporal de la foto del cuentakilómetros
  Future<String> urlFotoKm(String ruta) => _repository.getUrlFotoKm(ruta);
}
