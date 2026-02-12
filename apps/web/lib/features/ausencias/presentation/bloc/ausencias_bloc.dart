import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/repositories/ausencia_repository.dart';
import '../../domain/repositories/tipo_ausencia_repository.dart';
import 'ausencias_event.dart';
import 'ausencias_state.dart';

/// BLoC para gestionar Ausencias y Tipos de Ausencia
@injectable
class AusenciasBloc extends Bloc<AusenciasEvent, AusenciasState> {
  AusenciasBloc(
    this._ausenciaRepository,
    this._tipoAusenciaRepository,
  ) : super(const AusenciasInitial()) {
    on<AusenciasLoadRequested>(_onLoadRequested);
    on<AusenciasLoadByPersonalRequested>(_onLoadByPersonalRequested);
    on<AusenciasLoadByEstadoRequested>(_onLoadByEstadoRequested);
    on<AusenciasLoadByRangoFechasRequested>(_onLoadByRangoFechasRequested);
    on<AusenciaCreateRequested>(_onCreateRequested);
    on<AusenciaUpdateRequested>(_onUpdateRequested);
    on<AusenciaAprobarRequested>(_onAprobarRequested);
    on<AusenciaRechazarRequested>(_onRechazarRequested);
    on<AusenciaDeleteRequested>(_onDeleteRequested);
    on<TiposAusenciaLoadRequested>(_onTiposLoadRequested);
    on<AusenciaEliminarDiasParcialRequested>(_onEliminarDiasParcialRequested);
  }

  final AusenciaRepository _ausenciaRepository;
  final TipoAusenciaRepository _tipoAusenciaRepository;

  /// Helper: Actualiza una ausencia específica en el estado actual
  void _updateAusenciaInState(
    String idAusencia,
    AusenciaEntity Function(AusenciaEntity) updateFn,
    Emitter<AusenciasState> emit,
  ) {
    if (state is AusenciasLoaded) {
      final AusenciasLoaded currentState = state as AusenciasLoaded;

      final List<AusenciaEntity> updatedAusencias = currentState.ausencias.map((AusenciaEntity ausencia) {
        if (ausencia.id == idAusencia) {
          return updateFn(ausencia);
        }
        return ausencia;
      }).toList();

      emit(currentState.copyWith(ausencias: updatedAusencias));
    }
  }

  /// Helper: Refetch silencioso desde servidor
  Future<void> _refetchFromServer(Emitter<AusenciasState> emit) async {
    final List<AusenciaEntity> ausencias = await _ausenciaRepository.getAll();
    final List<TipoAusenciaEntity> tiposAusencia = await _tipoAusenciaRepository.getAll();

    emit(AusenciasLoaded(
      ausencias: ausencias,
      tiposAusencia: tiposAusencia,
    ));
  }

  /// Carga todas las ausencias y tipos
  Future<void> _onLoadRequested(
    AusenciasLoadRequested event,
    Emitter<AusenciasState> emit,
  ) async {
    debugPrint('🚀 AusenciasBloc: Cargando todas las ausencias...');
    emit(const AusenciasLoading());

    try {
      final List<AusenciaEntity> ausencias = await _ausenciaRepository.getAll();
      final List<TipoAusenciaEntity> tiposAusencia = await _tipoAusenciaRepository.getAll();

      debugPrint('🚀 AusenciasBloc: ✅ ${ausencias.length} ausencias y ${tiposAusencia.length} tipos cargados');
      emit(AusenciasLoaded(
        ausencias: ausencias,
        tiposAusencia: tiposAusencia,
      ));
    } catch (e, stack) {
      debugPrint('🚀 AusenciasBloc: ❌ Error al cargar: $e');
      debugPrint('Stack: $stack');
      emit(AusenciasError(e.toString()));
    }
  }

