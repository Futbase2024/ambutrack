import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/features/servicios/operativa/presentation/bloc/programacion_recurrente_event.dart';
import 'package:ambutrack_web/features/servicios/operativa/presentation/bloc/programacion_recurrente_state.dart';
import 'package:ambutrack_web/features/servicios/pacientes/domain/repositories/paciente_repository.dart';
import 'package:ambutrack_web/features/servicios/servicios/domain/repositories/servicio_recurrente_repository.dart';
import 'package:ambutrack_web/features/servicios/servicios/domain/repositories/traslado_repository.dart';
import 'package:ambutrack_web/features/tablas/motivos_traslado/domain/repositories/motivo_traslado_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

/// BLoC de la pantalla "Programación recurrente" (solo lectura)
@injectable
class ProgramacionRecurrenteBloc
    extends Bloc<ProgramacionRecurrenteEvent, ProgramacionRecurrenteState> {
  ProgramacionRecurrenteBloc(
    this._recurrenteRepository,
    this._trasladoRepository,
    this._pacienteRepository,
    this._motivoRepository,
  ) : super(const ProgramacionRecurrenteState()) {
    on<ProgramacionLoadRequested>(_onLoadRequested);
    on<ProgramacionTrasladosRequested>(_onTrasladosRequested);
  }

  final ServicioRecurrenteRepository _recurrenteRepository;
  final TrasladoRepository _trasladoRepository;
  final PacienteRepository _pacienteRepository;
  final MotivoTrasladoRepository _motivoRepository;

  Future<void> _onLoadRequested(
    ProgramacionLoadRequested event,
    Emitter<ProgramacionRecurrenteState> emit,
  ) async {
    debugPrint('🔁 ProgramacionRecurrenteBloc: Cargando servicios recurrentes');
    emit(state.copyWith(status: ProgramacionStatus.loading));
    try {
      final List<ServicioRecurrenteEntity> servicios = await _recurrenteRepository.getAll();
      final Map<String, String> pacientes = await _cargarPacientes();
      final Map<String, String> motivos = await _cargarMotivos();
      debugPrint('✅ ProgramacionRecurrenteBloc: ${servicios.length} servicios recurrentes');
      emit(
        state.copyWith(
          status: ProgramacionStatus.loaded,
          servicios: servicios,
          pacientes: pacientes,
          motivos: motivos,
        ),
      );
    } catch (e) {
      debugPrint('❌ ProgramacionRecurrenteBloc Error: $e');
      emit(state.copyWith(status: ProgramacionStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> _onTrasladosRequested(
    ProgramacionTrasladosRequested event,
    Emitter<ProgramacionRecurrenteState> emit,
  ) async {
    emit(
      state.copyWith(
        trasladosServicioId: event.idServicioRecurrente,
        traslados: const <TrasladoEntity>[],
        cargandoTraslados: true,
      ),
    );
    try {
      final List<TrasladoEntity> traslados =
          await _trasladoRepository.getByServicioRecurrente(event.idServicioRecurrente);
      if (state.trasladosServicioId != event.idServicioRecurrente) {
        return;
      }
      emit(state.copyWith(traslados: traslados, cargandoTraslados: false));
    } catch (e) {
      debugPrint('❌ ProgramacionRecurrenteBloc Error traslados: $e');
      emit(state.copyWith(cargandoTraslados: false));
    }
  }

  Future<Map<String, String>> _cargarPacientes() async {
    try {
      final List<PacienteEntity> pacientes = await _pacienteRepository.getAll();
      return <String, String>{
        for (final PacienteEntity p in pacientes) p.id: p.nombreCompleto.toUpperCase(),
      };
    } catch (e) {
      debugPrint('⚠️ ProgramacionRecurrenteBloc: No se pudieron cargar pacientes: $e');
      return const <String, String>{};
    }
  }

  Future<Map<String, String>> _cargarMotivos() async {
    try {
      final List<MotivoTrasladoEntity> motivos = await _motivoRepository.getAll();
      return <String, String>{
        for (final MotivoTrasladoEntity m in motivos) m.id: m.nombre,
      };
    } catch (e) {
      debugPrint('⚠️ ProgramacionRecurrenteBloc: No se pudieron cargar motivos: $e');
      return const <String, String>{};
    }
  }
}
