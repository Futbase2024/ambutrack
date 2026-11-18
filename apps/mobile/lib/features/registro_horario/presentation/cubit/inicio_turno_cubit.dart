import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/turno_actual_repository.dart';
import 'inicio_turno_reglas.dart';
import 'inicio_turno_state.dart';

/// Cubit del asistente "Iniciar turno"
///
/// Carga el turno vigente, vehículos, plantillas, checklist corto, documentación
/// del trabajador y base; y guía los pasos turno → vehículo → dotación → km →
/// revisión → confirmar.
class InicioTurnoCubit extends Cubit<InicioTurnoState> {
  InicioTurnoCubit(this._repository) : super(const InicioTurnoState());

  final TurnoActualRepository _repository;

  Future<void> cargar(TPersonalEntity personal, {double? latitud, double? longitud}) async {
    emit(const InicioTurnoState());
    try {
      final TurnoEntity? turno = await _repository.obtenerTurnoVigente(personal.id);
      final List<VehiculoEntity> vehiculos = await _repository.obtenerVehiculosOperativos();
      final List<PlantillaTurnoEntity> plantillas =
          turno == null ? await _repository.obtenerPlantillas() : const <PlantillaTurnoEntity>[];
      final VehiculoEntity? vehiculoTurno = await _vehiculoDelTurno(turno, vehiculos);
      final String? idBase = _idBase(turno, personal);

      final List<Object?> extras = await Future.wait<Object?>(<Future<Object?>>[
        _seguro(_repository.obtenerPlantillaChecklist(), const <String>[]),
        _seguro(_repository.obtenerDocumentosPersonal(personal.id), const <DocumentoPersonalEntity>[]),
        _seguro(_repository.obtenerPersonalActivo(), const <TPersonalEntity>[]),
        if (idBase != null) _seguro(_repository.obtenerUbicacionBase(idBase), null),
      ]);

      emit(InicioTurnoState(
        status: InicioTurnoStatus.listo,
        personal: personal,
        latitud: latitud,
        longitud: longitud,
        turno: turno,
        vehiculos: vehiculos,
        plantillas: plantillas,
        vehiculoSeleccionado: vehiculoTurno,
        plantillaSeleccionada: _plantillaSugerida(plantillas),
        checklistNombres: extras[0]! as List<String>,
        documentos: extras[1]! as List<DocumentoPersonalEntity>,
        personalActivo: (extras[2]! as List<TPersonalEntity>)
            .where((TPersonalEntity p) => p.id != personal.id)
            .toList(),
        ubicacionBase: extras.length > 3 ? extras[3] as UbicacionBaseEntity? : null,
        rol: _rolSugerido(personal.categoria),
      ));
      if (vehiculoTurno != null) {
        await _cargarOcupacion(vehiculoTurno.id);
      }
    } catch (e) {
      debugPrint('❌ [InicioTurnoCubit] Error al cargar: $e');
      emit(InicioTurnoState(status: InicioTurnoStatus.error, error: '$e'));
    }
  }

  // ===== Navegación =====

  void siguiente() {
    if (!state.puedeAvanzar || state.paso == PasoInicioTurno.resumen) {
      return;
    }
    emit(state.copyWith(paso: PasoInicioTurno.values[state.paso.index + 1]));
  }

  void anterior() {
    if (state.paso.index == 0) {
      return;
    }
    emit(state.copyWith(paso: PasoInicioTurno.values[state.paso.index - 1]));
  }

  // ===== Turno y vehículo =====

  void seleccionarPlantilla(PlantillaTurnoEntity plantilla) => emit(state.copyWith(plantillaSeleccionada: plantilla));

  void activarCambioVehiculo() => emit(state.copyWith(cambiandoVehiculo: true));

  void filtrar(String texto) => emit(state.copyWith(filtro: texto));

  Future<void> seleccionarVehiculo(VehiculoEntity vehiculo) async {
    emit(state.copyWith(vehiculoSeleccionado: vehiculo, ocupantes: const <OcupanteVehiculoEntity>[], limpiarKm: true));
    await _cargarOcupacion(vehiculo.id);
  }

