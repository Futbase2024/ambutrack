import 'package:supabase_flutter/supabase_flutter.dart';

import '../../entities/orden_reparacion_entity.dart';
import '../../entities/orden_reparacion_enums.dart';
import '../../entities/repuesto_orden_entity.dart';
import '../../models/orden_reparacion_supabase_model.dart';
import '../../models/repuesto_orden_supabase_model.dart';
import '../../ordenes_reparacion_contract.dart';

/// Implementación Supabase del datasource de Órdenes de Reparación
class SupabaseOrdenesReparacionDataSource implements OrdenesReparacionDataSource {
  SupabaseOrdenesReparacionDataSource({
    SupabaseClient? supabase,
    String ordenesTable = 'tordenes_reparacion',
    String repuestosTable = 'trepuestos_orden',
  })  : _supabase = supabase ?? Supabase.instance.client,
        _ordenesTable = ordenesTable,
        _repuestosTable = repuestosTable;

  final SupabaseClient _supabase;
  final String _ordenesTable;
  final String _repuestosTable;

  static const String _ordenSelect = OrdenReparacionSupabaseModel.selectWithJoins;
  static const String _repuestoSelect = RepuestoOrdenSupabaseModel.selectWithJoins;

  List<OrdenReparacionEntity> _toOrdenes(List<Map<String, dynamic>> rows) {
    return rows
        .map((Map<String, dynamic> json) => OrdenReparacionSupabaseModel.fromJson(json).toEntity())
        .toList();
  }

  OrdenReparacionEntity _toOrden(Map<String, dynamic> json) =>
      OrdenReparacionSupabaseModel.fromJson(json).toEntity();

  RepuestoOrdenEntity _toRepuesto(Map<String, dynamic> json) =>
      RepuestoOrdenSupabaseModel.fromJson(json).toEntity();

  // ==================== ÓRDENES ====================

  @override
  Future<List<OrdenReparacionEntity>> getAll() async {
    try {
      final List<Map<String, dynamic>> response = await _supabase
          .from(_ordenesTable)
          .select(_ordenSelect)
          .order('fecha_entrada', ascending: false);
      return _toOrdenes(response);
    } catch (e) {
      throw Exception('Error al obtener órdenes de reparación: $e');
    }
  }

  @override
  Future<OrdenReparacionEntity?> getById(String id) async {
    try {
      final Map<String, dynamic>? response =
          await _supabase.from(_ordenesTable).select(_ordenSelect).eq('id', id).maybeSingle();
      return response == null ? null : _toOrden(response);
    } catch (e) {
      throw Exception('Error al obtener orden de reparación por ID: $e');
    }
  }

  @override
  Future<List<OrdenReparacionEntity>> getByVehiculo(String vehiculoId) async {
    try {
      final List<Map<String, dynamic>> response = await _supabase
          .from(_ordenesTable)
          .select(_ordenSelect)
          .eq('vehiculo_id', vehiculoId)
          .order('fecha_entrada', ascending: false);
      return _toOrdenes(response);
    } catch (e) {
      throw Exception('Error al obtener órdenes del vehículo: $e');
    }
  }

  @override
  Future<List<OrdenReparacionEntity>> getByEstado(EstadoOrdenReparacion estado) async {
    try {
      final List<Map<String, dynamic>> response = await _supabase
          .from(_ordenesTable)
          .select(_ordenSelect)
          .eq('estado', estado.value)
          .order('fecha_entrada', ascending: false);
      return _toOrdenes(response);
    } catch (e) {
      throw Exception('Error al obtener órdenes por estado: $e');
    }
  }

  @override
  Future<OrdenReparacionEntity> create(OrdenReparacionEntity entity) async {
    try {
      final Map<String, dynamic> response = await _supabase
          .from(_ordenesTable)
          .insert(OrdenReparacionSupabaseModel.fromEntity(entity).toJson())
          .select(_ordenSelect)
          .single();
      return _toOrden(response);
    } catch (e) {
      throw Exception('Error al crear orden de reparación: $e');
    }
  }

  @override
  Future<OrdenReparacionEntity> update(OrdenReparacionEntity entity) async {
    try {
      final Map<String, dynamic> json = OrdenReparacionSupabaseModel.fromEntity(entity).toJson()
        ..remove('id');
      final Map<String, dynamic> response = await _supabase
          .from(_ordenesTable)
          .update(json)
          .eq('id', entity.id)
          .select(_ordenSelect)
          .single();
      return _toOrden(response);
    } catch (e) {
      throw Exception('Error al actualizar orden de reparación: $e');
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      await _supabase.from(_ordenesTable).delete().eq('id', id);
    } catch (e) {
      throw Exception('Error al eliminar orden de reparación: $e');
    }
  }

  @override
  Future<OrdenReparacionEntity> cambiarEstado(String id, EstadoOrdenReparacion estado) async {
    try {
      final String? fechaColumn = estado.fechaColumn;
      final Map<String, dynamic> changes = <String, dynamic>{
        'estado': estado.value,
        if (fechaColumn != null) fechaColumn: DateTime.now().toUtc().toIso8601String(),
      };
      final Map<String, dynamic> response = await _supabase
          .from(_ordenesTable)
          .update(changes)
          .eq('id', id)
          .select(_ordenSelect)
          .single();
      return _toOrden(response);
    } catch (e) {
      throw Exception('Error al cambiar estado de la orden: $e');
    }
  }

  // ==================== REPUESTOS ====================

  @override
  Future<List<RepuestoOrdenEntity>> getRepuestos(String ordenId) async {
    try {
      final List<Map<String, dynamic>> response = await _supabase
          .from(_repuestosTable)
          .select(_repuestoSelect)
          .eq('orden_id', ordenId)
          .order('created_at', ascending: true);
      return response.map(_toRepuesto).toList();
    } catch (e) {
      throw Exception('Error al obtener repuestos de la orden: $e');
    }
  }

  @override
  Future<RepuestoOrdenEntity> createRepuesto(RepuestoOrdenEntity entity) async {
    try {
      final Map<String, dynamic> response = await _supabase
          .from(_repuestosTable)
          .insert(RepuestoOrdenSupabaseModel.fromEntity(entity).toJson())
          .select(_repuestoSelect)
          .single();
      return _toRepuesto(response);
    } catch (e) {
      throw Exception('Error al crear repuesto: $e');
    }
  }

  @override
  Future<RepuestoOrdenEntity> updateRepuesto(RepuestoOrdenEntity entity) async {
    try {
      final Map<String, dynamic> json = RepuestoOrdenSupabaseModel.fromEntity(entity).toJson()
        ..remove('id');
      final Map<String, dynamic> response = await _supabase
          .from(_repuestosTable)
          .update(json)
          .eq('id', entity.id)
          .select(_repuestoSelect)
          .single();
      return _toRepuesto(response);
    } catch (e) {
      throw Exception('Error al actualizar repuesto: $e');
    }
  }

  @override
  Future<void> deleteRepuesto(String id) async {
    try {
      await _supabase.from(_repuestosTable).delete().eq('id', id);
    } catch (e) {
      throw Exception('Error al eliminar repuesto: $e');
    }
  }
}
