import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../entities/usuario_entity.dart';
import '../../models/usuario_supabase_model.dart';
import '../../usuarios_contract.dart';

/// Implementación de [UsuarioDataSource] usando Supabase
///
/// Características:
/// - Cache estático con expiración de 5 minutos
/// - JOIN con tabla empresas para obtener nombre de empresa
/// - Logging con debugPrint y emojis
/// - Invalidación de caché en operaciones CUD
class SupabaseUsuarioDataSource implements UsuarioDataSource {
  SupabaseUsuarioDataSource({
    SupabaseClient? supabase,
    this.tableName = 'usuarios',
  }) : _supabase = supabase ?? Supabase.instance.client;

  final SupabaseClient _supabase;
  final String tableName;

  // Cache estático con expiración de 5 minutos
  static List<UserEntity>? _cache;
  static DateTime? _cacheTimestamp;
  static const Duration _cacheDuration = Duration(minutes: 5);

  /// Verifica si el caché es válido
  bool get _isCacheValid {
    if (_cache == null || _cacheTimestamp == null) return false;
    return DateTime.now().difference(_cacheTimestamp!) < _cacheDuration;
  }

  /// Invalida el caché
  void _invalidateCache() {
    debugPrint('🗑️ SupabaseUsuarioDataSource: Invalidando caché');
    _cache = null;
    _cacheTimestamp = null;
  }

  /// Query base con JOIN a empresas
  String get _baseQuery => '*, empresas(nombre)';

  @override
  Future<UserEntity> create(UserEntity entity) async {
    debugPrint('🚀 SupabaseUsuarioDataSource: Creando usuario ${entity.email}');

    try {
      final Map<String, dynamic> response = await _supabase
          .from(tableName)
          .insert(UsuarioSupabaseModel.fromEntity(entity).toJson())
          .select(_baseQuery)
          .single();

      _invalidateCache();

      final UserEntity usuario = UsuarioSupabaseModel.fromJson(response).toEntity();
      debugPrint('✅ SupabaseUsuarioDataSource: Usuario creado con ID: ${usuario.uid}');

      return usuario;
    } catch (e) {
      debugPrint('❌ SupabaseUsuarioDataSource: Error al crear usuario: $e');
      rethrow;
    }
  }

  @override
  Future<UserEntity?> getById(String id) async {
    debugPrint('🔍 SupabaseUsuarioDataSource: Buscando usuario por ID: $id');

    try {
      final Map<String, dynamic>? response = await _supabase
          .from(tableName)
          .select(_baseQuery)
          .eq('id', id)
          .maybeSingle();

      if (response == null) {
        debugPrint('⚠️ SupabaseUsuarioDataSource: Usuario no encontrado');
        return null;
      }

      final UserEntity usuario = UsuarioSupabaseModel.fromJson(response).toEntity();
      debugPrint('✅ SupabaseUsuarioDataSource: Usuario encontrado: ${usuario.email}');

      return usuario;
    } catch (e) {
      debugPrint('❌ SupabaseUsuarioDataSource: Error al buscar usuario: $e');
      rethrow;
    }
  }

  @override
  Future<List<UserEntity>> getAll({int? limit, int? offset}) async {
    // Usar cache si es válido y no hay filtros
    if (_isCacheValid && limit == null && offset == null) {
      debugPrint('💾 SupabaseUsuarioDataSource: Usando caché (${_cache!.length} usuarios)');
      return _cache!;
    }

    debugPrint('📥 SupabaseUsuarioDataSource: Obteniendo todos los usuarios...');

    try {
      PostgrestTransformBuilder<List<Map<String, dynamic>>> query = _supabase
          .from(tableName)
          .select(_baseQuery)
          .order('created_at', ascending: false);

      if (limit != null) {
        query = query.limit(limit);
      }

      if (offset != null) {
        query = query.range(offset, offset + (limit ?? 25) - 1);
      }

      final List<dynamic> response = await query;

      final List<UserEntity> usuarios = response
          .map((dynamic json) => UsuarioSupabaseModel.fromJson(json as Map<String, dynamic>).toEntity())
          .toList();

      // Actualizar cache solo si no hay filtros
      if (limit == null && offset == null) {
        _cache = usuarios;
        _cacheTimestamp = DateTime.now();
      }

      debugPrint('✅ SupabaseUsuarioDataSource: ${usuarios.length} usuarios obtenidos');

      return usuarios;
    } catch (e) {
      debugPrint('❌ SupabaseUsuarioDataSource: Error al obtener usuarios: $e');
      rethrow;
    }
  }

