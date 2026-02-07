import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../../domain/repositories/checklist_vehiculo_repository.dart';
import '../../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../../auth/presentation/bloc/auth_state.dart';
import 'checklist_event.dart';
import 'checklist_state.dart';

/// BLoC para gestionar checklists de vehículos
class ChecklistBloc extends Bloc<ChecklistEvent, ChecklistState> {
  ChecklistBloc(this._repository, this._authBloc)
      : super(const ChecklistInitial()) {
    on<LoadChecklistTemplate>(_onLoadChecklistTemplate);
    on<LoadChecklistDetail>(_onLoadChecklistDetail);
    on<LoadChecklistHistory>(_onLoadChecklistHistory);
    on<UpdateItemResultado>(_onUpdateItemResultado);
    on<SaveChecklist>(_onSaveChecklist);
  }

  final ChecklistVehiculoRepository _repository;
  final AuthBloc _authBloc;
  final _uuid = const Uuid();

  /// Cargar plantilla de items para nuevo checklist
  Future<void> _onLoadChecklistTemplate(
    LoadChecklistTemplate event,
    Emitter<ChecklistState> emit,
  ) async {
    try {
      emit(const ChecklistLoading());

      final items = await _repository.getPlantillaItems(event.tipo);

      emit(ChecklistTemplateLoaded(
        tipo: event.tipo,
        vehiculoId: event.vehiculoId,
        items: items,
      ));
    } catch (e) {
      debugPrint('❌ Error al cargar plantilla de checklist: $e');
      emit(ChecklistError('Error al cargar plantilla: ${e.toString()}'));
    }
  }

  /// Cargar detalle de checklist existente
  Future<void> _onLoadChecklistDetail(
    LoadChecklistDetail event,
    Emitter<ChecklistState> emit,
  ) async {
    try {
      emit(const ChecklistLoading());

      final checklist = await _repository.getById(event.checklistId);

      emit(ChecklistDetailLoaded(
        checklist: checklist,
        items: checklist.items,
      ));
    } catch (e) {
      debugPrint('❌ Error al cargar detalle de checklist: $e');
      emit(ChecklistError('Error al cargar checklist: ${e.toString()}'));
    }
  }

  /// Cargar historial de checklists de un vehículo
  Future<void> _onLoadChecklistHistory(
    LoadChecklistHistory event,
    Emitter<ChecklistState> emit,
  ) async {
    try {
      emit(const ChecklistLoading());

      final checklists = await _repository.getByVehiculoId(event.vehiculoId);

      // Ordenar por fecha más reciente primero
      checklists.sort((a, b) =>
          b.fechaRealizacion.compareTo(a.fechaRealizacion));

      emit(ChecklistHistoryLoaded(checklists));
    } catch (e) {
      debugPrint('❌ Error al cargar historial de checklists: $e');
      emit(ChecklistError('Error al cargar historial: ${e.toString()}'));
    }
  }

  /// Actualizar resultado de un item
  Future<void> _onUpdateItemResultado(
    UpdateItemResultado event,
    Emitter<ChecklistState> emit,
  ) async {
    if (state is! ChecklistTemplateLoaded) return;

    final currentState = state as ChecklistTemplateLoaded;
    final updatedItems = currentState.items.map((item) {
      if (item.id == event.itemId) {
        return item.copyWith(
          resultado: event.resultado,
          observaciones: event.observaciones,
        );
      }
      return item;
    }).toList();

    emit(currentState.copyWith(items: updatedItems));
  }

  /// Guardar checklist completado
  Future<void> _onSaveChecklist(
    SaveChecklist event,
    Emitter<ChecklistState> emit,
  ) async {
    try {
      emit(const ChecklistLoading());

      final authState = _authBloc.state;
      if (authState is! AuthAuthenticated) {
        emit(const ChecklistError('Usuario no autenticado'));
        return;
      }

      final user = authState.user;

      // Calcular estadísticas
      final itemsPresentes = event.items
          .where((item) => item.resultado == ResultadoItem.presente)
          .length;
      final itemsAusentes = event.items
          .where((item) => item.resultado == ResultadoItem.ausente)
          .length;
      final checklistCompleto = itemsAusentes == 0;

      // Crear entidad de checklist
      final checklist = ChecklistVehiculoEntity(
        id: _uuid.v4(),
        vehiculoId: event.vehiculoId,
        realizadoPor: user.id,
        realizadoPorNombre: (user.nombreCompleto ?? 'USUARIO').toUpperCase(),
        fechaRealizacion: DateTime.now(),
        tipo: event.tipo,
        kilometraje: event.kilometraje,
        items: event.items,
        itemsPresentes: itemsPresentes,
        itemsAusentes: itemsAusentes,
        checklistCompleto: checklistCompleto,
        observacionesGenerales: event.observacionesGenerales,
        firmaUrl: event.firmaUrl,
        empresaId: user.empresaId ?? '',
        createdAt: DateTime.now(),
      );

      // Guardar en base de datos
      final savedChecklist = await _repository.create(checklist);

      emit(ChecklistSaved(savedChecklist));
    } catch (e) {
      debugPrint('❌ Error al guardar checklist: $e');
      emit(ChecklistError('Error al guardar checklist: ${e.toString()}'));
    }
  }
}
