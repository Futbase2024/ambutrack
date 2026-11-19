import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import '../../domain/repositories/checklist_repository.dart';
import 'checklist_event.dart';
import 'checklist_state.dart';

/// BLoC para gestión de checklists de ambulancia
///
/// Maneja la creación, visualización y actualización de checklists
class ChecklistBloc extends Bloc<ChecklistEvent, ChecklistState> {
  ChecklistBloc({
    required ChecklistRepository repository,
  })  : _repository = repository,
        super(const ChecklistState.initial()) {
    on<ChecklistEvent>(_onEvent);
  }

  final ChecklistRepository _repository;
  final _uuid = const Uuid();

  /// Manejador principal de eventos
  Future<void> _onEvent(
    ChecklistEvent event,
    Emitter<ChecklistState> emit,
  ) async {
    await event.when(
      started: () => _onStarted(emit),
      cargarHistorial: (vehiculoId) => _onCargarHistorial(emit, vehiculoId),
      cargarPlantilla: (tipo) => _onCargarPlantilla(emit, tipo),
      iniciarNuevoChecklist: (vehiculoId, tipo) =>
          _onIniciarNuevoChecklist(emit, vehiculoId, tipo),
      actualizarItem: (index, resultado, observaciones) =>
          _onActualizarItem(emit, index, resultado, observaciones),
      guardarChecklist: (
        kilometraje,
        empresaId,
        realizadoPor,
        realizadoPorNombre,
        observacionesGenerales,
        firmaUrl,
      ) =>
          _onGuardarChecklist(
        emit,
        kilometraje,
        empresaId,
        realizadoPor,
        realizadoPorNombre,
        observacionesGenerales,
        firmaUrl,
      ),
      cancelarChecklist: () => _onCancelarChecklist(emit),
      refrescarHistorial: () => _onRefrescarHistorial(emit),
      verDetalle: (checklistId) => _onVerDetalle(emit, checklistId),
    );
  }

  /// Evento: Started
  Future<void> _onStarted(Emitter<ChecklistState> emit) async {
    debugPrint('📋 ChecklistBloc: Iniciado');
    emit(const ChecklistState.initial());
  }

  /// Evento: Cargar historial de vehículo
  Future<void> _onCargarHistorial(
    Emitter<ChecklistState> emit,
    String vehiculoId,
  ) async {
    debugPrint('📋 ChecklistBloc: Cargando historial de vehículo $vehiculoId');
    emit(const ChecklistState.loading());

    try {
      final checklists = await _repository.getHistorialVehiculo(vehiculoId);
      debugPrint('✅ ChecklistBloc: ${checklists.length} checklists cargados');

      emit(
        ChecklistState.historialCargado(
          checklists: checklists,
          vehiculoId: vehiculoId,
        ),
      );
    } catch (e) {
      debugPrint('❌ ChecklistBloc: Error al cargar historial - $e');
      emit(
        ChecklistState.error(
          mensaje: 'Error al cargar historial: ${e.toString()}',
          vehiculoId: vehiculoId,
        ),
      );
    }
  }

  /// Evento: Cargar plantilla de items
  Future<void> _onCargarPlantilla(
    Emitter<ChecklistState> emit,
    TipoChecklist tipo,
  ) async {
    debugPrint('📋 ChecklistBloc: Cargando plantilla ${tipo.nombre}');
    // Este evento es interno, se usa dentro de iniciarNuevoChecklist
  }

