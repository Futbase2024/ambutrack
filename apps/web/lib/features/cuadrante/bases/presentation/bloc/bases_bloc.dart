import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/features/cuadrante/bases/domain/repositories/bases_repository.dart';
import 'package:ambutrack_web/features/cuadrante/bases/presentation/bloc/bases_event.dart';
import 'package:ambutrack_web/features/cuadrante/bases/presentation/bloc/bases_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

/// BLoC para la gestión de Bases/Centros Operativos
@injectable
class BasesBloc extends Bloc<BasesEvent, BasesState> {
  BasesBloc(this._basesRepository) : super(const BasesInitial()) {
    on<BasesLoadRequested>(_onBasesLoadRequested);
    on<BasesActivasLoadRequested>(_onBasesActivasLoadRequested);
    on<BaseCreateRequested>(_onBaseCreateRequested);
    on<BaseUpdateRequested>(_onBaseUpdateRequested);
    on<BaseDeleteRequested>(_onBaseDeleteRequested);
    on<BaseDeactivateRequested>(_onBaseDeactivateRequested);
    on<BaseReactivateRequested>(_onBaseReactivateRequested);
    // Deshabilitados temporalmente (campos codigo y tipo eliminados de Supabase)
    // on<BaseBuscarPorCodigoRequested>(_onBaseBuscarPorCodigoRequested);
    // on<BasesFiltrarPorTipoRequested>(_onBasesFiltrarPorTipoRequested);
    on<BasesFiltrarPorPoblacionRequested>(_onBasesFiltrarPorPoblacionRequested);
    // on<BaseVerificarCodigoRequested>(_onBaseVerificarCodigoRequested);
  }

  final BasesRepository _basesRepository;

  /// Carga todas las bases
  Future<void> _onBasesLoadRequested(
    BasesLoadRequested event,
    Emitter<BasesState> emit,
  ) async {
    debugPrint('🚀 BasesBloc: Cargando todas las bases...');
    emit(const BasesLoading());

    try {
      final List<BaseCentroEntity> bases = await _basesRepository.getAll();
      debugPrint('✅ BasesBloc: ${bases.length} bases cargadas');
      emit(BasesLoaded(bases));
    } catch (e) {
      debugPrint('❌ BasesBloc: Error al cargar bases - $e');
      emit(BasesError('Error al cargar bases: $e'));
    }
  }

  /// Carga solo las bases activas
  Future<void> _onBasesActivasLoadRequested(
    BasesActivasLoadRequested event,
    Emitter<BasesState> emit,
  ) async {
    debugPrint('🚀 BasesBloc: Cargando bases activas...');
    emit(const BasesLoading());

    try {
      final List<BaseCentroEntity> bases = await _basesRepository.getActivas();
      debugPrint('✅ BasesBloc: ${bases.length} bases activas cargadas');
      emit(BasesLoaded(bases));
    } catch (e) {
      debugPrint('❌ BasesBloc: Error al cargar bases activas - $e');
      emit(BasesError('Error al cargar bases activas: $e'));
    }
  }

  /// Crea una nueva base
  Future<void> _onBaseCreateRequested(
    BaseCreateRequested event,
    Emitter<BasesState> emit,
  ) async {
    debugPrint('🚀 BasesBloc: Creando base ${event.base.codigo}...');
    emit(const BasesLoading());

    try {
      await _basesRepository.create(event.base);
      debugPrint('✅ BasesBloc: Base ${event.base.codigo} creada exitosamente');

      // Recargar todas las bases
      final List<BaseCentroEntity> bases = await _basesRepository.getAll();
      emit(BaseOperationSuccess(
        'Base "${event.base.nombre}" creada exitosamente',
        bases,
      ));
    } catch (e) {
      debugPrint('❌ BasesBloc: Error al crear base - $e');
      emit(BasesError('Error al crear base: $e'));
    }
  }

  /// Actualiza una base existente
  Future<void> _onBaseUpdateRequested(
    BaseUpdateRequested event,
    Emitter<BasesState> emit,
  ) async {
    debugPrint('🚀 BasesBloc: Actualizando base ${event.base.codigo}...');
    emit(const BasesLoading());

    try {
      await _basesRepository.update(event.base);
      debugPrint('✅ BasesBloc: Base ${event.base.codigo} actualizada exitosamente');

      // Recargar todas las bases
      final List<BaseCentroEntity> bases = await _basesRepository.getAll();
      emit(BaseOperationSuccess(
        'Base "${event.base.nombre}" actualizada exitosamente',
        bases,
      ));
    } catch (e) {
      debugPrint('❌ BasesBloc: Error al actualizar base - $e');
      emit(BasesError('Error al actualizar base: $e'));
    }
  }

  /// Elimina una base (hard delete)
  Future<void> _onBaseDeleteRequested(
    BaseDeleteRequested event,
    Emitter<BasesState> emit,
  ) async {
    debugPrint('🚀 BasesBloc: Eliminando base ${event.baseId}...');
    emit(const BasesLoading());

    try {
      await _basesRepository.delete(event.baseId);
      debugPrint('✅ BasesBloc: Base ${event.baseId} eliminada exitosamente');

      // Recargar todas las bases
      final List<BaseCentroEntity> bases = await _basesRepository.getAll();
      emit(BaseOperationSuccess(
        'Base eliminada exitosamente',
        bases,
      ));
    } catch (e) {
      debugPrint('❌ BasesBloc: Error al eliminar base - $e');
      emit(BasesError('Error al eliminar base: $e'));
    }
  }

