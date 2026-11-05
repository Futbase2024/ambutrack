import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/features/personal/domain/entities/personal_entity.dart';
import 'package:ambutrack_web/features/personal/domain/repositories/personal_repository.dart';
import 'package:ambutrack_web/features/servicios/operativa/presentation/bloc/traslados_consulta_event.dart';
import 'package:ambutrack_web/features/servicios/operativa/presentation/bloc/traslados_consulta_state.dart';
import 'package:ambutrack_web/features/servicios/servicios/domain/repositories/traslado_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

/// BLoC de consulta (solo lectura) de traslados para las pantallas
/// operativas: histórico, estado del día, urgentes y generación diaria
@injectable
class TrasladosConsultaBloc extends Bloc<TrasladosConsultaEvent, TrasladosConsultaState> {
  TrasladosConsultaBloc(this._trasladoRepository, this._personalRepository)
      : super(const TrasladosConsultaInitial()) {
    on<TrasladosConsultaRequested>(_onRequested);
    on<TrasladosConsultaRefreshRequested>(_onRefreshRequested);
  }

  final TrasladoRepository _trasladoRepository;
  final PersonalRepository _personalRepository;

  TrasladosConsulta? _ultimaConsulta;
  Map<String, String>? _personal;

  Future<void> _onRequested(
    TrasladosConsultaRequested event,
    Emitter<TrasladosConsultaState> emit,
  ) async {
    _ultimaConsulta = event.consulta;
    await _cargar(event.consulta, emit, silent: event.silent);
  }

  Future<void> _onRefreshRequested(
    TrasladosConsultaRefreshRequested event,
    Emitter<TrasladosConsultaState> emit,
  ) async {
    final TrasladosConsulta? consulta = _ultimaConsulta;
    if (consulta != null) {
      await _cargar(consulta, emit, silent: event.silent);
    }
  }

  Future<void> _cargar(
    TrasladosConsulta consulta,
    Emitter<TrasladosConsultaState> emit, {
    required bool silent,
  }) async {
    debugPrint('🚑 TrasladosConsultaBloc: Consulta ${consulta.modo.name}');
    if (!silent) {
      emit(const TrasladosConsultaLoading());
    }
    try {
      final List<TrasladoEntity> traslados = await _consultar(consulta);
      final Map<String, String> personal = await _cargarPersonal();
      debugPrint('✅ TrasladosConsultaBloc: ${traslados.length} traslados');
      emit(
        TrasladosConsultaLoaded(
          consulta: consulta,
          traslados: traslados,
          personal: personal,
          actualizadoEn: DateTime.now(),
        ),
      );
    } catch (e) {
      debugPrint('❌ TrasladosConsultaBloc Error: $e');
      emit(TrasladosConsultaError(message: e.toString()));
    }
  }

  Future<List<TrasladoEntity>> _consultar(TrasladosConsulta consulta) {
    switch (consulta.modo) {
      case TrasladosConsultaModo.dia:
        return _trasladoRepository.getByFecha(consulta.desde!);
      case TrasladosConsultaModo.rango:
        return _trasladoRepository.getByRangoFechas(
          desde: consulta.desde!,
          hasta: consulta.hasta!,
        );
      case TrasladosConsultaModo.enCurso:
        return _trasladoRepository.getEnCurso();
    }
  }

  /// Nombres del personal (se cargan una sola vez; si falla, se sigue sin nombres)
  Future<Map<String, String>> _cargarPersonal() async {
    final Map<String, String>? cache = _personal;
    if (cache != null) {
      return cache;
    }
    try {
      final List<PersonalEntity> personal = await _personalRepository.getAll();
      final Map<String, String> mapa = <String, String>{
        for (final PersonalEntity p in personal)
          p.id: '${p.nombre} ${p.apellidos}'.trim().toUpperCase(),
      };
      _personal = mapa;
      return mapa;
    } catch (e) {
      debugPrint('⚠️ TrasladosConsultaBloc: No se pudo cargar el personal: $e');
      return const <String, String>{};
    }
  }
}