  /// Carga ausencias por personal
  Future<void> _onLoadByPersonalRequested(
    AusenciasLoadByPersonalRequested event,
    Emitter<AusenciasState> emit,
  ) async {
    debugPrint('🚀 AusenciasBloc: Cargando ausencias de personal: ${event.idPersonal}');
    emit(const AusenciasLoading());

    try {
      final List<AusenciaEntity> ausencias = await _ausenciaRepository.getByPersonal(event.idPersonal);
      final List<TipoAusenciaEntity> tiposAusencia = await _tipoAusenciaRepository.getAll();

      debugPrint('🚀 AusenciasBloc: ✅ ${ausencias.length} ausencias del personal');
      emit(AusenciasLoaded(
        ausencias: ausencias,
        tiposAusencia: tiposAusencia,
      ));
    } catch (e, stack) {
      debugPrint('🚀 AusenciasBloc: ❌ Error: $e');
      debugPrint('Stack: $stack');
      emit(AusenciasError(e.toString()));
    }
  }

  /// Carga ausencias por estado
  Future<void> _onLoadByEstadoRequested(
    AusenciasLoadByEstadoRequested event,
    Emitter<AusenciasState> emit,
  ) async {
    debugPrint('🚀 AusenciasBloc: Cargando ausencias en estado: ${event.estado}');
    emit(const AusenciasLoading());

    try {
      final List<AusenciaEntity> ausencias = await _ausenciaRepository.getByEstado(event.estado);
      final List<TipoAusenciaEntity> tiposAusencia = await _tipoAusenciaRepository.getAll();

      debugPrint('🚀 AusenciasBloc: ✅ ${ausencias.length} ausencias en estado ${event.estado}');
      emit(AusenciasLoaded(
        ausencias: ausencias,
        tiposAusencia: tiposAusencia,
      ));
    } catch (e, stack) {
      debugPrint('🚀 AusenciasBloc: ❌ Error: $e');
      debugPrint('Stack: $stack');
      emit(AusenciasError(e.toString()));
    }
  }

  /// Carga ausencias por rango de fechas
  Future<void> _onLoadByRangoFechasRequested(
    AusenciasLoadByRangoFechasRequested event,
    Emitter<AusenciasState> emit,
  ) async {
    debugPrint('🚀 AusenciasBloc: Cargando ausencias entre ${event.fechaInicio} y ${event.fechaFin}');
    emit(const AusenciasLoading());

    try {
      final List<AusenciaEntity> ausencias = await _ausenciaRepository.getByRangoFechas(
        fechaInicio: event.fechaInicio,
        fechaFin: event.fechaFin,
      );
      final List<TipoAusenciaEntity> tiposAusencia = await _tipoAusenciaRepository.getAll();

      debugPrint('🚀 AusenciasBloc: ✅ ${ausencias.length} ausencias en rango');
      emit(AusenciasLoaded(
        ausencias: ausencias,
        tiposAusencia: tiposAusencia,
      ));
    } catch (e, stack) {
      debugPrint('🚀 AusenciasBloc: ❌ Error: $e');
      debugPrint('Stack: $stack');
      emit(AusenciasError(e.toString()));
    }
  }

  /// Crea una nueva ausencia
  Future<void> _onCreateRequested(
    AusenciaCreateRequested event,
    Emitter<AusenciasState> emit,
  ) async {
    debugPrint('🚀 AusenciasBloc: Creando ausencia...');

    try {
      await _ausenciaRepository.create(event.ausencia);
      debugPrint('🚀 AusenciasBloc: ✅ Ausencia creada');

      // Recargar todas las ausencias
      add(const AusenciasLoadRequested());
    } catch (e, stack) {
      debugPrint('🚀 AusenciasBloc: ❌ Error al crear: $e');
      debugPrint('Stack: $stack');
      emit(AusenciasError(e.toString()));
    }
  }

  /// Actualiza una ausencia (optimistic update + sync)
  Future<void> _onUpdateRequested(
    AusenciaUpdateRequested event,
    Emitter<AusenciasState> emit,
  ) async {
    debugPrint('🚀 AusenciasBloc: Actualizando ausencia ID: ${event.ausencia.id}');

    final AusenciasState previousState = state;

    try {
      // 1️⃣ ACTUALIZACIÓN OPTIMISTA (instantánea, sin loading)
      _updateAusenciaInState(
        event.ausencia.id,
        (_) => event.ausencia,
        emit,
      );

      // 2️⃣ SINCRONIZACIÓN CON SERVIDOR
      await _ausenciaRepository.update(event.ausencia);
      debugPrint('🚀 AusenciasBloc: ✅ Ausencia actualizada en servidor');

      // 3️⃣ REFETCH SILENCIOSO
      await _refetchFromServer(emit);
    } catch (e, stack) {
      debugPrint('🚀 AusenciasBloc: ❌ Error al actualizar: $e');
      debugPrint('Stack: $stack');

      // 4️⃣ ROLLBACK
      if (previousState is AusenciasLoaded) {
        emit(previousState);
      }
      emit(AusenciasError(e.toString()));
    }
  }