  /// Evento: Iniciar nuevo checklist
  Future<void> _onIniciarNuevoChecklist(
    Emitter<ChecklistState> emit,
    String vehiculoId,
    TipoChecklist tipo,
  ) async {
    debugPrint(
      '📋 ChecklistBloc: Iniciando nuevo checklist - '
      'Vehículo: $vehiculoId, Tipo: ${tipo.nombre}',
    );
    emit(const ChecklistState.loading());

    try {
      // Cargar plantilla de items para el tipo de checklist
      final plantillaItems = await _repository.getPlantillaItems(tipo);
      debugPrint(
        '✅ ChecklistBloc: ${plantillaItems.length} items en plantilla',
      );

      // Inicializar mapas de resultados y observaciones vacíos
      final resultados = <int, ResultadoItem>{};
      final observaciones = <int, String>{};

      emit(
        ChecklistState.creandoChecklist(
          vehiculoId: vehiculoId,
          tipo: tipo,
          items: plantillaItems,
          resultados: resultados,
          observaciones: observaciones,
        ),
      );
    } catch (e) {
      debugPrint('❌ ChecklistBloc: Error al iniciar checklist - $e');
      emit(
        ChecklistState.error(
          mensaje: 'Error al cargar plantilla: ${e.toString()}',
          vehiculoId: vehiculoId,
        ),
      );
    }
  }

  /// Evento: Actualizar resultado de un item
  Future<void> _onActualizarItem(
    Emitter<ChecklistState> emit,
    int index,
    ResultadoItem resultado,
    String? observaciones,
  ) async {
    // Usar maybeWhen para acceder a los datos del estado creandoChecklist
    state.maybeWhen(
      creandoChecklist: (
        vehiculoId,
        tipo,
        items,
        resultadosActuales,
        observacionesActuales,
      ) {
        debugPrint(
          '📋 ChecklistBloc: Actualizando item $index - '
          'Resultado: ${resultado.nombre}',
        );

        // Copiar mapas actuales
        final nuevosResultados =
            Map<int, ResultadoItem>.from(resultadosActuales);
        final nuevasObservaciones =
            Map<int, String>.from(observacionesActuales);

        // Actualizar resultado
        nuevosResultados[index] = resultado;

        // Actualizar observaciones
        if (observaciones != null && observaciones.isNotEmpty) {
          nuevasObservaciones[index] = observaciones;
        } else {
          nuevasObservaciones.remove(index);
        }

        emit(
          ChecklistState.creandoChecklist(
            vehiculoId: vehiculoId,
            tipo: tipo,
            items: items,
            resultados: nuevosResultados,
            observaciones: nuevasObservaciones,
          ),
        );

        debugPrint(
          '✅ ChecklistBloc: Item actualizado - '
          'Completados: ${nuevosResultados.length}/${items.length}',
        );
      },
      orElse: () {
        debugPrint(
          '⚠️ ChecklistBloc: No se puede actualizar item fuera del estado de creación',
        );
      },
    );
  }

