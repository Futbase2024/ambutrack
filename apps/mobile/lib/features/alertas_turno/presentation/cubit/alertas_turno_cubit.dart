import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/models/aviso_caducidad.dart';
import '../../domain/repositories/alertas_turno_repository.dart';
import '../../domain/services/calculador_avisos_caducidad.dart';

/// Estado global de caducidades del técnico (documentación + vehículo en turno)
class AlertasTurnoState extends Equatable {
  const AlertasTurnoState({
    this.avisos = const <AvisoCaducidad>[],
    this.cargando = false,
    this.matricula,
  });

  final List<AvisoCaducidad> avisos;
  final bool cargando;

  /// Vehículo de la jornada abierta (null = no está en turno)
  final String? matricula;

  int get caducados => avisos.where((AvisoCaducidad a) => a.caducado).length;

  bool get hayAvisos => avisos.isNotEmpty;

  bool get hayMaterial => avisos.any((AvisoCaducidad a) => a.origen == OrigenAviso.material);

  @override
  List<Object?> get props => <Object?>[avisos, cargando, matricula];
}

/// Cubit global (singleton) que mantiene la lista de caducidades
///
/// Se actualiza al iniciar sesión, al volver a la app y tras fichar.
class AlertasTurnoCubit extends Cubit<AlertasTurnoState> {
  AlertasTurnoCubit(this._repository) : super(const AlertasTurnoState());

  final AlertasTurnoRepository _repository;

  Future<void> actualizar(String idPersonal) async {
    emit(AlertasTurnoState(avisos: state.avisos, cargando: true, matricula: state.matricula));
    final VehiculoEntity? vehiculo = await _vehiculoEnTurno(idPersonal);
    final List<Object> datos = await Future.wait<Object>(<Future<Object>>[
      _seguro(_repository.obtenerDocumentosPersonal(idPersonal), const <DocumentoPersonalEntity>[]),
      if (vehiculo != null) _seguro(_repository.obtenerMaterialVehiculo(vehiculo.id), const <StockVehiculoEntity>[]),
    ]);
    if (isClosed) {
      return;
    }
    final List<AvisoCaducidad> avisos = CalculadorAvisosCaducidad.calcular(
      ahora: DateTime.now(),
      vehiculo: vehiculo,
      documentos: datos[0] as List<DocumentoPersonalEntity>,
      material: datos.length > 1 ? datos[1] as List<StockVehiculoEntity> : const <StockVehiculoEntity>[],
    );
    debugPrint('⏰ [AlertasTurno] ${avisos.length} caducidades (${avisos.where((AvisoCaducidad a) => a.caducado).length} caducadas)');
    emit(AlertasTurnoState(avisos: avisos, matricula: vehiculo?.matricula));
  }

  void limpiar() => emit(const AlertasTurnoState());

  /// Vehículo de la jornada abierta (último fichaje = entrada)
  Future<VehiculoEntity?> _vehiculoEnTurno(String idPersonal) async {
    try {
      final RegistroHorarioEntity? ultimo = await _repository.obtenerUltimoFichaje(idPersonal);
      final String? id = ultimo?.tipo.toLowerCase() == 'entrada' ? ultimo?.vehiculoId : null;
      return id == null || id.isEmpty ? null : await _repository.obtenerVehiculo(id);
    } catch (e) {
      debugPrint('⚠️ [AlertasTurno] Sin vehículo en turno: $e');
      return null;
    }
  }

  Future<T> _seguro<T extends Object>(Future<T> futuro, T porDefecto) async {
    try {
      return await futuro;
    } catch (e) {
      debugPrint('⚠️ [AlertasTurno] Dato no disponible: $e');
      return porDefecto;
    }
  }
}
