import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/turno_actual_repository.dart';
import 'inicio_turno_state.dart';

/// Cubit de la hoja "Iniciar turno"
///
/// Carga el turno vigente del cuadrante, los vehículos operativos y,
/// si no hay turno, las plantillas para crear uno desde la app.
class InicioTurnoCubit extends Cubit<InicioTurnoState> {
  InicioTurnoCubit(this._repository) : super(const InicioTurnoState());

  final TurnoActualRepository _repository;

  Future<void> cargar(String idPersonal) async {
    emit(const InicioTurnoState());
    try {
      final TurnoEntity? turno = await _repository.obtenerTurnoVigente(idPersonal);
      final List<VehiculoEntity> vehiculos = await _repository.obtenerVehiculosOperativos();
      final List<PlantillaTurnoEntity> plantillas =
          turno == null ? await _repository.obtenerPlantillas() : const <PlantillaTurnoEntity>[];
      final VehiculoEntity? vehiculoTurno = await _vehiculoDelTurno(turno, vehiculos);

      emit(InicioTurnoState(
        status: InicioTurnoStatus.listo,
        turno: turno,
        vehiculos: vehiculos,
        plantillas: plantillas,
        vehiculoSeleccionado: vehiculoTurno,
        plantillaSeleccionada: _plantillaSugerida(plantillas),
      ));
    } catch (e) {
      debugPrint('❌ [InicioTurnoCubit] Error al cargar: $e');
      emit(InicioTurnoState(status: InicioTurnoStatus.error, error: '$e'));
    }
  }

  void seleccionarVehiculo(VehiculoEntity vehiculo) {
    emit(state.copyWith(vehiculoSeleccionado: vehiculo));
  }

  void seleccionarPlantilla(PlantillaTurnoEntity plantilla) {
    emit(state.copyWith(plantillaSeleccionada: plantilla));
  }

  void activarCambioVehiculo() {
    emit(state.copyWith(cambiandoVehiculo: true));
  }

  void filtrar(String texto) {
    emit(state.copyWith(filtro: texto));
  }

  /// Vehículo asignado en el turno (aunque no esté en la lista de operativos)
  Future<VehiculoEntity?> _vehiculoDelTurno(
    TurnoEntity? turno,
    List<VehiculoEntity> vehiculos,
  ) async {
    final String? id = turno?.idVehiculo;
    if (id == null || id.isEmpty) {
      return null;
    }
    for (final VehiculoEntity v in vehiculos) {
      if (v.id == id) {
        return v;
      }
    }
    return _repository.obtenerVehiculo(id);
  }

  /// Plantilla cuya hora de inicio está a menos de 1h de ahora, si existe
  PlantillaTurnoEntity? _plantillaSugerida(List<PlantillaTurnoEntity> plantillas) {
    const int minutosDia = 24 * 60;
    final DateTime ahora = DateTime.now();
    final int minutos = ahora.hour * 60 + ahora.minute;
    for (final PlantillaTurnoEntity p in plantillas) {
      final int diferencia = (minutos - _aMinutos(p.horaInicio)).abs() % minutosDia;
      if (diferencia <= 60 || diferencia >= minutosDia - 60) {
        return p;
      }
    }
    return null;
  }

  int _aMinutos(String hora) {
    final List<String> partes = hora.split(':');
    final int h = int.tryParse(partes.first) ?? 0;
    final int m = partes.length > 1 ? int.tryParse(partes[1]) ?? 0 : 0;
    return h * 60 + m;
  }
}
