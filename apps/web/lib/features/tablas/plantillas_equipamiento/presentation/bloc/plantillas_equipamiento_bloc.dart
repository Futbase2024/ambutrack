import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/features/tablas/plantillas_equipamiento/domain/repositories/plantillas_equipamiento_repository.dart';
import 'package:ambutrack_web/features/tablas/plantillas_equipamiento/presentation/bloc/plantillas_equipamiento_event.dart';
import 'package:ambutrack_web/features/tablas/plantillas_equipamiento/presentation/bloc/plantillas_equipamiento_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

/// BLoC de la tabla maestra de plantillas de equipamiento
@injectable
class PlantillasEquipamientoBloc extends Bloc<PlantillasEquipamientoEvent, PlantillasEquipamientoState> {
  PlantillasEquipamientoBloc(this._repository) : super(const PlantillasEquipamientoState()) {
    on<PlantillasLoadRequested>(_onLoad);
    on<PlantillaSelected>(_onSelected);
    on<PlantillaSaveRequested>(_onSavePlantilla);
    on<PlantillaDeleteRequested>(_onDeletePlantilla);
    on<PlantillaReaplicarRequested>(_onReaplicar);
    on<PlantillaItemSaveRequested>(_onSaveItem);
    on<PlantillaItemActivoRequested>(_onItemActivo);
    on<PlantillaItemDeleteRequested>(_onDeleteItem);
  }

  final PlantillasEquipamientoRepository _repository;

  Future<void> _onLoad(PlantillasLoadRequested event, Emitter<PlantillasEquipamientoState> emit) async {
    emit(state.copyWith(status: PlantillasStatus.loading));
    try {
      final List<PlantillaEquipamientoEntity> plantillas = await _repository.getAll();
      final String? id = plantillas.any((PlantillaEquipamientoEntity p) => p.id == state.plantillaId)
          ? state.plantillaId
          : (plantillas.isEmpty ? null : plantillas.first.id);
      final List<PlantillaEquipamientoItemEntity> items =
          id == null ? <PlantillaEquipamientoItemEntity>[] : await _repository.getItems(id);
      debugPrint('✅ PlantillasEquipamientoBloc: ${plantillas.length} plantillas, ${items.length} items');
      emit(state.copyWith(
        status: PlantillasStatus.loaded,
        plantillas: plantillas,
        plantillaId: id,
        clearPlantilla: id == null,
        items: items,
        clearError: true,
      ));
    } catch (e) {
      debugPrint('❌ PlantillasEquipamientoBloc: error al cargar: $e');
      emit(state.copyWith(status: PlantillasStatus.failure, error: e.toString()));
    }
  }

  Future<void> _onSelected(PlantillaSelected event, Emitter<PlantillasEquipamientoState> emit) async {
    emit(state.copyWith(plantillaId: event.plantillaId, cargandoItems: true));
    try {
      final List<PlantillaEquipamientoItemEntity> items = await _repository.getItems(event.plantillaId);
      emit(state.copyWith(items: items, cargandoItems: false));
    } catch (e) {
      emit(state.copyWith(cargandoItems: false, status: PlantillasStatus.failure, error: e.toString()));
    }
  }

  Future<void> _onSavePlantilla(PlantillaSaveRequested event, Emitter<PlantillasEquipamientoState> emit) {
    return _guardar(
      emit,
      mensaje: event.esNueva
          ? 'Plantilla creada. Se aplicará a los vehículos de sus tipos al añadir items.'
          : 'Plantilla actualizada. Los vehículos de los tipos indicados reciben su dotación.',
      accion: () async {
        final PlantillaEquipamientoEntity p = event.esNueva
            ? await _repository.create(event.plantilla)
            : await _repository.update(event.plantilla);
        return p.id;
      },
    );
  }