  @override
  Future<UserEntity> update(UserEntity entity) async {
    debugPrint('📝 SupabaseUsuarioDataSource: Actualizando usuario ${entity.uid}');

    try {
      final Map<String, dynamic> response = await _supabase
          .from(tableName)
          .update(UsuarioSupabaseModel.fromEntity(entity).toJson())
          .eq('id', entity.uid)
          .select(_baseQuery)
          .single();

      _invalidateCache();

      final UserEntity usuario = UsuarioSupabaseModel.fromJson(response).toEntity();
      debugPrint('✅ SupabaseUsuarioDataSource: Usuario actualizado');

      return usuario;
    } catch (e) {
      debugPrint('❌ SupabaseUsuarioDataSource: Error al actualizar usuario: $e');
      rethrow;
    }
  }

  @override
  Future<void> delete(String id) async {
    debugPrint('🗑️ SupabaseUsuarioDataSource: Eliminando usuario $id');

    try {
      await _supabase.from(tableName).delete().eq('id', id);

      _invalidateCache();

      debugPrint('✅ SupabaseUsuarioDataSource: Usuario eliminado');
    } catch (e) {
      debugPrint('❌ SupabaseUsuarioDataSource: Error al eliminar usuario: $e');
      rethrow;
    }
  }

  @override
  Future<bool> exists(String id) async {
    debugPrint('🔍 SupabaseUsuarioDataSource: Verificando existencia de usuario $id');

    try {
      final Map<String, dynamic>? response = await _supabase
          .from(tableName)
          .select('id')
          .eq('id', id)
          .maybeSingle();

      final bool exists = response != null;
      debugPrint('✅ SupabaseUsuarioDataSource: Usuario ${exists ? 'existe' : 'no existe'}');

      return exists;
    } catch (e) {
      debugPrint('❌ SupabaseUsuarioDataSource: Error al verificar existencia: $e');
      rethrow;
    }
  }

  @override
  Stream<List<UserEntity>> watchAll() {
    debugPrint('👁️ SupabaseUsuarioDataSource: Iniciando stream de usuarios');

    return _supabase
        .from(tableName)
        .stream(primaryKey: <String>['id'])
        .order('created_at', ascending: false)
        .asyncMap((List<Map<String, dynamic>> data) async {
          // Para cada usuario, obtener el nombre de la empresa
          final List<UserEntity> usuarios = <UserEntity>[];

          for (final Map<String, dynamic> item in data) {
            // Obtener nombre de empresa si tiene empresa_id
            final String? empresaId = item['empresa_id'] as String?;
            if (empresaId != null) {
              try {
                final Map<String, dynamic> empresaData = await _supabase
                    .from('empresas')
                    .select('nombre')
                    .eq('id', empresaId)
                    .single();
                item['empresas'] = empresaData;
              } catch (_) {
                // Si falla, continuar sin nombre de empresa
              }
            }

            usuarios.add(UsuarioSupabaseModel.fromJson(item).toEntity());
          }

          return usuarios;
        });
  }

  @override
  Stream<UserEntity?> watchById(String id) {
    debugPrint('👁️ SupabaseUsuarioDataSource: Iniciando stream de usuario $id');

    return _supabase
        .from(tableName)
        .stream(primaryKey: <String>['id'])
        .eq('id', id)
        .asyncMap((List<Map<String, dynamic>> data) async {
          if (data.isEmpty) return null;

          final Map<String, dynamic> item = data.first;

          // Obtener nombre de empresa si tiene empresa_id
          final String? empresaId = item['empresa_id'] as String?;
          if (empresaId != null) {
            try {
              final Map<String, dynamic> empresaData = await _supabase
                  .from('empresas')
                  .select('nombre')
                  .eq('id', empresaId)
                  .single();
              item['empresas'] = empresaData;
            } catch (_) {
              // Si falla, continuar sin nombre de empresa
            }
          }

          return UsuarioSupabaseModel.fromJson(item).toEntity();
        });
  }