  /// Desactiva una base (soft delete)
  Future<void> _onBaseDeactivateRequested(
    BaseDeactivateRequested event,
    Emitter<BasesState> emit,
  ) async {
    debugPrint('🚀 BasesBloc: Desactivando base ${event.baseId}...');
    emit(const BasesLoading());

    try {
      final BaseCentroEntity baseDesactivada = await _basesRepository.deactivateBase(event.baseId);
      debugPrint('✅ BasesBloc: Base ${baseDesactivada.nombre} desactivada exitosamente');

      // Recargar todas las bases
      final List<BaseCentroEntity> bases = await _basesRepository.getAll();
      emit(BaseOperationSuccess(
        'Base "${baseDesactivada.nombre}" desactivada exitosamente',
        bases,
      ));
    } catch (e) {
      debugPrint('❌ BasesBloc: Error al desactivar base - $e');
      emit(BasesError('Error al desactivar base: $e'));
    }
  }

  /// Reactiva una base
  Future<void> _onBaseReactivateRequested(
    BaseReactivateRequested event,
    Emitter<BasesState> emit,
  ) async {
    debugPrint('🚀 BasesBloc: Reactivando base ${event.baseId}...');
    emit(const BasesLoading());

    try {
      final BaseCentroEntity baseReactivada = await _basesRepository.reactivateBase(event.baseId);
      debugPrint('✅ BasesBloc: Base ${baseReactivada.nombre} reactivada exitosamente');

      // Recargar todas las bases
      final List<BaseCentroEntity> bases = await _basesRepository.getAll();
      emit(BaseOperationSuccess(
        'Base "${baseReactivada.nombre}" reactivada exitosamente',
        bases,
      ));
    } catch (e) {
      debugPrint('❌ BasesBloc: Error al reactivar base - $e');
      emit(BasesError('Error al reactivar base: $e'));
    }
  }

  /// Busca una base por código
  // Deshabilitado temporalmente (campo codigo eliminado de Supabase)
  // Future<void> _onBaseBuscarPorCodigoRequested(
  //   BaseBuscarPorCodigoRequested event,
  //   Emitter<BasesState> emit,
  // ) async {
  //   debugPrint('🚀 BasesBloc: Buscando base por código ${event.codigo}...');
  //   emit(const BasesLoading());
  //
  //   try {
  //     final BaseCentroEntity? base = await _basesRepository.getByCodigo(event.codigo);
  //     if (base != null) {
  //       debugPrint('✅ BasesBloc: Base encontrada - ${base.nombre}');
  //     } else {
  //       debugPrint('⚠️ BasesBloc: Base no encontrada con código ${event.codigo}');
  //     }
  //     emit(BaseFoundByCodigo(base));
  //   } catch (e) {
  //     debugPrint('❌ BasesBloc: Error al buscar base por código - $e');
  //     emit(BasesError('Error al buscar base: $e'));
  //   }
  // }

  // Deshabilitado temporalmente (campo tipo eliminado de Supabase)
  // /// Filtra bases por tipo
  // Future<void> _onBasesFiltrarPorTipoRequested(
  //   BasesFiltrarPorTipoRequested event,
  //   Emitter<BasesState> emit,
  // ) async {
  //   debugPrint('🚀 BasesBloc: Filtrando bases por tipo ${event.tipo}...');
  //   emit(const BasesLoading());
  //
  //   try {
  //     final List<BaseCentroEntity> bases = await _basesRepository.getByTipo(event.tipo);
  //     debugPrint('✅ BasesBloc: ${bases.length} bases encontradas del tipo ${event.tipo}');
  //     emit(BasesLoaded(bases));
  //   } catch (e) {
  //     debugPrint('❌ BasesBloc: Error al filtrar bases por tipo - $e');
  //     emit(BasesError('Error al filtrar bases: $e'));
  //   }
  // }

  /// Filtra bases por población
  Future<void> _onBasesFiltrarPorPoblacionRequested(
    BasesFiltrarPorPoblacionRequested event,
    Emitter<BasesState> emit,
  ) async {
    debugPrint('🚀 BasesBloc: Filtrando bases por población ${event.poblacionId}...');
    emit(const BasesLoading());

    try {
      final List<BaseCentroEntity> bases = await _basesRepository.getByPoblacion(event.poblacionId);
      debugPrint('✅ BasesBloc: ${bases.length} bases encontradas en la población');
      emit(BasesLoaded(bases));
    } catch (e) {
      debugPrint('❌ BasesBloc: Error al filtrar bases por población - $e');
      emit(BasesError('Error al filtrar bases: $e'));
    }
  }

  // Deshabilitado temporalmente (campo codigo eliminado de Supabase)
  // /// Verifica si un código de base está disponible
  // Future<void> _onBaseVerificarCodigoRequested(
  //   BaseVerificarCodigoRequested event,
  //   Emitter<BasesState> emit,
  // ) async {
  //   debugPrint('🚀 BasesBloc: Verificando disponibilidad del código ${event.codigo}...');
  //
  //   try {
  //     final bool isAvailable = await _basesRepository.isCodigoAvailable(event.codigo);
  //     debugPrint(
  //       '✅ BasesBloc: Código ${event.codigo} ${isAvailable ? "disponible" : "no disponible"}',
  //     );
  //     emit(BaseCodigoVerified(event.codigo, isAvailable));
  //   } catch (e) {
  //     debugPrint('❌ BasesBloc: Error al verificar código - $e');
  //     emit(BasesError('Error al verificar código: $e'));
  //   }
  // }
}
