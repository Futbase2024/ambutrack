import 'package:ambutrack_core/ambutrack_core.dart';
import 'package:ambutrack_web/features/almacen/domain/repositories/almacen_repository.dart';
import 'package:ambutrack_web/features/almacen/presentation/bloc/proveedores/proveedores_event.dart';
import 'package:ambutrack_web/features/almacen/presentation/bloc/proveedores/proveedores_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

/// BLoC para gestión de Proveedores del Almacén
///
/// Maneja todas las operaciones CRUD de proveedores y búsqueda
@injectable
class ProveedoresBloc extends Bloc<ProveedoresEvent, ProveedoresState> {
  ProveedoresBloc(this._repository) : super(const ProveedoresInitial()) {
    on<ProveedoresLoadRequested>(_onLoadRequested);
    on<ProveedorCreateRequested>(_onCreateRequested);
    on<ProveedorUpdateRequested>(_onUpdateRequested);
    on<ProveedorDeleteRequested>(_onDeleteRequested);
    on<ProveedoresSearchRequested>(_onSearchRequested);
    on<ProveedoresSearchCleared>(_onSearchCleared);
  }

  final AlmacenRepository _repository;

  /// Carga todos los proveedores
  Future<void> _onLoadRequested(
    ProveedoresLoadRequested event,
    Emitter<ProveedoresState> emit,
  ) async {
    debugPrint('🔄 ProveedoresBloc: Cargando proveedores...');
    emit(const ProveedoresLoading());

    try {
      final List<ProveedorEntity> proveedores = await _repository.getAllProveedores();
      debugPrint('🔄 ProveedoresBloc: ✅ ${proveedores.length} proveedores cargados');

      emit(ProveedoresLoaded(proveedores: proveedores));
    } catch (e, stackTrace) {
      debugPrint('🔄 ProveedoresBloc: ❌ Error al cargar proveedores: $e');
      debugPrint('Stack trace: $stackTrace');
      emit(ProveedoresError('Error al cargar proveedores: ${e.toString()}'));
    }
  }

  /// Crea un nuevo proveedor
  Future<void> _onCreateRequested(
    ProveedorCreateRequested event,
    Emitter<ProveedoresState> emit,
  ) async {
    debugPrint('🔄 ProveedoresBloc: Creando proveedor: ${event.proveedor.nombreComercial}');
    emit(const ProveedoresOperationInProgress());

    try {
      await _repository.createProveedor(event.proveedor);
      debugPrint('🔄 ProveedoresBloc: ✅ Proveedor creado exitosamente');

      // Recargar lista actualizada
      final List<ProveedorEntity> proveedores = await _repository.getAllProveedores();

      emit(ProveedoresOperationSuccess(
        message: 'Proveedor "${event.proveedor.nombreComercial}" creado exitosamente',
        proveedores: proveedores,
      ));

      // Transición automática a estado cargado
      emit(ProveedoresLoaded(proveedores: proveedores));
    } catch (e, stackTrace) {
      debugPrint('🔄 ProveedoresBloc: ❌ Error al crear proveedor: $e');
      debugPrint('Stack trace: $stackTrace');
      emit(ProveedoresError('Error al crear proveedor: ${e.toString()}'));
    }
  }

  /// Actualiza un proveedor existente
  Future<void> _onUpdateRequested(
    ProveedorUpdateRequested event,
    Emitter<ProveedoresState> emit,
  ) async {
    debugPrint('🔄 ProveedoresBloc: Actualizando proveedor: ${event.proveedor.id}');
    emit(const ProveedoresOperationInProgress());

    try {
      await _repository.updateProveedor(event.proveedor);
      debugPrint('🔄 ProveedoresBloc: ✅ Proveedor actualizado exitosamente');

      // Recargar lista actualizada
      final List<ProveedorEntity> proveedores = await _repository.getAllProveedores();

      emit(ProveedoresOperationSuccess(
        message: 'Proveedor "${event.proveedor.nombreComercial}" actualizado exitosamente',
        proveedores: proveedores,
      ));

      // Transición automática a estado cargado
      emit(ProveedoresLoaded(proveedores: proveedores));
    } catch (e, stackTrace) {
      debugPrint('🔄 ProveedoresBloc: ❌ Error al actualizar proveedor: $e');
      debugPrint('Stack trace: $stackTrace');
      emit(ProveedoresError('Error al actualizar proveedor: ${e.toString()}'));
    }
  }

  /// Elimina (desactiva) un proveedor
  Future<void> _onDeleteRequested(
    ProveedorDeleteRequested event,
    Emitter<ProveedoresState> emit,
  ) async {
    debugPrint('🔄 ProveedoresBloc: Eliminando proveedor: ${event.id}');
    emit(const ProveedoresOperationInProgress());

    try {
      await _repository.deleteProveedor(event.id);
      debugPrint('🔄 ProveedoresBloc: ✅ Proveedor eliminado exitosamente');

      // Recargar lista actualizada
      final List<ProveedorEntity> proveedores = await _repository.getAllProveedores();

      emit(ProveedoresOperationSuccess(
        message: 'Proveedor eliminado exitosamente',
        proveedores: proveedores,
      ));

      // Transición automática a estado cargado
      emit(ProveedoresLoaded(proveedores: proveedores));
    } catch (e, stackTrace) {
      debugPrint('🔄 ProveedoresBloc: ❌ Error al eliminar proveedor: $e');
      debugPrint('Stack trace: $stackTrace');
      emit(ProveedoresError('Error al eliminar proveedor: ${e.toString()}'));
    }
  }

  /// Busca proveedores por texto
  Future<void> _onSearchRequested(
    ProveedoresSearchRequested event,
    Emitter<ProveedoresState> emit,
  ) async {
    debugPrint('🔄 ProveedoresBloc: Buscando proveedores: "${event.query}"');

    if (event.query.trim().isEmpty) {
      // Si query vacío, cargar todos
      add(const ProveedoresLoadRequested());
      return;
    }

    emit(const ProveedoresLoading());

    try {
      final List<ProveedorEntity> proveedores = await _repository.searchProveedores(event.query);
      debugPrint('🔄 ProveedoresBloc: ✅ ${proveedores.length} proveedores encontrados');

      emit(ProveedoresLoaded(
        proveedores: proveedores,
        isSearching: true,
        searchQuery: event.query,
      ));
    } catch (e, stackTrace) {
      debugPrint('🔄 ProveedoresBloc: ❌ Error al buscar proveedores: $e');
      debugPrint('Stack trace: $stackTrace');
      emit(ProveedoresError('Error al buscar proveedores: ${e.toString()}'));
    }
  }

  /// Limpia la búsqueda y recarga todos los proveedores
  Future<void> _onSearchCleared(
    ProveedoresSearchCleared event,
    Emitter<ProveedoresState> emit,
  ) async {
    debugPrint('🔄 ProveedoresBloc: Limpiando búsqueda, recargando todos...');
    add(const ProveedoresLoadRequested());
  }
}
