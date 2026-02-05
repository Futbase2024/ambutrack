import 'package:ambutrack_core/ambutrack_core.dart';
import 'package:ambutrack_web/features/tablas/centros_hospitalarios/domain/repositories/centro_hospitalario_repository.dart';
import 'package:ambutrack_web/features/tablas/centros_hospitalarios/presentation/bloc/centro_hospitalario_event.dart';
import 'package:ambutrack_web/features/tablas/centros_hospitalarios/presentation/bloc/centro_hospitalario_state.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

/// BLoC para gestionar el estado de Centros Hospitalarios
@injectable
class CentroHospitalarioBloc extends Bloc<CentroHospitalarioEvent, CentroHospitalarioState> {
  CentroHospitalarioBloc(this._repository) : super(const CentroHospitalarioInitial()) {
    on<CentroHospitalarioLoadAllRequested>(_onLoadAllRequested);
    on<CentroHospitalarioCreateRequested>(_onCreateRequested);
    on<CentroHospitalarioUpdateRequested>(_onUpdateRequested);
    on<CentroHospitalarioDeleteRequested>(_onDeleteRequested);
  }

  final CentroHospitalarioRepository _repository;

  Future<void> _onLoadAllRequested(
    CentroHospitalarioLoadAllRequested event,
    Emitter<CentroHospitalarioState> emit,
  ) async {
    try {
      debugPrint('🚀 CentroHospitalarioBloc: Cargando centros hospitalarios...');
      emit(const CentroHospitalarioLoading());

      final List<CentroHospitalarioEntity> centros = await _repository.getAll();

      debugPrint('✅ CentroHospitalarioBloc: ${centros.length} centros cargados');
      emit(CentroHospitalarioLoaded(centros));
    } catch (e) {
      debugPrint('❌ CentroHospitalarioBloc.loadAll: Error: $e');
      emit(CentroHospitalarioError(e.toString()));
    }
  }

  Future<void> _onCreateRequested(
    CentroHospitalarioCreateRequested event,
    Emitter<CentroHospitalarioState> emit,
  ) async {
    try {
      debugPrint('🚀 CentroHospitalarioBloc: Creando centro: ${event.centro.nombre}');
      emit(const CentroHospitalarioLoading());

      await _repository.create(event.centro);

      debugPrint('✅ CentroHospitalarioBloc: Centro creado exitosamente');

      // Recargar lista
      final List<CentroHospitalarioEntity> centros = await _repository.getAll();
      emit(CentroHospitalarioLoaded(centros));
    } catch (e) {
      debugPrint('❌ CentroHospitalarioBloc.create: Error: $e');
      emit(CentroHospitalarioError(e.toString()));
    }
  }

  Future<void> _onUpdateRequested(
    CentroHospitalarioUpdateRequested event,
    Emitter<CentroHospitalarioState> emit,
  ) async {
    try {
      debugPrint('🚀 CentroHospitalarioBloc: Actualizando centro: ${event.centro.id}');
      emit(const CentroHospitalarioLoading());

      await _repository.update(event.centro);

      debugPrint('✅ CentroHospitalarioBloc: Centro actualizado exitosamente');

      // Recargar lista
      final List<CentroHospitalarioEntity> centros = await _repository.getAll();
      emit(CentroHospitalarioLoaded(centros));
    } catch (e) {
      debugPrint('❌ CentroHospitalarioBloc.update: Error: $e');
      emit(CentroHospitalarioError(e.toString()));
    }
  }

  Future<void> _onDeleteRequested(
    CentroHospitalarioDeleteRequested event,
    Emitter<CentroHospitalarioState> emit,
  ) async {
    try {
      debugPrint('🚀 CentroHospitalarioBloc: Eliminando centro: ${event.id}');
      emit(const CentroHospitalarioLoading());

      await _repository.delete(event.id);

      debugPrint('✅ CentroHospitalarioBloc: Centro eliminado exitosamente');

      // Recargar lista
      final List<CentroHospitalarioEntity> centros = await _repository.getAll();
      emit(CentroHospitalarioLoaded(centros));
    } catch (e) {
      debugPrint('❌ CentroHospitalarioBloc.delete: Error: $e');
      emit(CentroHospitalarioError(e.toString()));
    }
  }
}
