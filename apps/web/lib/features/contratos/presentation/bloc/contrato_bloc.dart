import 'package:ambutrack_core/ambutrack_core.dart';
import 'package:ambutrack_web/features/contratos/domain/repositories/contrato_repository.dart';
import 'package:ambutrack_web/features/contratos/presentation/bloc/contrato_event.dart';
import 'package:ambutrack_web/features/contratos/presentation/bloc/contrato_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

/// BLoC para gestión de contratos
@injectable
class ContratoBloc extends Bloc<ContratoEvent, ContratoState> {

  ContratoBloc(this._repository) : super(const ContratoInitial()) {
    on<ContratoLoadRequested>(_onLoadRequested);
    on<ContratoLoadActivosRequested>(_onLoadActivosRequested);
    on<ContratoLoadVigentesRequested>(_onLoadVigentesRequested);
    on<ContratoLoadByHospitalRequested>(_onLoadByHospitalRequested);
    on<ContratoCreateRequested>(_onCreateRequested);
    on<ContratoUpdateRequested>(_onUpdateRequested);
    on<ContratoDeleteRequested>(_onDeleteRequested);
    on<ContratoToggleActivoRequested>(_onToggleActivoRequested);
  }
  final ContratoRepository _repository;

  Future<void> _onLoadRequested(
    ContratoLoadRequested event,
    Emitter<ContratoState> emit,
  ) async {
    try {
      emit(const ContratoLoading());
      debugPrint('🚀 ContratoBloc: Cargando todos los contratos...');

      final List<ContratoEntity> contratos = await _repository.getAll();

      debugPrint('✅ ContratoBloc: ${contratos.length} contratos cargados');
      emit(ContratoLoaded(contratos));
    } catch (e) {
      debugPrint('❌ ContratoBloc: Error al cargar contratos: $e');
      emit(ContratoError('Error al cargar contratos: $e'));
    }
  }

  Future<void> _onLoadActivosRequested(
    ContratoLoadActivosRequested event,
    Emitter<ContratoState> emit,
  ) async {
    try {
      emit(const ContratoLoading());
      debugPrint('🚀 ContratoBloc: Cargando contratos activos...');

      final List<ContratoEntity> contratos = await _repository.getActivos();

      debugPrint('✅ ContratoBloc: ${contratos.length} contratos activos');
      emit(ContratoLoaded(contratos));
    } catch (e) {
      debugPrint('❌ ContratoBloc: Error al cargar contratos activos: $e');
      emit(ContratoError('Error al cargar contratos activos: $e'));
    }
  }

  Future<void> _onLoadVigentesRequested(
    ContratoLoadVigentesRequested event,
    Emitter<ContratoState> emit,
  ) async {
    try {
      emit(const ContratoLoading());
      debugPrint('🚀 ContratoBloc: Cargando contratos vigentes...');

      final List<ContratoEntity> contratos = await _repository.getVigentes();

      debugPrint('✅ ContratoBloc: ${contratos.length} contratos vigentes');
      emit(ContratoLoaded(contratos));
    } catch (e) {
      debugPrint('❌ ContratoBloc: Error al cargar contratos vigentes: $e');
      emit(ContratoError('Error al cargar contratos vigentes: $e'));
    }
  }

  Future<void> _onLoadByHospitalRequested(
    ContratoLoadByHospitalRequested event,
    Emitter<ContratoState> emit,
  ) async {
    try {
      emit(const ContratoLoading());
      debugPrint(
        '🚀 ContratoBloc: Cargando contratos del hospital ${event.hospitalId}...',
      );

      final List<ContratoEntity> contratos = await _repository.getByHospitalId(event.hospitalId);

      debugPrint('✅ ContratoBloc: ${contratos.length} contratos encontrados');
      emit(ContratoLoaded(contratos));
    } catch (e) {
      debugPrint('❌ ContratoBloc: Error al cargar contratos por hospital: $e');
      emit(ContratoError('Error al cargar contratos por hospital: $e'));
    }
  }

  Future<void> _onCreateRequested(
    ContratoCreateRequested event,
    Emitter<ContratoState> emit,
  ) async {
    try {
      emit(const ContratoLoading());
      debugPrint('🚀 ContratoBloc: Creando contrato ${event.contrato.codigo}...');

      await _repository.create(event.contrato);

      // Recargar lista
      final List<ContratoEntity> contratos = await _repository.getAll();

      debugPrint('✅ ContratoBloc: Contrato creado exitosamente');
      emit(
        ContratoOperationSuccess(
          'Contrato creado exitosamente',
          contratos,
        ),
      );
    } catch (e) {
      debugPrint('❌ ContratoBloc: Error al crear contrato: $e');
      emit(ContratoError('Error al crear contrato: $e'));
    }
  }

  Future<void> _onUpdateRequested(
    ContratoUpdateRequested event,
    Emitter<ContratoState> emit,
  ) async {
    try {
      emit(const ContratoLoading());
      debugPrint(
        '🚀 ContratoBloc: Actualizando contrato ${event.contrato.codigo}...',
      );

      await _repository.update(event.contrato);

      // Recargar lista
      final List<ContratoEntity> contratos = await _repository.getAll();

      debugPrint('✅ ContratoBloc: Contrato actualizado exitosamente');
      emit(
        ContratoOperationSuccess(
          'Contrato actualizado exitosamente',
          contratos,
        ),
      );
    } catch (e) {
      debugPrint('❌ ContratoBloc: Error al actualizar contrato: $e');
      emit(ContratoError('Error al actualizar contrato: $e'));
    }
  }

  Future<void> _onDeleteRequested(
    ContratoDeleteRequested event,
    Emitter<ContratoState> emit,
  ) async {
    try {
      emit(const ContratoLoading());
      debugPrint('🚀 ContratoBloc: Eliminando contrato ${event.id}...');

      await _repository.delete(event.id);

      // Recargar lista
      final List<ContratoEntity> contratos = await _repository.getAll();

      debugPrint('✅ ContratoBloc: Contrato eliminado exitosamente');
      emit(
        ContratoOperationSuccess(
          'Contrato eliminado exitosamente',
          contratos,
        ),
      );
    } catch (e) {
      debugPrint('❌ ContratoBloc: Error al eliminar contrato: $e');
      emit(ContratoError('Error al eliminar contrato: $e'));
    }
  }

  Future<void> _onToggleActivoRequested(
    ContratoToggleActivoRequested event,
    Emitter<ContratoState> emit,
  ) async {
    try {
      emit(const ContratoLoading());
      debugPrint(
        '🚀 ContratoBloc: Cambiando estado del contrato ${event.id}...',
      );

      await _repository.toggleActivo(event.id, activo: event.activo);

      // Recargar lista
      final List<ContratoEntity> contratos = await _repository.getAll();

      final String mensaje =
          event.activo ? 'Contrato activado' : 'Contrato desactivado';
      debugPrint('✅ ContratoBloc: $mensaje');
      emit(ContratoOperationSuccess(mensaje, contratos));
    } catch (e) {
      debugPrint('❌ ContratoBloc: Error al cambiar estado del contrato: $e');
      emit(ContratoError('Error al cambiar estado del contrato: $e'));
    }
  }
}
