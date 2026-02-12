import 'dart:async';

// Imports del core datasource (sistema nuevo de almacén - importación directa)
import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart' hide MovimientoStockEntity, StockDataSource, StockDataSourceFactory;
import 'package:ambutrack_core_datasource/src/datasources/almacen/entities/producto_entity.dart';
import 'package:ambutrack_web/features/almacen/domain/repositories/producto_repository.dart';
import 'package:ambutrack_web/features/almacen/presentation/bloc/producto/producto_event.dart';
import 'package:ambutrack_web/features/almacen/presentation/bloc/producto/producto_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

/// BLoC para gestionar el estado de Productos
@injectable
class ProductoBloc extends Bloc<ProductoEvent, ProductoState> {
  ProductoBloc(this._repository) : super(const ProductoInitial()) {
    on<ProductoLoadAllRequested>(_onLoadAllRequested);
    on<ProductoLoadByCategoriaRequested>(_onLoadByCategoriaRequested);
    on<ProductoSearchRequested>(_onSearchRequested);
    on<ProductoCreateRequested>(_onCreateRequested);
    on<ProductoUpdateRequested>(_onUpdateRequested);
    on<ProductoDeleteRequested>(_onDeleteRequested);
    on<ProductoWatchAllRequested>(_onWatchAllRequested);
    on<ProductoWatchByCategoriaRequested>(_onWatchByCategoriaRequested);
  }

  final ProductoRepository _repository;
  StreamSubscription<List<ProductoEntity>>? _productosSubscription;

  @override
  Future<void> close() {
    _productosSubscription?.cancel();
    return super.close();
  }

  /// Maneja la carga de todos los productos
  Future<void> _onLoadAllRequested(
    ProductoLoadAllRequested event,
    Emitter<ProductoState> emit,
  ) async {
    debugPrint('🔄 ProductoBloc: Cargando todos los productos...');
    emit(const ProductoLoading());

    try {
      final List<ProductoEntity> productos = await _repository.getAll();
      debugPrint('✅ ProductoBloc: ${productos.length} productos cargados');
      emit(ProductoLoaded(productos));
    } catch (e, stackTrace) {
      debugPrint('❌ ProductoBloc: Error al cargar productos: $e');
      debugPrint('Stack trace: $stackTrace');
      emit(ProductoError('Error al cargar productos: $e'));
    }
  }

  /// Maneja la carga de productos por categoría
  Future<void> _onLoadByCategoriaRequested(
    ProductoLoadByCategoriaRequested event,
    Emitter<ProductoState> emit,
  ) async {
    debugPrint('🔄 ProductoBloc: Cargando productos de categoría ${event.categoria}...');
    emit(const ProductoLoading());

    try {
      final List<ProductoEntity> productos = await _repository.getByCategoria(event.categoria);
      debugPrint('✅ ProductoBloc: ${productos.length} productos de categoría ${event.categoria} cargados');
      emit(ProductoLoaded(productos));
    } catch (e, stackTrace) {
      debugPrint('❌ ProductoBloc: Error al cargar productos por categoría: $e');
      debugPrint('Stack trace: $stackTrace');
      emit(ProductoError('Error al cargar productos por categoría: $e'));
    }
  }

  /// Maneja la búsqueda de productos
  Future<void> _onSearchRequested(
    ProductoSearchRequested event,
    Emitter<ProductoState> emit,
  ) async {
    debugPrint('🔍 ProductoBloc: Buscando productos con query: "${event.query}"...');
    emit(const ProductoLoading());

    try {
      final List<ProductoEntity> productos = await _repository.search(event.query);
      debugPrint('✅ ProductoBloc: ${productos.length} productos encontrados');
      emit(ProductoLoaded(productos));
    } catch (e, stackTrace) {
      debugPrint('❌ ProductoBloc: Error al buscar productos: $e');
      debugPrint('Stack trace: $stackTrace');
      emit(ProductoError('Error al buscar productos: $e'));
    }
  }

  /// Maneja la creación de un producto
  Future<void> _onCreateRequested(
    ProductoCreateRequested event,
    Emitter<ProductoState> emit,
  ) async {
    debugPrint('➕ ProductoBloc: Creando producto "${event.producto.nombre}"...');
    emit(const ProductoOperationInProgress());

    try {
      await _repository.create(event.producto);
      debugPrint('✅ ProductoBloc: Producto creado exitosamente');
      emit(const ProductoOperationSuccess('Producto creado exitosamente'));

      // Recargar lista después de crear
      add(const ProductoLoadAllRequested());
    } catch (e, stackTrace) {
      debugPrint('❌ ProductoBloc: Error al crear producto: $e');
      debugPrint('Stack trace: $stackTrace');
      emit(ProductoError('Error al crear producto: $e'));
    }
  }