  /// Aprueba una ausencia (optimistic update + sync)
  Future<void> _onAprobarRequested(
    AusenciaAprobarRequested event,
    Emitter<AusenciasState> emit,
  ) async {
    debugPrint('🚀 AusenciasBloc: Aprobando ausencia ID: ${event.idAusencia}');

    // Guardar estado actual por si falla
    final AusenciasState previousState = state;

    try {
      // 1️⃣ ACTUALIZACIÓN OPTIMISTA (instantánea, sin loading)
      _updateAusenciaInState(
        event.idAusencia,
        (AusenciaEntity ausencia) => ausencia.copyWith(
          estado: EstadoAusencia.aprobada,
          aprobadoPor: event.aprobadoPor,
          observaciones: event.observaciones,
          fechaAprobacion: DateTime.now(),
        ),
        emit,
      );
      debugPrint('🚀 AusenciasBloc: ✅ UI actualizada optimistamente');

      // 2️⃣ SINCRONIZACIÓN CON SERVIDOR (en segundo plano)
      await _ausenciaRepository.aprobar(
        idAusencia: event.idAusencia,
        aprobadoPor: event.aprobadoPor,
        observaciones: event.observaciones,
      );
      debugPrint('🚀 AusenciasBloc: ✅ Servidor sincronizado');

      // 3️⃣ REFETCH SILENCIOSO (garantiza consistencia)
      await _refetchFromServer(emit);
      debugPrint('🚀 AusenciasBloc: ✅ Datos sincronizados desde servidor');
    } catch (e, stack) {
      debugPrint('🚀 AusenciasBloc: ❌ Error al aprobar: $e');
      debugPrint('Stack: $stack');

      // 4️⃣ ROLLBACK (restaurar estado anterior)
      if (previousState is AusenciasLoaded) {
        emit(previousState);
        debugPrint('🚀 AusenciasBloc: ⏪ Rollback aplicado');
      }

      emit(AusenciasError(e.toString()));
    }
  }

  /// Rechaza una ausencia (optimistic update + sync)
  Future<void> _onRechazarRequested(
    AusenciaRechazarRequested event,
    Emitter<AusenciasState> emit,
  ) async {
    debugPrint('🚀 AusenciasBloc: Rechazando ausencia ID: ${event.idAusencia}');

    // Guardar estado actual por si falla
    final AusenciasState previousState = state;

    try {
      // 1️⃣ ACTUALIZACIÓN OPTIMISTA (instantánea, sin loading)
      _updateAusenciaInState(
        event.idAusencia,
        (AusenciaEntity ausencia) => ausencia.copyWith(
          estado: EstadoAusencia.rechazada,
          aprobadoPor: event.aprobadoPor,
          observaciones: event.observaciones,
          fechaAprobacion: DateTime.now(),
        ),
        emit,
      );
      debugPrint('🚀 AusenciasBloc: ✅ UI actualizada optimistamente');

      // 2️⃣ SINCRONIZACIÓN CON SERVIDOR (en segundo plano)
      await _ausenciaRepository.rechazar(
        idAusencia: event.idAusencia,
        aprobadoPor: event.aprobadoPor,
        observaciones: event.observaciones,
      );
      debugPrint('🚀 AusenciasBloc: ✅ Servidor sincronizado');

      // 3️⃣ REFETCH SILENCIOSO (garantiza consistencia)
      await _refetchFromServer(emit);
      debugPrint('🚀 AusenciasBloc: ✅ Datos sincronizados desde servidor');
    } catch (e, stack) {
      debugPrint('🚀 AusenciasBloc: ❌ Error al rechazar: $e');
      debugPrint('Stack: $stack');

      // 4️⃣ ROLLBACK (restaurar estado anterior)
      if (previousState is AusenciasLoaded) {
        emit(previousState);
        debugPrint('🚀 AusenciasBloc: ⏪ Rollback aplicado');
      }

      emit(AusenciasError(e.toString()));
    }
  }

