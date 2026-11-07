import 'package:supabase_flutter/supabase_flutter.dart';

import '../../empresas_tenant_contract.dart';
import '../../entities/empresa_tenant_entity.dart';
import '../../models/empresa_tenant_supabase_model.dart';

/// Implementación Supabase (solo lectura) de la tabla `empresas`
class SupabaseEmpresasTenantDataSource implements EmpresasTenantDataSource {
  SupabaseEmpresasTenantDataSource({
    SupabaseClient? supabase,
    String tableName = 'empresas',
  })  : _supabase = supabase ?? Supabase.instance.client,
        _tableName = tableName;

  final SupabaseClient _supabase;
  final String _tableName;

  @override
  Future<List<EmpresaTenantEntity>> getAll() async {
    try {
      final List<Map<String, dynamic>> response =
          await _supabase.from(_tableName).select().order('nombre', ascending: true);
      return response
          .map((Map<String, dynamic> json) => EmpresaTenantSupabaseModel.fromJson(json).toEntity())
          .toList();
    } catch (e) {
      throw Exception('Error al obtener empresas: $e');
    }
  }

  @override
  Future<EmpresaTenantEntity?> getById(String id) async {
    try {
      final Map<String, dynamic>? response =
          await _supabase.from(_tableName).select().eq('id', id).maybeSingle();
      if (response == null) {
        return null;
      }
      return EmpresaTenantSupabaseModel.fromJson(response).toEntity();
    } catch (e) {
      throw Exception('Error al obtener empresa por ID: $e');
    }
  }
}
