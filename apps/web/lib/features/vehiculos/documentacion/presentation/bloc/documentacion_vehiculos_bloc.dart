import 'dart:async';

import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/features/vehiculos/documentacion/domain/repositories/documentacion_vehiculo_repository.dart';
import 'package:ambutrack_web/features/vehiculos/documentacion/presentation/bloc/documentacion_vehiculos_event.dart';
import 'package:ambutrack_web/features/vehiculos/documentacion/presentation/bloc/documentacion_vehiculos_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

/// BLoC para gestionar la documentación de vehículos
@injectable
class DocumentacionVehiculosBloc
    extends Bloc<DocumentacionVehiculosEvent, DocumentacionVehiculosState> {
  DocumentacionVehiculosBloc(this._documentacionRepository)
      : super(const DocumentacionVehiculosInitial()) {
    on<DocumentacionVehiculosLoadRequested>(_onLoadRequested);
    on<DocumentacionVehiculosRefreshRequested>(_onRefreshRequested);
    on<DocumentacionVehiculosByVehiculoRequested>(_onByVehiculoRequested);
    on<DocumentacionVehiculosByEstadoRequested>(_onByEstadoRequested);
    on<DocumentacionVehiculosProximosVencerRequested>(_onProximosVencerRequested);
    on<DocumentacionVehiculosVencidosRequested>(_onVencidosRequested);
    on<DocumentacionVehiculoCreateRequested>(_onCreateRequested);
    on<DocumentacionVehiculoUpdateRequested>(_onUpdateRequested);
    on<DocumentacionVehiculoDeleteRequested>(_onDeleteRequested);
    on<DocumentacionVehiculoActualizarEstadoRequested>(_onActualizarEstadoRequested);
    on<DocumentacionVehiculosBuscarPorPolizaRequested>(_onBuscarPorPolizaRequested);
    on<DocumentacionVehiculosBuscarPorCompaniaRequested>(
        _onBuscarPorCompaniaRequested);
  }

  final DocumentacionVehiculoRepository _documentacionRepository;

  Future<void> _onLoadRequested(
    DocumentacionVehiculosLoadRequested event,
    Emitter<DocumentacionVehiculosState> emit,
  ) async {
    final DateTime startTime = DateTime.now();
    debugPrint('📚 DocumentacionVehiculosBloc: Iniciando carga...');
    emit(const DocumentacionVehiculosLoading());

    try {
      debugPrint('📚 DocumentacionVehiculosBloc: Llamando a repository.getAll()');
      final List<DocumentacionVehiculoEntity> documentos = await _documentacionRepository.getAll();

      debugPrint(
          '📚 DocumentacionVehiculosBloc: ✅ ${documentos.length} documentos recibidos');

      final Duration elapsed = DateTime.now().difference(startTime);
      debugPrint('⏱️ Tiempo de carga BLoC: ${elapsed.inMilliseconds}ms');

      emit(DocumentacionVehiculosLoaded(documentos: documentos));
    } on Exception catch (e) {
      debugPrint('❌ DocumentacionVehiculosBloc: ERROR - $e');
      emit(DocumentacionVehiculosError(message: e.toString()));
    } catch (e, stackTrace) {
      debugPrint('❌ DocumentacionVehiculosBloc: ERROR INESPERADO - $e');
      debugPrint('Stack trace: $stackTrace');
      emit(DocumentacionVehiculosError(message: e.toString()));
    }
  }

  Future<void> _onRefreshRequested(
    DocumentacionVehiculosRefreshRequested event,
    Emitter<DocumentacionVehiculosState> emit,
  ) async {
    debugPrint('📚 DocumentacionVehiculosBloc: Refrescando...');
    add(const DocumentacionVehiculosLoadRequested());
  }

  Future<void> _onByVehiculoRequested(
    DocumentacionVehiculosByVehiculoRequested event,
    Emitter<DocumentacionVehiculosState> emit,
  ) async {
    final DateTime startTime = DateTime.now();
    debugPrint(
        '📚 DocumentacionVehiculosBloc: Cargando por vehículo=${event.vehiculoId}');
    emit(const DocumentacionVehiculosLoading());

    try {
      final List<DocumentacionVehiculoEntity> documentos =
          await _documentacionRepository.getByVehiculo(event.vehiculoId);

      debugPrint(
          '📚 DocumentacionVehiculosBloc: ✅ ${documentos.length} documentos para vehículo');

      final Duration elapsed = DateTime.now().difference(startTime);
      debugPrint('⏱️ Tiempo de carga: ${elapsed.inMilliseconds}ms');

      emit(DocumentacionVehiculosLoaded(
        documentos: documentos,
        filtroVehiculoId: event.vehiculoId,
      ));
    } on Exception catch (e) {
      debugPrint('❌ DocumentacionVehiculosBloc: ERROR - $e');
      emit(DocumentacionVehiculosError(message: e.toString()));
    } catch (e, stackTrace) {
      debugPrint('❌ DocumentacionVehiculosBloc: ERROR INESPERADO - $e');
      debugPrint('Stack trace: $stackTrace');
      emit(DocumentacionVehiculosError(message: e.toString()));
    }
  }

  Future<void> _onByEstadoRequested(
    DocumentacionVehiculosByEstadoRequested event,
    Emitter<DocumentacionVehiculosState> emit,
  ) async {
    final DateTime startTime = DateTime.now();
    debugPrint(
        '📚 DocumentacionVehiculosBloc: Cargando por estado=${event.estado}');
    emit(const DocumentacionVehiculosLoading());

    try {
      final List<DocumentacionVehiculoEntity> documentos =
          await _documentacionRepository.getByEstado(event.estado);

      debugPrint(
          '📚 DocumentacionVehiculosBloc: ✅ ${documentos.length} documentos con estado ${event.estado}');

      final Duration elapsed = DateTime.now().difference(startTime);
      debugPrint('⏱️ Tiempo de carga: ${elapsed.inMilliseconds}ms');

      emit(DocumentacionVehiculosLoaded(
        documentos: documentos,
        filtroEstado: event.estado,
      ));
    } on Exception catch (e) {
      debugPrint('❌ DocumentacionVehiculosBloc: ERROR - $e');
      emit(DocumentacionVehiculosError(message: e.toString()));
    } catch (e, stackTrace) {
      debugPrint('❌ DocumentacionVehiculosBloc: ERROR INESPERADO - $e');
      debugPrint('Stack trace: $stackTrace');
      emit(DocumentacionVehiculosError(message: e.toString()));
    }
  }

  Future<void> _onProximosVencerRequested(
    DocumentacionVehiculosProximosVencerRequested event,
    Emitter<DocumentacionVehiculosState> emit,
  ) async {
    final DateTime startTime = DateTime.now();
    debugPrint('📚 DocumentacionVehiculosBloc: Cargando próximos a vencer...');
    emit(const DocumentacionVehiculosLoading());

    try {
      final List<DocumentacionVehiculoEntity> documentos = await _documentacionRepository.getProximosAVencer();

      debugPrint(
          '📚 DocumentacionVehiculosBloc: ✅ ${documentos.length} próximos a vencer');

      final Duration elapsed = DateTime.now().difference(startTime);
      debugPrint('⏱️ Tiempo de carga: ${elapsed.inMilliseconds}ms');

      emit(DocumentacionVehiculosLoaded(documentos: documentos));
    } on Exception catch (e) {
      debugPrint('❌ DocumentacionVehiculosBloc: ERROR - $e');
      emit(DocumentacionVehiculosError(message: e.toString()));
    } catch (e, stackTrace) {
      debugPrint('❌ DocumentacionVehiculosBloc: ERROR INESPERADO - $e');
      debugPrint('Stack trace: $stackTrace');
      emit(DocumentacionVehiculosError(message: e.toString()));
    }
  }

  Future<void> _onVencidosRequested(
    DocumentacionVehiculosVencidosRequested event,
    Emitter<DocumentacionVehiculosState> emit,
  ) async {
    final DateTime startTime = DateTime.now();
    debugPrint('📚 DocumentacionVehiculosBloc: Cargando vencidos...');
    emit(const DocumentacionVehiculosLoading());

    try {
      final List<DocumentacionVehiculoEntity> documentos = await _documentacionRepository.getVencidos();

      debugPrint(
          '📚 DocumentacionVehiculosBloc: ✅ ${documentos.length} vencidos');

      final Duration elapsed = DateTime.now().difference(startTime);
      debugPrint('⏱️ Tiempo de carga: ${elapsed.inMilliseconds}ms');

      emit(DocumentacionVehiculosLoaded(documentos: documentos));
    } on Exception catch (e) {
      debugPrint('❌ DocumentacionVehiculosBloc: ERROR - $e');
      emit(DocumentacionVehiculosError(message: e.toString()));
    } catch (e, stackTrace) {
      debugPrint('❌ DocumentacionVehiculosBloc: ERROR INESPERADO - $e');
      debugPrint('Stack trace: $stackTrace');
      emit(DocumentacionVehiculosError(message: e.toString()));
    }
  }

  Future<void> _onCreateRequested(
    DocumentacionVehiculoCreateRequested event,
    Emitter<DocumentacionVehiculosState> emit,
  ) async {
    debugPrint('📚 DocumentacionVehiculosBloc: Creando documento...');

    try {
      await _documentacionRepository.create(event.documento);

      debugPrint('📚 DocumentacionVehiculosBloc: ✅ Documento creado');
      add(const DocumentacionVehiculosLoadRequested());
    } on Exception catch (e) {
      debugPrint('❌ DocumentacionVehiculosBloc: ERROR - $e');
      emit(DocumentacionVehiculosError(message: e.toString()));
    } catch (e, stackTrace) {
      debugPrint('❌ DocumentacionVehiculosBloc: ERROR INESPERADO - $e');
      debugPrint('Stack trace: $stackTrace');
      emit(DocumentacionVehiculosError(message: e.toString()));
    }
  }

  Future<void> _onUpdateRequested(
    DocumentacionVehiculoUpdateRequested event,
    Emitter<DocumentacionVehiculosState> emit,
  ) async {
    debugPrint('📚 DocumentacionVehiculosBloc: Actualizando documento...');

    try {
      await _documentacionRepository.update(event.documento);

      debugPrint('📚 DocumentacionVehiculosBloc: ✅ Documento actualizado');
      add(const DocumentacionVehiculosLoadRequested());
    } on Exception catch (e) {
      debugPrint('❌ DocumentacionVehiculosBloc: ERROR - $e');
      emit(DocumentacionVehiculosError(message: e.toString()));
    } catch (e, stackTrace) {
      debugPrint('❌ DocumentacionVehiculosBloc: ERROR INESPERADO - $e');
      debugPrint('Stack trace: $stackTrace');
      emit(DocumentacionVehiculosError(message: e.toString()));
    }
  }

  Future<void> _onDeleteRequested(
    DocumentacionVehiculoDeleteRequested event,
    Emitter<DocumentacionVehiculosState> emit,
  ) async {
    debugPrint(
        '📚 DocumentacionVehiculosBloc: Eliminando documento ${event.documentoId}');

    try {
      await _documentacionRepository.delete(event.documentoId);

      debugPrint('📚 DocumentacionVehiculosBloc: ✅ Documento eliminado');
      add(const DocumentacionVehiculosLoadRequested());
    } on Exception catch (e) {
      debugPrint('❌ DocumentacionVehiculosBloc: ERROR - $e');
      emit(DocumentacionVehiculosError(message: e.toString()));
    } catch (e, stackTrace) {
      debugPrint('❌ DocumentacionVehiculosBloc: ERROR INESPERADO - $e');
      debugPrint('Stack trace: $stackTrace');
      emit(DocumentacionVehiculosError(message: e.toString()));
    }
  }

  Future<void> _onActualizarEstadoRequested(
    DocumentacionVehiculoActualizarEstadoRequested event,
    Emitter<DocumentacionVehiculosState> emit,
  ) async {
    debugPrint(
        '📚 DocumentacionVehiculosBloc: Actualizando estado ${event.documentoId}');

    try {
      await _documentacionRepository.actualizarEstado(event.documentoId);

      debugPrint('📚 DocumentacionVehiculosBloc: ✅ Estado actualizado');
      add(const DocumentacionVehiculosLoadRequested());
    } on Exception catch (e) {
      debugPrint('❌ DocumentacionVehiculosBloc: ERROR - $e');
      emit(DocumentacionVehiculosError(message: e.toString()));
    } catch (e, stackTrace) {
      debugPrint('❌ DocumentacionVehiculosBloc: ERROR INESPERADO - $e');
      debugPrint('Stack trace: $stackTrace');
      emit(DocumentacionVehiculosError(message: e.toString()));
    }
  }

  Future<void> _onBuscarPorPolizaRequested(
    DocumentacionVehiculosBuscarPorPolizaRequested event,
    Emitter<DocumentacionVehiculosState> emit,
  ) async {
    final DateTime startTime = DateTime.now();
    debugPrint(
        '📚 DocumentacionVehiculosBloc: Buscando por póliza=${event.numeroPoliza}');
    emit(const DocumentacionVehiculosLoading());

    try {
      final List<DocumentacionVehiculoEntity> documentos =
          await _documentacionRepository.buscarPorPoliza(event.numeroPoliza);

      debugPrint(
          '📚 DocumentacionVehiculosBloc: ✅ ${documentos.length} documentos encontrados');

      final Duration elapsed = DateTime.now().difference(startTime);
      debugPrint('⏱️ Tiempo de búsqueda: ${elapsed.inMilliseconds}ms');

      emit(DocumentacionVehiculosLoaded(documentos: documentos));
    } on Exception catch (e) {
      debugPrint('❌ DocumentacionVehiculosBloc: ERROR - $e');
      emit(DocumentacionVehiculosError(message: e.toString()));
    } catch (e, stackTrace) {
      debugPrint('❌ DocumentacionVehiculosBloc: ERROR INESPERADO - $e');
      debugPrint('Stack trace: $stackTrace');
      emit(DocumentacionVehiculosError(message: e.toString()));
    }
  }

  Future<void> _onBuscarPorCompaniaRequested(
    DocumentacionVehiculosBuscarPorCompaniaRequested event,
    Emitter<DocumentacionVehiculosState> emit,
  ) async {
    final DateTime startTime = DateTime.now();
    debugPrint(
        '📚 DocumentacionVehiculosBloc: Buscando por compañía=${event.compania}');
    emit(const DocumentacionVehiculosLoading());

    try {
      final List<DocumentacionVehiculoEntity> documentos =
          await _documentacionRepository.buscarPorCompania(event.compania);

      debugPrint(
          '📚 DocumentacionVehiculosBloc: ✅ ${documentos.length} documentos encontrados');

      final Duration elapsed = DateTime.now().difference(startTime);
      debugPrint('⏱️ Tiempo de búsqueda: ${elapsed.inMilliseconds}ms');

      emit(DocumentacionVehiculosLoaded(documentos: documentos));
    } on Exception catch (e) {
      debugPrint('❌ DocumentacionVehiculosBloc: ERROR - $e');
      emit(DocumentacionVehiculosError(message: e.toString()));
    } catch (e, stackTrace) {
      debugPrint('❌ DocumentacionVehiculosBloc: ERROR INESPERADO - $e');
      debugPrint('Stack trace: $stackTrace');
      emit(DocumentacionVehiculosError(message: e.toString()));
    }
  }
}
