import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../turnos/entities/turno_entity.dart';
import '../../../turnos/turno_factory.dart';
import '../../checklist_vehiculo_contract.dart';
import '../../entities/checklist_vehiculo_entity.dart';
import '../../entities/item_checklist_entity.dart';
import '../../models/checklist_vehiculo_supabase_model.dart';
import '../../models/item_checklist_supabase_model.dart';

/// Implementación de ChecklistVehiculoDataSource usando Supabase
class SupabaseChecklistVehiculoDataSource
    implements ChecklistVehiculoDataSource {
  SupabaseChecklistVehiculoDataSource({SupabaseClient? supabaseClient})
      : _supabase = supabaseClient ?? Supabase.instance.client;

  final SupabaseClient _supabase;
  static const String _tableChecklists = 'checklists_vehiculo';
  static const String _tableItems = 'items_checklist_vehiculo';
  static const String _tablePlantilla = 'plantilla_checklist_vehiculo';

  @override
  Future<List<ChecklistVehiculoEntity>> getAll() async {
    try {
      debugPrint(
          '📦 SupabaseChecklistVehiculoDS: Obteniendo todos los checklists...');

      final response = await _supabase
          .from(_tableChecklists)
          .select()
          .order('fecha_realizacion', ascending: false);

      final List<ChecklistVehiculoEntity> checklists = [];
      for (final json in response as List) {
        final checklist = await _getChecklistWithItems(json);
        checklists.add(checklist);
      }

      debugPrint(
          '📦 SupabaseChecklistVehiculoDS: ✅ ${checklists.length} checklists obtenidos');
      return checklists;
    } catch (e, stack) {
      debugPrint(
          '📦 SupabaseChecklistVehiculoDS: ❌ Error al obtener checklists: $e');
      debugPrint('Stack: $stack');
      rethrow;
    }
  }

  @override
  Future<ChecklistVehiculoEntity> getById(String id) async {
    try {
      debugPrint('📦 SupabaseChecklistVehiculoDS: Obteniendo checklist ID: $id');

      final response =
          await _supabase.from(_tableChecklists).select().eq('id', id).single();

      final checklist = await _getChecklistWithItems(response);

      debugPrint('📦 SupabaseChecklistVehiculoDS: ✅ Checklist obtenido');
      return checklist;
    } catch (e, stack) {
      debugPrint(
          '📦 SupabaseChecklistVehiculoDS: ❌ Error al obtener checklist: $e');
      debugPrint('Stack: $stack');
      rethrow;
    }
  }

  @override
  Future<List<ChecklistVehiculoEntity>> getByVehiculoId(
      String vehiculoId) async {
    try {
      debugPrint(
          '📦 SupabaseChecklistVehiculoDS: Obteniendo checklists de vehículo: $vehiculoId');

      final response = await _supabase
          .from(_tableChecklists)
          .select()
          .eq('vehiculo_id', vehiculoId)
          .order('fecha_realizacion', ascending: false);

      final List<ChecklistVehiculoEntity> checklists = [];
      for (final json in response as List) {
        final checklist = await _getChecklistWithItems(json);
        checklists.add(checklist);
      }

      debugPrint(
          '📦 SupabaseChecklistVehiculoDS: ✅ ${checklists.length} checklists del vehículo');
      return checklists;
    } catch (e, stack) {
      debugPrint('📦 SupabaseChecklistVehiculoDS: ❌ Error: $e');
      debugPrint('Stack: $stack');
      rethrow;
    }
  }

  @override
  Future<ChecklistVehiculoEntity?> getUltimoChecklist(
    String vehiculoId,
    TipoChecklist tipo,
  ) async {
    try {
      debugPrint(
          '📦 SupabaseChecklistVehiculoDS: Obteniendo último checklist ${tipo.toJson()} de vehículo: $vehiculoId');

      final response = await _supabase
          .from(_tableChecklists)
          .select()
          .eq('vehiculo_id', vehiculoId)
          .eq('tipo', tipo.toJson())
          .order('fecha_realizacion', ascending: false)
          .limit(1);

      if ((response as List).isEmpty) {
        debugPrint('📦 SupabaseChecklistVehiculoDS: ✅ No hay checklists previos');
        return null;
      }

      final checklist = await _getChecklistWithItems(response.first);

      debugPrint('📦 SupabaseChecklistVehiculoDS: ✅ Último checklist obtenido');
      return checklist;
    } catch (e, stack) {
      debugPrint(
          '📦 SupabaseChecklistVehiculoDS: ❌ Error al obtener último checklist: $e');
      debugPrint('Stack: $stack');
      rethrow;
    }
  }

  @override
  Future<List<ItemChecklistEntity>> getPlantillaItems(
      TipoChecklist tipo) async {
    try {
      debugPrint(
          '📦 SupabaseChecklistVehiculoDS: Obteniendo plantilla de items para tipo: ${tipo.toJson()}');

      final response = await _supabase
          .from(_tablePlantilla)
          .select()
          .eq('tipo_checklist', tipo.toJson())
          .eq('activo', true)
          .order('orden', ascending: true);

      final List<ItemChecklistEntity> items = (response as List)
          .map((json) {
            // Convertir plantilla a ItemChecklistEntity temporal
            return ItemChecklistEntity(
              id: '', // Se generará al crear el checklist
              checklistId: '', // Se asignará al crear el checklist
              categoria: CategoriaChecklistExtension.fromJson(json['categoria']),
              itemNombre: json['item_nombre'] as String,
              cantidadRequerida: json['cantidad_requerida'] as int?,
              resultado: ResultadoItem.noAplica, // Default inicial
              observaciones: null,
              orden: json['orden'] as int,
              createdAt: DateTime.now(),
            );
          })
          .toList();

      debugPrint(
          '📦 SupabaseChecklistVehiculoDS: ✅ ${items.length} items de plantilla obtenidos');
      return items;
    } catch (e, stack) {
      debugPrint(
          '📦 SupabaseChecklistVehiculoDS: ❌ Error al obtener plantilla: $e');
      debugPrint('Stack: $stack');
      rethrow;
    }
  }

  @override
  Future<ChecklistVehiculoEntity> create(
      ChecklistVehiculoEntity checklist) async {
    try {
      debugPrint(
          '📦 SupabaseChecklistVehiculoDS: Creando checklist para vehículo: ${checklist.vehiculoId}');

      // 1. Crear el checklist principal
      final checklistModel =
          ChecklistVehiculoSupabaseModel.fromEntity(checklist);
      final checklistJson = checklistModel.toJson();
      checklistJson.remove('id');
      checklistJson.remove('created_at');
      checklistJson.remove('updated_at');

      final checklistResponse = await _supabase
          .from(_tableChecklists)
          .insert(checklistJson)
          .select()
          .single();

      final createdChecklistId = checklistResponse['id'] as String;
      debugPrint(
          '📦 SupabaseChecklistVehiculoDS: ✅ Checklist creado con ID: $createdChecklistId');

      // 2. Crear los items del checklist
      if (checklist.items.isNotEmpty) {
        debugPrint(
            '📦 SupabaseChecklistVehiculoDS: Creando ${checklist.items.length} items...');

        final itemsJson = checklist.items.map((item) {
          final itemModel = ItemChecklistSupabaseModel.fromEntity(
            item.copyWith(checklistId: createdChecklistId),
          );
          final json = itemModel.toJson();
          json.remove('id');
          json.remove('created_at');
          return json;
        }).toList();

        await _supabase.from(_tableItems).insert(itemsJson);

        debugPrint('📦 SupabaseChecklistVehiculoDS: ✅ Items creados');
      }

      // 3. Obtener el checklist completo con items
      final created = await getById(createdChecklistId);

      debugPrint(
          '📦 SupabaseChecklistVehiculoDS: ✅ Checklist completo creado');
      return created;
    } catch (e, stack) {
      debugPrint(
          '📦 SupabaseChecklistVehiculoDS: ❌ Error al crear checklist: $e');
      debugPrint('Stack: $stack');
      rethrow;
    }
  }

  @override
  Future<ChecklistVehiculoEntity> update(
      ChecklistVehiculoEntity checklist) async {
    try {
      debugPrint(
          '📦 SupabaseChecklistVehiculoDS: Actualizando checklist ID: ${checklist.id}');

      // 1. Actualizar el checklist principal
      final checklistModel =
          ChecklistVehiculoSupabaseModel.fromEntity(checklist);
      final checklistJson = checklistModel.toJson();
      checklistJson.remove('id');
      checklistJson.remove('created_at');
      checklistJson.remove('updated_at');

      await _supabase
          .from(_tableChecklists)
          .update(checklistJson)
          .eq('id', checklist.id);

      debugPrint('📦 SupabaseChecklistVehiculoDS: ✅ Checklist actualizado');

      // 2. Actualizar items (eliminar y recrear)
      await _supabase.from(_tableItems).delete().eq('checklist_id', checklist.id);

      if (checklist.items.isNotEmpty) {
        final itemsJson = checklist.items.map((item) {
          final itemModel = ItemChecklistSupabaseModel.fromEntity(item);
          final json = itemModel.toJson();
          json.remove('id');
          json.remove('created_at');
          return json;
        }).toList();

        await _supabase.from(_tableItems).insert(itemsJson);

        debugPrint('📦 SupabaseChecklistVehiculoDS: ✅ Items actualizados');
      }

      // 3. Obtener el checklist completo actualizado
      final updated = await getById(checklist.id);

      return updated;
    } catch (e, stack) {
      debugPrint(
          '📦 SupabaseChecklistVehiculoDS: ❌ Error al actualizar checklist: $e');
      debugPrint('Stack: $stack');
      rethrow;
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      debugPrint('📦 SupabaseChecklistVehiculoDS: Eliminando checklist ID: $id');

      // Los items se eliminarán automáticamente por el ON DELETE CASCADE
      await _supabase.from(_tableChecklists).delete().eq('id', id);

      debugPrint('📦 SupabaseChecklistVehiculoDS: ✅ Checklist eliminado');
    } catch (e, stack) {
      debugPrint(
          '📦 SupabaseChecklistVehiculoDS: ❌ Error al eliminar checklist: $e');
      debugPrint('Stack: $stack');
      rethrow;
    }
  }

  @override
  Stream<List<ChecklistVehiculoEntity>> watchByVehiculoId(String vehiculoId) {
    debugPrint(
        '📦 SupabaseChecklistVehiculoDS: 🔄 Stream de checklists para vehículo: $vehiculoId');

    return _supabase
        .from(_tableChecklists)
        .stream(primaryKey: ['id'])
        .eq('vehiculo_id', vehiculoId)
        .order('fecha_realizacion', ascending: false)
        .asyncMap((data) async {
          debugPrint(
              '📦 SupabaseChecklistVehiculoDS: 🔄 Stream actualizado: ${data.length} checklists');

          final List<ChecklistVehiculoEntity> checklists = [];
          for (final json in data) {
            final checklist = await _getChecklistWithItems(json);
            checklists.add(checklist);
          }

          return checklists;
        });
  }

  /// Vehículo con el que trabaja hoy el personal
  ///
  /// 1. Jornada abierta: vehículo del último fichaje de entrada (es el real,
  ///    incluso si cambió de vehículo respecto al cuadrante)
  /// 2. Si no hay jornada abierta: vehículo del turno vigente (±1 h), incluidos
  ///    turnos de noche o de 24 h que terminan mañana
  @override
  Future<String?> getVehiculoAsignadoHoy(String personalId) async {
    try {
      final String? enJornada = await _vehiculoJornadaAbierta(personalId);
      if (enJornada != null) {
        return enJornada;
      }
      return await _vehiculoTurnoVigente(personalId);
    } catch (e) {
      debugPrint('❌ Error al obtener vehículo asignado: $e');
      return null;
    }
  }

  Future<String?> _vehiculoJornadaAbierta(String personalId) async {
    final Map<String, dynamic>? ultimo = await _supabase
        .from('registros_horarios')
        .select('tipo, vehiculo_id')
        .eq('personal_id', personalId)
        .order('fecha_hora', ascending: false)
        .limit(1)
        .maybeSingle();
    final String? vehiculoId = ultimo?['vehiculo_id'] as String?;
    final bool abierta = (ultimo?['tipo'] as String?)?.toLowerCase() == 'entrada';
    return abierta && vehiculoId != null && vehiculoId.isNotEmpty ? vehiculoId : null;
  }

  /// Turno vigente (±1 h) calculado con hora real: los turnos del cuadrante
  /// guardan la hora en `horaInicio`/`horaFin`, no en las fechas
  Future<String?> _vehiculoTurnoVigente(String personalId) async {
    final TurnoEntity? turno = await TurnoDataSourceFactory.createSupabase(_supabase).getTurnoVigente(personalId);
    final String? vehiculoId = turno?.idVehiculo;
    return vehiculoId == null || vehiculoId.isEmpty ? null : vehiculoId;
  }

  /// Helper para obtener un checklist con sus items
  Future<ChecklistVehiculoEntity> _getChecklistWithItems(
      Map<String, dynamic> checklistJson) async {
    final checklistId = checklistJson['id'] as String;

    // Obtener items del checklist
    final itemsResponse = await _supabase
        .from(_tableItems)
        .select()
        .eq('checklist_id', checklistId)
        .order('orden', ascending: true);

    final items = (itemsResponse as List)
        .map((json) =>
            ItemChecklistSupabaseModel.fromJson(json as Map<String, dynamic>)
                .toEntity())
        .toList();

    // Crear el checklist con sus items
    return ChecklistVehiculoSupabaseModel.fromJson(checklistJson)
        .toEntity(items: items);
  }
}