  /// Elimina una ausencia (optimistic update + sync)
  Future<void> _onDeleteRequested(
    AusenciaDeleteRequested event,
    Emitter<AusenciasState> emit,
  ) async {
    debugPrint('🚀 AusenciasBloc: Eliminando ausencia ID: ${event.id}');

    // Guardar estado actual por si falla
    final AusenciasState previousState = state;

    try {
      // 1️⃣ ACTUALIZACIÓN OPTIMISTA (instantánea, sin loading)
      if (state is AusenciasLoaded) {
        final AusenciasLoaded currentState = state as AusenciasLoaded;
        final List<AusenciaEntity> updatedAusencias = currentState.ausencias.where((AusenciaEntity ausencia) => ausencia.id != event.id).toList();
        emit(currentState.copyWith(ausencias: updatedAusencias));
        debugPrint('🚀 AusenciasBloc: ✅ UI actualizada optimistamente (ausencia removida)');
      }

      // 2️⃣ SINCRONIZACIÓN CON SERVIDOR (en segundo plano)
      await _ausenciaRepository.delete(event.id);
      debugPrint('🚀 AusenciasBloc: ✅ Servidor sincronizado (ausencia eliminada)');

      // 3️⃣ REFETCH SILENCIOSO (garantiza consistencia)
      await _refetchFromServer(emit);
      debugPrint('🚀 AusenciasBloc: ✅ Datos sincronizados desde servidor');
    } catch (e, stack) {
      debugPrint('🚀 AusenciasBloc: ❌ Error al eliminar: $e');
      debugPrint('Stack: $stack');

      // 4️⃣ ROLLBACK (restaurar estado anterior)
      if (previousState is AusenciasLoaded) {
        emit(previousState);
        debugPrint('🚀 AusenciasBloc: ⏪ Rollback aplicado (ausencia restaurada)');
      }

      emit(AusenciasError(e.toString()));
    }
  }

  /// Carga solo los tipos de ausencia
  Future<void> _onTiposLoadRequested(
    TiposAusenciaLoadRequested event,
    Emitter<AusenciasState> emit,
  ) async {
    debugPrint('🚀 AusenciasBloc: Cargando tipos de ausencia...');
    emit(const AusenciasLoading());

    try {
      final List<TipoAusenciaEntity> tiposAusencia = await _tipoAusenciaRepository.getAll();

      debugPrint('🚀 AusenciasBloc: ✅ ${tiposAusencia.length} tipos cargados');

      if (state is AusenciasLoaded) {
        emit((state as AusenciasLoaded).copyWith(tiposAusencia: tiposAusencia));
      } else {
        emit(AusenciasLoaded(
          ausencias: const <AusenciaEntity>[],
          tiposAusencia: tiposAusencia,
        ));
      }
    } catch (e, stack) {
      debugPrint('🚀 AusenciasBloc: ❌ Error al cargar tipos: $e');
      debugPrint('Stack: $stack');
      emit(AusenciasError(e.toString()));
    }
  }