  /// Maneja la actualización de un producto
  Future<void> _onUpdateRequested(
    ProductoUpdateRequested event,
    Emitter<ProductoState> emit,
  ) async {
    debugPrint('✏️ ProductoBloc: Actualizando producto "${event.producto.nombre}"...');
    emit(const ProductoOperationInProgress());

    try {
      await _repository.update(event.producto);
      debugPrint('✅ ProductoBloc: Producto actualizado exitosamente');
      emit(const ProductoOperationSuccess('Producto actualizado exitosamente'));

      // Recargar lista después de actualizar
      add(const ProductoLoadAllRequested());
    } catch (e, stackTrace) {
      debugPrint('❌ ProductoBloc: Error al actualizar producto: $e');
      debugPrint('Stack trace: $stackTrace');
      emit(ProductoError('Error al actualizar producto: $e'));
    }
  }

  /// Maneja la eliminación de un producto
  Future<void> _onDeleteRequested(
    ProductoDeleteRequested event,
    Emitter<ProductoState> emit,
  ) async {
    debugPrint('🗑️ ProductoBloc: Eliminando producto con id ${event.id}...');
    emit(const ProductoOperationInProgress());

    try {
      await _repository.delete(event.id);
      debugPrint('✅ ProductoBloc: Producto eliminado exitosamente');
      emit(const ProductoOperationSuccess('Producto eliminado exitosamente'));

      // Recargar lista después de eliminar
      add(const ProductoLoadAllRequested());
    } catch (e, stackTrace) {
      debugPrint('❌ ProductoBloc: Error al eliminar producto: $e');
      debugPrint('Stack trace: $stackTrace');
      emit(ProductoError('Error al eliminar producto: $e'));
    }
  }

  /// Maneja la suscripción a todos los productos en tiempo real
  Future<void> _onWatchAllRequested(
    ProductoWatchAllRequested event,
    Emitter<ProductoState> emit,
  ) async {
    debugPrint('👁️ ProductoBloc: Iniciando watch de todos los productos...');
    emit(const ProductoLoading());

    try {
      await _productosSubscription?.cancel();

      _productosSubscription = _repository.watchAll().listen(
        (List<ProductoEntity> productos) {
          debugPrint('🔄 ProductoBloc: Recibidos ${productos.length} productos del stream');
          emit(ProductoLoaded(productos));
        },
        onError: (Object error, StackTrace stackTrace) {
          debugPrint('❌ ProductoBloc: Error en stream: $error');
          debugPrint('Stack trace: $stackTrace');
          emit(ProductoError('Error en tiempo real: $error'));
        },
      );
    } catch (e, stackTrace) {
      debugPrint('❌ ProductoBloc: Error al iniciar watch: $e');
      debugPrint('Stack trace: $stackTrace');
      emit(ProductoError('Error al iniciar suscripción: $e'));
    }
  }

  /// Maneja la suscripción a productos por categoría en tiempo real
  Future<void> _onWatchByCategoriaRequested(
    ProductoWatchByCategoriaRequested event,
    Emitter<ProductoState> emit,
  ) async {
    debugPrint('👁️ ProductoBloc: Iniciando watch de productos categoría ${event.categoria}...');
    emit(const ProductoLoading());

    try {
      await _productosSubscription?.cancel();

      _productosSubscription = _repository.watchByCategoria(event.categoria).listen(
        (List<ProductoEntity> productos) {
          debugPrint('🔄 ProductoBloc: Recibidos ${productos.length} productos de categoría ${event.categoria} del stream');
          emit(ProductoLoaded(productos));
        },
        onError: (Object error, StackTrace stackTrace) {
          debugPrint('❌ ProductoBloc: Error en stream por categoría: $error');
          debugPrint('Stack trace: $stackTrace');
          emit(ProductoError('Error en tiempo real: $error'));
        },
      );
    } catch (e, stackTrace) {
      debugPrint('❌ ProductoBloc: Error al iniciar watch por categoría: $e');
      debugPrint('Stack trace: $stackTrace');
      emit(ProductoError('Error al iniciar suscripción: $e'));
    }
  }
}
