import 'package:ambutrack_core/ambutrack_core.dart';
import 'package:ambutrack_web/features/personal/domain/entities/personal_entity.dart';
import 'package:ambutrack_web/features/personal/domain/repositories/personal_repository.dart';
import 'package:ambutrack_web/features/turnos/domain/entities/preferencia_personal_entity.dart';
import 'package:ambutrack_web/features/turnos/domain/entities/resultado_generacion_entity.dart';
import 'package:ambutrack_web/features/turnos/domain/repositories/turnos_repository.dart';
import 'package:ambutrack_web/features/turnos/domain/services/generacion_automatica_service.dart';
import 'package:ambutrack_web/features/turnos/presentation/bloc/generacion_automatica_event.dart';
import 'package:ambutrack_web/features/turnos/presentation/bloc/generacion_automatica_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

@injectable
class GeneracionAutomaticaBloc
    extends Bloc<GeneracionAutomaticaEvent, GeneracionAutomaticaState> {
  GeneracionAutomaticaBloc(
    this._generacionService,
    this._turnosRepository,
    this._personalRepository,
  ) : super(const GeneracionAutomaticaInitial()) {
    on<GeneracionAutomaticaSolicitada>(_onGeneracionSolicitada);
    on<GeneracionAutomaticaConfirmada>(_onGeneracionConfirmada);
    on<GeneracionAutomaticaCancelada>(_onGeneracionCancelada);
  }

  final GeneracionAutomaticaService _generacionService;
  final TurnosRepository _turnosRepository;
  final PersonalRepository _personalRepository;

  ResultadoGeneracionEntity? _resultadoActual;

  Future<void> _onGeneracionSolicitada(
    GeneracionAutomaticaSolicitada event,
    Emitter<GeneracionAutomaticaState> emit,
  ) async {
    try {
      debugPrint('🚀 GeneracionAutomaticaBloc: Iniciando generación automática...');
      emit(const GeneracionAutomaticaGenerando());

      // 1. Obtener personal seleccionado
      final List<PersonalEntity> todoPersonal = await _personalRepository.getAll();
      final List<PersonalEntity> personalSeleccionado = todoPersonal
          .where((PersonalEntity p) => event.idsPersonal.contains(p.id))
          .toList();

      debugPrint('👥 Personal seleccionado: ${personalSeleccionado.length}');

      if (personalSeleccionado.isEmpty) {
        emit(const GeneracionAutomaticaError('No se seleccionó personal'));
        return;
      }

      // 2. Obtener turnos existentes en el período
      final List<TurnoEntity> turnosExistentes = await _turnosRepository.getAll();
      final List<TurnoEntity> turnosPeriodo = turnosExistentes
          .where((TurnoEntity t) =>
              !t.fechaInicio.isBefore(event.fechaInicio) &&
              !t.fechaInicio.isAfter(event.fechaFin))
          .toList();

      debugPrint('📅 Turnos existentes en período: ${turnosPeriodo.length}');

      // 3. Obtener preferencias (por ahora vacío, se puede implementar después)
      final List<PreferenciaPersonalEntity> preferencias = <PreferenciaPersonalEntity>[];

      // 4. Generar cuadrante
      final ResultadoGeneracionEntity resultado =
          await _generacionService.generarCuadrante(
        fechaInicio: event.fechaInicio,
        fechaFin: event.fechaFin,
        personal: personalSeleccionado,
        configuracion: event.configuracion,
        preferencias: preferencias,
        turnosExistentes: turnosPeriodo,
      );

      _resultadoActual = resultado;

      debugPrint('✅ Generación completada:');
      debugPrint('   - Turnos: ${resultado.turnosGenerados.length}');
      debugPrint('   - Conflictos: ${resultado.conflictos.length}');
      debugPrint('   - Advertencias: ${resultado.advertencias.length}');

      emit(GeneracionAutomaticaCompletada(resultado));
    } catch (e, stackTrace) {
      debugPrint('❌ Error en generación automática: $e');
      debugPrint(stackTrace.toString());
      emit(GeneracionAutomaticaError(e.toString()));
    }
  }

  Future<void> _onGeneracionConfirmada(
    GeneracionAutomaticaConfirmada event,
    Emitter<GeneracionAutomaticaState> emit,
  ) async {
    if (_resultadoActual == null) {
      emit(const GeneracionAutomaticaError('No hay resultado para confirmar'));
      return;
    }

    try {
      debugPrint('💾 Guardando turnos generados...');
      emit(const GeneracionAutomaticaGuardando());

      int turnosGuardados = 0;

      // Guardar cada turno generado
      for (final TurnoEntity turno in _resultadoActual!.turnosGenerados) {
        await _turnosRepository.create(turno);
        turnosGuardados++;
      }

      debugPrint('✅ $turnosGuardados turnos guardados exitosamente');

      emit(GeneracionAutomaticaGuardada(turnosGuardados));
      _resultadoActual = null;
    } catch (e, stackTrace) {
      debugPrint('❌ Error al guardar turnos: $e');
      debugPrint(stackTrace.toString());
      emit(GeneracionAutomaticaError('Error al guardar: $e'));
    }
  }

  Future<void> _onGeneracionCancelada(
    GeneracionAutomaticaCancelada event,
    Emitter<GeneracionAutomaticaState> emit,
  ) async {
    debugPrint('🚫 Generación cancelada por el usuario');
    _resultadoActual = null;
    emit(const GeneracionAutomaticaInitial());
  }
}