  /// Evento: Guardar checklist completo
  Future<void> _onGuardarChecklist(
    Emitter<ChecklistState> emit,
    double kilometraje,
    String empresaId,
    String realizadoPor,
    String realizadoPorNombre,
    String? observacionesGenerales,
    String? firmaUrl,
  ) async {
    // Usar maybeWhen para extraer datos del estado
    await state.maybeWhen(
      creandoChecklist: (
        vehiculoId,
        tipo,
        items,
        resultados,
        observaciones,
      ) async {
        debugPrint('📋 ChecklistBloc: Guardando checklist...');

        // Validar que todos los items estén verificados
        if (resultados.length != items.length) {
          debugPrint(
            '❌ ChecklistBloc: No todos los items están verificados - '
            '${resultados.length}/${items.length}',
          );
          emit(
            ChecklistState.error(
              mensaje:
                  'Debes verificar todos los items antes de guardar (${resultados.length}/${items.length})',
              vehiculoId: vehiculoId,
            ),
          );
          return;
        }

        // Validar observaciones en items ausentes
        for (var i = 0; i < items.length; i++) {
          final resultado = resultados[i];
          final observacion = observaciones[i];

          if (resultado == ResultadoItem.ausente &&
              (observacion == null || observacion.isEmpty)) {
            debugPrint(
              '❌ ChecklistBloc: Falta observación en item ausente $i',
            );
            emit(
              ChecklistState.error(
                mensaje:
                    'Debes añadir observaciones en los items marcados como ausentes',
                vehiculoId: vehiculoId,
              ),
            );
            return;
          }
        }

        emit(const ChecklistState.guardando());

        try {
          // Crear items del checklist con los resultados
          final itemsConResultado = <ItemChecklistEntity>[];
          for (var i = 0; i < items.length; i++) {
            final plantillaItem = items[i];
            final resultado = resultados[i]!;
            final observacion = observaciones[i];

            final item = ItemChecklistEntity(
              id: _uuid.v4(),
              checklistId: '', // Se establecerá al crear el checklist
              categoria: plantillaItem.categoria,
              itemNombre: plantillaItem.itemNombre,
              cantidadRequerida: plantillaItem.cantidadRequerida,
              resultado: resultado,
              observaciones: observacion,
              orden: plantillaItem.orden,
              createdAt: DateTime.now(),
            );

            itemsConResultado.add(item);
          }

          // Calcular estadísticas
          final itemsPresentes = itemsConResultado
              .where((item) => item.resultado == ResultadoItem.presente)
              .length;
          final itemsAusentes = itemsConResultado
              .where((item) => item.resultado == ResultadoItem.ausente)
              .length;
          final checklistCompleto = itemsAusentes == 0;

          // Crear checklist con datos del usuario autenticado
          final checklist = ChecklistVehiculoEntity(
            id: _uuid.v4(),
            vehiculoId: vehiculoId,
            realizadoPor: realizadoPor,
            realizadoPorNombre: realizadoPorNombre,
            fechaRealizacion: DateTime.now(),
            tipo: tipo,
            kilometraje: kilometraje,
            items: itemsConResultado,
            itemsPresentes: itemsPresentes,
            itemsAusentes: itemsAusentes,
            checklistCompleto: checklistCompleto,
            observacionesGenerales: observacionesGenerales,
            firmaUrl: firmaUrl,
            empresaId: empresaId,
            createdAt: DateTime.now(),
          );

          final checklistGuardado = await _repository.crearChecklist(checklist);

          debugPrint(
            '✅ ChecklistBloc: Checklist guardado exitosamente - '
            'ID: ${checklistGuardado.id}',
          );

          emit(ChecklistState.checklistGuardado(checklist: checklistGuardado));
        } catch (e) {
          debugPrint('❌ ChecklistBloc: Error al guardar checklist - $e');
          emit(
            ChecklistState.error(
              mensaje: 'Error al guardar checklist: ${e.toString()}',
              vehiculoId: vehiculoId,
            ),
          );
        }
      },
      orElse: () {
        debugPrint(
          '⚠️ ChecklistBloc: No se puede guardar fuera del estado de creación',
        );
      },
    );
  }

  /// Evento: Cancelar creación de checklist
  Future<void> _onCancelarChecklist(Emitter<ChecklistState> emit) async {
    state.maybeWhen(
      creandoChecklist: (vehiculoId, tipo, items, resultados, observaciones) {
        debugPrint('📋 ChecklistBloc: Cancelando creación de checklist');
        // Volver al historial del vehículo
        add(ChecklistEvent.cargarHistorial(vehiculoId: vehiculoId));
      },
      orElse: () {},
    );
  }

  /// Evento: Refrescar historial (pull-to-refresh)
  Future<void> _onRefrescarHistorial(Emitter<ChecklistState> emit) async {
    state.maybeWhen(
      historialCargado: (checklists, vehiculoId) {
        debugPrint('📋 ChecklistBloc: Refrescando historial');
        add(ChecklistEvent.cargarHistorial(vehiculoId: vehiculoId));
      },
      orElse: () {},
    );
  }

  /// Evento: Ver detalle de checklist guardado
  Future<void> _onVerDetalle(
    Emitter<ChecklistState> emit,
    String checklistId,
  ) async {
    debugPrint('📋 ChecklistBloc: Cargando detalle de checklist $checklistId');
    emit(const ChecklistState.loading());

    try {
      final checklist = await _repository.getById(checklistId);
      debugPrint('✅ ChecklistBloc: Detalle cargado');

      emit(ChecklistState.viendoDetalle(checklist: checklist));
    } catch (e) {
      debugPrint('❌ ChecklistBloc: Error al cargar detalle - $e');
      emit(
        ChecklistState.error(
          mensaje: 'Error al cargar detalle: ${e.toString()}',
        ),
      );
    }
  }
}
