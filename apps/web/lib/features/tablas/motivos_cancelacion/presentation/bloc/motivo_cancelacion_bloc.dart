import 'package:ambutrack_core/ambutrack_core.dart';
import 'package:ambutrack_web/features/tablas/motivos_cancelacion/domain/repositories/motivo_cancelacion_repository.dart';
import 'package:ambutrack_web/features/tablas/motivos_cancelacion/presentation/bloc/motivo_cancelacion_event.dart';
import 'package:ambutrack_web/features/tablas/motivos_cancelacion/presentation/bloc/motivo_cancelacion_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

/// BLoC para gestionar los motivos de cancelación
@injectable
class MotivoCancelacionBloc
    extends Bloc<MotivoCancelacionEvent, MotivoCancelacionState> {
  MotivoCancelacionBloc(this._repository)
      : super(const MotivoCancelacionInitial()) {
    on<MotivoCancelacionLoadRequested>(_onLoadRequested);
    on<MotivoCancelacionCreateRequested>(_onCreateRequested);
    on<MotivoCancelacionUpdateRequested>(_onUpdateRequested);
    on<MotivoCancelacionDeleteRequested>(_onDeleteRequested);
  }

  final MotivoCancelacionRepository _repository;

  /// Carga todos los motivos
  Future<void> _onLoadRequested(
    MotivoCancelacionLoadRequested event,
    Emitter<MotivoCancelacionState> emit,
  ) async {
    try {
      debugPrint('🔄 MotivoCancelacionBloc: Cargando motivos...');
      emit(const MotivoCancelacionLoading());

      final List<MotivoCancelacionEntity> motivos = await _repository.getAll();

      debugPrint('✅ MotivoCancelacionBloc: ${motivos.length} motivos cargados');
      emit(MotivoCancelacionLoaded(motivos));
    } catch (e, stackTrace) {
      debugPrint('❌ MotivoCancelacionBloc: Error al cargar motivos: $e');
      debugPrint('Stack trace: $stackTrace');
      emit(MotivoCancelacionError('Error al cargar motivos: $e'));
    }
  }

  /// Crea un nuevo motivo
  Future<void> _onCreateRequested(
    MotivoCancelacionCreateRequested event,
    Emitter<MotivoCancelacionState> emit,
  ) async {
    try {
      debugPrint('🔄 MotivoCancelacionBloc: Creando motivo: ${event.motivo.nombre}');

      await _repository.create(event.motivo);

      debugPrint('✅ MotivoCancelacionBloc: Motivo creado exitosamente');

      // Recargar la lista
      add(const MotivoCancelacionLoadRequested());
    } catch (e, stackTrace) {
      debugPrint('❌ MotivoCancelacionBloc: Error al crear motivo: $e');
      debugPrint('Stack trace: $stackTrace');
      emit(MotivoCancelacionError('Error al crear motivo: $e'));

      // Recargar la lista para mantener consistencia
      add(const MotivoCancelacionLoadRequested());
    }
  }

  /// Actualiza un motivo existente
  Future<void> _onUpdateRequested(
    MotivoCancelacionUpdateRequested event,
    Emitter<MotivoCancelacionState> emit,
  ) async {
    try {
      debugPrint('🔄 MotivoCancelacionBloc: Actualizando motivo: ${event.motivo.nombre}');

      await _repository.update(event.motivo);

      debugPrint('✅ MotivoCancelacionBloc: Motivo actualizado exitosamente');

      // Recargar la lista
      add(const MotivoCancelacionLoadRequested());
    } catch (e, stackTrace) {
      debugPrint('❌ MotivoCancelacionBloc: Error al actualizar motivo: $e');
      debugPrint('Stack trace: $stackTrace');
      emit(MotivoCancelacionError('Error al actualizar motivo: $e'));

      // Recargar la lista para mantener consistencia
      add(const MotivoCancelacionLoadRequested());
    }
  }

  /// Elimina un motivo
  Future<void> _onDeleteRequested(
    MotivoCancelacionDeleteRequested event,
    Emitter<MotivoCancelacionState> emit,
  ) async {
    try {
      debugPrint('🔄 MotivoCancelacionBloc: Eliminando motivo con id=${event.id}');

      await _repository.delete(event.id);

      debugPrint('✅ MotivoCancelacionBloc: Motivo eliminado exitosamente');

      // Recargar la lista
      add(const MotivoCancelacionLoadRequested());
    } catch (e, stackTrace) {
      debugPrint('❌ MotivoCancelacionBloc: Error al eliminar motivo: $e');
      debugPrint('Stack trace: $stackTrace');
      emit(MotivoCancelacionError('Error al eliminar motivo: $e'));

      // Recargar la lista para mantener consistencia
      add(const MotivoCancelacionLoadRequested());
    }
  }
}
