import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../certificaciones/entities/certificacion_entity.dart';
import '../../../certificaciones/certificacion_contract.dart';
import '../../../certificaciones/models/certificacion_supabase_model.dart';

/// Implementación de Supabase para certificaciones
class SupabaseCertificacionDataSource implements CertificacionDataSource {
  SupabaseCertificacionDataSource() : _supabase = Supabase.instance.client;

  final SupabaseClient _supabase;
  static const String _tableName = 'certificaciones';

  @override
  Future<List<CertificacionEntity>> getAll() async {
    debugPrint('📦 CertificacionDataSource: Obteniendo todos los registros...');

    try {
      final List<dynamic> data = await _supabase
          .from(_tableName)
          .select()
          .order('codigo', ascending: true);

      debugPrint('📦 CertificacionDataSource: ✅ ${data.length} registros obtenidos');

      return data
          .map((dynamic json) =>
              CertificacionSupabaseModel.fromJson(json as Map<String, dynamic>).toEntity())
          .toList();
    } catch (e) {
      debugPrint('📦 CertificacionDataSource: ❌ Error al obtener registros: $e');
      rethrow;
    }
  }

  @override
  Future<CertificacionEntity> getById(String id) async {
    debugPrint('📦 CertificacionDataSource: Obteniendo por ID: $id');

    try {
      final Map<String, dynamic> data =
          await _supabase.from(_tableName).select().eq('id', id).single();

      debugPrint('📦 CertificacionDataSource: ✅ Registro obtenido');

      return CertificacionSupabaseModel.fromJson(data).toEntity();
    } catch (e) {
      debugPrint('📦 CertificacionDataSource: ❌ Error al obtener por ID: $e');
      rethrow;
    }
  }

  @override
  Future<List<CertificacionEntity>> getActivas() async {
    debugPrint('📦 CertificacionDataSource: Obteniendo certificaciones activas...');

    try {
      final List<dynamic> data = await _supabase
          .from(_tableName)
          .select()
          .eq('activa', true)
          .order('codigo', ascending: true);

      debugPrint('📦 CertificacionDataSource: ✅ ${data.length} registros activos');

      return data
          .map((dynamic json) =>
              CertificacionSupabaseModel.fromJson(json as Map<String, dynamic>).toEntity())
          .toList();
    } catch (e) {
      debugPrint('📦 CertificacionDataSource: ❌ Error al obtener activas: $e');
      rethrow;
    }
  }

  @override
  Future<CertificacionEntity?> getByCodigo(String codigo) async {
    debugPrint('📦 CertificacionDataSource: Obteniendo por código: $codigo');

    try {
      final Map<String, dynamic>? data =
          await _supabase.from(_tableName).select().eq('codigo', codigo).maybeSingle();

      if (data == null) {
        debugPrint('📦 CertificacionDataSource: ⚠️ No se encontró certificación con código: $codigo');
        return null;
      }

      debugPrint('📦 CertificacionDataSource: ✅ Registro obtenido');

      return CertificacionSupabaseModel.fromJson(data).toEntity();
    } catch (e) {
      debugPrint('📦 CertificacionDataSource: ❌ Error al obtener por código: $e');
      rethrow;
    }
  }

  @override
  Future<CertificacionEntity> create(CertificacionEntity entity) async {
    debugPrint('📦 CertificacionDataSource: Creando registro...');

    try {
      final CertificacionSupabaseModel model =
          CertificacionSupabaseModel.fromEntity(entity);
      final Map<String, dynamic> data =
          await _supabase.from(_tableName).insert(model.toJson()).select().single();

      debugPrint('📦 CertificacionDataSource: ✅ Registro creado');

      return CertificacionSupabaseModel.fromJson(data).toEntity();
    } catch (e) {
      debugPrint('📦 CertificacionDataSource: ❌ Error al crear: $e');
      rethrow;
    }
  }

  @override
  Future<CertificacionEntity> update(CertificacionEntity entity) async {
    debugPrint('📦 CertificacionDataSource: Actualizando registro: ${entity.id}');

    try {
      final CertificacionSupabaseModel model =
          CertificacionSupabaseModel.fromEntity(entity);
      final Map<String, dynamic> data = await _supabase
          .from(_tableName)
          .update(model.toJson())
          .eq('id', entity.id)
          .select()
          .single();

      debugPrint('📦 CertificacionDataSource: ✅ Registro actualizado');

      return CertificacionSupabaseModel.fromJson(data).toEntity();
    } catch (e) {
      debugPrint('📦 CertificacionDataSource: ❌ Error al actualizar: $e');
      rethrow;
    }
  }

  @override
  Future<void> delete(String id) async {
    debugPrint('📦 CertificacionDataSource: Eliminando registro: $id');

    try {
      await _supabase.from(_tableName).delete().eq('id', id);

      debugPrint('📦 CertificacionDataSource: ✅ Registro eliminado');
    } catch (e) {
      debugPrint('📦 CertificacionDataSource: ❌ Error al eliminar: $e');
      rethrow;
    }
  }

  @override
  Stream<List<CertificacionEntity>> watchAll() {
    debugPrint('📦 CertificacionDataSource: Iniciando stream de todos los registros');

    return _supabase
        .from(_tableName)
        .stream(primaryKey: <String>['id'])
        .order('codigo', ascending: true)
        .map(
          (List<Map<String, dynamic>> data) => data
              .map(
                  (Map<String, dynamic> json) => CertificacionSupabaseModel.fromJson(json).toEntity())
              .toList(),
        );
  }

  @override
  Stream<List<CertificacionEntity>> watchActivas() {
    debugPrint('📦 CertificacionDataSource: Stream de certificaciones activas');

    return _supabase
        .from(_tableName)
        .stream(primaryKey: <String>['id'])
        .eq('activa', true)
        .order('codigo', ascending: true)
        .map(
          (List<Map<String, dynamic>> data) => data
              .map(
                  (Map<String, dynamic> json) => CertificacionSupabaseModel.fromJson(json).toEntity())
              .toList(),
        );
  }
}