  /// Selecciona el vehículo leído por QR (id, matrícula o nº interno). false si no existe
  Future<bool> seleccionarPorCodigo(String codigo) async {
    final String c = codigo.trim().toUpperCase().replaceAll(RegExp(r'[\s-]'), '');
    for (final VehiculoEntity v in state.vehiculos) {
      final bool coincide = v.id.toUpperCase() == c ||
          v.matricula.toUpperCase().replaceAll(RegExp(r'[\s-]'), '') == c ||
          (v.numeroInterno?.toUpperCase() == c);
      if (coincide) {
        emit(state.copyWith(cambiandoVehiculo: true));
        await seleccionarVehiculo(v);
        return true;
      }
    }
    return false;
  }

  // ===== Dotación =====

  void seleccionarRol(RolDotacion rol) => emit(state.copyWith(rol: rol));

  void seleccionarCompanero(TPersonalEntity? companero) {
    emit(companero == null ? state.copyWith(limpiarCompanero: true) : state.copyWith(companero: companero));
  }

  // ===== Km, combustible y foto =====

  void cambiarKm(String texto) {
    final int? km = int.tryParse(texto.replaceAll(RegExp(r'\D'), ''));
    emit(km == null ? state.copyWith(limpiarKm: true) : state.copyWith(km: km));
  }

  void seleccionarCombustible(NivelCombustible nivel) => emit(state.copyWith(combustible: nivel));

  void cambiarFoto(Uint8List? bytes) {
    emit(bytes == null ? state.copyWith(limpiarFoto: true) : state.copyWith(fotoKm: bytes));
  }

  // ===== Checklist =====

  void responder(int indice, {required bool correcto}) {
    emit(state.copyWith(respuestas: <int, bool>{...state.respuestas, indice: correcto}));
  }

  void observar(int indice, String texto) {
    emit(state.copyWith(observaciones: <int, String>{...state.observaciones, indice: texto}));
  }

  void marcarTodoCorrecto() {
    emit(state.copyWith(
      respuestas: <int, bool>{for (int i = 0; i < state.checklistNombres.length; i++) i: true},
    ));
  }

  // ===== Resumen =====

  void cambiarDeclaracion({required bool valor}) => emit(state.copyWith(declaracion: valor));

  void cambiarMotivoFueraBase(String motivo) => emit(state.copyWith(motivoFueraBase: motivo));

  // ===== Privados =====

  Future<void> _cargarOcupacion(String idVehiculo) async {
    emit(state.copyWith(cargandoOcupacion: true));
    final List<OcupanteVehiculoEntity> ocupantes =
        await _seguro(_repository.obtenerOcupacionVehiculo(idVehiculo), const <OcupanteVehiculoEntity>[]);
    if (isClosed || state.vehiculoSeleccionado?.id != idVehiculo) {
      return;
    }
    emit(state.copyWith(ocupantes: ocupantes, cargandoOcupacion: false));
  }

  /// Datos opcionales: si fallan no impiden iniciar turno
  Future<T> _seguro<T>(Future<T> futuro, T porDefecto) async {
    try {
      return await futuro;
    } catch (e) {
      debugPrint('⚠️ [InicioTurnoCubit] Dato opcional no disponible: $e');
      return porDefecto;
    }
  }

  String? _idBase(TurnoEntity? turno, TPersonalEntity personal) {
    final String? base = turno?.idBase?.isNotEmpty ?? false ? turno!.idBase : personal.baseId;
    return base?.isNotEmpty ?? false ? base : null;
  }

  RolDotacion? _rolSugerido(String? categoria) {
    final String c = (categoria ?? '').toLowerCase();
    if (c.contains('conductor')) {
      return RolDotacion.conductor;
    }
    if (c.contains('enfermer')) {
      return RolDotacion.enfermero;
    }
    if (c.contains('médic') || c.contains('medic')) {
      return RolDotacion.medico;
    }
    if (c.contains('técnico') || c.contains('tecnico') || c.contains('tes')) {
      return RolDotacion.tes;
    }
    return null;
  }

  /// Vehículo asignado en el turno (aunque no esté en la lista de operativos)
  Future<VehiculoEntity?> _vehiculoDelTurno(TurnoEntity? turno, List<VehiculoEntity> vehiculos) async {
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