  /// Elimina días parciales de una ausencia
  ///
  /// Casos:
  /// 1. Si se elimina todo el rango → eliminar ausencia completa
  /// 2. Si se elimina desde el inicio → modificar fechaInicio
  /// 3. Si se elimina hasta el final → modificar fechaFin
  /// 4. Si se elimina del medio → dividir en dos ausencias
  Future<void> _onEliminarDiasParcialRequested(
    AusenciaEliminarDiasParcialRequested event,
    Emitter<AusenciasState> emit,
  ) async {
    debugPrint('🚀 AusenciasBloc: Eliminando días parciales de ausencia ID: ${event.ausencia.id}');
    debugPrint('   Rango original: ${event.ausencia.fechaInicio} - ${event.ausencia.fechaFin}');
    debugPrint('   Rango a eliminar: ${event.fechaInicioEliminar} - ${event.fechaFinEliminar}');

    final AusenciasState previousState = state;

    try {
      final DateTime fechaInicioOriginal = event.ausencia.fechaInicio;
      final DateTime fechaFinOriginal = event.ausencia.fechaFin;
      final DateTime fechaInicioEliminar = event.fechaInicioEliminar;
      final DateTime fechaFinEliminar = event.fechaFinEliminar;

      // Normalizar fechas (sin hora)
      final DateTime inicioOrig = DateTime(fechaInicioOriginal.year, fechaInicioOriginal.month, fechaInicioOriginal.day);
      final DateTime finOrig = DateTime(fechaFinOriginal.year, fechaFinOriginal.month, fechaFinOriginal.day);
      final DateTime inicioElim = DateTime(fechaInicioEliminar.year, fechaInicioEliminar.month, fechaInicioEliminar.day);
      final DateTime finElim = DateTime(fechaFinEliminar.year, fechaFinEliminar.month, fechaFinEliminar.day);

      // Caso 1: Eliminar todo el rango (fechas iguales o el rango a eliminar cubre toda la ausencia)
      if ((inicioElim.isAtSameMomentAs(inicioOrig) || inicioElim.isBefore(inicioOrig)) &&
          (finElim.isAtSameMomentAs(finOrig) || finElim.isAfter(finOrig))) {
        debugPrint('   → Caso 1: Eliminando ausencia completa');
        await _ausenciaRepository.delete(event.ausencia.id);
      }
      // Caso 2: Eliminar desde el inicio (mantener solo la parte final)
      else if (inicioElim.isAtSameMomentAs(inicioOrig) || inicioElim.isBefore(inicioOrig)) {
        debugPrint('   → Caso 2: Recortando desde el inicio');
        final DateTime nuevaFechaInicio = finElim.add(const Duration(days: 1));
        final AusenciaEntity ausenciaActualizada = event.ausencia.copyWith(
          fechaInicio: nuevaFechaInicio,
          updatedAt: DateTime.now(),
        );
        await _ausenciaRepository.update(ausenciaActualizada);
      }
      // Caso 3: Eliminar hasta el final (mantener solo la parte inicial)
      else if (finElim.isAtSameMomentAs(finOrig) || finElim.isAfter(finOrig)) {
        debugPrint('   → Caso 3: Recortando desde el final');
        final DateTime nuevaFechaFin = inicioElim.subtract(const Duration(days: 1));
        final AusenciaEntity ausenciaActualizada = event.ausencia.copyWith(
          fechaFin: nuevaFechaFin,
          updatedAt: DateTime.now(),
        );
        await _ausenciaRepository.update(ausenciaActualizada);
      }
      // Caso 4: Eliminar del medio (dividir en dos)
      else {
        debugPrint('   → Caso 4: Dividiendo ausencia en dos');

        // Crear primera parte (desde inicio original hasta un día antes de eliminar)
        final AusenciaEntity primeraParte = event.ausencia.copyWith(
          fechaFin: inicioElim.subtract(const Duration(days: 1)),
          updatedAt: DateTime.now(),
        );

        // Crear segunda parte (desde un día después de eliminar hasta fin original)
        // Necesita nuevo ID, así que creamos una nueva ausencia
        final AusenciaEntity segundaParte = AusenciaEntity(
          id: '', // Se generará automáticamente
          idPersonal: event.ausencia.idPersonal,
          idTipoAusencia: event.ausencia.idTipoAusencia,
          fechaInicio: finElim.add(const Duration(days: 1)),
          fechaFin: finOrig,
          motivo: event.ausencia.motivo,
          estado: event.ausencia.estado,
          observaciones: event.ausencia.observaciones,
          documentoAdjunto: event.ausencia.documentoAdjunto,
          documentoStoragePath: event.ausencia.documentoStoragePath,
          fechaAprobacion: event.ausencia.fechaAprobacion,
          aprobadoPor: event.ausencia.aprobadoPor,
          activo: event.ausencia.activo,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Actualizar la primera parte
        await _ausenciaRepository.update(primeraParte);

        // Crear la segunda parte
        await _ausenciaRepository.create(segundaParte);
      }

      debugPrint('🚀 AusenciasBloc: ✅ Días parciales eliminados exitosamente');

      // Recargar datos
      await _refetchFromServer(emit);
    } catch (e, stack) {
      debugPrint('🚀 AusenciasBloc: ❌ Error al eliminar días parciales: $e');
      debugPrint('Stack: $stack');

      // Rollback
      if (previousState is AusenciasLoaded) {
        emit(previousState);
      }

      emit(AusenciasError(e.toString()));
    }
  }
}