  Future<void> _onDeletePlantilla(PlantillaDeleteRequested event, Emitter<PlantillasEquipamientoState> emit) {
    return _guardar(
      emit,
      mensaje: 'Plantilla eliminada. Las líneas ya creadas en los vehículos se conservan.',
      accion: () async {
        await _repository.delete(event.plantillaId);
        return null;
      },
    );
  }

  Future<void> _onReaplicar(PlantillaReaplicarRequested event, Emitter<PlantillasEquipamientoState> emit) async {
    final String? id = state.plantillaId;
    if (id == null) {
      return;
    }
    int lineas = 0;
    await _guardar(
      emit,
      mensajeDinamico: () => lineas == 0
          ? 'Todos los vehículos ya tenían la dotación completa de esta plantilla.'
          : 'Se han creado $lineas líneas nuevas en los vehículos.',
      accion: () async {
        lineas = await _repository.reaplicar(id);
        return id;
      },
    );
  }

  Future<void> _onSaveItem(PlantillaItemSaveRequested event, Emitter<PlantillasEquipamientoState> emit) {
    return _guardar(
      emit,
      mensaje: event.esNuevo
          ? 'Item añadido. Se ha creado su línea en todos los vehículos de la plantilla.'
          : 'Item actualizado. El cambio se refleja en todos los vehículos de la plantilla.',
      accion: () async {
        if (event.esNuevo) {
          await _repository.createItem(event.item);
        } else {
          await _repository.updateItem(event.item);
        }
        return state.plantillaId;
      },
    );
  }

  Future<void> _onItemActivo(PlantillaItemActivoRequested event, Emitter<PlantillasEquipamientoState> emit) {
    return _guardar(
      emit,
      mensaje: event.activo
          ? 'Item reactivado en la plantilla.'
          : 'Item desactivado. En los vehículos queda como "Fuera de plantilla" sin borrar datos.',
      accion: () async {
        await _repository.setItemActivo(event.itemId, activo: event.activo);
        return state.plantillaId;
      },
    );
  }

  Future<void> _onDeleteItem(PlantillaItemDeleteRequested event, Emitter<PlantillasEquipamientoState> emit) {
    return _guardar(
      emit,
      mensaje: 'Item eliminado de la plantilla. Las líneas de los vehículos se conservan.',
      accion: () async {
        await _repository.deleteItem(event.itemId);
        return state.plantillaId;
      },
    );
  }

  /// Ejecuta la escritura, recarga plantillas + items y publica el resultado una vez.
  /// [accion] devuelve la plantilla que debe quedar seleccionada.
  Future<void> _guardar(
    Emitter<PlantillasEquipamientoState> emit, {
    required Future<String?> Function() accion,
    String? mensaje,
    String Function()? mensajeDinamico,
  }) async {
    emit(state.copyWith(saving: true));
    try {
      final String? seleccion = await accion();
      final List<PlantillaEquipamientoEntity> plantillas = await _repository.getAll();
      final String? id = plantillas.any((PlantillaEquipamientoEntity p) => p.id == seleccion)
          ? seleccion
          : (plantillas.isEmpty ? null : plantillas.first.id);
      final List<PlantillaEquipamientoItemEntity> items =
          id == null ? <PlantillaEquipamientoItemEntity>[] : await _repository.getItems(id);
      emit(state.copyWith(
        status: PlantillasStatus.loaded,
        plantillas: plantillas,
        plantillaId: id,
        clearPlantilla: id == null,
        items: items,
        saving: false,
        operacion: state.operacion + 1,
        resultado: PlantillasResultado.exito,
        mensaje: mensajeDinamico?.call() ?? mensaje,
        clearError: true,
      ));
    } catch (e) {
      debugPrint('❌ PlantillasEquipamientoBloc: error en operación: $e');
      emit(state.copyWith(
        saving: false,
        operacion: state.operacion + 1,
        resultado: PlantillasResultado.error,
        error: e.toString(),
      ));
    }
  }
}