  @override
  Future<List<UserEntity>> createBatch(List<UserEntity> entities) async {
    debugPrint('🚀 SupabaseUsuarioDataSource: Creando ${entities.length} usuarios en batch');

    try {
      final List<dynamic> response = await _supabase
          .from(tableName)
          .insert(entities.map((UserEntity e) => UsuarioSupabaseModel.fromEntity(e).toJson()).toList())
          .select(_baseQuery);

      _invalidateCache();

      final List<UserEntity> usuarios = response
          .map((dynamic json) => UsuarioSupabaseModel.fromJson(json as Map<String, dynamic>).toEntity())
          .toList();

      debugPrint('✅ SupabaseUsuarioDataSource: ${usuarios.length} usuarios creados');

      return usuarios;
    } catch (e) {
      debugPrint('❌ SupabaseUsuarioDataSource: Error al crear usuarios en batch: $e');
      rethrow;
    }
  }

  @override
  Future<List<UserEntity>> updateBatch(List<UserEntity> entities) async {
    debugPrint('📝 SupabaseUsuarioDataSource: Actualizando ${entities.length} usuarios en batch');

    try {
      final List<UserEntity> updatedUsuarios = <UserEntity>[];

      for (final UserEntity entity in entities) {
        final UserEntity updated = await update(entity);
        updatedUsuarios.add(updated);
      }

      debugPrint('✅ SupabaseUsuarioDataSource: ${updatedUsuarios.length} usuarios actualizados');

      return updatedUsuarios;
    } catch (e) {
      debugPrint('❌ SupabaseUsuarioDataSource: Error al actualizar usuarios en batch: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteBatch(List<String> ids) async {
    debugPrint('🗑️ SupabaseUsuarioDataSource: Eliminando ${ids.length} usuarios en batch');

    try {
      // Usar filter con operador 'in' para postgrest 2.5.0
      final String idsString = ids.map((String id) => '"$id"').join(',');
      await _supabase.from(tableName).delete().filter('id', 'in', '($idsString)');

      _invalidateCache();

      debugPrint('✅ SupabaseUsuarioDataSource: ${ids.length} usuarios eliminados');
    } catch (e) {
      debugPrint('❌ SupabaseUsuarioDataSource: Error al eliminar usuarios en batch: $e');
      rethrow;
    }
  }

  @override
  Future<int> count() async {
    debugPrint('🔢 SupabaseUsuarioDataSource: Contando usuarios');

    try {
      // Sintaxis correcta para postgrest 2.5.0
      final PostgrestResponse<List<Map<String, dynamic>>> response = await _supabase
          .from(tableName)
          .select('id')
          .count(CountOption.exact);

      final int total = response.count ?? 0;
      debugPrint('✅ SupabaseUsuarioDataSource: Total de usuarios: $total');

      return total;
    } catch (e) {
      debugPrint('❌ SupabaseUsuarioDataSource: Error al contar usuarios: $e');
      rethrow;
    }
  }

  @override
  Future<void> clear() async {
    debugPrint('⚠️ SupabaseUsuarioDataSource: Limpiando todos los usuarios (operación peligrosa)');

    try {
      await _supabase.from(tableName).delete().neq('id', '00000000-0000-0000-0000-000000000000');

      _invalidateCache();

      debugPrint('✅ SupabaseUsuarioDataSource: Todos los usuarios eliminados');
    } catch (e) {
      debugPrint('❌ SupabaseUsuarioDataSource: Error al limpiar usuarios: $e');
      rethrow;
    }
  }

  // Métodos específicos del dominio

  @override
  Future<List<UserEntity>> getByRol(String rol) async {
    debugPrint('🔍 SupabaseUsuarioDataSource: Buscando usuarios por rol: $rol');

    try {
      final List<dynamic> response = await _supabase
          .from(tableName)
          .select(_baseQuery)
          .eq('rol', rol)
          .order('created_at', ascending: false);

      final List<UserEntity> usuarios = response
          .map((dynamic json) => UsuarioSupabaseModel.fromJson(json as Map<String, dynamic>).toEntity())
          .toList();

      debugPrint('✅ SupabaseUsuarioDataSource: ${usuarios.length} usuarios con rol $rol encontrados');

      return usuarios;
    } catch (e) {
      debugPrint('❌ SupabaseUsuarioDataSource: Error al buscar por rol: $e');
      rethrow;
    }
  }

  @override
  Future<List<UserEntity>> getByEmpresa(String empresaId) async {
    debugPrint('🔍 SupabaseUsuarioDataSource: Buscando usuarios por empresa: $empresaId');

    try {
      final List<dynamic> response = await _supabase
          .from(tableName)
          .select(_baseQuery)
          .eq('empresa_id', empresaId)
          .order('created_at', ascending: false);

      final List<UserEntity> usuarios = response
          .map((dynamic json) => UsuarioSupabaseModel.fromJson(json as Map<String, dynamic>).toEntity())
          .toList();

      debugPrint('✅ SupabaseUsuarioDataSource: ${usuarios.length} usuarios de la empresa encontrados');

      return usuarios;
    } catch (e) {
      debugPrint('❌ SupabaseUsuarioDataSource: Error al buscar por empresa: $e');
      rethrow;
    }
  }

  @override
  Future<List<UserEntity>> getActivos() async {
    debugPrint('🔍 SupabaseUsuarioDataSource: Buscando usuarios activos');

    try {
      final List<dynamic> response = await _supabase
          .from(tableName)
          .select(_baseQuery)
          .eq('activo', true)
          .order('created_at', ascending: false);

      final List<UserEntity> usuarios = response
          .map((dynamic json) => UsuarioSupabaseModel.fromJson(json as Map<String, dynamic>).toEntity())
          .toList();

      debugPrint('✅ SupabaseUsuarioDataSource: ${usuarios.length} usuarios activos encontrados');

      return usuarios;
    } catch (e) {
      debugPrint('❌ SupabaseUsuarioDataSource: Error al buscar activos: $e');
      rethrow;
    }
  }

  @override
  Future<List<UserEntity>> searchByEmailOrDni(String query) async {
    debugPrint('🔍 SupabaseUsuarioDataSource: Buscando usuarios por query: $query');

    try {
      final List<dynamic> response = await _supabase
          .from(tableName)
          .select(_baseQuery)
          .or('email.ilike.%$query%,dni.ilike.%$query%')
          .order('created_at', ascending: false);

      final List<UserEntity> usuarios = response
          .map((dynamic json) => UsuarioSupabaseModel.fromJson(json as Map<String, dynamic>).toEntity())
          .toList();

      debugPrint('✅ SupabaseUsuarioDataSource: ${usuarios.length} usuarios encontrados');

      return usuarios;
    } catch (e) {
      debugPrint('❌ SupabaseUsuarioDataSource: Error en búsqueda: $e');
      rethrow;
    }
  }

  @override
  Future<UserEntity?> getByEmail(String email) async {
    debugPrint('🔍 SupabaseUsuarioDataSource: Buscando usuario por email: $email');

    try {
      final Map<String, dynamic>? response = await _supabase
          .from(tableName)
          .select(_baseQuery)
          .eq('email', email)
          .maybeSingle();

      if (response == null) {
        debugPrint('⚠️ SupabaseUsuarioDataSource: Usuario no encontrado');
        return null;
      }

      final UserEntity usuario = UsuarioSupabaseModel.fromJson(response).toEntity();
      debugPrint('✅ SupabaseUsuarioDataSource: Usuario encontrado');

      return usuario;
    } catch (e) {
      debugPrint('❌ SupabaseUsuarioDataSource: Error al buscar por email: $e');
      rethrow;
    }
  }

  @override
  Future<UserEntity?> getByDni(String dni) async {
    debugPrint('🔍 SupabaseUsuarioDataSource: Buscando usuario por DNI: $dni');

    try {
      final Map<String, dynamic>? response = await _supabase
          .from(tableName)
          .select(_baseQuery)
          .eq('dni', dni)
          .maybeSingle();

      if (response == null) {
        debugPrint('⚠️ SupabaseUsuarioDataSource: Usuario no encontrado');
        return null;
      }

      final UserEntity usuario = UsuarioSupabaseModel.fromJson(response).toEntity();
      debugPrint('✅ SupabaseUsuarioDataSource: Usuario encontrado');

      return usuario;
    } catch (e) {
      debugPrint('❌ SupabaseUsuarioDataSource: Error al buscar por DNI: $e');
      rethrow;
    }
  }

  @override
  Future<void> cambiarEstado(String id, bool activo) async {
    debugPrint('🔄 SupabaseUsuarioDataSource: Cambiando estado de usuario $id a ${activo ? 'activo' : 'inactivo'}');

    try {
      await _supabase
          .from(tableName)
          .update(<String, dynamic>{'activo': activo})
          .eq('id', id);

      _invalidateCache();

      debugPrint('✅ SupabaseUsuarioDataSource: Estado cambiado correctamente');
    } catch (e) {
      debugPrint('❌ SupabaseUsuarioDataSource: Error al cambiar estado: $e');
      rethrow;
    }
  }
}
